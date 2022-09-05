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
        m << b.to_xml
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
      if f = xml.at(ns("./formattedref"))
        bibrender_formattedref(f, xml)
      else bibrender_relaton(xml, renderings)
      end
    end

    def bibrender_formattedref(formattedref, xml)
      code = render_identifier(bibitem_ref_code(xml))
      (code[:sdo] && xml["suppress_identifier"] != "true") and
        formattedref << " [#{code[:sdo]}] "
    end

    def bibrender_relaton(xml, renderings)
      f = renderings[xml["id"]][:formattedref]
      f &&= "<formattedref>#{f}</formattedref>"
      xml.children =
        "#{f}#{xml.xpath(ns('./docidentifier | ./uri | ./note')).to_xml}"
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
    end

    def bibliography_bibitem_number1(bibitem, idx)
      ins = bibitem.at(ns(".//docidentifier")).previous_element
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

    def docid_prefixes(docxml)
      docxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
        i.children = @xrefs.klass.docid_prefix(i["type"], i.text)
      end
    end
  end
end
