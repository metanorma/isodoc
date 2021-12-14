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
      concept1_linkmention(ref, r, opts)
      concept1_ref(node, ref, opts)
      if opts[:ital] == "false"
        r = node.at(ns(".//renderterm"))
        r&.replace(r&.children)
      end
      node.replace(node.children)
    end

    def concept1_linkmention(ref, renderterm, opts)
      if opts[:linkmention] == "true" && !renderterm.nil? && !ref.nil?
        ref2 = ref.clone
        r2 = renderterm.clone
        renderterm.replace(ref2).children = r2
      end
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
      label = @i18n.relatedterms[node["type"]].upcase
      node.replace(l10n("<p><strong>#{label}:</strong> "\
                        "<em>#{p.to_xml}</em> (#{ref.to_xml})</p>"))
    end

    def designation(docxml)
      docxml.xpath(ns("//term")).each do |t|
        merge_second_preferred(t)
      end
      docxml.xpath(ns("//preferred | //admitted | //deprecates")).each do |p|
        designation1(p)
      end
    end

    def merge_second_preferred(term)
      pref = nil
      term.xpath(ns("./preferred[expression/name]")).each_with_index do |p, i|
        if i.zero? then pref = p
        elsif merge_preferred_eligible?(pref, p)
          pref.at(ns("./expression/name")) <<
            l10n("; #{p.at(ns('./expression/name')).children.to_xml}")
          p.remove
        end
      end
    end

    def merge_preferred_eligible?(first, second)
      firstex = first.at(ns("./expression")) || {}
      secondex = second.at(ns("./expression")) || {}
      first["geographic-area"] == second["geographic-area"] &&
        firstex["language"] == secondex["language"] &&
        !first.at(ns("./pronunciation | ./grammar")) &&
        !second.at(ns("./pronunciation | ./grammar"))
    end

    def designation1(desgn)
      s = desgn.at(ns("./termsource"))
      name = desgn.at(ns("./expression/name | ./letter-symbol/name | "\
                         "./graphical-symbol")) or return

      designation_annotate(desgn, name)
      s and desgn.next = s
    end

    def designation_annotate(desgn, name)
      designation_boldface(desgn)
      designation_field(desgn, name)
      g = desgn.at(ns("./expression/grammar")) and
        name << ", #{designation_grammar(g).join(', ')}"
      designation_localization(desgn, name)
      designation_pronunciation(desgn, name)
      desgn.children = name.children
    end

    def designation_boldface(desgn)
      desgn.name == "preferred" or return
      name = desgn.at(ns("./expression/name | ./letter-symbol/name")) or return
      name.children = "<strong>#{name.children}</strong>"
    end

    def designation_field(desgn, name)
      f = desgn.xpath(ns("./field-of-application | ./usage-info"))
        &.map { |u| u.children.to_xml }&.join(", ")
      return nil if f&.empty?

      name << ", &#x3c;#{f}&#x3e;"
    end

    def designation_grammar(grammar)
      ret = []
      grammar.xpath(ns("./gender | ./number")).each do |x|
        ret << @i18n.grammar_abbrevs[x.text]
      end
      %w(isPreposition isParticiple isAdjective isVerb isAdverb isNoun)
        .each do |x|
        grammar.at(ns("./#{x}[text() = 'true']")) and
          ret << @i18n.grammar_abbrevs[x]
      end
      ret
    end

    def designation_localization(desgn, name)
      loc = [desgn&.at(ns("./expression/@language"))&.text,
             desgn&.at(ns("./expression/@script"))&.text,
             desgn&.at(ns("./@geographic-area"))&.text].compact
      return if loc.empty?

      name << ", #{loc.join(' ')}"
    end

    def designation_pronunciation(desgn, name)
      f = desgn.at(ns("./expression/pronunciation")) or return

      name << ", /#{f.children.to_xml}/"
    end

    def termexample(docxml)
      docxml.xpath(ns("//termexample")).each do |f|
        example1(f)
      end
    end

    def termnote(docxml)
      docxml.xpath(ns("//termnote")).each do |f|
        termnote1(f)
      end
    end

    # introduce name element
    def termnote1(elem)
      lbl = l10n(@xrefs.anchor(elem["id"], :label) || "???")
      prefix_name(elem, "", lower2cap(lbl), "name")
    end

    def termdefinition(docxml)
      docxml.xpath(ns("//term[definition]")).each do |f|
        termdefinition1(f)
      end
    end

    def termdefinition1(elem)
      unwrap_definition(elem)
      multidef(elem) if elem.xpath(ns("./definition")).size > 1
    end

    def multidef(elem)
      d = elem.at(ns("./definition"))
      d = d.replace("<ol><li>#{d.children.to_xml}</li></ol>").first
      elem.xpath(ns("./definition")).each do |f|
        f = f.replace("<li>#{f.children.to_xml}</li>").first
        d << f
      end
      d.wrap("<definition></definition>")
    end

    def unwrap_definition(elem)
      elem.xpath(ns("./definition")).each do |d|
        %w(verbal-definition non-verbal-representation).each do |e|
          v = d&.at(ns("./#{e}"))
          v&.replace(v.children)
        end
      end
    end

    def termsource(docxml)
      docxml.xpath(ns("//termsource/modification")).each do |f|
        termsource_modification(f)
      end
      docxml.xpath(ns("//termsource")).each do |f|
        termsource1(f)
      end
    end

    def termsource1(elem)
      while elem&.next_element&.name == "termsource"
        elem << "; #{elem.next_element.remove.children.to_xml}"
      end
      elem.children = l10n("[#{@i18n.source}: #{elem.children.to_xml.strip}]")
    end

    def termsource_modification(mod)
      mod.previous_element.next = l10n(", #{@i18n.modified}")
      mod.text.strip.empty? or mod.previous = " &#x2013; "
      mod.elements.size == 1 and
        mod.elements[0].replace(mod.elements[0].children)
      mod.replace(mod.children)
    end
  end
end
