module IsoDoc
  class Convert
    def clause_parse(node, out)
      out.div **attr_code(id: node["id"]) do |s|
        node.children.each do |c1|
          if c1.name == "title"
            if node["inline-header"]
              out.span **{ class: "zzMoveToFollowing" } do |s|
                s.b do |b|
                  b << "#{get_anchors()[node['id']][:label]}. #{c1.text} "
                end
              end
            else
              s.send "h#{get_anchors()[node['id']][:level]}" do |h|
                h << "#{get_anchors()[node['id']][:label]}. #{c1.text}"
              end
            end
          else
            parse(c1, s)
          end
        end
      end
    end

    def clause_name(num, title, div, inline_header, header_class)
      if inline_header
        clause_name_inline(num, title)
      else
        clause_name_header(num, title, div, header_class)
      end
    end

    def clause_name_inline(num, title)
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
    end

    def clause(isoxml, out)
      isoxml.xpath(ns("//clause[parent::sections]")).each do |c|
        next if c.at(ns("./title")).text == "Scope"
        out.div **attr_code(id: c["id"]) do |s|
          c.elements.each do |c1|
            if c1.name == "title"
              clause_name("#{get_anchors()[c['id']][:label]}.", 
                          c1.text, s, c["inline-header"], nil)
            else
              parse(c1, s)
            end
          end
        end
      end
    end

    def annex_name(annex, name, div)
      div.h1 **{ class: "Annex" } do |t|
        t << "#{get_anchors()[annex['id']][:label]}<br/><br/>"
        t << "<b>#{name.text}</b>"
      end
    end

    def annex(isoxml, out)
      isoxml.xpath(ns("//annex")).each do |c|
        page_break(out)
        out.div **attr_code(id: c["id"], class: "Section3" ) do |s|
          #s1.div **{ class: "annex" } do |s|
          c.elements.each do |c1|
            if c1.name == "title" then annex_name(c, c1, s)
            else
              parse(c1, s)
            end
          end
          # end
        end
      end
    end

    def scope(isoxml, out)
      f = isoxml.at(ns("//clause[title = 'Scope']")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("1.", "Scope", div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    TERM_DEF_BOILERPLATE = <<~BOILERPLATE.freeze
      <p>ISO and IEC maintain terminological databases for use in 
      standardization at the following addresses:</p>
      <ul> <li> <p>ISO Online browsing platform: available at 
           <link target="http://www.iso.org/obp"/></p> </li>
           <li> <p>IEC Electropedia: available at 
           <link target="http://www.electropedia.org"/></p> </li> </ul>
    BOILERPLATE

    def term_defs_boilerplate(div, source, term)
      if source.nil? && term.nil?
        div << "<p>No terms and definitions are listed in this document.</p>"
      else
        out = "<p>For the purposes of this document, " +
          term_defs_boilerplate_cont(div, source, term)
        div << out
      end
      div << TERM_DEF_BOILERPLATE
    end

    def term_defs_boilerplate_cont(div, src, term)
      if src.nil?
        "the following terms and definitions apply.</p>"
      elsif term.nil?
        "the terms and definitions given in #{src["citeas"]} apply.</p>"
      else
        "the terms and definitions given in #{src["citeas"]} "\
          "and the following apply.</p>"
      end
    end

    def terms_defs(isoxml, out)
      f = isoxml.at(ns("//terms")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("3.", "Terms and Definitions", div, false, nil)
        term_defs_boilerplate(div, f.at(ns("./source")), f.at(ns(".//term")))
        f.elements.each do |e|
          parse(e, div) unless %w{title source}.include? e.name
        end
      end
    end

    def symbols_abbrevs(isoxml, out)
      f = isoxml.at(ns("//symbols-abbrevs")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("4.", "Symbols and Abbreviated Terms", div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      num = f.at(ns(".//subsection")) ? "0." : nil
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        # div.h1 "Introduction", **attr_code(title_attr)
        clause_name(num, "Introduction", div, false, title_attr)
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
        s.h1 **{ class: "ForewordTitle" } { |h1| h1 << "Foreword" }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end
  end
end
