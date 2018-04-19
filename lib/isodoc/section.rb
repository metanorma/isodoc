module IsoDoc
  class Convert
    def inline_header_title(out, node, c1)
      out.span **{ class: "zzMoveToFollowing" } do |s|
        s.b do |b|
          b << "#{get_anchors[node['id']][:label]}. #{c1.content} "
        end
      end
    end

    def clause_parse_title(node, div, c1, out)
      if node["inline-header"] == "true"
        inline_header_title(out, node, c1)
      else
        div.send "h#{get_anchors[node['id']][:level]}" do |h|
          h << "#{get_anchors[node['id']][:label]}. "
          c1.children.each { |c2| parse(c2, h) }
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

    def clause_name(num, title, div, header_class)
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

    MIDDLE_CLAUSE = 
      "//clause[parent::sections][not(xmlns:title = 'Scope')]"\
      "[not(descendant::terms)]".freeze

    def clause(isoxml, out)
      isoxml.xpath(ns(MIDDLE_CLAUSE)).each do |c|
        out.div **attr_code(id: c["id"]) do |s|
          c.elements.each do |c1|
            if c1.name == "title"
              clause_name("#{get_anchors[c['id']][:label]}.",
                          c1.content, s, nil)
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

    def scope(isoxml, out, num)
      f = isoxml.at(ns("//clause[title = 'Scope']")) or return num
      out.div **attr_code(id: f["id"]) do |div|
        num = num + 1
        clause_name("#{num}.", @scope_lbl, div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    def external_terms_boilerplate(sources)
      @external_terms_boilerplate.gsub(/%/, sources)
    end

    def internal_external_terms_boilerplate(sources)
      @internal_external_terms_boilerplate.gsub(/%/, sources)
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
      sources = sentence_join(src.map { |s| s["target"] })
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

    TERM_CLAUSE = "//sections/terms | "\
      "//sections/clause[descendant::terms]".freeze

    def terms_defs(isoxml, out, num)
      f = isoxml.at(ns(TERM_CLAUSE)) or return num
      out.div **attr_code(id: f["id"]) do |div|
        num = num + 1
        clause_name("#{num}.", terms_defs_title(f), div, nil)
        term_defs_boilerplate(div, isoxml.xpath(ns(".//termdocsource")),
                              f.at(ns(".//term")))
        f.elements.each do |e|
          parse(e, div) unless %w{title source}.include? e.name
        end
      end
      num
    end

    # subclause
    def terms_parse(isoxml, out)
      clause_parse(isoxml, out)
    end

    def symbols_abbrevs(isoxml, out, num)
      f = isoxml.at(ns("//sections/symbols-abbrevs")) or return num
      out.div **attr_code(id: f["id"], class: "Symbols") do |div|
        num = num + 1
        clause_name("#{num}.", @symbols_lbl, div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    # subclause
    def symbols_parse(isoxml, out)
      isoxml.children.first.previous =
        "<title>Symbols and Abbreviated Terms</title>"
      clause_parse(isoxml, out)
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      num = f.at(ns(".//clause")) ? "0." : nil
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        # div.h1 "Introduction", **attr_code(title_attr)
        clause_name(num, @introduction_lbl, div, title_attr)
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
