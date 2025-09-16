module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def concept(docxml)
      @definition_ids = docxml.xpath(ns("//definitions//dt"))
        .each_with_object({}) { |x, m| m[x["id"]] = true }
      docxml.xpath(ns("//concept")).each { |f| concept1(f) }
    end

    def concept1(node)
      node.ancestors("definition, source, related").empty? or return
      xref = node&.at(ns("./semx/fmt-xref/@target"))&.text or
        return concept_render(node, ital: "true", ref: "true", bold: "false",
                                    linkref: "true", linkmention: "false")
      if @definition_ids[xref]
        concept_render(node, ital: "false", ref: "false", bold: "false",
                             linkref: "true", linkmention: "false")
      else concept_render(node, ital: "true", ref: "true", bold: "false",
                                linkref: "true", linkmention: "false")
      end
    end

    def concept_render(node, defaults)
      opts, render, ref, ret = concept_render_init(node, defaults)
      ret&.at(ns("./refterm"))&.remove
      ref && opts[:ref] != "false" and render&.next = " "
      concept1_linkmention(ref, render, opts)
      concept1_ref(ret, ref, opts)
      concept1_style(ret, opts)
      concept_dup(node, ret)
    end

    def concept_dup(node, ret)
      concept_dup_cleanup_orig(node)
      ret.xpath(ns(".//xref | .//eref | .//origin | .//link")).each(&:remove)
      ret.xpath(ns(".//semx")).each do |s|
        s.children.empty? and s.remove
      end
      f = Nokogiri::XML::Node.new("fmt-concept", node.document)
      f << ret
      node.next = f
    end

    def concept_dup_cleanup_orig(node)
      node.xpath(".//xmlns:semx[xmlns:fmt-xref | xmlns:fmt-eref | " \
         "xmlns:fmt-origin | xmlns:fmt-link]").each(&:remove)
      node.xpath(ns(".//xref | .//eref | .//origin | .//link")).each do |x|
        x["original-id"] or next
        x["id"] = x["original-id"]
        x.delete("original-id")
      end
    end

    def concept1_style(node, opts)
      r = node.at(ns(".//renderterm")) or return
      opts[:ital] == "true" and r.children = "<em>#{to_xml(r.children)}</em>"
      opts[:bold] == "true" and
        r.children = "<strong>#{to_xml(r.children)}</strong>"
      r.replace(r.children)
    end

    def concept_render_init(node, defaults)
      opts = concept_render_opts(node, defaults)
      ret = semx_fmt_dup(node)
      ret.children.each { |x| x.text? and x.remove }
      [opts, ret.at(ns("./renderterm")),
       ret.at(ns("./semx/fmt-xref | ./semx/fmt-eref | ./termref")), ret]
    end

    def concept_render_opts(node, defaults)
      %i(bold ital ref linkref linkmention)
        .each_with_object({}) { |x, m| m[x] = node[x.to_s] || defaults[x] }
    end

    def concept1_linkmention(ref, renderterm, opts)
      (opts[:linkmention] == "true" && !renderterm.nil? && !ref.nil?) or return
      ref2 = ref.clone
      r2 = renderterm.clone
      ref2.children = r2
      if ref.parent.name == "semx"
        renderterm.replace(<<~SEMX)
          <semx element='#{ref.parent['element']}' source='#{ref.parent['source']}'>#{to_xml(ref2)}</semx>
        SEMX
      else
        renderterm.replace(ref2)
      end
    end

    def concept1_ref(_node, ref, opts)
      ref.nil? and return
      opts[:ref] == "false" and return ref.remove
      concept1_ref_content(ref)
      %w(fmt-xref fmt-eref).include? ref.name and get_linkend(ref)
      opts[:linkref] == "false" && %w(fmt-xref fmt-eref).include?(ref.name) and
        ref.replace(ref.children)
    end

    def concept1_ref_content(ref)
      prev = "["
      foll = "]"
      non_locality_elems(ref).select do |c|
        !c.text? || /\S/.match(c)
      end.empty? or
        (prev, foll = @i18n.term_defined_in.split("%"))
      ref.previous = prev
      ref.next = foll
    end
  end
end
