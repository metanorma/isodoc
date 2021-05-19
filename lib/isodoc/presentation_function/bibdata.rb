module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def bibdata(docxml)
      a = bibdata_current(docxml) or return
      bibdata_i18n(a)
      a.next =
        "<localized-strings>#{i8n_name(trim_hash(@i18n.get), '').join('')}"\
        "</localized-strings>"
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
    end

    def hash_translate(bibdata, hash, xpath, lang = @lang)
      x = bibdata.at(ns(xpath)) or return
      x["language"] = ""
      hash.is_a? Hash or return
      hash[x.text] or return
      x.next = x.dup
      x.next["language"] = lang
      x.next.children = hash[x.text]
    end

    def i18n_tag(k, v)
      "<localized-string key='#{k}' language='#{@lang}'>#{v}</localized-string>"
    end

    def i18n_safe(k)
      k.to_s.gsub(/\s|\./, "_")
    end

    def i8n_name(h, pref)
      if h.is_a? Hash then i8n_name1(h, pref)
      elsif h.is_a? Array
        h.reject { |a| blank?(a) }.each_with_object([])
          .with_index do |(v1, g), i|
          i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
        end
      else [i18n_tag(pref, h)]
      end
    end

    def i8n_name1(h, pref)
      h.reject { |k, v| blank?(v) }.each_with_object([]) do |(k, v), g|
        if v.is_a? Hash then i8n_name(v, i18n_safe(k)).each { |x| g << x }
        elsif v.is_a? Array
          v.reject { |a| blank?(a) }.each_with_index do |v1, i|
            i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
          end
        else
          g << i18n_tag("#{pref}#{pref.empty? ? '' : '.'}#{i18n_safe(k)}", v)
        end
      end
    end

    # https://stackoverflow.com/a/31822406
    def blank?(v)
      v.nil? || v.respond_to?(:empty?) && v.empty?
    end

    def trim_hash(h)
      loop do
        h_new = trim_hash1(h)
        break h if h==h_new

        h = h_new
      end
    end

    def trim_hash1(h)
      return h unless h.is_a? Hash

      h.each_with_object({}) do |(k, v), g|
        next if blank?(v)

        g[k] = if v.is_a? Hash then trim_hash1(h[k])
               elsif v.is_a? Array
                 h[k].map { |a| trim_hash1(a) }.reject { |a| blank?(a) }
               else
                 v
               end
      end
    end
  end
end
