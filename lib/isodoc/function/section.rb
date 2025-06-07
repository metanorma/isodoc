require_relative "section_titles"

module IsoDoc
  module Function
    module Section
      def clause_attrs(node)
        { id: node["id"] }
      end

      # used for subclauses
      def clause_parse(node, out)
        out.div **attr_code(clause_attrs(node)) do |div|
          clause_parse_title(node, div, node.at(ns("./fmt-title")), out)
          node.children.reject { |c1| c1.name == "fmt-title" }.each do |c1|
            parse(c1, div)
          end
        end
      end

      def clause(node, out)
        out.div **attr_code(clause_attrs(node)) do |s|
          clause_name(node, node.at(ns("./fmt-title")), s, nil)
          node.elements.reject { |c1| c1.name == "fmt-title" }.each do |c1|
            parse(c1, s)
          end
        end
      end

      def annex_attrs(node)
        { id: node["id"], class: "Section3" }
      end

      def annex(node, out)
        page_break(out)
        out.div **attr_code(annex_attrs(node)) do |s|
          node.elements.each do |c1|
            if c1.name == "fmt-title" then annex_name(node, c1, s)
            else parse(c1, s)
            end
          end
        end
      end

      def appendix_parse(isoxml, out)
        clause_parse(isoxml, out)
      end

      def indexsect(node, out)
        clause_parse(node, out)
      end

      def scope(node, out)
        out.div **attr_code(id: node["id"]) do |div|
          clause_name(node, node.at(ns("./fmt-title")), div, nil)
          node.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      TERM_CLAUSE = "//sections/terms | " \
                    "//sections/clause[descendant::terms]".freeze

      def terms_defs(node, out)
        out.div **attr_code(id: node["id"]) do |div|
          clause_name(node, node.at(ns("./fmt-title")), div, nil)
          node.elements.each do |e|
            parse(e, div) unless %w{fmt-title source}.include? e.name
          end
        end
      end

      # subclause
      def terms_parse(isoxml, out)
        clause_parse(isoxml, out)
      end

      def symbols_abbrevs(node, out)
        out.div **attr_code(id: node["id"], class: "Symbols") do |div|
          clause_name(node, node.at(ns("./fmt-title")), div, nil)
          node.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      # subclause
      def symbols_parse(isoxml, out)
        clause_parse(isoxml, out)
      end

      def introduction(clause, out)
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./fmt-title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      def foreword(clause, out)
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(clause, clause.at(ns("./fmt-title")), s,
                      { class: "ForewordTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "fmt-title" }
        end
      end

      def acknowledgements(clause, out)
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./fmt-title")), div, title_attr)
          clause.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      def abstract(clause, out)
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(clause, clause.at(ns("./fmt-title")), s,
                      { class: "AbstractTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "fmt-title" }
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
          clause_name(clause, clause.at(ns("./fmt-title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      def table_of_contents(clause, out)
        @bare and return
        page_break(out)
        out.div **attr_code(preface_attrs(clause)) do |div|
          clause_name(clause, clause.at(ns("./fmt-title")), div,
                      { class: "IntroTitle" })
          clause.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      def colophon(node, out)
        @seen_colophon or page_break(out)
        @seen_colophon = true
        out.div class: "Section3", id: node["id"] do |div|
          clause_name(node, node.at(ns("./fmt-title")), div,
                      { class: "IntroTitle" })
          node.elements.each do |e|
            parse(e, div) unless e.name == "fmt-title"
          end
        end
      end

      def clause?(name)
        %w(clause references definitions terms foreword introduction abstract
           executivesummary acknowledgements indexsect).include? name
      end

      def single_term_clause?(elem)
        t = elem.xpath(ns("./clause | ./terms | ./definitions | ./references"))
        t.size == 1 && %w(terms definitions references).include?(t[0].name)
      end

      def executivesummary(clause, out)
        introduction clause, out
      end

      # block, e.g. note, admonition
      def preface_block(block, out)
        parse(block, out)
      end

      def copyright_parse(node, out)
        @bare and return
        out.div class: "boilerplate-copyright" do |div|
                    children_parse(node, div)
        end
      end

      def license_parse(node, out)
        @bare and return
        out.div class: "boilerplate-license" do |div|
                    children_parse(node, div)
        end
      end

      def legal_parse(node, out)
        @bare and return
        out.div class: "boilerplate-legal" do |div|
                    children_parse(node, div)
        end
      end

      def feedback_parse(node, out)
        @bare and return
        out.div class: "boilerplate-feedback" do |div|
                    children_parse(node, div)
        end
      end

      def footnotes(docxml, div)
        docxml.xpath(ns("/*/fmt-footnote-container"))
          .each do |fn|
            fn.children.each { |n| parse(n, div) }
          end
      end
    end
  end
end
