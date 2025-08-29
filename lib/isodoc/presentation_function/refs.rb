require_relative "docid"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def references(docxml)
      bibliography_bibitem_number(docxml)
      @ref_renderings = references_render(docxml)
      docxml.xpath(ns("//references/bibitem")).each do |x|
        bibitem(x, @ref_renderings)
        reference_name(x)
      end
      hidden_items(docxml)
      move_norm_ref_to_sections(docxml)
    end

    def reference_names(docxml)
      docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
        reference_name(ref)
      end
    end

    def reference_name(ref)
      ids = bibitem_ref_code(ref)
      identifiers = render_identifier(ids)
      reference = docid_l10n(identifiers[:metanorma] || identifiers[:sdo] ||
                    identifiers[:ordinal] || identifiers[:doi])
      @xrefs.get[ref["id"]] = { xref: reference }
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

    def references_render(docxml)
      d = docxml.clone
      d.remove_namespaces!
      refs = d.xpath("//references/bibitem").each_with_object([]) do |b, m|
        prep_for_rendering(b)
        m << to_xml(b)
      end.join
      @bibrender.render_all("<references>#{refs}</references>",
                            type: citestyle)
    end

    def prep_for_rendering(bib)
      bib["suppress_identifier"] == true and
        bib.xpath(ns("./docidentifier")).each(&:remove)
      bib["type"] ||= "standard"
    end

    def bibitem(xml, renderings)
      implicit_reference(xml) and xml["hidden"] = "true"
      bibrender_item(xml, renderings)
    end

    def bibrender_item(xml, renderings)
      if (f = xml.at(ns("./formattedref"))) && xml.at(ns("./title")).nil?
        bibrender_formattedref(f, xml)
      else bibrender_relaton(xml, renderings)
      end
    end

    def bibrender_formattedref(formattedref, xml); end

    def bibrender_relaton(xml, renderings)
      f = renderings[xml["id"]][:formattedref] or return
      f &&= "<formattedref>#{f}</formattedref>"
      if x = xml.at(ns("./formattedref"))
        x.replace(f)
      elsif xml.children.empty?
        xml << f
      else
        xml.children.first.previous = f
      end
    end

    def citestyle
      nil
    end

    def bibliography_bibitem_number_skip(bibitem)
      implicit_reference(bibitem) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma']")) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma-ordinal']")) ||
        bibitem["suppress_identifier"] == "true" ||
        bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
    end

    def bibliography_bibitem_number(docxml)
      i = 0
      docxml.xpath(ns("//references")).each do |r|
        r.xpath(ns("./bibitem")).each do |b|
          i = bibliography_bibitem_number1(b, i, r["normative"] == "true")
        end
      end
      reference_names docxml
      bibliography_bibitem_tag(docxml)
    end

    def bibliography_bibitem_number1(bibitem, idx, normative)
      ins = bibliography_bibitem_number_insert_pt(bibitem)
      mn = bibitem.at(ns(".//docidentifier[@type = 'metanorma']")) and
        /^\[?\d+\]?$/.match?(mn.text) and mn.remove # ignore numbers already inserted
      if !bibliography_bibitem_number_skip(bibitem) && (!normative || mn)
        # respect numeric ids in normative only if already inserted
        idx += 1
        ins.next =
          "<docidentifier type='metanorma-ordinal'>[#{idx}]</docidentifier>"
      end
      idx
    end

    def bibliography_bibitem_number_insert_pt(bibitem)
      bibitem.children.empty? and bibitem.add_child(" ")
      unless d = bibitem.at(ns(".//docidentifier"))
        d = bibitem.children.first
        d.previous = " " and return d.previous
      end
      unless ins = d.previous_element
        d.previous = " "
        ins = d.previous
      end
      ins
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
        implicit_reference(b) and next
        b["suppress_identifier"] == "true" and next
        idx += 1 unless b["hidden"]
        insert_biblio_tag(b, idx, !norm, standard?(b))
      end
      idx
    end

    def insert_biblio_tag(bib, ordinal, biblio, standard)
      datefn = date_note_process(bib)
      ids = bibitem_ref_code(bib)
      idents = render_identifier(ids)
      ret = if biblio then biblio_ref_entry_code(ordinal, idents, ids,
                                                 standard, datefn, bib)
            else norm_ref_entry_code(ordinal, idents, ids, standard, datefn,
                                     bib)
            end
      bib << "<biblio-tag>#{ret}</biblio-tag>"
    end

    def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, _bib)
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
    def biblio_ref_entry_code(ordinal, ids, _id, _standard, datefn, _bib)
      # standard and id = nil
      ret = ids[:ordinal] || ids[:metanorma] || "[#{ordinal}]"
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

    # strip any fns in docidentifier before they are extracted for rendering
    def date_note_process(bib)
      ret = ident_fn(bib)
      date_note = bib.at(ns("./note[@type = 'Unpublished-Status']"))
      date_note.nil? and return ret
      id = "_#{UUIDTools::UUID.random_create}"
      @new_ids[id] = nil
      "#{ret}<fn id='#{id}' reference='#{id}'><p>#{date_note.content}</p></fn>"
    end

    def ident_fn(bib)
      ret = bib.at(ns("./docidentifier//fn")) or return ""
      to_xml(ret.remove)
    end

    # reference not to be rendered because it is deemed implicit
    # in the standards environment
    def implicit_reference(bib)
      bib["hidden"] == "true"
    end

    SKIP_DOCID = <<~XPATH.strip.freeze
      @type = 'DOI' or @type = 'doi' or @type = 'ISSN' or @type = 'issn' or @type = 'ISBN' or @type = 'isbn' or starts-with(@type, 'ISSN.') or starts-with(@type, 'ISBN.') or starts-with(@type, 'issn.') or starts-with(@type, 'isbn.')
    XPATH

    def standard?(bib)
      ret = false
      bib.xpath(ns("./docidentifier")).each do |id|
        id["type"].nil? ||
          id.at(".//self::*[#{SKIP_DOCID} or @type = 'metanorma']") and next
        ret = true
      end
      ret
    end
  end
end
