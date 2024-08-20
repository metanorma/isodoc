module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def designation(docxml)
      docxml.xpath(ns("//term")).each { |t| merge_second_preferred(t) }
      docxml.xpath(ns("//preferred | //admitted | //deprecates"))
        .each { |p| designation1(p) }
      docxml.xpath(ns("//deprecates")).each { |d| deprecates(d) }
      docxml.xpath(ns("//admitted")).each { |d| admits(d) }
    end

    def deprecates(elem)
      #elem.children.first.previous = @i18n.l10n("#{@i18n.deprecated}: ")
      elem.add_first_child @i18n.l10n("#{@i18n.deprecated}: ")
    end

    def admits(elem); end

    def merge_second_preferred(term)
      pref = nil
      term.xpath(ns("./preferred[expression/name]")).each_with_index do |p, i|
        (i.zero? and pref = p) or merge_second_preferred1(pref, p)
      end
    end

    def merge_second_preferred1(pref, second)
      merge_preferred_eligible?(pref, second) or return
      n1 = pref.at(ns("./expression/name"))
      n2 = second.remove.at(ns("./expression/name"))
      n1.children = l10n("#{to_xml(n1.children)}; #{Common::to_xml(n2.children)}")
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
      name = desgn.at(ns("./expression/name | ./letter-symbol/name | " \
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
      designation_bookmarks(desgn, name)
      desgn.children = name.children
    end

    def designation_boldface(desgn)
      desgn.name == "preferred" or return
      name = desgn.at(ns("./expression/name | ./letter-symbol/name")) or return
      name.children = "<strong>#{name.children}</strong>"
    end

    def designation_field(desgn, name)
      f = desgn.xpath(ns("./field-of-application | ./usage-info"))
        &.map { |u| to_xml(u.children) }&.join(", ")
      f&.empty? and return nil
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
      loc.empty? and return
      name << ", #{loc.join(' ')}"
    end

    def designation_pronunciation(desgn, name)
      f = desgn.at(ns("./expression/pronunciation")) or return
      name << ", /#{to_xml(f.children)}/"
    end

    def designation_bookmarks(desgn, name)
      desgn.xpath(ns(".//bookmark")).each do |b|
        name << b.remove
      end
    end

    def termexample(docxml)
      docxml.xpath(ns("//termexample")).each { |f| example1(f) }
    end

    def termnote(docxml)
      docxml.xpath(ns("//termnote")).each { |f| termnote1(f) }
    end

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
      d = d.replace("<ol><li>#{to_xml(d.children)}</li></ol>").first
      elem.xpath(ns("./definition")).each do |f|
        f = f.replace("<li>#{to_xml(f.children)}</li>").first
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
      docxml.xpath(ns("//termsource")).each { |f| termsource_modification(f) }
      docxml.xpath(ns("//termsource")).each { |f| termsource1(f) }
    end

    def termsource1(elem)
      while elem&.next_element&.name == "termsource"
        elem << "; #{to_xml(elem.next_element.remove.children)}"
      end
      elem.children = l10n("[#{@i18n.source}: #{to_xml(elem.children).strip}]")
    end

    def termsource_modification(elem)
      origin = elem.at(ns("./origin"))
      s = termsource_status(elem["status"]) and origin.next = l10n(", #{s}")
      termsource_add_modification_text(elem.at(ns("./modification")))
    end

    def termsource_add_modification_text(mod)
      mod or return
      mod.text.strip.empty? or mod.previous = " &#x2014; "
      mod.elements.size == 1 and
        mod.elements[0].replace(mod.elements[0].children)
      mod.replace(mod.children)
    end

    def termsource_status(status)
      case status
      when "modified" then @i18n.modified
      when "adapted" then @i18n.adapted
      end
    end
  end
end
