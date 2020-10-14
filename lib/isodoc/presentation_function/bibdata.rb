require "gyoku"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def bibdata(docxml)
      a = docxml.at(ns("//bibdata")) or return
      b = a.dup
      b.name = "local_bibdata"
      bibdata_i18n(b)
      a.next = b
    end

    def bibdata_i18n(b)
      b << "<i18nyaml>#{Gyoku.xml(i8n_name(trim_hash(@i18n.get)))}</i18nyaml>"
      hash_translate(b, @i18n.get["doctype_dict"], "./ext/doctype")
      hash_translate(b, @i18n.get["stage_dict"], "./status/stage")
      hash_translate(b, @i18n.get["substage_dict"], "./status/substage")
    end

    def hash_translate(bibdata, hash, xpath)
      hash.is_a? Hash or return
      x = bibdata.at(ns(xpath)) or return
      hash[x.text] or return
      x.children = hash[x.text]
    end

    def i8n_name(h)
      return h unless h.is_a? Hash
      h.each_with_object({}) do |(k,v), g|
        next if blank?(v)
        g["i18n_#{k.gsub(/\s/, "_")}"] = if v.is_a? Hash then i8n_name(h[k])
                         elsif v.is_a? Array
                           h[k].map { |a| i8n_name(a) }.reject { |a| blank?(a) }
                         else
                           v
                         end
      end
    end

    #https://stackoverflow.com/a/31822406
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
      h.each_with_object({}) do |(k,v), g|
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
