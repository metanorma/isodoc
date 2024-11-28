module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_name(node, delims, label, elem)
      label&.empty? and label = nil
      name, ins, ids, number = prefix_name_prep(node, elem)
      ins.next = fmt_xref_label(label, number, ids)
      # autonum can be empty, e.g single note in clause: "NOTE []"
      number and node["autonum"] = number.gsub(/<[^>]+>/, "")
      !node.at(ns("./fmt-#{elem}")) &&
        (c = fmt_caption(label, elem, name, ids, delims)) and ins.next = c
      prefix_name_postprocess(node)
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

    def prefix_name_postprocess(node)
      node.at(ns("./sentinel"))&.remove
    end

    def semx(node, label, element = "autonum")
      id = node["id"] || node[:id]
      /<semx element='[^']+' source='#{id}'/.match?(label) and return label
      l = stripsemx(label)
      %(<semx element='#{element}' source='#{id}'>#{l}</semx>)
    end

    def autonum(id, num)
      /<semx/.match?(num) and return num # already contains markup
      "<semx element='autonum' source='#{id}'>#{num}</semx>"
    end

    def fmt_xref_label(label, _number, ids)
      label or return ""
      x = @xrefs.anchor(ids[:elem], :xref, false) or return ""
      ret = "<fmt-xref-label>#{x}</fmt-xref-label>"
      container = @xrefs.anchor(ids[:elem], :container, false)
      y = prefix_container_fmt_xref_label(container, x)
      y != x and
        ret += "<fmt-xref-label container='#{container}'>#{y}</fmt-xref-label>"
      ret
    end

    def prefix_container_fmt_xref_label(container, xref)
      container or return xref
      container_container = @xrefs.anchor(container, :container, false)
      container_label =
        prefix_container_fmt_xref_label(container_container,
                                        @xrefs.anchor(container, :xref, false))
      l10n(connectives_spans(@i18n.nested_xref
        .sub("%1", "<span class='fmt-xref-container'>#{container_label}</span>")
        .sub("%2", xref)))
    end

    # Remove ".blank?" tests if want empty delim placeholders for manipulation
    def fmt_caption(label, elem, name, ids, delims)
      label = fmt_caption_label_wrap(label)
      c = fmt_caption2(label, elem, name, ids, delims)
      c.blank? and return
      !delims[:label].blank? and
        f = "<span class='fmt-label-delim'>#{delims[:label]}</span>"
      "<fmt-#{elem}>#{c}#{f}</fmt-#{elem}>"
    end

    def fmt_caption_label_wrap(label)
      label.blank? || %r{<span class=['"]fmt-caption-label['"]}.match?(label) or
        label = "<span class='fmt-caption-label'>#{label}</span>"
      label
    end

    def fmt_caption2(label, elem, name, ids, delims)
      if name && !name.children.empty?
        label.blank? or
          d = "<span class='fmt-caption-delim'>#{delims[:caption]}</span>"
        attr = " element='#{elem}' source='#{ids[:name]}'"
        "#{label}#{d}<semx #{attr}>#{to_xml(name.children)}</semx>"
      elsif label then label
      end
    end
  end
end
