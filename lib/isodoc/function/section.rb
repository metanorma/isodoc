module IsoDoc::Function
  module Section
    def clausedelim
      "."
    end

    def clausedelimspace(out)
      insert_tab(out, 1)
    end

    def inline_header_title(out, node, c1)
      out.span **{ class: "zzMoveToFollowing" } do |s|
        s.b do |b|
          if anchor(node['id'], :label, false) && !@suppressheadingnumbers
            b << "#{anchor(node['id'], :label)}#{clausedelim}"
            clausedelimspace(out)
          end
          c1&.children&.each { |c2| parse(c2, b) }
        end
      end
    end

    # used for subclauses
    def clause_parse_title(node, div, c1, out)
      if node["inline-header"] == "true"
        inline_header_title(out, node, c1)
      else
        div.send "h#{anchor(node['id'], :level, false) || '1'}" do |h|
          lbl = anchor(node['id'], :label, false)
          h << "#{lbl}#{clausedelim}" if lbl && !@suppressheadingnumbers
          clausedelimspace(out) if lbl && !@suppressheadingnumbers
          c1&.children&.each { |c2| parse(c2, h) }
        end
      end
    end

    # used for subclauses
    def clause_parse(node, out)
      out.div **attr_code(id: node["id"]) do |div|
        clause_parse_title(node, div, node.at(ns("./title")), out)
        node.children.reject { |c1| c1.name == "title" }.each do |c1|
          parse(c1, div)
        end
      end
    end

    def clause_name(num, title, div, header_class)
      header_class = {} if header_class.nil?
      div.h1 **attr_code(header_class) do |h1|
        if num && !@suppressheadingnumbers
          h1 << "#{num}#{clausedelim}"
          clausedelimspace(h1)
        end
        title.is_a?(String) ? h1 << title :
          title&.children&.each { |c2| parse(c2, h1) }
      end
      div.parent.at(".//h1")
    end

    MIDDLE_CLAUSE =
      "//clause[parent::sections][not(xmlns:title = 'Scope')]"\
      "[not(descendant::terms)]".freeze

    def clause(isoxml, out)
      isoxml.xpath(ns(self.class::MIDDLE_CLAUSE)).each do |c|
        out.div **attr_code(id: c["id"]) do |s|
          clause_name(anchor(c['id'], :label),
                      c&.at(ns("./title")), s, nil)
          c.elements.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, s)
          end
        end
      end
    end

    def annex_name(annex, name, div)
      div.h1 **{ class: "Annex" } do |t|
        t << "#{anchor(annex['id'], :label)}<br/><br/>"
        t.b do |b|
          name&.children&.each { |c2| parse(c2, b) }
        end
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
        clause_name(num, @scope_lbl, div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    def terms_defs_title(f)
      symbols = f.at(ns(".//definitions"))
      return @termsdefsymbols_lbl if symbols
      @termsdef_lbl
    end

    TERM_CLAUSE = "//sections/terms | "\
      "//sections/clause[descendant::terms]".freeze

    def terms_defs(isoxml, out, num)
      f = isoxml.at(ns(TERM_CLAUSE)) or return num
      out.div **attr_code(id: f["id"]) do |div|
        num = num + 1
        clause_name(num, terms_defs_title(f), div, nil)
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
        clause_name(num, f&.at(ns("./title")) || @symbols_lbl, div, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
      num
    end

    # subclause
    def symbols_parse(isoxml, out)
      isoxml.at(ns("./title")) or
        isoxml.children.first.previous = "<title>#{@symbols_lbl}</title>"
      clause_parse(isoxml, out)
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        clause_name(nil, @introduction_lbl, div, title_attr)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def foreword(isoxml, out)
      f = isoxml.at(ns("//foreword")) || return
      page_break(out)
      out.div **attr_code(id: f["id"]) do |s|
        s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
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
        s.h1(**{ class: "AbstractTitle" }) { |h1| h1 << @abstract_lbl }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end

    def preface(isoxml, out)
      title_attr = { class: "IntroTitle" }
      isoxml.xpath(ns("//preface/clause")).each do |f|
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
