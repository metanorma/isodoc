require_relative "../../relaton/render/general"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def references(docxml)
      bibliography_bibitem_number(docxml)
      renderings = references_render(docxml)
      docxml.xpath(ns("//references/bibitem")).each do |x|
        bibitem(x, renderings)
      end
      docxml.xpath(ns("//references[bibitem/@hidden = 'true']")).each do |x|
        x.at(ns("./bibitem[not(@hidden = 'true')]")) and next
        x["hidden"] = "true"
      end
      @xrefs.parse_inclusions(refs: true).parse(docxml)
    end

    def references_render(docxml)
      d = docxml.clone
      d.remove_namespaces!
      refs = d.xpath("//references/bibitem").each_with_object([]) do |b, m|
        prep_for_rendering(b)
        m << to_xml(b)
      end.join
      bibrenderer.render_all("<references>#{refs}</references>",
                             type: citestyle)
    end

    def prep_for_rendering(bib)
      bib["suppress_identifier"] == true and
        bib.xpath(ns("./docidentifier")).each(&:remove)
      bib["type"] ||= "standard"
    end

    def bibitem(xml, renderings)
      @xrefs.klass.implicit_reference(xml) and xml["hidden"] = "true"
      bibrender(xml, renderings)
    end

    def bibrender(xml, renderings)
      if (f = xml.at(ns("./formattedref"))) && xml.at(ns("./title")).nil?
        bibrender_formattedref(f, xml)
      else bibrender_relaton(xml, renderings)
      end
    end

    def bibrender_formattedref(formattedref, xml); end

    def bibrender_relaton(xml, renderings)
      f = renderings[xml["id"]][:formattedref]
      f &&= "<formattedref>#{f}</formattedref>"
      x = xml.xpath(ns("./docidentifier | ./uri | ./note | ./biblio-tag"))
      xml.children = "#{f}#{x.to_xml}"
    end

    def bibrenderer
      ::Relaton::Render::IsoDoc::General.new(language: @lang)
    end

    def citestyle
      nil
    end

    def bibliography_bibitem_number_skip(bibitem)
      @xrefs.klass.implicit_reference(bibitem) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma']")) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma-ordinal']")) ||
        bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
    end

    def bibliography_bibitem_number(docxml)
      i = 0
      docxml.xpath(ns("//references[@normative = 'false']/bibitem")).each do |b|
        i = bibliography_bibitem_number1(b, i)
      end
      @xrefs.references docxml
      bibliography_bibitem_tag(docxml)
    end

    def bibliography_bibitem_number1(bibitem, idx)
      ins = bibliography_bibitem_number_insert_pt(bibitem)
      mn = bibitem.at(ns(".//docidentifier[@type = 'metanorma']")) and
        /^\[?\d+\]?$/.match?(mn.text) and
        mn.remove # ignore numbers already inserted
      unless bibliography_bibitem_number_skip(bibitem)
        idx += 1
        ins.next =
          "<docidentifier type='metanorma-ordinal'>[#{idx}]</docidentifier>"
      end
      idx
    end

    def bibliography_bibitem_number_insert_pt(bibitem)
      unless ins = bibitem.at(ns(".//docidentifier")).previous_element
        bibitem.at(ns(".//docidentifier")).previous = " "
        ins = bibitem.at(ns(".//docidentifier")).previous
      end
      ins
    end

    def docid_prefixes(docxml)
      docxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
        i.children = @xrefs.klass.docid_prefix(i["type"], i.text)
      end
    end

    def bibliography_bibitem_tag(docxml)
      [true, false].each do |norm|
        i = 0
        docxml.xpath(ns("//references[@normative = '#{norm}']")).each do |r|
          i = bibliography_bibitem_tag1(r, i, norm)
        end
      end
    end

    def bibliography_bibitem_tag1(ref, idx, norm)
      ref.xpath(ns("./bibitem")).each do |b|
        @xrefs.klass.implicit_reference(b) and next
        idx += 1 unless b["hidden"]
        insert_biblio_tag(b, idx, !norm, @xrefs.klass.standard?(b))
      end
      idx
    end

    def insert_biblio_tag(bib, ordinal, biblio, standard)
      ids = @xrefs.klass.bibitem_ref_code(bib)
      idents = @xrefs.klass.render_identifier(ids)
      datefn = date_note_process(bib)
      ret = if biblio then biblio_ref_entry_code(ordinal, idents, ids,
                                                 standard, datefn)
            else norm_ref_entry_code(ordinal, idents, ids, standard, datefn)
            end
      bib << "<biblio-tag>#{ret}</biblio-tag>"
    end

    def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn)
      ret = (idents[:ordinal] || idents[:metanorma] || idents[:sdo]).to_s
      (idents[:ordinal] || idents[:metanorma]) && idents[:sdo] and
        ret += ", #{idents[:sdo]}"
      ret += datefn
      ret.empty? and return ret
      idents[:sdo] and ret += ","
      "#{ret} "
    end

    # if ids is just a number, only use that ([1] Non-Standard)
    # else, use both ordinal, as prefix, and ids
    def biblio_ref_entry_code(ordinal, ids, _id, standard, datefn)
      standard and id = nil
      ret = (ids[:ordinal] || ids[:metanorma] || "[#{ordinal}]")
      if ids[:sdo]
        ret = prefix_bracketed_ref(ret)
        ret += "#{ids[:sdo]}#{datefn}, "
      else
        ret = prefix_bracketed_ref("#{ret}#{datefn}")
      end
      ret
    end

    def prefix_bracketed_ref(text)
      "#{text}<tab/>"
    end

    def date_note_process(bib)
      date_note = bib.at(ns("./note[@type = 'Unpublished-Status']"))
      date_note.nil? and return ""
      id = UUIDTools::UUID.random_create.to_s
      "<fn reference='#{id}'><p>#{date_note.content}</p></fn>"
    end
  end
end
