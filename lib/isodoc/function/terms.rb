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

      def termnote_p_class
        nil
      end

      def termnote_parse(node, out)
        para = block_body_first_elem(node)
        out.div **note_attrs(node) do |div|
          termnote_parse1(node, para, div)
          para&.xpath("./following-sibling::*")&.each { |n| parse(n, div) }
        end
      end

      def termnote_parse1(node, para, div)
        div.p **attr_code(class: termnote_p_class) do |p|
          name = node.at(ns("./fmt-name")) and
            p.span class: "termnote_label" do |s|
              children_parse(name, s)
            end
          para&.name == "p" and children_parse(para, p)
        end
        para&.name != "p" and parse(para, div)
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
