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
      parsed = Pubid::Registry.parse(id)
      # Pubid::Ieee in particular happily parses any "letters+digits" token
      # as an IEEE Std identifier and synthesises an "IEEE Std" prefix that
      # wasn't in the input (e.g. "REF4" -> "IEEE Std REF4"). Refuse to
      # annotate when the parser has invented structure not present in the
      # input -- detected by a non-identity round-trip.
      return id if parsed.to_s != id
      parsed.to_s(annotated: true)
    rescue Pubid::Core::Errors::ParseError
      std_docid_semantic_full(id)
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
