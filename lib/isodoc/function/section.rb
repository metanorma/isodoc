require_relative "./section_titles"

module IsoDoc
  module Function
    module Section
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

      def clause(isoxml, out)
        isoxml.xpath(ns(middle_clause(isoxml))).each do |c|
          out.div **attr_code(clause_attrs(c)) do |s|
            clause_name(c, c&.at(ns("./title")), s, nil)
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
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
              else parse(c1, s)
              end
            end
          end
        end
      end

      def scope(isoxml, out, num)
        f = isoxml.at(ns("//clause[@type = 'scope']")) or return num
        out.div **attr_code(id: f["id"]) do |div|
          num = num + 1
          clause_name(f, f&.at(ns("./title")), div, nil)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
        num
      end

      TERM_CLAUSE = "//sections/terms | " \
                    "//sections/clause[descendant::terms]".freeze

      def terms_defs(isoxml, out, num)
        f = isoxml.at(ns(TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          num = num + 1
          clause_name(f, f&.at(ns("./title")), div, nil)
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
          clause_name(f, f.at(ns("./title")), div, nil)
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

      def introduction(clause, out)
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def foreword(clause, out)
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(clause, clause.at(ns("./title")) || @i18n.foreword, s,
                      { class: "ForewordTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def acknowledgements(clause, out)
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./title")), div, title_attr)
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def abstract(clause, out)
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(clause, clause.at(ns("./title")), s,
                      { class: "AbstractTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def preface_attrs(node)
        { id: node["id"],
          class: node["type"] == "toc" ? "TOC" : "Section3" }
      end

      def preface(clause, out)
        if clause["type"] == "toc"
          table_of_contents(clause, out)
        else
          preface_normal(clause, out)
        end
      end

      def preface_normal(clause, out)
        page_break(out)
        out.div **attr_code(preface_attrs(clause)) do |div|
          clause_name(clause, clause.at(ns("./title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def table_of_contents(clause, out)
        page_break(out)
        out.div **attr_code(preface_attrs(clause)) do |div|
          clause_name(clause, clause.at(ns("./title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def colophon(isoxml, out)
        isoxml.at(ns("//colophon")) or return
        page_break(out)
        isoxml.xpath(ns("//colophon/clause")).each do |f|
          out.div class: "Section3", id: f["id"] do |div|
            clause_name(f, f&.at(ns("./title")), div, { class: "IntroTitle" })
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
          end
        end
      end

      def is_clause?(name)
        %w(clause references definitions terms foreword introduction abstract
           acknowledgements).include? name
      end

      def single_term_clause?(elem)
        t = elem.xpath(ns("./clause | ./terms | ./definitions | ./references"))
        t.size == 1 && %w(terms definitions references).include?(t[0].name)
      end

      def front(isoxml, out)
        p = isoxml.at(ns("//preface")) or return
        p.elements.each do |e|
          if is_clause?(e.name)
            case e.name
            when "abstract" then abstract e, out
            when "foreword" then foreword e, out
            when "introduction" then introduction e, out
            when "executivesummary" then executivesummary e, out
            when "clause" then preface e, out
            when "acknowledgements" then acknowledgements e, out
            end
          else
            preface_block(e, out)
          end
        end
      end

      def executivesummary(clause, out)
        introduction clause, out
      end

      # block, e.g. note, admonition
      def preface_block(block, out)
        parse(block, out)
      end

      def copyright_parse(node, out)
        return if @bare

        out.div class: "boilerplate-copyright" do |div|
          node.children.each { |n| parse(n, div) }
        end
      end

      def license_parse(node, out)
        return if @bare

        out.div class: "boilerplate-license" do |div|
          node.children.each { |n| parse(n, div) }
        end
      end

      def legal_parse(node, out)
        return if @bare

        out.div class: "boilerplate-legal" do |div|
          node.children.each { |n| parse(n, div) }
        end
      end

      def feedback_parse(node, out)
        return if @bare

        out.div class: "boilerplate-feedback" do |div|
          node.children.each { |n| parse(n, div) }
        end
      end
    end
  end
end
