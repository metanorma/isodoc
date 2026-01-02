module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def fmt_ref(docxml)
      docxml.xpath(ns("//xref | //eref | //origin | //link")).each do |x|
        sem_xml_descendant?(x) and next
        tag = x.name
        y = Nokogiri::XML::Node.new("fmt-#{tag}", x.document)
        x.attributes.keys.reject { |a| a == "id" }.each { |a| y[a] = x[a] }
        n = semx_fmt_dup(x) # semx/fmt-xref for ease of processing
        n.children.each { |c| y << c }
        n << y
        x.next = n
      end
    end

    def prefix_container(container, linkend, node, target)
      prefix_container?(container, node) or return linkend
      container_container = @xrefs.anchor(container, :container, false)
      container_label =
        prefix_container(container_container,
                         anchor_xref(node, container, container: true),
                         node, target)
      l10n(connectives_spans(@i18n.nested_xref
        .sub("%1", "<span class='fmt-xref-container'>#{esc container_label}</span>")
        .sub("%2", esc(linkend))))
    end

    def anchor_value(id)
      @xrefs.anchor(id, :bare_xref) || @xrefs.anchor(id, :value) ||
        @xrefs.anchor(id, :label) || @xrefs.anchor(id, :xref)
    end

    def anchor_linkend(node, linkend)
      node["style"] == "id" and
        return anchor_id_postproc(node)
      node["style"] && x = @ref_renderings&.dig(node["bibitemid"], :citation,
                                                node["style"].to_sym) and
        return x.strip
      node["citeas"].nil? && node["bibitemid"] and
        return citeas_cleanup(@xrefs.anchor(node["bibitemid"], :xref)) || "???"
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
      linkend = prefix_container(container, linkend, node, node["target"])
      capitalise_xref(node, linkend, anchor_value(node["target"]))
    end

    def anchor_xref(node, target, container: false)
      x = anchor_xref_short(node, target, container)
      t = @xrefs.anchor(target, :title)
      ret = case node["style"]
            when "basic" then t
            when "full" then anchor_xref_full(x, t)
            when "short", nil then x
            else @xrefs.anchor(target, node[:style].to_sym)
            end
      ret || x
    end

    def anchor_xref_short(node, target, container)
      if (l = node["label"]) && !container
        v = anchor_value(target)
        @i18n.l10n(%[<span class="fmt-element-name">#{l}</span> #{esc v}])
      else @xrefs.anchor(target, :xref)
      end
    end

    def anchor_xref_full(num, title)
      (!title.nil? && !title.empty?) or return nil
      l10n("#{num}<span class='fmt-comma'>,</span> #{title}")
    end

    def prefix_container?(container, node)
      node["style"] == "modspec" and return false # TODO: move to mn-requirements?
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
                  out = locs.each do |l|
                    l[:label] = esc(anchor_linkend1(l[:node]))
                  end
                  l10n(combine_conn(out))
                end
      capitalise_xref(node, linkend, anchor_value(node["target"]))
    end

    # Note % to entry and Note % to entry:
    # cannot conflate as Note % to entry 1 and 2
    # So Notes 1 and 3, but Note 1 to entry and Note 3 to entry
    def combine_conflated_xref_locations(locs)
      out = if locs.any? { |l| l[:elem]&.include?("%") }
              locs.each { |l| l[:label] = @xrefs.anchor(l[:target], :xref) }
            else
              conflate_xref_locations(locs)
            end
      combine_conflated_xref_locations_container(locs, l10n(combine_conn(out)))
    end

    def conflate_xref_locations(locs)
      out = locs.each { |l| l[:label] = anchor_value(l[:target]) }
      label = @i18n.inflect(locs.first[:elem], number: "pl")
      out[0][:label] = l10n("#{label} #{esc out[0][:label]}").strip
      out
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
        m << { conn: l["connective"], custom: l["custom-connective"],
               target: l["target"],
               type:, node: l, elem: @xrefs.anchor(l["target"], :elem),
               container: @xrefs.anchor(l["target"], :container, false) ||
                 %w(termnote).include?(type) }
      end
    end

    def loc2xref(entry)
      if entry[:target]
        <<~XML
          <fmt-xref nested='true' target='#{entry[:target]}'>#{entry[:label]}</fmt-xref>
        XML
      else
        entry[:label]
      end
    end

    def combine_conn(list)
      list.size == 1 and list.first[:label]
      if list[1..].all? { |l| l[:conn] == "and" }
        connectives_spans(@i18n.boolean_conj(list.map do |l|
          loc2xref(l)
        end, "and"))
      elsif list[1..].all? { |l| l[:conn] == "or" }
        connectives_spans(@i18n.boolean_conj(list.map do |l|
          loc2xref(l)
        end, "or"))
      else
        ret = loc2xref(list[0])
        list[1..].each { |l| ret = i18n_chain_boolean(ret, l) }
      if list[0][:conn] == "from" && list[0][:custom]
        # TODO: languages with mandatory from, include from in chain_to
        ret = connectives_spans("<conn>#{list[0][:custom]}</conn> ") + ret
      end
        ret
      end
    end

    def conn_sub(str, conn)
       str.sub(%r{<conn>[^<]+</conn>}, "<conn>#{conn}</conn>")
    end

    def i18n_chain_boolean(value, entry)
      ret = @i18n.send("chain_#{entry[:conn]}")
        .sub("%1", value)
        .sub("%2", loc2xref(entry))
      c = entry[:custom] and ret = conn_sub(ret, c)
      connectives_spans(ret)
    end

    def can_conflate_xref_rendering?(locs)
      @i18n.get["no_conflate_xref_locations"] == true and return false
      (locs.all? { |l| l[:container].nil? } ||
       locs.all? { |l| l[:container] == locs.first[:container] }) &&
        locs.all? { |l| l[:type] == locs[0][:type] }
    end

    def capitalise_xref(node, linkend, label)
      linktext = linkend.gsub(/<[^<>]+>/, "")
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
