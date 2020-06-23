module IsoDoc::Function
  module Blocks
    def example_label(node, div, name)
      n = @xrefs.get[node["id"]]
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
                style: "border-collapse:collapse;border-spacing:0;"\
                "#{keep_style(node)}" )
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

    def note_label(node)
      n = @xrefs.get[node["id"]]
      return @note_lbl if n.nil? || n[:label].nil? || n[:label].empty?
      l10n("#{@note_lbl} #{n[:label]}")
    end

    def note_p_parse(node, div)
      div.p do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
        node.first_element_child.children.each { |n| parse(n, p) }
      end
      node.element_children[1..-1].each { |n| parse(n, div) }
    end

    def note_parse1(node, div)
      div.p do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
      end
      node.children.each { |n| parse(n, div) }
    end

    def keep_style(node)
      ret = ""
      node["keep-with-next"] == "true" and
        ret += "page-break-after: avoid;"
      node["keep-lines-together"] == "true" and
        ret += "page-break-inside: avoid;"
      return nil if ret.empty?
      ret
    end

    def note_attrs(node)
      attr_code(id: node["id"], class: "Note", style: keep_style(node))
    end

    def note_parse(node, out)
      @note = true
      out.div **note_attrs(node) do |div|
        node.first_element_child.name == "p" ?
          note_p_parse(node, div) : note_parse1(node, div)
      end
      @note = false
    end
  end
end
