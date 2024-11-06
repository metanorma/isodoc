module IsoDoc
  module Function
    module Blocks
      def example_label(_node, div, name)
        name.nil? and return
        div.p class: "example-title" do |_p|
          name.children.each { |n| parse(n, div) }
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
          example_label(node, div, node.at(ns("./name")))
          node.children.each do |n|
            parse(n, div) unless n.name == "name"
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
              example_label(node, td, node.at(ns("./name")))
            end
            tr.td **EXAMPLE_TD_ATTR do |td|
              node.children.each { |n| parse(n, td) unless n.name == "name" }
            end
          end
        end
      end

      def example_parse(node, out)
        example_div_parse(node, out)
      end

      def note_p_parse(node, div)
        name = node.at(ns("./name"))&.remove
        div.p do |p|
          name and p.span class: "note_label" do |s|
            name.children.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..].each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        name = node.at(ns("./name")) and div.p do |p|
          p.span class: "note_label" do |s|
            name.remove.children.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) }
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
          if node&.at(ns("./*[local-name() != 'name'][1]"))&.name == "p"
            note_p_parse(node, div)
          else
            note_parse1(node, div)
          end
        end
        @note = false
      end

      def admonition_name_parse(_node, div, name)
        div.p class: "AdmonitionTitle", style: "text-align:center;" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def admonition_class(_node)
        "Admonition"
      end

      def admonition_name(node, _type)
        node&.at(ns("./name"))
      end

      def admonition_attrs(node)
        attr_code(id: node["id"], class: admonition_class(node),
                  style: keep_style(node), coverpage: node["coverpage"])
      end

      def admonition_parse(node, out)
        type = node["type"]
        name = admonition_name(node, type)
        out.div **admonition_attrs(node) do |t|
          admonition_name_parse(node, t, name) if name
          node.children.each { |n| parse(n, t) unless n.name == "name" }
        end
      end

      def admonition_parse(node, out)
        out.div **admonition_attrs(node) do |div|
          if node&.at(ns("./*[local-name() != 'name'][1]"))&.name == "p"
            # admonition_p_parse(node, div, name)
            # if will prefix name to first para
            admonition_parse1(node, div)
          else
            admonition_parse1(node, div)
          end
        end
      end

      def admonition_p_parse(node, div)
        div.p do |p|
          if name = admonition_name(node, node["type"])&.remove
            name.children.each { |n| parse(n, p) }
            insert_tab(p, 1)
          end
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..].each { |n| parse(n, div) }
      end

      def admonition_parse1(node, div)
        name = admonition_name(node, node["type"])
        if name
          admonition_name_parse(node, div, name)
          # insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) unless n.name == "name" }
      end
    end
  end
end
