module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_name(node, delims, label, elem)
      label, delims = prefix_name_defaults(node, delims, label, elem)
      name, ins, ids, number = prefix_name_prep(node, elem)
      ins.next = fmt_xref_label(label, number, ids)
      # autonum can be empty, e.g single note in clause: "NOTE []"
      number and node["autonum"] = number.gsub(/<[^>]+>/, "")
      !node.at(ns("./fmt-#{elem}")) &&
        (c = fmt_caption(label, elem, name, ids, delims)) and ins.next = c
      prefix_name_postprocess(node, elem)
    end

    def prefix_name_defaults(node, delims, label, elem)
      label&.empty? and label = nil
      node["unnumbered"] == "true" && !node.at(ns("./#{elem}")) &&
        node.name != "admonition" and label = nil
      # do not caption unnumbered uncaptioned blocks, other than admonitions
      delims.nil? and delims = {}
      [label, delims]
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
      #@new_ids ||= {}
      id = "_#{UUIDTools::UUID.random_create}"
      @new_ids[id] = nil
      { elem: node["id"], name: id }
    end

    def prefix_name_postprocess(node, elem)
      node.at(ns("./sentinel"))&.remove
      strip_duplicate_ids(node, node.at(ns("./#{elem}")),
                          node.at(ns("./fmt-#{elem}")))
    end

    def transfer_id(old, new)
      old["id"] or return
      new["id"] = old["id"]
      old["original-id"] = old["id"]
      old.delete("id")
    end

    def semx_fmt_dup(elem)
      add_id(elem)
      new = Nokogiri::XML(<<~XML).root
        <semx xmlns='#{elem.namespace.href}' element='#{elem.name}' source='#{elem['original-id'] || elem['id']}'>#{to_xml(elem.children)}</semx>
      XML
      strip_duplicate_ids(nil, elem, new)
      new
    end

    def gather_all_ids(elem)
      elem.xpath(".//*[@id]").each_with_object([]) do |i, m|
        m << i["id"]
      end
    end

    # remove ids duplicated between sem_title and pres_title
    # index terms are assumed transferred to pres_title from sem_title
    def strip_duplicate_ids(_node, sem_title, pres_title)
      sem_title && pres_title or return
      ids = gather_all_ids(pres_title)
      sem_title.xpath(".//*[@id]").each do |x|
        ids.include?(x["id"]) or next
        x["original-id"] = x["id"]
        x.delete("id")
      end
      sem_title.xpath(ns(".//index")).each(&:remove)
    end

    def semx(node, label, element = "autonum")
      id = node["id"] || node[:id]
      /<semx element='[^']+' source='#{id}'/.match?(label) and return label
      l = stripsemx(label)
      %(<semx element='#{element}' source='#{id}'>#{l}</semx>)
    end

    def autonum(id, num)
      num.include?("<semx") and return num # already contains markup
      "<semx element='autonum' source='#{id}'>#{num}</semx>"
    end

    def semx_orig(node, orig = nil)
      orig ||= node.parent.parent
      orig.at(".//*[@id = '#{node['source']}']")
    end

    def labelled_autonum(label, id, num)
      elem = "<span class='fmt-element-name'>#{label}</span>"
      num.blank? and return elem
      l10n("#{elem} #{autonum(id, num)}")
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

    # detect whether string which may contain XML markup is empty
    def empty_xml?(str)
      str.blank? and return true
      x = Nokogiri::XML::DocumentFragment.parse(str)
      x.to_str.strip.empty?
    end

    # Remove ".blank?" tests if want empty delim placeholders for manipulation
    def fmt_caption(label, elem, name, ids, delims)
      label = fmt_caption_label_wrap(label)
      c = fmt_caption2(label, elem, name, ids, delims)
      empty_xml?(c) and return
      !delims[:label].blank? and
        f = "<span class='fmt-label-delim'>#{delims[:label]}</span>"
      "<fmt-#{elem}>#{c}#{f}</fmt-#{elem}>"
    end

    def fmt_caption_label_wrap(label)
      empty_xml?(label) ||
        %r{<span class=['"]fmt-caption-label['"]}.match?(label) or
        label = "<span class='fmt-caption-label'>#{label}</span>"
      label
    end

    def fmt_caption2(label, elem, name, ids, delims)
      if name && !name.children.empty?
        empty_xml?(label) or
          d = "<span class='fmt-caption-delim'>#{delims[:caption]}</span>"
        attr = " element='#{elem}' source='#{ids[:name]}'"
        "#{label}#{d}<semx #{attr}>#{to_xml(name.children)}</semx>"
      elsif label then label
      end
    end
  end
end
