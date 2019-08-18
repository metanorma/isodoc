module IsoDoc::Function
  module References

    # This is highly specific to ISO, but it's not a bad precedent for
    # references anyway; keeping here instead of in IsoDoc::Iso for now
    def docid_l10n(x)
      return x if x.nil?
      x.gsub(/All Parts/i, @all_parts_lbl.downcase)
    end

    # TODO generate formatted ref if not present
    def nonstd_bibitem(list, b, ordinal, bibliography)
      list.p **attr_code(iso_bibitem_entry_attrs(b, bibliography)) do |r|
        id = bibitem_ref_code(b)
        if bibliography
          ref_entry_code(r, ordinal, id)
        else
          r << "#{id}, "
        end
        reference_format(b, r)
      end
    end


    def std_bibitem_entry(list, b, ordinal, biblio)
      list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
        prefix_bracketed_ref(ref, ordinal) if biblio
        ref << bibitem_ref_code(b)
        date_note_process(b, ref)
        ref << ", "
        reference_format(b, ref)
      end
    end

    # if t is just a number, only use that ([1] Non-Standard)
    # else, use both ordinal, as prefix, and t
    def ref_entry_code(r, ordinal, t)
      if /^\d+$/.match(t)
        prefix_bracketed_ref(r, t)
      else
        prefix_bracketed_ref(r, ordinal)
        r << "#{t}, "
      end
    end

    def bibitem_ref_code(b)
      id = b.at(ns("./docidentifier[not(@type = 'DOI' or @type = 'metanorma')]"))
      id ||= b.at(ns("./docidentifier[not(@type = 'DOI')]"))
      id ||= b.at(ns("./docidentifier")) or return "(NO ID)"
      docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
    end

    def docid_prefix(prefix, docid)
      docid = "#{prefix} #{docid}" if prefix && !omit_docid_prefix(prefix)
      docid_l10n(docid)
    end

    def omit_docid_prefix(prefix)
      return true if prefix.nil? || prefix.empty?
      return ["ISO", "IEC", "metanorma"].include? prefix
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
      title = b.at(ns("./title[@language = '#{@lang}' and @type = 'main']")) ||
        b.at(ns("./title[@language = '#{@lang}']")) ||
        b.at(ns("./title[@type = 'main']")) ||
        b.at(ns("./title"))
      title
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

    def reference_format(b, r)
      if ftitle = b.at(ns("./formattedref"))
        ftitle&.children&.each { |n| parse(n, r) }
      else
        title = iso_title(b)
        r.i do |i|
          title&.children&.each { |n| parse(n, i) }
        end
      end
    end

    ISO_PUBLISHER_XPATH =
      "./contributor[xmlns:role/@type = 'publisher']/"\
      "organization[abbreviation = 'ISO' or xmlns:abbreviation = 'IEC' or "\
      "xmlns:name = 'International Organization for Standardization' or "\
      "xmlns:name = 'International Electrotechnical Commission']".freeze

    def is_standard(b)
      ret = false
      b.xpath(ns("./docidentifier")).each do |id|
        next if id["type"].nil? || %w(metanorma DOI).include?(id["type"])
        ret = true
      end
      ret
    end

    def biblio_list(f, div, bibliography)
      f.xpath(ns("./bibitem")).each_with_index do |b, i|
        next if implicit_reference(b)
        if(is_standard(b))
          std_bibitem_entry(div, b, i + 1, bibliography)
        else
          nonstd_bibitem(div, b, i + 1, bibliography)
        end
      end
    end

    def norm_ref_preface(f, div)
      refs = f.elements.select do |e|
        ["reference", "bibitem"].include? e.name
      end
      pref = refs.empty? ? @norm_empty_pref : @norm_with_refs_pref
      div.p pref
    end

    def norm_ref(isoxml, out, num)
      q = "//bibliography/references[title = 'Normative References' or "\
        "title = 'Normative references']"
      f = isoxml.at(ns(q)) or return num
      out.div do |div|
        num = num + 1
        clause_name(num, @normref_lbl, div, nil)
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

    def format_ref(ref, prefix, isopub, date, allparts)
      if isopub
        #if date
        #on = date.at(ns("./on"))
        #ref += on&.text == "--" ? ":--" : "" # ":#{date_range(date)}"
        #ref += " (all parts)" if allparts
        # ref = docid_prefix(prefix, ref)
        #end
      end
      ref = docid_prefix(prefix, ref)
      return "[#{ref}]" if /^\d+$/.match(ref) && !prefix && !/^\[.*\]$/.match(ref)
      ref
    end

    def reference_names(ref)
      isopub = ref.at(ns(ISO_PUBLISHER_XPATH))
      docid = ref.at(ns("./docidentifier"))
      prefix = ref.at(ns("./docidentifier/@type"))
      # return ref_names(ref) unless docid
      date = ref.at(ns("./date[@type = 'published']"))
      allparts = ref.at(ns("./extent[@type='part'][referenceFrom='all']"))
      reference = format_ref(docid_l10n(docid.text), prefix&.text, isopub, date, allparts)
      @anchors[ref["id"]] = { xref: reference }
    end

    # def ref_names(ref)
    #  linkend = ref.text
    # linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match linkend
    # @anchors[ref["id"]] = { xref: linkend }
    # end
  end
end
