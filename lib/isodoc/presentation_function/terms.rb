module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    DESIGNATION_ELEMS =
      %w(preferred admitted deprecates related definition source).freeze

    def target_desgn_elem(name)
      target = "fmt-#{name}"
      name == "source" and target = "fmt-termsource"
      target
    end

    def termcontainers(docxml)
      docxml.xpath(ns("//term")).each do |t|
        DESIGNATION_ELEMS.each do |w|
          target = target_desgn_elem(w)
          d = t.at(ns("./#{w}[last()]")) and d.after("<#{target}/>")
        end
      end
    end

    def termcleanup(docxml)
      docxml.xpath(ns("//term")).each do |t|
        DESIGNATION_ELEMS.each do |w|
          target = target_desgn_elem(w)
          t.xpath(ns("./#{w}//fmt-name | ./#{w}//fmt-xref-label")).each(&:remove)
          f = t.at(ns(".//#{target}"))
          f&.children&.empty? and f.remove
        end
      end
    end

    def termexample(docxml)
      docxml.xpath(ns("//termexample")).each { |f| example1(f) }
    end

    def termnote(docxml)
      docxml.xpath(ns("//termnote")).each { |f| termnote1(f) }
    end

    def termnote_delim(_elem)
      l10n(": ")
    end

    def termnote1(elem)
      lbl = termnote_label(elem)
      prefix_name(elem, { label: termnote_delim(elem) }, lower2cap(lbl), "name")
    end

    def termnote_label(elem)
      @xrefs.anchor(elem["id"], :label, false) || "???"
    end

    def termdefinition(docxml)
      docxml.xpath(ns("//term[definition]")).each { |f| termdefinition1(f) }
    end

    def termdefinition1(elem)
      d = elem.xpath(ns("./definition"))
      d1 = elem.at(ns("./fmt-definition"))
      if d.size > 1 then multidef(elem, d, d1)
      else singledef(elem, d, d1)
      end
      unwrap_definition(elem, d1)
      s1 = d.xpath(ns(".//source"))
      s2 = d1.xpath(ns(".//source"))
      s1.each_with_index do |s, i|
        modification_dup_align(s, s2[i])
      end
      termdomain(elem, d1)
    end

    def multidef(_elem, defn, fmt_defn)
      ret = defn.each_with_object([]) do |f, m|
        m << "<li #{add_id_text}>#{to_xml(semx_fmt_dup(f))}</li>"
      end
      fmt_defn << "<ol #{add_id_text}>#{ret.join("\n")}</ol>"
    end

    def singledef(_elem, defn, fmt_defn)
      fmt_defn << semx_fmt_dup(defn.first)
    end

    def unwrap_definition(_elem, fmt_defn)
      fmt_defn.xpath(ns(".//semx[@element = 'definition']")).each do |d|
        %w(verbal-definition non-verbal-representation).each do |e|
          v = d&.at(ns("./#{e}"))
          v&.replace(v.children)
        end
      end
    end

    def termdomain(elem, fmt_defn)
      d = elem.at(ns(".//domain")) or return
      p = fmt_defn.at(ns(".//p")) or return
      d1 = semx_fmt_dup(d)
      p.add_first_child "&lt;#{to_xml(d1)}&gt;  "
    end

    def termsource(docxml)
      copy_baselevel_termsource(docxml)
      # TODO should I wrap fmt-definition//termsource in fmt-termsource, in order to preserve termsource attributes?
      # differentiating term and nonterm source under designations is not worth it
      docxml.xpath(ns("//fmt-termsource/source | //fmt-definition//source | //fmt-preferred//source | //fmt-admitted//source | //fmt-deprecates//source"))
        .each do |f|
        termsource_modification(f)
      end
      docxml.xpath(ns("//fmt-preferred//fmt-termsource | //fmt-admitted//fmt-termsource | //fmt-deprecates//fmt-termsource"))
        .each do |f|
          termsource_designation(f)
        end
      docxml.xpath(ns("//fmt-termsource/source | //fmt-definition//source | //fmt-preferred//source | //fmt-admitted//source | //fmt-deprecates//source"))
        .each do |f|
        f.parent and termsource1(f)
      end
    end

    def termsource_designation(fmtsource)
      p = fmtsource.previous_element
      p&.name == "p" or return
      p << " "
      p << fmtsource.children
    end

    def copy_baselevel_termsource(docxml)
      docxml.xpath(ns("//term[source]")).each do |x|
        s = x.xpath(ns("./source"))
        s1 = x.at(ns("./fmt-termsource"))
        s.each do |ss|
          dup = ss.clone
          modification_dup_align(ss, dup)
          s1 << dup
        end
        strip_duplicate_ids(nil, s, s1)
        %w(status type).each { |a| s[0][a] and s1[a] = s[0][a] }
      end
    end

    def modification_dup_align(sem, pres)
      m = sem&.at(ns("./modification")) or return
      m1 = pres.at(ns("./modification"))
      if m["original-id"]
        m["id"] = m["original-id"]
        m.delete("original-id")
      end
      new_m1 = semx_fmt_dup(m)
      m1.replace("<modification>#{to_xml(new_m1)}</modification>")
    end

    def termsource1(elem)
      ret = [semx_fmt_dup(elem)]
      while elem&.next_element&.name == "source"
        ret << semx_fmt_dup(elem.next_element.remove)
      end
      s = ret.map { |x| to_xml(x) }.map(&:strip).join("; ")
      termsource_label(elem, s)
    end

    def termsource_label(elem, sources)
      elem.replace(l10n("[#{@i18n.source}: #{sources}]"))
    end

    def termsource_modification(elem)
      elem.xpath(".//text()[normalize-space() = '']").each(&:remove)
      origin = elem.at(ns("./origin"))
      s = termsource_status(elem["status"]) and origin.next = l10n(", #{s}")
      mod = elem.at(ns("./modification")) or return
      termsource_add_modification_text(mod)
    end

    def termsource_add_modification_text(mod)
      mod or return
      if mod.text.strip.empty?
        mod.remove
        return
      end
      mod.previous = " &#x2014; "
      c = mod.at(ns("./semx")) || mod
      c.elements.size == 1 and c.children = to_xml(c.elements[0].children)
      mod.replace(mod.children)
    end

    def termsource_status(status)
      case status
      when "modified" then @i18n.modified
      when "adapted" then @i18n.adapted
      end
    end

    def term(docxml)
      docxml.xpath(ns("//term")).each { |f| term1(f) }
    end

    def term1(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, {}, "#{lbl}#{clausedelim}", "name")
    end
  end
end
