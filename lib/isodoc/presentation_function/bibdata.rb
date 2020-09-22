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
  end
end
