module IsoDoc
  class Convert
    def inline_header_title(out, node, c1)
      out.span **{ class: "zzMoveToFollowing" } do |s|
        s.b do |b|
          b << "#{get_anchors[node['id']][:label]}. #{c1.text} "
        end
      end
    end

    def clause_parse_title(node, div, c1, out)
      if node["inline-header"] == "true"
        inline_header_title(out, node, c1)
      else
        div.send "h#{get_anchors[node['id']][:level]}" do |h|
          h << "#{get_anchors[node['id']][:label]}. #{c1.text}"
        end
      end
    end

    def clause_parse(node, out)
      out.div **attr_code(id: node["id"]) do |div|
        node.children.each do |c1|
          if c1.name == "title"
            clause_parse_title(node, div, c1, out)
          else
            parse(c1, div)
          end
        end
      end
    end

    def clause_name(num, title, div, inline_header, header_class)
      if inline_header
        clause_name_inline(num, title, div)
      else
        clause_name_header(num, title, div, header_class)
      end
    end

    def clause_name_inline(num, title, div)
      div.span **{ class: "zzMoveToFollowing" } do |s|
        s.b do |b|
          b << num
          b << title + " "
        end
      end
    end

    def clause_name_header(num, title, div, header_class)
      header_class = {} if header_class.nil?
      div.h1 **attr_code(header_class) do |h1|
        if num
          h1 << num
          insert_tab(h1, 1)
        end
        h1 << title
      end
      div.parent.at(".//h1")
    end

    def clause(isoxml, out)
      isoxml.xpath(ns("//clause[parent::sections]")).each do |c|
        next if c.at(ns("./title")).text == "Scope"
        out.div **attr_code(id: c["id"]) do |s|
          c.elements.each do |c1|
            if c1.name == "title"
              clause_name("#{get_anchors[c['id']][:label]}.",
                          c1.text, s, c["inline-header"] == "true", nil)
            else
              parse(c1, s)
            end
          end
        end
      end
    end

    def annex_name(annex, name, div)
      div.h1 **{ class: "Annex" } do |t|
        t << "#{get_anchors[annex['id']][:label]}<br/><br/>"
        t << "<b>#{name.text}</b>"
      end
    end

    def annex(isoxml, out)
      isoxml.xpath(ns("//annex")).each do |c|
        page_break(out)
        out.div **attr_code(id: c["id"], class: "Section3") do |s|
          c.elements.each do |c1|
            if c1.name == "title" then annex_name(c, c1, s)
            else
              parse(c1, s)
            end
          end
        end
      end
    end

    def scope(isoxml, out)
      f = isoxml.at(ns("//clause[title = 'Scope']")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("1.", @scope_lbl, div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def term_defs_boilerplate(div, source, term)
      if source.empty? && term.nil?
        div << @no_terms_boilerplate
      else
        div << term_defs_boilerplate_cont(source, term)
      end
      div << @term_def_boilerplate
    end

    def term_defs_boilerplate_cont(src, term)
      sources = sentence_join(src.map { |s| s["citeas"] })
      if src.empty?
        @internal_terms_boilerplate
      elsif term.nil?
        external_terms_boilerplate(sources)
      else
        internal_external_terms_boilerplate(sources)
      end
    end

    def terms_defs_title(f)
      symbols = f.at(".//symbols-abbrevs")
      return @termsdefsymbols_lbl if symbols
      @termsdef_lbl
    end

    def terms_defs(isoxml, out)
      f = isoxml.at(ns("//sections/terms")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("3.", terms_defs_title(f), div, false, nil)
        term_defs_boilerplate(div, f.xpath(ns("./source")), f.at(ns(".//term")))
        f.elements.each do |e|
          parse(e, div) unless %w{title source}.include? e.name
        end
      end
    end

    # subclause
    def terms_parse(isoxml, out)
      clause_parse(isoxml, out)
    end

    def symbols_abbrevs(isoxml, out)
      f = isoxml.at(ns("//sections/symbols-abbrevs")) || return
      out.div **attr_code(id: f["id"], class: "Symbols") do |div|
        clause_name("4.", @symbols_lbl, div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    # subclause
    def symbols_parse(isoxml, out)
      isoxml.children.first.
        add_previous_sibling("<title>Symbols and Abbreviated Terms</title>")
      clause_parse(isoxml, out)
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      num = f.at(ns(".//subsection")) ? "0." : nil
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        # div.h1 "Introduction", **attr_code(title_attr)
        clause_name(num, @introduction_lbl, div, false, title_attr)
        f.elements.each do |e|
          if e.name == "patent-notice"
            e.elements.each { |e1| parse(e1, div) }
          else
            parse(e, div) unless e.name == "title"
          end
        end
      end
    end

    def foreword(isoxml, out)
      f = isoxml.at(ns("//foreword")) || return
      page_break(out)
      out.div **attr_code(id: f["id"]) do |s|
        s.h1 **{ class: "ForewordTitle" } { |h1| h1 << @foreword_lbl }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end
  end
end
