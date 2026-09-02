module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    # Wrap token sub-spans of a standard docidentifier (publisher, document
    # number, part, year, ...) in <span class="..."> markers for CSS styling.
    # Flavors opt in by overriding `annotate_docid?`; they customise span
    # class naming via `std_docid_span_classes`. Pubid parsing is shared.
    def std_docid_semantic(id)
      annotate_docid?(id) or return id
      id.nil? || id.empty? || id == "IEV" || /^\[?\d+\]?$/.match?(id) and
        return id
      nbsp = id.include?("\u00a0")
      bracket = id.match?(/\A\[.+\]\Z/m)
      id = id.gsub("\u00a0", " ").sub(/\A\[(.+)\]\Z/m, "\\1")
      ret = std_docid_span_classes(std_docid_semantic_parse(id))
      std_docid_semantic_restore_format(ret, nbsp, bracket)
    end

    def std_docid_semantic_parse(id)
      result = pubid_parse(id)
      # Pubid::Ieee in particular happily parses any "letters+digits" token
      # as an IEEE Std identifier and synthesises an "IEEE Std" prefix that
      # wasn't in the input (e.g. "REF4" -> "IEEE Std REF4"). Refuse to
      # annotate when the parser has invented structure not present in the
      # input -- detected by a non-identity round-trip.
      return std_docid_semantic_full(id) if result.nil?

      result
    rescue StandardError
      std_docid_semantic_full(id)
    end

    # pubid 2 has no universal Pubid::Registry.parse: try each registered
    # flavor. Outcomes:
    #   1. A flavor round-trips the input AND renders annotation markup —
    #      return it (some flavors' renderers ignore annotated: and
    #      return plain text; those need the regex fallback below).
    #   2. A flavor parses but synthesizes structure the input lacks
    #      (e.g. "REF4" -> "IEEE Std REF4") — return the input unchanged
    #      (1.x's round-trip guard).
    #   3. Nothing parses, a round-tripper renders plain, or the parse
    #      only canonicalizes FORM (e.g. em-dash year -> "--") — nil, so
    #      the caller uses the regex fallback, which preserves the
    #      original string (1.x's ParseError path).
    def pubid_parse(string)
      Pubid.eager_load_flavors!
      parsed_any = false
      plain_roundtrip = false
      canonicalized = false
      Pubid::Registry.flavors.each_value do |flavor|
        next unless flavor.respond_to?(:parse)

        begin
          parsed = flavor.parse(string)
          parsed_any = true
          if parsed.to_s == string
            annotated = parsed.to_s(annotated: true)
            return annotated if annotated != parsed.to_s

            plain_roundtrip = true
          elsif dash_normalize(parsed.to_s) == dash_normalize(string)
            canonicalized = true
          end
        rescue StandardError
          next
        end
      end
      return string if parsed_any && !plain_roundtrip && !canonicalized

      nil
    end

    # Compare strings ignoring dash FORM (em-dash / double dash / single
    # dash), so a parse that only canonicalizes punctuation is not
    # mistaken for structure synthesis.
    def dash_normalize(string)
      string.tr("—", "-").gsub("--", "-")
    end

    # Regex-based fallback when Pubid::Registry cannot parse the id. Emits
    # the same generic class names that Pubid uses (publisher, docnumber,
    # part, year) so that flavors' `std_docid_span_classes` remaps work
    # uniformly across both the Pubid-parse path and this fallback.
    def std_docid_semantic_full(ident)
      ident
        .sub(/^([^0-9]+)(\p{Zs}|$)/, '<span class="publisher">\1</span>\2')
        .sub(/([0-9]+)/, '<span class="docnumber">\1</span>')
        .sub(/-([0-9]+)/, '-<span class="part">\1</span>')
        .sub(/:([0-9]{4})(?!\d)/, ':<span class="year">\1</span>')
    end

    # Default: pass through Pubid's generic class names unchanged. Flavors
    # override to remap (e.g. ISO -> "stdpublisher", IEEE -> "std_publisher").
    def std_docid_span_classes(id)
      id
    end

    def std_docid_semantic_restore_format(id, nbsp, bracket)
      nbsp and Nokogiri::XML(id).traverse do |n|
        n.text? or next
        n.replace(n.text.gsub(" ", "\u00a0"))
      end
      bracket and id = "[#{id}]"
      id
    end

    # Flavors opt in by overriding to return true. Default is off so that
    # downstream consumers of IsoDoc::PresentationXMLConvert that have not
    # explicitly opted in (ITU, NIST, OGC, ...) keep their current behaviour.
    def annotate_docid?(_id)
      false
    end
  end
end
