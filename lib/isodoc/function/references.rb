module IsoDoc
  module Function
    module References
      # This is highly specific to ISO, but it's not a bad precedent for
      # references anyway; keeping here instead of in IsoDoc::Iso for now
      def docid_l10n(text)
        return text if text.nil?

        text.gsub(/All Parts/i, @i18n.all_parts.downcase) if @i18n.all_parts
        text
      end

      # TODO generate formatted ref if not present
      def nonstd_bibitem(list, bib, ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(bib, biblio)) do |ref|
          ids = bibitem_ref_code(bib)
          idents = render_identifier(ids)
          if biblio then ref_entry_code(ref, ordinal, idents, ids)
          else
            ref << (idents[:ordinal] || idents[:metanorma] || idents[:sdo]).to_s
            ref << ", #{idents[sdo]}" if idents[:ordinal] && idents[:sdo]
          end
          ref << ", " unless biblio && !idents[:sdo]
          reference_format(bib, ref)
        end
      end

      def std_bibitem_entry(list, bib, ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(bib, biblio)) do |ref|
          idents = render_identifier(bibitem_ref_code(bib))
          if biblio then ref_entry_code(ref, ordinal, idents, nil)
          else
            ref << (idents[:ordinal] || idents[:metanorma] || idents[:sdo]).to_s
            ref << ", #{idents[:sdo]}" if (idents[:ordinal] ||
                                          idents[:metanorma]) && idents[:sdo]
          end
          date_note_process(bib, ref)
          ref << ", " unless biblio && !idents[:sdo]
          reference_format(bib, ref)
        end
      end

      # if ids is just a number, only use that ([1] Non-Standard)
      # else, use both ordinal, as prefix, and ids
      def ref_entry_code(ref, ordinal, ids, _id)
        prefix_bracketed_ref(ref, ids[:ordinal] || ids[:metanorma] ||
                             "[#{ordinal}]")
        ids[:sdo] and ref << (ids[:sdo]).to_s
      end

      def pref_ref_code(bib)
        ret = bib.xpath(ns("./docidentifier[@primary = 'true']"))
        ret.empty? and
          ret = bib.at(ns("./docidentifier[not(@type = 'DOI' or "\
                          "@type = 'metanorma' "\
                          "or @type = 'metanorma-ordinal' or "\
                          "@type = 'ISSN' or @type = 'ISBN' or "\
                          "@type = 'rfc-anchor')]"))
        ret
      end

      # returns [metanorma, non-metanorma, DOI/ISSN/ISBN] identifiers
      def bibitem_ref_code(bib)
        id = bib.at(ns("./docidentifier[@type = 'metanorma']"))
        id1 = pref_ref_code(bib)
        id2 = bib.at(ns("./docidentifier[@type = 'DOI' or @type = 'ISSN' or "\
                        "@type = 'ISBN']"))
        id3 = bib.at(ns("./docidentifier[@type = 'metanorma-ordinal']"))
        return [id, id1, id2, id3] if id || id1 || id2 || id3

        id = Nokogiri::XML::Node.new("docidentifier", bib.document)
        id << "(NO ID)"
        [nil, id, nil, nil]
      end

      def bracket_if_num(num)
        return nil if num.nil?

        num = num.text.sub(/^\[/, "").sub(/\]$/, "")
        return "[#{num}]" if /^\d+$/.match?(num)

        num
      end

      def unbracket1(ident)
        ident&.text&.sub(/^\[/, "")&.sub(/\]$/, "")
      end

      def unbracket(ident)
        if ident.respond_to?(:size)
          ident.map { |x| unbracket1(x) }.join("&#xA0;/ ")
        else
          unbracket1(ident)
        end
      end

      def render_identifier(ident)
        { metanorma: bracket_if_num(ident[0]),
          sdo: unbracket(ident[1]),
          doi: unbracket(ident[2]),
          ordinal: bracket_if_num(ident[3]) }
      end

      def docid_prefix(prefix, docid)
        docid = "#{prefix} #{docid}" if prefix && !omit_docid_prefix(prefix) &&
          !/^#{prefix}\b/.match(docid)
        docid_l10n(docid)
      end

      def omit_docid_prefix(prefix)
        return true if prefix.nil? || prefix.empty?

        %w(ISO IEC IEV ITU W3C csd metanorma repository metanorma-ordinal)
          .include? prefix
      end

      def date_note_process(bib, ref)
        date_note = bib.at(ns("./note[@type = 'Unpublished-Status']"))
        return if date_note.nil?

        date_note.children = "<p>#{date_note.content}</p>"
        footnote_parse(date_note, ref)
      end

      def iso_bibitem_entry_attrs(bib, biblio)
        { id: bib["id"], class: biblio ? "Biblio" : "NormRef" }
      end

      def iso_title(bib)
        bib.at(ns("./title[@language = '#{@lang}' and @type = 'main']")) ||
          bib.at(ns("./title[@language = '#{@lang}']")) ||
          bib.at(ns("./title[@type = 'main']")) ||
          bib.at(ns("./title"))
      end

      # reference not to be rendered because it is deemed implicit
      # in the standards environment
      def implicit_reference(bib)
        bib["hidden"] == "true"
      end

      def prefix_bracketed_ref(ref, text)
        ref << text.to_s
        insert_tab(ref, 1)
      end

      def reference_format(bib, out)
        if ftitle = bib.at(ns("./formattedref"))
          ftitle&.children&.each { |n| parse(n, out) }
        else
          out.i do |i|
            iso_title(bib)&.children&.each { |n| parse(n, i) }
          end
        end
      end

      def standard?(bib)
        ret = false
        drop = %w(metanorma DOI ISSN ISBN)
        bib.xpath(ns("./docidentifier")).each do |id|
          next if id["type"].nil? || drop.include?(id["type"])

          ret = true
        end
        ret
      end

      def biblio_list(refs, div, biblio)
        i = 0
        refs.children.each do |b|
          if b.name == "bibitem"
            next if implicit_reference(b)

            i += 1 unless b["hidden"]
            if standard?(b) then std_bibitem_entry(div, b, i, biblio)
            else nonstd_bibitem(div, b, i, biblio)
            end
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
        (f = isoxml.at(ns(norm_ref_xpath)) and f["hidden"] != "true") or
          return num
        out.div do |div|
          num += 1
          clause_name(num, f.at(ns("./title")), div, nil)
          if f.name == "clause"
            f.elements.each { |e| parse(e, div) unless e.name == "title" }
          else biblio_list(f, div, false)
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
        (f = isoxml.at(ns(bibliography_xpath)) and f["hidden"] != "true") or
          return
        page_break(out)
        out.div do |div|
          div.h1 **{ class: "Section3" } do |h1|
            f&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(f, div, true)
        end
      end

      def bibliography_parse(node, out)
        node["hidden"] != true or return
        out.div do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out,
                             { class: "Section3" })
          biblio_list(node, div, true)
        end
      end
    end
  end
end
