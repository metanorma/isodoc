module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def concept(docxml)
      @definition_ids = docxml.xpath(ns("//definitions//dt"))
        .each_with_object({}) { |x, m| m[x["id"]] = true }
      docxml.xpath(ns("//concept")).each { |f| concept1(f) }
    end

    def concept1(node)
      xref = node&.at(ns("./xref/@target"))&.text or
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
      opts, render, ref = concept_render_init(node, defaults)
      node&.at(ns("./refterm"))&.remove
      ref && opts[:ref] != "false" and render&.next = " "
      concept1_linkmention(ref, render, opts)
      concept1_ref(node, ref, opts)
      concept1_style(node, opts)
      node.replace(node.children)
    end

    def concept1_style(node, opts)
      r = node.at(ns(".//renderterm")) or return
      opts[:ital] == "true" and r.children = "<em>#{to_xml(r.children)}</em>"
      opts[:bold] == "true" and
        r.children = "<strong>#{to_xml(r.children)}</strong>"
      r.replace(r.children)
    end

    def concept_render_init(node, defaults)
      opts = %i(bold ital ref linkref linkmention)
        .each_with_object({}) { |x, m| m[x] = node[x.to_s] || defaults[x] }
      [opts, node.at(ns("./renderterm")),
       node.at(ns("./xref | ./eref | ./termref"))]
    end

    def concept1_linkmention(ref, renderterm, opts)
      (opts[:linkmention] == "true" && !renderterm.nil? && !ref.nil?) or return
      ref2 = ref.clone
      r2 = renderterm.clone
      renderterm.replace(ref2).children = r2
    end

    def concept1_ref(_node, ref, opts)
      ref.nil? and return
      opts[:ref] == "false" and return ref.remove
      concept1_ref_content(ref)
      %w(xref eref).include? ref.name and get_linkend(ref)
      opts[:linkref] == "false" && %w(xref eref).include?(ref.name) and
        ref.replace(ref.children)
    end

    def concept1_ref_content(ref)
      prev = "["
      foll = "]"
      non_locality_elems(ref).select do |c|
        !c.text? || /\S/.match(c)
      end.empty? and
        (prev, foll = @i18n.term_defined_in.split("%"))
      ref.previous = prev
      ref.next = foll
    end

    def related(docxml)
      docxml.xpath(ns("//related")).each { |f| related1(f) }
    end

    def related1(node)
      p = node.at(ns("./preferred"))
      ref = node.at(ns("./xref | ./eref | ./termref"))
      label = @i18n.relatedterms[node["type"]].upcase
      if p && ref
        node.replace(l10n("<p><strong>#{label}:</strong> " \
                          "<em>#{to_xml(p)}</em> (#{Common::to_xml(ref)})</p>"))
      else
        node.replace(l10n("<p><strong>#{label}:</strong> " \
                          "<strong>**RELATED TERM NOT FOUND**</strong></p>"))
      end
    end
  end
end
