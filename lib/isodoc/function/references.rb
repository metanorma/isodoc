module IsoDoc::Function
  module References

    # This is highly specific to ISO, but it's not a bad precedent for
    # references anyway; keeping here instead of in IsoDoc::Iso for now
    def docid_l10n(x)
      return x if x.nil?
      x.gsub(/All Parts/i, @i18n.all_parts.downcase) if @i18n.all_parts
      x
    end

    # TODO generate formatted ref if not present
    def nonstd_bibitem(list, b, ordinal, biblio)
      list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
        ids = bibitem_ref_code(b)
        identifiers = render_identifier(ids)
        if biblio then ref_entry_code(ref, ordinal, identifiers, ids)
        else
          ref << "#{identifiers[0] || identifiers[1]}"
          ref << ", #{identifiers[1]}" if identifiers[0] && identifiers[1]
        end
        ref << ", " unless biblio && !identifiers[1]
        reference_format(b, ref)
      end
    end

    def std_bibitem_entry(list, b, ordinal, biblio)
      list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
        identifiers = render_identifier(bibitem_ref_code(b))
        if biblio then ref_entry_code(ref, ordinal, identifiers, nil)
        else
          ref << "#{identifiers[0] || identifiers[1]}"
          ref << ", #{identifiers[1]}" if identifiers[0] && identifiers[1]
        end
        date_note_process(b, ref)
        ref << ", " unless biblio && !identifiers[1]
        reference_format(b, ref)
      end
    end

    # if t is just a number, only use that ([1] Non-Standard)
    # else, use both ordinal, as prefix, and t
    def ref_entry_code(r, ordinal, t, id)
      prefix_bracketed_ref(r, t[0] || "[#{ordinal}]")
      t[1] and r << "#{t[1]}"
    end

    def pref_ref_code(b)
      b.at(ns("./docidentifier[not(@type = 'DOI' or @type = 'metanorma' "\
              "or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]"))
    end

    # returns [metanorma, non-metanorma, DOI/ISSN/ISBN] identifiers
    def bibitem_ref_code(b)
      id = b.at(ns("./docidentifier[@type = 'metanorma']"))
      id1 = pref_ref_code(b)
      id2 = b.at(ns("./docidentifier[@type = 'DOI' or @type = 'ISSN' or "\
                    "@type = 'ISBN']")) 
      return [id, id1, id2] if id || id1 || id2
      id = Nokogiri::XML::Node.new("docidentifier", b.document)
      id << "(NO ID)"
      [nil, id, nil]
    end

    def bracket_if_num(x)
      return nil if x.nil?
      x = x.text.sub(/^\[/, "").sub(/\]$/, "")
      return "[#{x}]" if /^\d+$/.match(x)
      x
    end

    def render_identifier(id)
      [
        bracket_if_num(id[0]),
        id[1].nil? ? nil :
        docid_prefix(id[1]["type"], id[1].text.sub(/^\[/, "").sub(/\]$/, "")),
        id[2].nil? ? nil :
        docid_prefix(id[2]["type"], id[2].text.sub(/^\[/, "").sub(/\]$/, "")),
      ]
    end

    def docid_prefix(prefix, docid)
      docid = "#{prefix} #{docid}" if prefix && !omit_docid_prefix(prefix)
      docid_l10n(docid)
    end

    def omit_docid_prefix(prefix)
      return true if prefix.nil? || prefix.empty?
      return %w(ISO IEC ITU W3C metanorma).include? prefix
    end

    def date_note_process(b, ref)
      date_note = b.at(ns("./note[@type = 'Unpublished-Status']"))
      return if date_note.nil?
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
      ref << text.to_s
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

    def is_standard(b)
      ret = false
      b.xpath(ns("./docidentifier")).each do |id|
        next if id["type"].nil? ||
          %w(metanorma DOI ISSN ISBN).include?(id["type"])
        ret = true
      end
      ret
    end

    def biblio_list(f, div, biblio)
      i = 0
      f.children.each do |b|
        if b.name == "bibitem"
          next if implicit_reference(b)
          i += 1
          (is_standard(b)) ? std_bibitem_entry(div, b, i, biblio) :
            nonstd_bibitem(div, b, i, biblio)
        else
          parse(b, div) unless %w(title).include? b.name
        end
      end
    end

    def norm_ref_xpath
      "//bibliography/references[@normative = 'true'] | "\
        "//bibliography/clause[.//references[@normative = 'true']]"
    end

    def norm_ref(isoxml, out, num)
      f = isoxml.at(ns(norm_ref_xpath)) or return num
      out.div do |div|
        num = num + 1
        clause_name(num, f.at(ns("./title")), div, nil)
        if f.name == "clause"
          f.elements.each { |e| parse(e, div) unless e.name == "title" }
        else
          biblio_list(f, div, false)
        end
      end
      num
    end

    def bibliography_xpath 
      "//bibliography/clause[.//references]"\
        "[not(.//references[@normative = 'true'])] | "\
        "//bibliography/references[@normative = 'false']"
    end

    def bibliography(isoxml, out)
      f = isoxml.at(ns(bibliography_xpath)) || return
      page_break(out)
      out.div do |div|
        #div.h1 @bibliography_lbl, **{ class: "Section3" }
        div.h1 **{class: "Section3"} do |h1|
          f&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
        end
        biblio_list(f, div, true)
      end
    end

    def bibliography_parse(node, out)
      title = node&.at(ns("./title"))&.text || ""
      out.div do |div|
        clause_parse_title(node, div, node.at(ns("./title")), out,
                           { class: "Section3" })
        biblio_list(node, div, true)
      end
    end

    def format_ref(ref, prefix, isopub, date, allparts)
      ref = docid_prefix(prefix, ref)
      return "[#{ref}]" if /^\d+$/.match(ref) && !prefix &&
        !/^\[.*\]$/.match(ref)
        ref
    end

    # def ref_names(ref)
    #  linkend = ref.text
    # linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match linkend
    # @anchors[ref["id"]] = { xref: linkend }
    # end
  end
end
