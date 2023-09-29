module IsoDoc
  module Function
    module References
      # This is highly specific to ISO, but it's not a bad precedent for
      # references anyway; keeping here instead of in IsoDoc::Iso for now
      def docid_l10n(text)
        text.nil? and return text
        @i18n.all_parts and text.gsub!(/All Parts/i, @i18n.all_parts.downcase)
        text.size < 20 and text.gsub!(/ /, "&#xa0;")
        text
      end

      def nonstd_bibitem(list, bib, _ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(bib, biblio)) do |ref|
          tag = bib.at(ns("./biblio-tag"))
          tag&.children&.each { |n| parse(n, ref) }
          reference_format(bib, ref)
        end
      end

      def std_bibitem_entry(list, bib, _ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(bib, biblio)) do |ref|
          tag = bib.at(ns("./biblio-tag"))
          tag&.children&.each { |n| parse(n, ref) }
          reference_format(bib, ref)
        end
      end

      SKIP_DOCID = <<~XPATH.strip.freeze
        @type = 'DOI' or @type = 'doi' or @type = 'ISSN' or @type = 'issn' or @type = 'ISBN' or @type = 'isbn' or starts-with(@type, 'ISSN.') or starts-with(@type, 'ISBN.') or starts-with(@type, 'issn.') or starts-with(@type, 'isbn.')
      XPATH

      SKIP_DOC1 = <<~XPATH.strip.freeze
        #{SKIP_DOCID} or @type = 'metanorma-ordinal' or @type = 'metanorma'
      XPATH

      PRIMARY_ID = "docidentifier[@primary = 'true']".freeze

      def pref_ref_code(bib)
        bib["suppress_identifier"] == "true" and return nil
        lang = "[@language = '#{@lang}']"
        ret = bib.xpath(ns("./#{PRIMARY_ID}[not(#{SKIP_DOCID})]#{lang}"))
        ret.empty? and
          ret = bib.xpath(ns("./#{PRIMARY_ID}[not(#{SKIP_DOCID})]"))
        ret.empty? and
          ret = bib.at(ns("./docidentifier[not(#{SKIP_DOC1})]#{lang}")) ||
            bib.at(ns("./docidentifier[not(#{SKIP_DOC1})]"))
        ret
      end

      # returns [metanorma, non-metanorma, DOI/ISSN/ISBN] identifiers
      def bibitem_ref_code(bib)
        id = bib.at(ns("./docidentifier[@type = 'metanorma']"))
        id1 = pref_ref_code(bib)
        id2 = bib.at(ns("./docidentifier[#{SKIP_DOCID}]"))
        id3 = bib.at(ns("./docidentifier[@type = 'metanorma-ordinal']"))
        return [id, id1, id2, id3] if id || id1 || id2 || id3
        return [nil, nil, nil, nil] if bib["suppress_identifier"] == "true"

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

        %w(ISO IEC IEV ITU W3C BIPM csd metanorma repository metanorma-ordinal)
          .include? prefix
      end

      def iso_bibitem_entry_attrs(bib, biblio)
        { id: bib["id"], class: biblio ? "Biblio" : "NormRef" }
      end

      # reference not to be rendered because it is deemed implicit
      # in the standards environment
      def implicit_reference(bib)
        bib["hidden"] == "true"
      end

      def reference_format(bib, out)
        ftitle = bib.at(ns("./formattedref"))
        ftitle&.children&.each { |n| parse(n, out) }
      end

      def standard?(bib)
        ret = false
        bib.xpath(ns("./docidentifier")).each do |id|
          next if id["type"].nil? ||
            id.at(".//self::*[#{SKIP_DOCID} or @type = 'metanorma']")

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
        "//bibliography/references[@normative = 'true'] | " \
          "//bibliography/clause[.//references[@normative = 'true']] | " \
          "//sections/references[@normative = 'true'] | " \
          "//sections/clause[.//references[@normative = 'true']]"
      end

      def norm_ref(node, out)
        node["hidden"] != "true" or return
        out.div do |div|
          clause_name(node, node.at(ns("./title")), div, nil)
          if node.name == "clause"
            node.elements.each { |e| parse(e, div) unless e.name == "title" }
          else biblio_list(node, div, false)
          end
        end
      end

      def bibliography_xpath
        "//bibliography/clause[.//references]" \
          "[not(.//references[@normative = 'true'])] | " \
          "//bibliography/references[@normative = 'false']"
      end

      def bibliography(node, out)
        node["hidden"] != "true" or return
        page_break(out)
        out.div do |div|
          div.h1 class: "Section3" do |h1|
            node.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(node, div, true)
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
