module IsoDoc::Function
  module Section
    def clausedelim
      "."
    end

    def clausedelimspace(out)
      insert_tab(out, 1)
    end

    def inline_header_title(out, node, title)
      out.span **{ class: "zzMoveToFollowing" } do |s|
        s.b do |b|
          title&.children&.each { |c2| parse(c2, b) }
          clausedelimspace(out) if /\S/.match(title&.text)
        end
      end
    end

    # used for subclauses
    def clause_parse_title(node, div, title, out, header_class = {})
      return if title.nil?
      if node["inline-header"] == "true"
        inline_header_title(out, node, title)
      else
        depth = (title && title["depth"]) ? title["depth"] :
          node.ancestors("clause, annex, terms, references, definitions, "\
                        "acknowledgements, introduction, foreword").size + 1
        div.send "h#{depth}", **attr_code(header_class) do |h|
          title&.children&.each { |c2| parse(c2, h) }
        end
      end
    end

    def clause_attrs(node)
      { id: node["id"] }
    end

    # used for subclauses
    def clause_parse(node, out)
      out.div **attr_code(clause_attrs(node)) do |div|
        clause_parse_title(node, div, node.at(ns("./title")), out)
        node.children.reject { |c1| c1.name == "title" }.each do |c1|
          parse(c1, div)
        end
      end
    end

    def clause_name(_num, title, div, header_class)
      header_class = {} if header_class.nil?
      div.h1 **attr_code(header_class) do |h1|
        title.is_a?(String) ? h1 << title :
          title&.children&.each { |c2| parse(c2, h1) }
      end
      div.parent.at(".//h1")
    end

    def clause(isoxml, out)
      isoxml.xpath(ns(middle_clause)).each do |c|
        out.div **attr_code(clause_attrs(c)) do |s|
          clause_name(nil, c&.at(ns("./title")), s, nil)
          c.elements.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, s)
          end
        end
      end
    end

    def annex_name(annex, name, div)
      return if name.nil?
      div.h1 **{ class: "Annex" } do |t|
        name.children.each { |c2| parse(c2, t) }
      end
    end

    def annex_attrs(node)
      { id: node["id"], class: "Section3" }
    end

    def annex(isoxml, out)
      isoxml.xpath(ns("//annex")).each do |c|
        page_break(out)
        out.div **attr_code(annex_attrs(c)) do |s|
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
      f = isoxml.at(ns("//clause[@type = 'scope']")) or return num
      out.div **attr_code(id: f["id"]) do |div|
        num = num + 1
        clause_name(num, f&.at(ns("./title")), div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    TERM_CLAUSE = "//sections/terms | "\
      "//sections/clause[descendant::terms]".freeze

    def term_def_title(title)
      case title&.text
      when "Terms, definitions, symbols and abbreviated terms"
        @i18n.termsdefsymbolsabbrev
      when "Terms, definitions and symbols"
        @i18n.termsdefsymbols
      when "Terms, definitions and abbreviated terms"
        @i18n.termsdefabbrev
      when "Terms and definitions"
        @i18n.termsdef
      else
        title
      end
    end

    def terms_defs(isoxml, out, num)
      f = isoxml.at(ns(TERM_CLAUSE)) or return num
      out.div **attr_code(id: f["id"]) do |div|
        num = num + 1
        clause_name(num, term_def_title(f&.at(ns("./title"))), div, nil)
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
      f = isoxml.at(ns("//sections/definitions")) or return num
      out.div **attr_code(id: f["id"], class: "Symbols") do |div|
        num = num + 1
        clause_name(num, f&.at(ns("./title")) || @i18n.symbols, div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    # subclause
    def symbols_parse(isoxml, out)
      isoxml.at(ns("./title")) or
        isoxml.children.first.previous = "<title>#{@i18n.symbols}</title>"
      clause_parse(isoxml, out)
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        clause_name(nil, @i18n.introduction, div, title_attr)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def foreword(isoxml, out)
      f = isoxml.at(ns("//foreword")) || return
      page_break(out)
      out.div **attr_code(id: f["id"]) do |s|
        s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @i18n.foreword }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end

    def acknowledgements(isoxml, out)
      f = isoxml.at(ns("//acknowledgements")) || return
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        clause_name(nil, f&.at(ns("./title")), div, title_attr)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def abstract(isoxml, out)
      f = isoxml.at(ns("//preface/abstract")) || return
      page_break(out)
      out.div **attr_code(id: f["id"]) do |s|
        s.h1(**{ class: "AbstractTitle" }) { |h1| h1 << @i18n.abstract }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end

    def preface(isoxml, out)
      title_attr = { class: "IntroTitle" }
      isoxml.xpath(ns("//preface/clause | //preface/terms | //preface/definitions | "\
                      "//preface/references")).each do |f|
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(nil, f&.at(ns("./title")), div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end
    end

    def copyright_parse(node, out)
      out.div **{class: "boilerplate-copyright"} do |div|
        node.children.each { |n| parse(n, div) }
      end
    end

    def license_parse(node, out)
      out.div **{class: "boilerplate-license"} do |div|
        node.children.each { |n| parse(n, div) }
      end
    end

    def legal_parse(node, out)
      out.div **{class: "boilerplate-legal"} do |div|
        node.children.each { |n| parse(n, div) }
      end
    end

    def feedback_parse(node, out)
      out.div **{class: "boilerplate-feedback"} do |div|
        node.children.each { |n| parse(n, div) }
      end
    end
  end
end
