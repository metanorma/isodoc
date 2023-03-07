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

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction")) || return
        page_break(out)
        out.div class: "Section3", id: f["id"] do |div|
          clause_name(f, f.at(ns("./title")), div, { class: "IntroTitle" })
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword")) || return
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          clause_name(f, f.at(ns("./title")) || @i18n.foreword, s,
                      { class: "ForewordTitle" })
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def acknowledgements(isoxml, out)
        f = isoxml.at(ns("//acknowledgements")) || return
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: f["id"] do |div|
          clause_name(f, f&.at(ns("./title")), div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def abstract(isoxml, out)
        f = isoxml.at(ns("//preface/abstract")) || return
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          clause_name(f, f.at(ns("./title")), s, { class: "AbstractTitle" })
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def preface(isoxml, out)
        isoxml.xpath(ns("//preface/clause | //preface/references | " \
                        "//preface/definitions | //preface/terms")).each do |f|
          page_break(out)
          out.div class: "Section3", id: f["id"] do |div|
            clause_name(f, f&.at(ns("./title")), div, { class: "IntroTitle" })
            f.elements.each do |e|
              parse(e, div) unless e.name == "title"
            end
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

      def preface_block(isoxml, out)
        p = isoxml.at(ns("//preface")) or return
        p.elements.each do |e|
          next if is_clause?(e.name)

          parse(e, out)
        end
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
