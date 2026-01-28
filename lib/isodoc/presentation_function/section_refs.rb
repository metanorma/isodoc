module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def references(docxml)
      @ref_renderings = references_render(docxml)
      docxml.xpath(ns("//references/bibitem")).each do |x|
        bibitem(x, @ref_renderings)
        reference_name(x)
      end
      bibliography_bibitem_number(docxml)
      hidden_items(docxml)
      move_norm_ref_to_sections(docxml)
    end

    def reference_names(docxml)
      docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
        reference_name(ref)
      end
    end

    def reference_name(ref)
      identifiers = render_identifier(bibitem_ref_code(ref))
      reference = docid_l10n(identifiers[:content] || identifiers[:metanorma] ||
                             identifiers[:sdo] || identifiers[:ordinal] ||
                             identifiers[:doi])
      @xrefs.get[ref["id"]] = { xref: esc(reference), type: "bibitem" }
    end

    def move_norm_ref_to_sections(docxml)
      docxml.at(ns(@xrefs.klass.norm_ref_xpath)) or return
      s = move_norm_ref_to_sections_insert_pt(docxml) or return
      docxml.xpath(ns(@xrefs.klass.norm_ref_xpath)).each do |r|
        r.at("./ancestor::xmlns:bibliography") or next
        s << r.remove
      end
    end

    def move_norm_ref_to_sections_insert_pt(docxml)
      s = docxml.at(ns("//sections")) and return s
      s = docxml.at(ns("//preface")) and
        return s.after("<sections/>").next_element
      docxml.at(ns("//annex | //bibliography"))&.before("<sections/>")
        &.previous_element
    end

    def hidden_items(docxml)
      docxml.xpath(ns("//references[bibitem/@hidden = 'true']")).each do |x|
        x.at(ns("./bibitem[not(@hidden = 'true')]")) and next
        x.elements.map(&:name).any? do |n|
          !%w(title bibitem).include?(n)
        end and next
        x["hidden"] = "true"
      end
    end
  end
end
