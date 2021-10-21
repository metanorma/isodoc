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

    def related(docxml)
      docxml.xpath(ns("//related")).each { |f| related1(f) }
    end

    def related1(node)
      p = node.at(ns("./preferred"))
      ref = node.at(ns("./xref | ./eref | ./termref"))
      label = Metanorma::Utils
        .strict_capitalize_first(@i18n.relatedterms[node["type"]])
      node.replace(l10n("<p><strong>#{label}:</strong> "\
                        "<em>#{p.to_xml}</em> (#{ref.to_xml})</p>"))
    end

    def designation(docxml)
      docxml.xpath(ns("//preferred | //admitted | //deprecates")).each do |p|
        designation1(p)
      end
      docxml.xpath(ns("//term")).each do |t|
        merge_second_preferred(t)
      end
    end

    def merge_second_preferred(term)
      pref = nil
      term.xpath(ns("./preferred")).each_with_index do |p, i|
        if i.zero? then pref = p
        else
          pref << l10n("; #{p.children.to_xml}")
          p.remove
        end
      end
    end

    def designation1(desgn)
      return unless name = desgn.at(ns("./expression/name"))

      if g = desgn.at(ns("./expression/grammar"))
        name << " #{designation_grammar(g).join(', ')}"
      end
      s = desgn.at(ns("./termsource"))
      desgn.children = name.children
      s and desgn.next = s
    end

    def designation_grammar(grammar)
      ret = []
      grammar.xpath(ns("./gender")).each do |x|
        ret << @i18n.grammar_abbrevs[x.text]
      end
      %w(isPreposition isParticiple isAdjective isVerb isAdverb isNoun)
        .each do |x|
        grammar.at(ns("./#{x}[text() = 'true']")) and
          ret << @i18n.grammar_abbrevs[x]
      end
      ret
    end
  end
end
