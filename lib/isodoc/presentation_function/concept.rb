module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def concept(docxml)
      docxml.xpath(ns("//concept")).each { |f| concept1(f) }
    end

    def concept1(node)
      xref = node&.at(ns("./xref/@target"))&.text or
        return concept_render(node, ital: node["ital"] || "true",
                                    ref: node["ref"] || "true",
                                    linkref: node["linkref"] || "true",
                                    linkmention: node["linkmention"] || "false")
      if node.at(ns("//definitions//dt[@id = '#{xref}']"))
        concept_render(node, ital: node["ital"] || "false",
                             ref: node["ref"] || "false",
                             linkref: node["linkref"] || "true",
                             linkmention: node["linkmention"] || "false")
      else concept_render(node, ital: node["ital"] || "true",
                                ref: node["ref"] || "true",
                                linkref: node["linkref"] || "true",
                                linkmention: node["linkmention"] || "false")
      end
    end

    def concept_render(node, opts)
      node&.at(ns("./refterm"))&.remove
      r = node.at(ns("./renderterm"))
      ref = node.at(ns("./xref | ./eref | ./termref"))
      ref && opts[:ref] != "false" and r&.next = " "
      opts[:ital] == "true" and r&.name = "em"
      if opts[:linkmention] == "true" && !r.nil? && !ref.nil?
        ref2 = ref.clone
        r2 = r.clone
        r.replace(ref2).children = r2
      end
      concept1_ref(node, ref, opts)
      if opts[:ital] == "false"
        r = node.at(ns(".//renderterm"))
        r&.replace(r&.children)
      end
      node.replace(node.children)
    end

    def concept1_ref(_node, ref, opts)
      ref.nil? and return
      return ref.remove if opts[:ref] == "false"

      r = concept1_ref_content(ref)
      ref = r.at("./descendant-or-self::xmlns:xref | "\
                 "./descendant-or-self::xmlns:eref | "\
                 "./descendant-or-self::xmlns:termref")
      %w(xref eref).include? ref&.name and get_linkend(ref)
      if opts[:linkref] == "false" && %w(xref eref).include?(ref&.name)
        ref.replace(ref.children)
      end
    end

    def concept1_ref_content(ref)
      if non_locality_elems(ref).select do |c|
           !c.text? || /\S/.match(c)
         end.empty?
        ref.replace(@i18n.term_defined_in.sub(/%/,
                                              ref.to_xml))
      else ref.replace("[#{ref.to_xml}]")
      end
    end
  end
end
