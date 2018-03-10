module IsoDoc
  class Convert
    def definition_parse(node, out)
      node.children.each { |n| parse(n, out) }
    end

    def modification_parse(node, out)
      out << "[MODIFICATION]"
      para = node.at(ns("./p"))
      para.children.each { |n| parse(n, out) }
    end

    def deprecated_term_parse(node, out)
      out.p **{ class: "DeprecatedTerms" } do |p|
        p << l10n("#{@deprecated_lbl}: #{node.text}")
      end
    end

    def admitted_term_parse(node, out)
      out.p **{ class: "AltTerms" } { |p| p << node.text }
    end

    def term_parse(node, out)
      out.p **{ class: "Terms" } { |p| p << node.text }
    end

    def para_then_remainder(first, node, p, div)
      if first.name == "p"
        first.children.each { |n| parse(n, p) }
        node.elements.drop(1).each { |n| parse(n, div) }
      else
        node.elements.each { |n| parse(n, div) }
      end
    end

    def termnote_parse(node, out)
      out.div **{ class: "Note" } do |div|
        first = node.first_element_child
        div.p **{ class: "Note" } do |p|
          p << "#{get_anchors[node['id']][:label]}: "
          para_then_remainder(first, node, p, div)
        end
      end
    end

    def termref_parse(node, out)
      out.p do |p|
        p << "[TERMREF]"
        node.children.each { |n| parse(n, p) }
        p << "[/TERMREF]"
      end
    end

    def termdef_parse(node, out)
      out.p **{ class: "TermNum", id: node["id"] } do |p|
        p << get_anchors[node["id"]][:label]
      end
      set_termdomain("")
      node.children.each { |n| parse(n, out) }
    end
  end
end
