require "csv"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def bibdata(docxml)
      a = bibdata_current(docxml) or return
      address_precompose(a)
      bibdata_i18n(a)
      @xrefs.klass.info docxml, nil
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
      { language: @lang, script: @script, locale: @locale }.each do |k, v|
        a.xpath(ns("./#{k}")).each do |l|
          l.text == v and l["current"] = "true"
        end
      end
      a
    end

    def bibdata_i18n(bib)
      hash_translate(bib, @i18n.get["doctype_dict"], "./ext/doctype",
                     "//presentation-metadata/doctype-alias", @lang)
      hash_translate(bib, @i18n.get["stage_dict"], "./status/stage", nil, @lang)
      hash_translate(bib, @i18n.get["substage_dict"], "./status/substage", nil,
                     @lang)
      edition_translate(bib)
    end

    # translate dest_xpath in bibdata using lookup in hash
    # source text is dest_xpath by default, can be alt_source_xpath if given
    def hash_translate(bibdata, hash, dest_xpath, alt_source_xpath, lang)
      hash.is_a? Hash or return
      x = bibdata.xpath(ns(dest_xpath))
      alt_source_xpath and alt_x = bibdata.at(ns(alt_source_xpath))&.text
      x.each do |d|
        v = hash[alt_x || d.text] and tag_translate(d, lang, v)
      end
    end

    # does not allow %Spellout and %Ordinal in the ordinal expression
    # to be mixed
    def edition_translate(bibdata)
      x = bibdata.at(ns("./edition")) or return
      /^\d+$/.match?(x.text) or return
      @i18n.edition_ordinal or return
      tag_translate(x, @lang, @i18n
        .populate("edition_ordinal", { "var1" => x.text.to_i }))
    end

    def tag_translate(tag, lang, value)
      tag["language"] = ""
      tag.next = tag.dup
      tag.next["language"] = lang
      tag.next.children = value
    end
  end
end
