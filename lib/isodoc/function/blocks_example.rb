module IsoDoc::Function
  module Blocks
    def example_label(node, div, name)
      n = get_anchors[node["id"]]
      div.p **{ class: "example-title" } do |p|
        lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
          l10n("#{@example_lbl} #{n[:label]}")
        p << lbl
        name and !lbl.nil? and p << "&nbsp;&mdash; "
        name and name.children.each { |n| parse(n, div) }
      end
    end

    EXAMPLE_TBL_ATTR =
      { class: "example_label", style: "width:82.8pt;padding:0 0 0 0;\
        margin-left:0pt;vertical-align:top;" }.freeze

    # used if we are boxing examples
    def example_div_parse(node, out)
      out.div **attr_code(id: node["id"], class: "example") do |div|
        example_label(node, div, node.at(ns("./name")))
        node.children.each do |n|
          parse(n, div) unless n.name == "name"
        end
      end
    end

    def example_table_attr(node)
      attr_code(id: node["id"], class: "example",
                style: "border-collapse:collapse;border-spacing:0;" )
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
  end
end
