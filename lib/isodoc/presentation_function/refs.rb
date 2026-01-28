module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def references_render(docxml)
      d = docxml.clone
      d.remove_namespaces!
      refs = d.xpath("//references/bibitem").each_with_object([]) do |b, m|
        prep_for_rendering(b)
        m << to_xml(b)
      end.join
      @bibrender.render_all("<references>#{refs}</references>")
    end

    def prep_for_rendering(bib)
      bib["suppress_identifier"] == true and
        bib.xpath(ns("./docidentifier")).each(&:remove)
      bib["type"] ||= "standard"
    end

    def bibitem(bib, renderings)
      implicit_reference(bib) and bib["hidden"] = "true"
      notes_inside_bibitem(bib)
      bibrender_item(bib, renderings)
      add_id_to_display_bib_notes(bib)
      @xrefs.bibitem_note_names(bib)
    end

    def notes_inside_bibitem(bib)
      while (n = bib.next_element) && n.name == "note"
        n["type"] = (n["type"] ? "display,#{n['type']}" : "display")
        bib << n.remove
      end
    end

    def add_id_to_display_bib_notes(bib)
      bib.xpath(ns("./note")).each do |n|
        t = n["type"] or next
        t.split(",").map(&:strip).include?("display") or next
        add_id(n)
      end
    end

    def bibrender_item(bib, renderings)
      if (f = bib.at(ns("./formattedref"))) && bib.at(ns("./title")).nil?
        bibrender_formattedref(f, bib)
      else bibrender_relaton(bib, renderings)
      end
      bibitem_notes(bib)
    end

    def bibrender_formattedref(formattedref, bib); end

    def bibrender_relaton(bib, renderings)
      f = renderings[bib["id"]][:formattedref] or return
      f &&= "<formattedref>#{f}</formattedref>"
      if x = bib.at(ns("./formattedref"))
        x.replace(f)
      elsif bib.children.empty?
        bib << f
      else
        bib.children.first.previous = f
      end
    end

    def bibitem_notes(bib)
      f = bib.at(ns("./formattedref")) or return
      bibnote_extract(bib, "display").each do |n|
        f << <<~XML
          <note type='display'>#{to_xml(semx_fmt_dup(n))}</note>
        XML
        transfer_id(n, f.elements.last)
      end
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
      ret = if biblio then biblio_ref_entry_code(ordinal, idents,
                                                 standard, datefn, bib)
            else norm_ref_entry_code(ordinal, idents, standard, datefn, bib)
            end
      bib.add_first_child("<biblio-tag>#{@i18n.l10n(ret)}</biblio-tag>")
    end

    def norm_ref_entry_code(_ordinal, ids, _standard, datefn, _bib)
      ret = esc((ids[:ordinal] || ids[:content] || ids[:metanorma] || ids[:sdo])
        .to_s)
      (ids[:ordinal] || ids[:metanorma]) && ids[:sdo] and
        ret += ", #{esc ids[:sdo]}"
      ret += datefn
      ret.empty? and return ret
      ids[:sdo] and ret += ","
      ret.sub(",", "").strip.empty? and return ""
      "#{ret} "
    end

    # if ids is just a number, only use that ([1] Non-Standard)
    # else, use both ordinal, as prefix, and ids
    def biblio_ref_entry_code(ordinal, ids, _standard, datefn, _bib)
      ret = esc(ids[:ordinal]) || esc(ids[:content]) || esc(ids[:metanorma]) ||
        "[#{esc ordinal.to_s}]"
      if ids[:sdo] && !ids[:sdo].empty?
        ret = prefix_bracketed_ref(ret)
        ret += "#{esc ids[:sdo]}#{datefn}, "
      else
        ret = prefix_bracketed_ref("#{ret}#{datefn}")
      end
      ret
    end

    def prefix_bracketed_ref(text)
      "#{text}<tab/>"
    end

    def bibnote_extract(bib, type)
      bib.xpath(ns("./note")).each_with_object([]) do |n, m|
        n["type"] or next
        n["type"].split(",").map(&:strip).include?(type) and m << n
      end
    end

    # strip any fns in docidentifier before they are extracted for rendering
    def date_note_process(bib)
      ret = ident_fn(bib)
      date_note = bibnote_extract(bib, "Unpublished-Status")
      date_note.empty? and return ret
      id = "_#{UUIDTools::UUID.random_create}"
      @new_ids[id] = nil
      <<~XML
        #{ret}<fn id='#{id}' reference='#{id}'><p>#{date_note.first.content}</p></fn>
      XML
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

    # DOI, ISSN, ISBN cover term
    SERIAL_NUM_DOCID = <<~XPATH.strip.freeze
      @type = 'DOI' or @type = 'doi' or @type = 'ISSN' or @type = 'issn' or @type = 'ISBN' or @type = 'isbn' or starts-with(@type, 'ISSN.') or starts-with(@type, 'ISBN.') or starts-with(@type, 'issn.') or starts-with(@type, 'isbn.')
    XPATH

    def standard?(bib)
      ret = false
      bib.xpath(ns("./docidentifier")).each do |id|
        id["type"].nil? || id.at(".//self::*[#{SERIAL_NUM_DOCID} or "\
          "@type = 'metanorma']") and next
        ret = true
      end
      ret
    end
  end
end
