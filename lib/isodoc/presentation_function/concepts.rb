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

    def related(docxml)
      docxml.xpath(ns("//fmt-related/semx")).each { |f| related1(f) }
    end

    def related1(node)
      p, ref, orig = related1_prep(node)
      label = @i18n.relatedterms[orig["type"]].upcase
      ret = "<strong>**RELATED TERM NOT FOUND**</strong>"
      p && ref and ret = "<em>#{to_xml(p)}</em> (#{Common::to_xml(ref)})"
      node.children = (l10n("<p><strong>#{label}:</strong> #{ret}</p>"))
    end

    def related1_prep(node)
      p = node.at(ns("./fmt-preferred"))&.children
      ref = node.at(ns("./xref | ./eref | ./termref"))
      orig = semx_orig(node)
      [p, ref, orig]
    end

    def related_designation1(desgn)
      out = desgn.parent.at(ns("./fmt-#{desgn.name}"))
      d1 = semx_fmt_dup(desgn)
      %w(preferred admitted deprecates).each do |w|
        d = d1.at(ns("./#{w}[last()]")) and d.after("<fmt-#{w}/>")
      end
      out << d1
    end

    def designation(docxml)
      docxml.xpath(ns("//related")).each { |p| related_designation1(p) }
      docxml.xpath(ns("//preferred | //admitted | //deprecates"))
        .each { |p| designation1(p) }
      docxml.xpath(ns("//fmt-preferred | //fmt-admitted | //fmt-deprecates"))
        .each { |t| merge_second_preferred(t) }
      docxml.xpath(ns("//fmt-deprecates")).each { |d| deprecates(d) }
      docxml.xpath(ns("//fmt-admitted")).each { |d| admits(d) }
    end

    def deprecates(elem)
      elem.xpath(ns(".//semx[@element = 'deprecates']")).each do |t|
        t.previous = @i18n.l10n("#{@i18n.deprecated}: ")
      end
    end

    def admits(elem); end

    def merge_second_preferred(term)
      pref = nil
      out = term.xpath(ns("./semx")).each_with_index
        .with_object([]) do |(p, i), m|
        if (i.zero? && (pref = p)) || merge_preferred_eligible?(pref, p)
          m << p
        else p.wrap("<p></p>")
        end
      end
      pref&.replace(merge_second_preferred1(out, term))
    end

    def merge_second_preferred1(desgns, term)
      desgns[1..].each(&:remove)
      ret = l10n(desgns.map { |x| to_xml(x) }.join("; "))
      term.ancestors("fmt-related").empty? and ret = "<p>#{ret}</p>"
      ret
    end

    def merge_preferred_eligible?(first, second)
      orig_first, orig_second, firstex, secondex =
        merge_preferred_eligible_prep(first, second)
      orig_first["geographic-area"] == orig_second["geographic-area"] &&
        firstex["language"] == secondex["language"] &&
        !orig_first.at(ns("./pronunciation | ./grammar | ./graphical-symbol")) &&
        !orig_second.at(ns("./pronunciation | ./grammar | ./graphical-symbol")) &&
        orig_first.name == "preferred" && orig_second.name == "preferred"
    end

    def merge_preferred_eligible_prep(first, second)
      orig_first = semx_orig(first)
      orig_second = semx_orig(second)
      firstex = orig_first.at(ns("./expression")) || {}
      secondex = orig_second.at(ns("./expression")) || {}
      [orig_first, orig_second, firstex, secondex]
    end

    def designation1(desgn)
      desgn.parent.name == "related" and return
      out = desgn.parent.at(ns("./fmt-#{desgn.name}"))
      d1 = semx_fmt_dup(desgn)
      s = d1.at(ns("./source"))
      modification_dup_align(desgn.at(ns("./source")), s)
      name = d1.at(ns("./expression/name | ./letter-symbol/name | " \
                         "./graphical-symbol")) or return
      designation_annotate(d1, name, desgn)
      out << d1
      s and out << s.wrap("<fmt-termsource></fmt-termsource>").parent
    end

    def designation_annotate(desgn, name, orig)
      designation_boldface(desgn)
      designation_field(desgn, name, orig)
      designation_grammar(desgn, name)
      designation_localization(desgn, name, orig)
      designation_pronunciation(desgn, name)
      designation_bookmarks(desgn, name)
      desgn.children = name.children
    end

    def designation_boldface(desgn)
      desgn["element"] == "preferred" or return
      name = desgn.at(ns("./expression/name | ./letter-symbol/name")) or return
      name.children = "<strong>#{name.children}</strong>"
    end

    def designation_field(_desgn, name, orig)
      f = orig.xpath(ns("./field-of-application | ./usage-info"))
        &.map { |u| to_xml(semx_fmt_dup(u)) }&.join(", ")
      f&.empty? and return nil
      name << "<span class='fmt-designation-field'>, &#x3c;#{f}&#x3e;</span>"
    end

    def designation_grammar(desgn, name)
      g = desgn.at(ns("./expression/grammar")) or return
      ret = g.xpath(ns("./gender | ./number")).each_with_object([]) do |x, m|
        m << @i18n.grammar_abbrevs[x.text]
      end
      %w(isPreposition isParticiple isAdjective isVerb isAdverb isNoun)
        .each do |x|
        g.at(ns("./#{x}[text() = 'true']")) and ret << @i18n.grammar_abbrevs[x]
      end
      name << ", #{ret.join(', ')}"
    end

    def designation_localization(desgn, name, orig_desgn)
      loc = [desgn.at(ns("./expression/@language"))&.text,
             desgn.at(ns("./expression/@script"))&.text,
             orig_desgn.at("./@geographic-area")&.text].compact
      loc.empty? and return
      name << ", #{loc.join(' ')}"
    end

    def designation_pronunciation(desgn, name)
      f = desgn.at(ns("./expression/pronunciation")) or return
      name << ", /#{to_xml(f.children)}/"
    end

    def designation_bookmarks(desgn, name)
      desgn.xpath(ns(".//bookmark")).each { |b| name << b.remove }
    end
  end
end
