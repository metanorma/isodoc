require "csv"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def bibdata(docxml)
      toc_metadata(docxml)
      fonts_metadata(docxml)
      docid_prefixes(docxml)
      a = bibdata_current(docxml) or return
      address_precompose(a)
      bibdata_i18n(a)
      a.next =
        "<localized-strings>#{i8n_name(trim_hash(@i18n.get), '').join}" \
        "</localized-strings>"
    end

    def toc_metadata(docxml)
      return unless @tocfigures || @toctables || @tocrecommendations

      ins = docxml.at(ns("//metanorma-extension")) ||
        docxml.at(ns("//bibdata")).after("<metanorma-extension/>").next_element
      @tocfigures and
        ins << "<toc type='figure'><title>#{@i18n.toc_figures}</title></toc>"
      @toctables and
        ins << "<toc type='table'><title>#{@i18n.toc_tables}</title></toc>"
      @tocfigures and
        ins << "<toc type='recommendation'><title>#{@i18n.toc_recommendations}" \
               "</title></toc>"
    end

    def address_precompose(bib)
      bib.xpath(ns("//bibdata//address")).each do |b|
        next if b.at(ns("./formattedAddress"))

        x = address_precompose1(b)
        b.children = "<formattedAddress>#{x}</formattedAddress>"
      end
    end

    def fonts_metadata(xmldoc)
      return unless @fontist_fonts

      ins = xmldoc.at(ns("//presentation-metadata")) ||
        xmldoc.at(ns("//metanorma-extension")) || xmldoc.at(ns("//bibdata"))
      CSV.parse_line(@fontist_fonts, col_sep: ";").map(&:strip).each do |f|
        ins.next = presmeta("fonts", f)
      end
      @fontlicenseagreement and
        ins.next = presmeta("font-license-agreement", @fontlicenseagreement)
    end

    def presmeta(name, value)
      "<presentation-metadata><name>#{name}</name><value>#{value}</value>" \
        "</presentation-metadata>"
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

    # does not allow %Spellout and %Ordinal in the ordinal expression to be mixed
    def edition_translate(bibdata)
      x = bibdata.at(ns("./edition")) or return
      /^\d+$/.match?(x.text) or return
      tag_translate(x, @lang,
                    @i18n.edition_ordinal.sub(/%(Spellout|Ordinal)?/,
                                              edition_translate1(x.text.to_i)))
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

    def i18n_tag(key, value)
      "<localized-string key='#{key}' language='#{@lang}'>#{value}" \
        "</localized-string>"
    end

    def i18n_safe(key)
      key.to_s.gsub(/\s|\./, "_")
    end

    def i8n_name(hash, pref)
      case hash
      when Hash then i8n_name1(hash, pref)
      when Array
        hash.reject { |a| blank?(a) }.each_with_object([])
          .with_index do |(v1, g), i|
          i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
        end
      else [i18n_tag(pref, hash)]
      end
    end

    def i8n_name1(hash, pref)
      hash.reject { |_k, v| blank?(v) }.each_with_object([]) do |(k, v), g|
        case v
        when Hash then i8n_name(v, i18n_safe(k)).each { |x| g << x }
        when Array
          v.reject { |a| blank?(a) }.each_with_index do |v1, i|
            i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
          end
        else
          g << i18n_tag("#{pref}#{pref.empty? ? '' : '.'}#{i18n_safe(k)}", v)
        end
      end
    end

    # https://stackoverflow.com/a/31822406
    def blank?(elem)
      elem.nil? || (elem.respond_to?(:empty?) && elem.empty?)
    end

    def trim_hash(hash)
      loop do
        h_new = trim_hash1(hash)
        break hash if hash == h_new

        hash = h_new
      end
    end

    def trim_hash1(hash)
      return hash unless hash.is_a? Hash

      hash.each_with_object({}) do |(k, v), g|
        next if blank?(v)

        g[k] = case v
               when Hash then trim_hash1(hash[k])
               when Array
                 hash[k].map { |a| trim_hash1(a) }.reject { |a| blank?(a) }
               else v
               end
      end
    end
  end
end
