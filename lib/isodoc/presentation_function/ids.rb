module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def add_id_text
      id = "_#{UUIDTools::UUID.random_create}"
      @new_ids[id] = nil
      %(id="#{id}")
    end

    def add_id(elem)
      elem["id"] and return
      id = "_#{UUIDTools::UUID.random_create}"
      elem["id"] = id
      @new_ids[id] = nil
    end

    def id_validate(docxml)
      add_missing_presxml_id(docxml)
      repeat_id_validate(docxml) # feeds orig_id_cleanup
      orig_id_cleanup(docxml)
      idref_validate(docxml)
      contenthash_id_cleanup(docxml)
    end

    def add_missing_presxml_id(docxml)
      docxml.xpath(ns("//fmt-name | //fmt-title | //fmt-definition | " \
        "//fmt-sourcecode | //fmt-provision")).each do |x|
        add_id(x)
      end
    end

    def repeat_id_validate1(elem)
      if @doc_ids[elem["id"]]
        @log&.add("Anchors", elem,
                  "Anchor #{elem['id']} has already been " \
                  "used at line #{@doc_ids[elem['id']]}", severity: 0)
      end
      @doc_ids[elem["id"]] = elem.line
    end

    def repeat_id_validate(doc)
      @doc_ids = {}
      doc.xpath("//*[@id]").each do |x|
        repeat_id_validate1(x)
      end
    end

    # if have moved a new GUID id to original-id in copying, move it back to id
    def orig_id_cleanup(docxml)
      @doc_orig_ids = {}
      docxml.xpath("//*[@original-id]").each do |x|
        if !@doc_ids[x["original-id"]] && !x["id"]
          x["id"] = x["original-id"]
          x.delete("original-id")
          @doc_ids[x["id"]] = x.line
        else
          @doc_orig_ids[x["original-id"]] = x.line
        end
      end
    end

    def idref_validate(doc)
      @log or return
      Metanorma::Utils::anchor_attributes(presxml: true).each do |e|
        doc.xpath("//xmlns:#{e[0]}[@#{e[1]}]").each do |x|
          idref_validate1(x, e[1])
        end
      end
    end

    def idref_validate1(node, attr)
      node[attr].strip.empty? and return
      @doc_ids[node[attr]] and return
      @doc_orig_ids[node[attr]] and return
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
        "//annotation | //floating-title | //li | //executivesummary | " \
        "//preface/abstract | //foreword | //introduction | //annex | " \
        "//acknowledgements | //clause | //references | //terms | " \
        "//preferred | //deprecates | //admitted | //related")).each do |s|
        add_id(s)
      end
    end

    # do not sanitise "#"
    def to_ncname(ident)
      ret = ident.split("#", 2)
      ret.map { |x| Metanorma::Utils::to_ncname(x) }.join("#")
    end

    def contenthash_id_cleanup(docxml)
      add_new_contenthash_id(docxml, @new_ids)
      xref_new_contenthash_id(docxml, @new_ids)
    end

    def add_new_contenthash_id(docxml, ids)
      suffix = "" # for disambiguation in Metanorma Collections
      docxml["document_suffix"] and suffix = "_#{docxml['document_suffix']}"
      %w(original-id id).each do |k|
        docxml.xpath("//*[@#{k}]").each do |x|
          ids.has_key?(x[k]) or next
          new_id = Metanorma::Utils::contenthash(x) + suffix
          ids[x[k]] = new_id
          x[k] = new_id
        end
      end
    end

    def xref_new_contenthash_id(docxml, ids)
      Metanorma::Utils::anchor_attributes(presxml: true).each do |e|
        docxml.xpath("//xmlns:#{e[0]}[@#{e[1]}]").each do |x|
          ids.has_key?(x[e[1]]) or next
          ids[x[e[1]]] or next
          x[e[1]] = ids[x[e[1]]]
        end
      end
    end
  end
end
