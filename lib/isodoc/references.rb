module IsoDoc
  class Convert
    def iso_bibitem_ref_code(b)
      isocode = b.at(ns("./docidentifier"))
      isodate = b.at(ns("./date[@type = 'published']"))
      reference = isocode.text
      reference += ": #{isodate.text}" if isodate
      reference
    end

    def date_note_process(b, ref)
      date_note = b.at(ns("./note[text()][contains(.,'ISO DATE:')]"))
      return if date_note.nil?
      date_note.content = date_note.content.gsub(/ISO DATE: /, "")
      date_note.children.first.replace("<p>#{date_note.content}</p>")
      footnote_parse(date_note, ref)
    end

    def iso_bibitem_entry_attrs(b, biblio)
      { id: b["id"], class: biblio ? "Biblio" : nil }
    end

    def iso_bibitem_entry(list, b, ordinal, biblio)
      list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
        if biblio
          ref << "[#{ordinal}]"
          insert_tab(ref, 1)
        end
        ref << iso_bibitem_ref_code(b)
        date_note_process(b, ref)
        ref << ", "
        ref.i { |i| i << " #{b.at(ns('./title')).text}" }
      end
    end

    def ref_entry_code(r, ordinal, t)
      if /^\d+$/.match?(t)
        r << "[#{t}]"
        insert_tab(r, 1)
      else
        r << "[#{ordinal}]"
        insert_tab(r, 1)
        r << "#{t},"
      end
    end

    def ref_entry(list, b, ordinal, _bibliography)
      ref = b.at(ns("./ref"))
      para = b.at(ns("./p"))
      list.p **attr_code("id": ref["id"], class: "Biblio") do |r|
        ref_entry_code(r, ordinal, ref.text.gsub(/[\[\]]/, ""))
        para.children.each { |n| parse(n, r) }
      end
    end

    # TODO generate formatted ref if not present
    def noniso_bibitem(list, b, ordinal, bibliography)
      list.p **attr_code("id": b["id"], class: "Biblio") do |r|
        if bibliography
          ref_entry_code(r, ordinal,
                         b.at(ns("./docidentifier")).text.gsub(/[\[\]]/, ""))
        else
          r << "#{iso_bibitem_ref_code(b)}, "
        end
        b.at(ns("./formattedref")).children.each { |n| parse(n, r) }
      end
    end

    ISO_PUBLISHER_XPATH =
      "./contributor[xmlns:role/@type = 'publisher']/"\
      "organization[name = 'ISO' or xmlns:name = 'IEC']".freeze

    def split_bibitems(f)
      iso_bibitem = []
      non_iso_bibitem = []
      f.xpath(ns("./bibitem")).each do |x|
        if x.at(ns(ISO_PUBLISHER_XPATH)).nil?
          non_iso_bibitem << x
        else
          iso_bibitem << x
        end
      end
      { iso: iso_bibitem, noniso: non_iso_bibitem }
    end

    def biblio_list(f, div, bibliography)
      bibitems = split_bibitems(f)
      bibitems[:iso].each_with_index do |b, i|
        iso_bibitem_entry(div, b, (i + 1), bibliography)
      end
      bibitems[:noniso].each_with_index do |b, i|
        noniso_bibitem(div, b, (i + 1 + bibitems[:iso].size), bibliography)
      end
    end

    def norm_ref_preface(f, div)
      refs = f.elements.select do |e|
        ["reference", "bibitem"].include? e.name
      end
      pref = if refs.empty? then @norm_empty_pref
             else
               @norm_with_refs_pref
             end
      div.p pref
    end

    def norm_ref(isoxml, out)
      q = "./*/references[title = 'Normative References']"
      f = isoxml.at(ns(q)) || return
      out.div do |div|
        clause_name("2.", @normref_lbl, div, false, nil)
        norm_ref_preface(f, div)
        biblio_list(f, div, false)
      end
    end

    def bibliography(isoxml, out)
      q = "./*/references[title = 'Bibliography']"
      f = isoxml.at(ns(q)) || return
      page_break(out)
      out.div do |div|
        div.h1 "Bibliography", **{ class: "Section3" }
        f.elements.reject do |e|
          ["reference", "title", "bibitem"].include? e.name
        end.each { |e| parse(e, div) }
        biblio_list(f, div, true)
      end
    end

    def format_ref(ref, isopub)
      return "ISO #{ref}" if isopub
      return "[#{ref}]" if /^\d+$/.match?(ref) && !/^\[.*\]$/.match?(ref)
      ref
    end

    def reference_names(ref)
      isopub = ref.at(ns(ISO_PUBLISHER_XPATH))
      docid = ref.at(ns("./docidentifier"))
      return ref_names(ref) unless docid
      date = ref.at(ns("./date[@type = 'published']"))
      reference = format_ref(docid.text, isopub)
      reference += ": #{date.text}" if date && isopub
      @anchors[ref["id"]] = { xref: reference }
    end

    def ref_names(ref)
      linkend = ref.text
      linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match? linkend
      @anchors[ref["id"]] = { xref: linkend }
    end
  end
end
