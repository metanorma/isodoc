module IsoDoc
  module Function
    module Terms
      def definition_parse(node, out)
        node.children.each { |n| parse(n, out) }
      end

      def modification_parse(node, out)
        para = node.at(ns("./p"))
        para.children.each { |n| parse(n, out) }
      end

      def deprecated_term_parse(node, out)
        out.p class: "DeprecatedTerms", style: "text-align:left;" do |p|
          node.children.each { |c| parse(c, p) }
        end
      end

      def admitted_term_parse(node, out)
        out.p class: "AltTerms", style: "text-align:left;" do |p|
          node.children.each { |c| parse(c, p) }
        end
      end

      def term_parse(node, out)
        out.p class: "Terms", style: "text-align:left;" do |p|
          node.children.each { |c| parse(c, p) }
        end
      end

      def para_then_remainder(first, node, para, div)
        if first.name == "p"
          first.children.each { |n| parse(n, para) }
          node.elements.drop(1).each { |n| parse(n, div) }
        else
          node.elements.each { |n| parse(n, div) }
        end
      end

      def termnote_p_class
        nil
      end

      def termnote_parse(node, div)
        name = node.at(ns("./fmt-name"))
        para = node.at(ns("./p"))
        div.p **attr_code(class: termnote_p_class) do |p|
          name and p.span class: "note_label" do |s|
            name.children.each { |n| parse(n, s) }
          end
          p << " " # TODO to Presentation XML
          para.children.each { |n| parse(n, p) }
        end
        para.xpath("./following-sibling::*").each { |n| parse(n, div) }
      end

      def termref_parse(node, out)
        out.p do |p|
          node.children.each { |n| parse(n, p) }
        end
      end

      def termdomain_parse(node, out)
        node["hidden"] == "true" and return
        node.children.each { |n| parse(n, out) }
      end

      def termdef_parse(node, out)
        name = node.at(ns("./fmt-name"))&.remove
        out.p class: "TermNum", id: node["id"] do |p|
          name&.children&.each { |n| parse(n, p) }
        end
        node.children.each { |n| parse(n, out) }
      end

      def termdocsource_parse(_node, _out); end
    end
  end
end
