module IsoDoc
  module Function
    module References
      def bibitem_entry(list, bib, _ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(bib, biblio)) do |ref|
          tag = bib.at(ns("./biblio-tag"))
          tag&.children&.each { |n| parse(n, ref) }
          reference_format(bib, ref)
        end
      end

      def iso_bibitem_entry_attrs(bib, biblio)
        { id: bib["id"], class: biblio ? "Biblio" : "NormRef" }
      end

      def reference_format(bib, out)
        ftitle = bib.at(ns("./formattedref"))
        ftitle&.children&.each { |n| parse(n, out) }
      end

      def biblio_list(refs, div, biblio)
        i = 0
        refs.children.each do |b|
          if b.name == "bibitem"
            b["hidden"] == "true" and next
            i += 1
            bibitem_entry(div, b, i, biblio)
          else
            parse(b, div) unless %w(fmt-title).include? b.name
          end
        end
      end

      def norm_ref_xpath
        "//bibliography/references[@normative = 'true'] | " \
          "//bibliography/clause[.//references[@normative = 'true']] | " \
          "//sections/references[@normative = 'true'] | " \
          "//sections/clause[not(@type)][.//references[@normative = 'true']]"
      end

      def norm_ref(node, out)
        node["hidden"] != "true" or return
        out.div do |div|
          clause_name(node, node.at(ns("./fmt-title")), div, nil)
          if node.name == "clause"
            node.elements.each { |e| parse(e, div) unless e.name == "fmt-title" }
          else biblio_list(node, div, false)
          end
        end
      end

      def bibliography_xpath
        "//bibliography/clause[.//references]" \
          "[not(.//references[@normative = 'true'])] | " \
          "//bibliography/references[@normative = 'false']"
      end

      def bibliography(node, out)
        node["hidden"] != "true" or return
        page_break(out)
        out.div do |div|
          div.h1 class: "Section3" do |h1|
            node.at(ns("./fmt-title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(node, div, true)
        end
      end

      def bibliography_parse(node, out)
        node["hidden"] != true or return
        out.div do |div|
          clause_parse_title(node, div, node.at(ns("./fmt-title")), out,
                             { class: "Section3" })
          biblio_list(node, div, true)
        end
      end
    end
  end
end
