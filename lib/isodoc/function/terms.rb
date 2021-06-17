module IsoDoc::Function
  module Terms
    def definition_parse(node, out)
      node.children.each { |n| parse(n, out) }
    end

    def modification_parse(node, out)
      out << "[MODIFICATION]"
      para = node.at(ns("./p"))
      para.children.each { |n| parse(n, out) }
    end

    def deprecated_term_parse(node, out)
      out.p **{ class: "DeprecatedTerms", style: "text-align:left;" } do |p|
        p << l10n("#{@i18n.deprecated}: ")
        node.children.each { |c| parse(c, p) }
      end
    end

    def admitted_term_parse(node, out)
      out.p **{ class: "AltTerms", style: "text-align:left;" } do |p|
        node.children.each { |c| parse(c, p) }
      end
    end

    def term_parse(node, out)
      out.p **{ class: "Terms", style: "text-align:left;" } do |p|
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

    def termnote_delim
      l10n(": ")
    end

    def termnote_parse(node, out)
      name = node&.at(ns("./name"))&.remove
      out.div **note_attrs(node) do |div|
        div.p do |p|
          if name
            name.children.each { |n| parse(n, p) }
            p << termnote_delim
          end
          para_then_remainder(node.first_element_child, node, p, div)
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
      name = node&.at(ns("./name"))&.remove
      out.p **{ class: "TermNum", id: node["id"] } do |p|
        name&.children&.each { |n| parse(n, p) }
      end
      set_termdomain("")
      node.children.each { |n| parse(n, out) }
    end

    def termdocsource_parse(_node, _out); end
  end
end
