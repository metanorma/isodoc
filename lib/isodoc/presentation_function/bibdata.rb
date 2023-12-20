require "csv"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def bibdata(docxml)
      docid_prefixes(docxml)
      a = bibdata_current(docxml) or return
      address_precompose(a)
      bibdata_i18n(a)
    end

    def address_precompose(bib)
      bib.xpath(ns("//bibdata//address")).each do |b|
        next if b.at(ns("./formattedAddress"))

        x = address_precompose1(b)
        b.children = "<formattedAddress>#{x}</formattedAddress>"
      end
    end

    def address_precompose1(addr)
      ret = []
      addr.xpath(ns("./street")).each { |s| ret << to_xml(s.children) }
      a = addr.at(ns("./city")) and ret << to_xml(a.children)
      addr.xpath(ns("./state")).each { |s| ret << to_xml(s.children) }
      a = addr.at(ns("./country")) and ret << to_xml(a.children)
      a = addr.at(ns("./postcode")) and ret[-1] += " #{to_xml a.children}"
      ret.join("<br/>")
    end

    def bibdata_current(docxml)
      a = docxml.at(ns("//bibdata")) or return
      a.xpath(ns("./language")).each do |l|
        l.text == @lang and l["current"] = "true"
      end
      a.xpath(ns("./script")).each do |l|
        l.text == @script and l["current"] = "true"
      end
      a
    end

    def bibdata_i18n(bib)
      hash_translate(bib, @i18n.get["doctype_dict"], "./ext/doctype")
      hash_translate(bib, @i18n.get["stage_dict"], "./status/stage")
      hash_translate(bib, @i18n.get["substage_dict"], "./status/substage")
      edition_translate(bib)
    end

    def hash_translate(bibdata, hash, xpath, lang = @lang)
      x = bibdata.at(ns(xpath)) or return
      hash.is_a? Hash or return
      hash[x.text] or return
      tag_translate(x, lang, hash[x.text])
    end

    # does not allow %Spellout and %Ordinal in the ordinal expression
    # to be mixed
    def edition_translate(bibdata)
      x = bibdata.at(ns("./edition")) or return
      /^\d+$/.match?(x.text) or return
      @i18n.edition_ordinal or return
      edn = edition_translate1(x.text.to_i) or return
      tag_translate(x, @lang,
                    @i18n.edition_ordinal.sub(/%(Spellout|Ordinal)?/, edn))
    end

    def edition_translate1(num)
      ruleset = case @i18n.edition_ordinal
                when /%Spellout/ then "SpelloutRules"
                when /%Ordinal/ then "OrdinalRules"
                else "Digit"
                end
      ruleset == "Digit" and return num.to_s
      ed = @c.decode(@i18n.edition)
      @i18n.inflect_ordinal(num, @i18n.inflection&.dig(ed) || {},
                            ruleset)
    end

    def tag_translate(tag, lang, value)
      tag["language"] = ""
      tag.next = tag.dup
      tag.next["language"] = lang
      tag.next.children = value
    end
  end
end
