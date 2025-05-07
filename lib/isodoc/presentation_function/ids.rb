module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def id_validate(docxml)
      repeat_id_validate(docxml)
      idref_validate(docxml)
    end

    def repeat_id_validate1(elem)
      if @doc_ids[elem["id"]]
        @log.add("Anchors", elem,
                 "Anchor #{elem['id']} has already been " \
                 "used at line #{@doc_ids[elem['id']]}", severity: 0)
      end
      @doc_ids[elem["id"]] = elem.line
    end

    def repeat_id_validate(doc)
      @log or return
      @doc_ids = {}
      doc.xpath("//*[@id]").each do |x|
        repeat_id_validate1(x)
      end
    end

    def idref_validate(doc)
      @log or return
      doc.xpath("//*[@original-id]").each do |x|
        @doc_ids[x["original-id"]] = x.line
      end
      Metanorma::Utils::anchor_attributes(presxml: true).each do |e|
        doc.xpath("//xmlns:#{e[0]}[@#{e[1]}]").each do |x|
          idref_validate1(x, e[1])
        end
      end
    end

    def idref_validate1(node, attr)
      node[attr].strip.empty? and return
      @doc_ids[node[attr]] and return
      @log.add("Anchors", node,
               "Anchor #{node[attr]} pointed to by #{node.name} " \
               "is not defined in the document", severity: 1)
    end

    def provide_ids(docxml)
      anchor_sanitise(docxml)
      populate_id(docxml)
      add_missing_id(docxml)
    end

    def anchor_sanitise(docxml)
      Metanorma::Utils::anchor_attributes.each do |a|
        docxml.xpath("//xmlns:#{a[0]}").each do |x|
          x[a[1]] &&= to_ncname(x[a[1]])
        end
      end
    end

    def populate_id(docxml)
      docxml.xpath("//*[@id]").each do |x|
        x["semx-id"] = x["id"]
        x["anchor"] and x["id"] = to_ncname(x["anchor"])
      end
    end

    def add_missing_id(docxml)
      docxml.xpath(ns("//source | //modification | //erefstack | //fn | " \
        "//review | //floating-title")).each do |s|
        s["id"] ||= "_#{UUIDTools::UUID.random_create}"
      end
    end

    # do not sanitise "#"
    def to_ncname(ident)
      ret = ident.split("#", 2)
      ret.map { |x| Metanorma::Utils::to_ncname(x) }.join("#")
    end
  end
end
