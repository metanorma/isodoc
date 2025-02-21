module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def footnote_collect(fnotes)
      seen = {}
      ret = fnotes.each_with_object([]) do |x, m|
        x["id"] ||= "_#{UUIDTools::UUID.random_create}"
        seen[x["reference"]] or m << fnbody(x, seen)
        x["target"] = seen[x["reference"]]
      end
      footnote_container(fnotes, ret)
    end

    def footnote_container(fnotes, fnbodies)
      fnbodies.empty? and return
      ctr = Nokogiri::XML::Node.new("fmt-footnote-container",
                                    fnotes.first.document)
      fnbodies.each { |x| ctr << x }
      ctr
    end

    def fnbody(fnote, seen)
      body = Nokogiri::XML::Node.new("fmt-fn-body", fnote.document)
      body["id"] = "_#{UUIDTools::UUID.random_create}"
      body["target"] = fnote["id"]
      body["reference"] = fnote["reference"]
      body << semx_fmt_dup(fnote)
      insert_fn_ref(fnote, body)
      seen[fnote["reference"]] = body["id"]
      body
    end

    def insert_fn_ref(fnote, body)
      ins = body.at(ns(".//p")) ||
        body.at(ns("./semx")).children.first.before("<p> </p>").previous
      lbl = fn_label(fnote)
      ins.children.first.previous = <<~FNOTE
        <span class="fmt-footnote-label"><sup>#{lbl}</sup><span class="fmt-caption-delim"><tab/></span>
      FNOTE
    end

    def fn_label(fnote)
      <<~FNOTE
        <semx element="autonum" source="#{fnote['id']}">#{fnote['reference']}</semx>
      FNOTE
    end

    def table_fn(elem)
      fns = footnote_collect((elem.xpath(ns(".//fn")) -
                              elem.xpath(ns("./name//fn")))) and
        elem << fns
    end

    def document_footnotes(docxml)
      fns = docxml.xpath(ns("//fn"))
      table_fns = docxml.xpath(ns("//table//fn")) - docxml.xpath(ns("//table/name//fn"))
      fig_fns = docxml.xpath(ns("//figure//fn")) - docxml.xpath(ns("//figure/name//fn"))
      fns = footnote_collect(fns - table_fns - fig_fns)
      if fns
        docxml.root << fns
      end
    end
  end
end
