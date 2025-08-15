module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def docid_prefixes(docxml)
      docxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
        i.children = docid_prefix(i["type"], to_xml(i.children))
      end
    end

    def pref_ref_code(bib)
      bib["suppress_identifier"] == "true" and return nil
      ret = bib.xpath(ns("./docidentifier[@scope = 'biblio-tag']"))
      ret.empty? or return ret.map { |x| to_xml(x.children) }
      ret = pref_ref_code_parse(bib) or return nil
      ins = bib.at(ns("./docidentifier[last()]"))
      ret.reverse_each do |r|
        id = docid_l10n(r, citation: false)
        ins.next = "<docidentifier scope='biblio-tag'>#{id}</docidentifier>"
      end
      ret
    end

    def pref_ref_code_parse(bib)
      data, = @bibrender.parse(bib)
      ret = data[:authoritative_identifier] or return nil
      ret.empty? and return nil
      ret
    end

    # returns [metanorma, non-metanorma, DOI/ISSN/ISBN] identifiers
    def bibitem_ref_code(bib)
      id, id1, id2, id3 = bibitem_ref_code_prep(bib)
      id || id1 || id2 || id3 and return [id, id1, id2, id3]
      bib["suppress_identifier"] == "true" and return [nil, nil, nil, nil]
      [nil, no_identifier(bib), nil, nil]
    end

    def bibitem_ref_code_prep(bib)
      id = bib.at(ns("./docidentifier[@type = 'metanorma']"))
      id1 = pref_ref_code(bib)
      id2 = bib.at(ns("./docidentifier[#{SKIP_DOCID}]"))
      id3 = bib.at(ns("./docidentifier[@type = 'metanorma-ordinal']"))
      [id, id1, id2, id3]
    end

    def no_identifier(bib)
      @i18n.no_identifier or return nil
      id = Nokogiri::XML::Node.new("docidentifier", bib.document)
      id << @i18n.no_identifier
      id
    end

    def xml_to_string_skip_fn(node)
      node1 = node.dup
      node1.xpath(ns(".//fn")).each(&:remove)
      to_xml(node1.children)
    end

    def bracket_if_num(num)
      num.nil? and return nil
      num = xml_to_string_skip_fn(num).sub(/^\[/, "").sub(/\]$/, "")
      /^\d+$/.match?(num) and return "[#{num}]"
      num
    end

    def unbracket1(ident)
      ident.nil? and return nil
      ident.is_a?(String) or ident = xml_to_string_skip_fn(ident)
      ident.sub(/^\[/, "").sub(/\]$/, "")
    end

    def unbracket(ident)
      if ident.respond_to?(:size)
        ident.map { |x| unbracket1(x) }.join("&#xA0;/ ")
      else unbracket1(ident)
      end
    end

    def render_identifier(ident)
      { metanorma: bracket_if_num(ident[0]),
        sdo: unbracket(ident[1]),
        doi: unbracket(ident[2]),
        ordinal: bracket_if_num(ident[3]) }
    end
  end
end
