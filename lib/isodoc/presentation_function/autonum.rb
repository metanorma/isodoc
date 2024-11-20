module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_name(node, delims, label, elem)
      label&.empty? and label = nil
      name, ins, ids, number = prefix_name_prep(node, elem)
      label and ins.next = fmt_label(label, number, ids)
      # autonum can be empty, e.g single note in clause: "NOTE []"
      number and node["autonum"] = number
      c = fmt_caption(label, elem, name, ids, delims) and ins.next = c
      node.at(ns("./sentinel"))&.remove
    end

    def prefix_name_prep(node, elem)
      lbls = prefix_name_labels(node)
      name = node.at(ns("./#{elem}")) and name["id"] = lbls[:name]
      ins = name || node.add_first_child("<sentinel/>").elements.first
      node["unnumbered"] or
        number = @xrefs.anchor(node["id"], :value, false)&.strip
      [name, ins, lbls, number]
    end

    def prefix_name_labels(node)
      { elem: node["id"],
        name: "_#{UUIDTools::UUID.random_create}" }
    end

    def autonum(id, num)
      /<semx/.match?(num) and return num # already contains markup
      "<semx element='autonum' source='#{id}'>#{num}</semx>"
    end

    def fmt_label(_label, _number, ids)
      x = @xrefs.anchor(ids[:elem], :xref, false) and
        return "<fmt-xref-label>#{x}</fmt-xref-label>"
      ""
      # label = cleanup_entities(label.strip)
      # <<~XML
      # <fmt-caption-label id='#{ids[:label]}'>#{label}</fmt-caption-label>#{xref}
      # XML
    end

    # Remove ".blank?" tests if we want empty delim placeholders for manipulation
    def fmt_caption(label, elem, name, ids, delims)
      c = if name && !name.children.empty?
            label.blank? or
              d = "<span class='fmt-caption-delim'>#{delims[:caption]}</span>"
            attr = " element='#{elem}' source='#{ids[:name]}'"
            "#{label}#{d}<semx #{attr}>#{to_xml(name.children)}</semx>"
          elsif label then label
          else return end
      !delims[:label].blank? and
        f = "<span class='fmt-label-delim'>#{delims[:label]}</span>"
      "<fmt-#{elem}><span class='fmt-caption-label'>#{c}</span>#{f}</fmt-#{elem}>"
    end
  end
end
