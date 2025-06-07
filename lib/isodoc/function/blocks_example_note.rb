module IsoDoc
  module Function
    module Blocks
      def example_label(_node, div, name)
        name.nil? and return
        div.p class: "example-title" do |_p|
                    children_parse(name, div)
        end
      end

      EXAMPLE_TBL_ATTR =
        { class: "example_label", style: "width:82.8pt;padding:0 0 0 0;\
        margin-left:0pt;vertical-align:top;" }.freeze

      def example_div_attr(node)
        attr_code(id: node["id"], class: "example", style: keep_style(node))
      end

      # used if we are boxing examples
      def example_div_parse(node, out)
        out.div **example_div_attr(node) do |div|
          example_label(node, div, node.at(ns("./fmt-name")))
          node.children.each do |n|
            parse(n, div) unless n.name == "fmt-name"
          end
        end
      end

      def example_table_attr(node)
        attr_code(id: node["id"], class: "example",
                  style: "border-collapse:collapse;border-spacing:0;" \
                         "#{keep_style(node)}")
      end

      EXAMPLE_TD_ATTR =
        { style: "vertical-align:top;padding:0;", class: "example" }.freeze

      def example_table_parse(node, out)
        out.table **example_table_attr(node) do |t|
          t.tr do |tr|
            tr.td **EXAMPLE_TBL_ATTR do |td|
              example_label(node, td, node.at(ns("./fmt-name")))
            end
            tr.td **EXAMPLE_TD_ATTR do |td|
              node.children.each do |n|
                parse(n, td) unless n.name == "fmt-name"
              end
            end
          end
        end
      end

      def example_parse(node, out)
        example_div_parse(node, out)
      end

      def block_body_first_elem(node)
        node.elements.each do |n|
          %w(title fmt-title fmt-xref-label fmt-name name)
            .include?(n.name) and next
          return n
        end
        nil
      end

      def starts_with_para?(node)
        block_body_first_elem(node)&.name == "p"
      end

      def note_p_class
        nil
      end

      def note_p_parse(node, div)
        name = node.at(ns("./fmt-name"))
        para = node.at(ns("./p"))
        div.p **attr_code(class: note_p_class) do |p|
          name and p.span class: "note_label" do |s|
            name.children.each { |n| parse(n, s) }
          end
          children_parse(para, p)
        end
        para.xpath("./following-sibling::*").each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        name = node.at(ns("./fmt-name")) and
          div.p **attr_code(class: note_p_class) do |p|
            p.span class: "note_label" do |s|
              name.remove.children.each { |n| parse(n, s) }
            end
          end
        children_parse(node, div)
      end

      def keep_style(node)
        ret = ""
        node["style"] and ret += "#{node['style']};"
        node["keep-with-next"] == "true" and
          ret += "page-break-after: avoid;"
        node["keep-lines-together"] == "true" and
          ret += "page-break-inside: avoid;"
        return nil if ret.empty?

        ret
      end

      def note_attrs(node)
        attr_code(id: node["id"], class: "Note", style: keep_style(node),
                  coverpage: node["coverpage"])
      end

      def note_parse(node, out)
        @note = true
        out.div **note_attrs(node) do |div|
          if starts_with_para?(node)
            note_p_parse(node, div)
          else
            note_parse1(node, div)
          end
        end
        @note = false
      end

      def admonition_name_parse(_node, div, name)
        div.p class: "AdmonitionTitle", style: "text-align:center;" do |p|
          children_parse(name, p)
        end
      end

      def admonition_class(_node)
        "Admonition"
      end

      def admonition_name(node, _type)
        node&.at(ns("./fmt-name"))
      end

      def admonition_attrs(node)
        attr_code(id: node["id"], class: admonition_class(node),
                  style: keep_style(node), coverpage: node["coverpage"])
      end

      def admonition_parse(node, out)
        out.div **admonition_attrs(node) do |div|
          if starts_with_para?(node)
            admonition_p_parse(node, div)
          else
            admonition_parse1(node, div)
          end
        end
      end

      # code to allow name and first paragraph to be rendered in same block
      def admonition_p_parse(node, div)
        admonition_parse1(node, div)
      end

      # code to allow name and first paragraph to be rendered in same block
      def admonition_name_in_first_para(node, div)
        name = node.at(ns("./fmt-name"))
        para = node.at(ns("./p"))
        div.p do |p|
          if name = admonition_name(node, node["type"])&.remove
            name.children.each { |n| parse(n, p) }
            admonition_name_para_delim(p) # TODO to Presentation XML
          end
          para.children.each { |n| parse(n, p) }
        end
        para.xpath("./following-sibling::*").each { |n| parse(n, div) }
      end

      def admonition_name_para_delim(para)
        insert_tab(para, 1)
      end

      def admonition_parse1(node, div)
        name = admonition_name(node, node["type"])
        if name
          admonition_name_parse(node, div, name)
        end
        node.children.each { |n| parse(n, div) unless n.name == "fmt-name" }
      end
    end
  end
end
