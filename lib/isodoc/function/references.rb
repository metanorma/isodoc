module IsoDoc::Function
  module References

    # This is highly specific to ISO, but it's not a bad precedent for
    # references anyway; keeping here instead of in IsoDoc::Iso for now
    def docid_l10n(x)
      return x if x.nil?
      x.gsub(/All Parts/, @all_parts_lbl)
    end

    def iso_bibitem_ref_code(b)
      isocode = b.at(ns("./docidentifier")).text
      isodate = b.at(ns("./date[@type = 'published']"))
      iso_allparts = b.at(ns("./allParts"))
      reference = docid_l10n(isocode)
      reference += ":#{date_range(isodate)}" if isodate
      reference += " (all parts)" if iso_allparts&.text == "true"
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
      { id: b["id"], class: biblio ? "Biblio" : "NormRef" }
    end

    def iso_title(b)
      title = b.at(ns("./title[@language = '#{@language}']"))
      title = b.at(ns("./title")) unless title
      title.text
    end

    # reference not to be rendered because it is deemed implicit
    # in the standards environment
    def implicit_reference(b)
      false
    end

    def prefix_bracketed_ref(ref, text)
      ref << "[#{text}]"
      insert_tab(ref, 1)
    end

    def iso_bibitem_entry(list, b, ordinal, biblio)
      return if implicit_reference(b)
      list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
        prefix_bracketed_ref(ref, ordinal) if biblio
        ref << iso_bibitem_ref_code(b)
        date_note_process(b, ref)
        ref << ", "
        ref.i { |i| i << " #{iso_title(b)}" }
      end
    end

    def ref_entry_code(r, ordinal, t)
      if /^\d+$/.match?(t)
        prefix_bracketed_ref(r, t)
      else
        prefix_bracketed_ref(r, ordinal)
        r << "#{t}, "
      end
    end

    def reference_format(b, r)
      title = b.at(ns("./formattedref")) ||
        b.at(ns("./title[@language = '#{@language}']")) || b.at(ns("./title"))
      title&.children&.each { |n| parse(n, r) }
    end

    # TODO generate formatted ref if not present
    def noniso_bibitem(list, b, ordinal, bibliography)
      list.p **attr_code(iso_bibitem_entry_attrs(b, bibliography)) do |r|
        if bibliography
          id = docid_l10n(b.at(ns("./docidentifier")).text.gsub(/[\[\]]/, ""))
          ref_entry_code(r, ordinal, id)
        else
          r << "#{iso_bibitem_ref_code(b)}, "
        end
        reference_format(b, r)
      end
    end

    ISO_PUBLISHER_XPATH =
      "./contributor[xmlns:role/@type = 'publisher']/"\
      "organization[abbreviation = 'ISO' or xmlns:abbreviation = 'IEC' or "\
      "xmlns:name = 'International Organization for Standardization' or "\
      "xmlns:name = 'International Electrotechnical Commission']".freeze

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

    def norm_ref(isoxml, out, num)
      q = "//bibliography/references[title = 'Normative References' or "\
        "title = 'Normative references']"
      f = isoxml.at(ns(q)) or return num
      out.div do |div|
        num = num + 1
        clause_name("#{num}.", @normref_lbl, div, nil)
        norm_ref_preface(f, div)
        biblio_list(f, div, false)
      end
      num
    end

    BIBLIOGRAPHY_XPATH = "//bibliography/clause[title = 'Bibliography'] | "\
      "//bibliography/references[title = 'Bibliography']".freeze


    def bibliography(isoxml, out)
      f = isoxml.at(ns(BIBLIOGRAPHY_XPATH)) || return
      page_break(out)
      out.div do |div|
        div.h1 @bibliography_lbl, **{ class: "Section3" }
        f.elements.reject do |e|
          ["reference", "title", "bibitem"].include? e.name
        end.each { |e| parse(e, div) }
        biblio_list(f, div, true)
      end
    end

    def bibliography_parse(node, out)
      title = node&.at(ns("./title"))&.text || ""
      out.div do |div|
        div.h2 title, **{ class: "Section3" }
        node.elements.reject do |e|
          ["reference", "title", "bibitem"].include? e.name
        end.each { |e| parse(e, div) }
        biblio_list(node, div, true)
      end
    end

    def format_ref(ref, isopub, date)
      if isopub
        return ref unless date
        on = date.at(ns("./on"))
        return ref if on&.text == "--"
        return ref + ":#{date_range(date)}"
      end
      return "[#{ref}]" if /^\d+$/.match?(ref) && !/^\[.*\]$/.match?(ref)
      ref
    end

    def reference_names(ref)
      isopub = ref.at(ns(ISO_PUBLISHER_XPATH))
      docid = ref.at(ns("./docidentifier"))
      # return ref_names(ref) unless docid
      date = ref.at(ns("./date[@type = 'published']"))
      reference = format_ref(docid_l10n(docid.text), isopub, date)
      @anchors[ref["id"]] = { xref: reference }
    end

    # def ref_names(ref)
    #  linkend = ref.text
    # linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match? linkend
    # @anchors[ref["id"]] = { xref: linkend }
    # end
  end
end
