module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_container(container, linkend, node, _target)
      l10n("#{anchor_xref(node, container)}, #{linkend}")
    end

    def anchor_value(id)
      @xrefs.anchor(id, :value) || @xrefs.anchor(id, :label) ||
        @xrefs.anchor(id, :xref)
    end

    def anchor_linkend(node, linkend)
      node["style"] == "id" and
        return anchor_id_postproc(node)
      node["citeas"].nil? && node["bibitemid"] and
        return @xrefs.anchor(node["bibitemid"], :xref) || "???"
      node.at(ns("./location")) and
        return combine_xref_locations(node) || "???"
      node["target"] && node["droploc"] and
        return anchor_value(node["target"]) || "???"
      node["target"] && !/.#./.match(node["target"]) and
        return anchor_linkend1(node) || "???"
      linkend || "???"
    end

    def anchor_id_postproc(node)
      node["target"]
    end

    def anchor_linkend1(node)
      linkend = anchor_xref(node, node["target"])
      container = @xrefs.anchor(node["target"], :container, false)
      prefix_container?(container, node) and
        linkend = prefix_container(container, linkend, node, node["target"])
      capitalise_xref(node, linkend, anchor_value(node["target"]))
    end

    def anchor_xref(node, target)
      x = @xrefs.anchor(target, :xref)
      t = @xrefs.anchor(target, :title)
      if node["style"] == "basic" && t then t
      elsif node["style"] == "full" && t
        l10n("#{x}, #{t}")
      else x
      end
    end

    def prefix_container?(container, node)
      type = @xrefs.anchor(node["target"], :type)
      container &&
        get_note_container_id(node, type) != container &&
        @xrefs.get[node["target"]]
    end

    def combine_xref_locations(node)
      locs = gather_xref_locations(node)
      linkend = if can_conflate_xref_rendering?(locs)
                  combine_conflated_xref_locations(locs)
                else
                  out = locs.each { |l| l[:label] = anchor_linkend1(l[:node]) }
                  l10n(combine_conn(out))
                end
      capitalise_xref(node, linkend, anchor_value(node["target"]))
    end

    def combine_conflated_xref_locations(locs)
      out = locs.each { |l| l[:label] = anchor_value(l[:target]) }
      label = @i18n.inflect(locs.first[:elem], number: "pl")
      out[0][:label] = l10n("#{label} #{out[0][:label]}")
      combine_conflated_xref_locations_container(locs, l10n(combine_conn(out)))
    end

    def combine_conflated_xref_locations_container(locs, ret)
      container = @xrefs.anchor(locs.first[:node]["target"], :container,
                                false)
      prefix_container?(container, locs.first[:node]) and
        ret = prefix_container(container, ret, locs.first[:node],
                               locs.first[:node]["target"])
      ret
    end

    def gather_xref_locations(node)
      node.xpath(ns("./location")).each_with_object([]) do |l, m|
        type = @xrefs.anchor(l["target"], :type)
        m << { conn: l["connective"], target: l["target"],
               type: type, node: l, elem: @xrefs.anchor(l["target"], :elem),
               container: @xrefs.anchor(node["target"], :container, false) ||
                 %w(termnote).include?(type) }
      end
    end

    def loc2xref(entry)
      if entry[:target]
        "<xref nested='true' target='#{entry[:target]}'>#{entry[:label]}</xref>"
      else
        entry[:label]
      end
    end

    def combine_conn(list)
      return list.first[:label] if list.size == 1

      if list[1..-1].all? { |l| l[:conn] == "and" }
        @i18n.boolean_conj(list.map { |l| loc2xref(l) }, "and")
      elsif list[1..-1].all? { |l| l[:conn] == "or" }
        @i18n.boolean_conj(list.map { |l| loc2xref(l) }, "or")
      else
        ret = loc2xref(list[0])
        list[1..-1].each { |l| ret = i18n_chain_boolean(ret, l) }
        ret
      end
    end

    def i18n_chain_boolean(value, entry)
      @i18n.send("chain_#{entry[:conn]}").sub(/%1/, value)
        .sub(/%2/, loc2xref(entry))
    end

    def can_conflate_xref_rendering?(locs)
      (locs.all? { |l| l[:container].nil? } ||
       locs.all? { |l| l[:container] == locs.first[:container] }) &&
        locs.all? { |l| l[:type] == locs[0][:type] }
    end

    def capitalise_xref(node, linkend, label)
      linktext = linkend.gsub(/<[^>]+>/, "")
      (label && !label.empty? && /^#{Regexp.escape(label)}/.match?(linktext)) ||
        linktext[0, 1].match?(/\p{Upper}/) and return linkend
      node["case"] and
        return Common::case_with_markup(linkend, node["case"], @script)

      capitalise_xref1(node, linkend)
    end

    def capitalise_xref1(node, linkend)
      if start_of_sentence(node)
        Common::case_with_markup(linkend, "capital", @script)
      else linkend
      end
    end
  end
end
