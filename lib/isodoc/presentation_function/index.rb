module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def strip_index(docxml)
      docxml.xpath(ns("//index | //index-xref | //indexsect")).each(&:remove)
    end

    def index(xml)
      if xml.at(ns("//index"))
        i = xml.at(ns("//indexsect")) ||
          xml.root.add_child(
            "<indexsect #{add_id_text}>" \
            "<fmt-title #{add_id_text}>#{@i18n.index}</fmt-title></indexsect>",
          ).first
        index = sort_indexterms(xml.xpath(ns("//index")),
                                xml.xpath(ns("//index-xref[@also = 'false']")),
                                xml.xpath(ns("//index-xref[@also = 'true']")))
        index1(xml, i, index)
      else strip_index(xml)
      end
    end

    def index1(docxml, indexsect, index)
      c = indexsect.add_child("<ul></ul>").first
      index.keys.sort.each do |k|
        words = index_sort_buckets(index[k].keys)
        words.keys.localize(@lang.to_sym).sort.to_a.each do |w|
          words[w].each { |w1| c.add_child index_entries(w1, index[k]) }
        end
      end
      index1_cleanup(docxml)
    end

    # Sorting is case-insensitive, so entries differing only in case (or
    # only in markup, which the sort key strips) share a sort key; they
    # are kept as distinct entries in a bucket per key, sorted adjacently
    # (metanorma/metanorma#298: overwriting them lost all but one entry)
    def index_sort_buckets(keys)
      keys.compact.each_with_object({}) do |w, v|
        (v[sortable(w).downcase] ||= []) << w
      end.transform_values(&:sort)
    end

    def index1_cleanup(docxml)
      docxml.xpath(ns("//indexsect//xref")).each do |x|
        x.children.remove
      end
      @xrefs.bookmark_anchor_names(docxml)
    end

    def sortable(str)
      str or return " "
      HTMLEntities.new.decode(Nokogiri::XML.fragment(str).text)
    end

    def index_entries_opt
      { xref_lbl: ", ", see_lbl: ", #{see_lbl}", also_lbl: ", #{also_lbl}" }
    end

    def index_entries(primary, index)
      ret = index_entries_head(primary, index.dig(primary, nil, nil),
                               index_entries_opt)
      words2 = index_sort_buckets(index[primary].keys)
      unless words2.empty?
        ret += "<ul>"
        words2.keys.localize(@lang.to_sym).sort.to_a.each do |w|
          words2[w].each { |w1| ret += index_entries2(w1, index[primary]) }
        end
        ret += "</ul>"
      end
      "#{ret}</li>"
    end

    def index_entries2(secondary, index)
      ret = index_entries_head(secondary, index.dig(secondary, nil),
                               index_entries_opt)
      words3 = index_sort_buckets(index[secondary].keys)
      unless words3.empty?
        ret += "<ul>"
        words3.keys.localize(@lang.to_sym).sort.to_a.each do |w|
          words3[w].each do |w1|
            ret += "#{index_entries_head(w1, index[secondary][w1],
                                         index_entries_opt)}</li>"
          end
        end
        ret += "</ul>"
      end
      "#{ret}</li>"
    end

    def index_entries_head(head, entries, opt)
      ret = "<li #{add_id_text}>#{head}"
      xref = entries&.dig(:xref)&.join(", ")
      see = index_entries_see(entries, :see)
      also = index_entries_see(entries, :also)
      ret += "#{opt[:xref_lbl]} #{xref}" if xref
      ret += "#{opt[:see_lbl]} #{see}" if see
      ret += "#{opt[:also_lbl]} #{also}" if also
      ret
    end

    def index_entries_see(entries, label)
      see_sort = entries&.dig(label) or return nil
      x = index_sort_buckets(see_sort)
      x.keys.localize(@lang.to_sym).sort.to_a.flat_map do |k|
        @index_fold_case ? [index_fold_head(x[k])] : x[k].uniq
      end.join(", ")
    end

    def see_lbl
      @lang == "en" ? @i18n.see : "<em>#{@i18n.see}</em>"
    end

    def also_lbl
      @lang == "en" ? @i18n.see_also : "<em>#{@i18n.see_also}</em>"
    end

    def sort_indexterms(terms, see, also)
      index = extract_indexterms(terms)
      index = extract_indexsee(index, see, :see)
      index = extract_indexsee(index, also, :also)
      @index_fold_case and index_fold_case(index)
      index.keys.sort.each_with_object({}) do |k, v|
        v[sortable(k)[0].upcase.transliterate] ||= {}
        v[sortable(k)[0].upcase.transliterate][k] = index[k]
      end
    end

    # Entries differing only in case merge into a single headword, the
    # lowercase spelling, with the union of their subentries and locators:
    # ((activity)) mid-sentence and ((Activity)) sentence-initially are
    # the same entry. Suppressed by the :index-case-sensitive: document
    # attribute for identifier-heavy documents, where Activity and
    # activity are distinct case-bearing names (metanorma/metanorma#298).
    # Applied per level: primaries, then secondaries, then tertiaries.
    def index_fold_case(index)
      index_fold_level(index)
      index.each_value do |sec|
        index_fold_level(sec)
        sec.each_value { |ter| index_fold_level(ter) }
      end
    end

    def index_fold_level(hash)
      hash.keys.grep(String).group_by { |w| sortable(w).downcase }
        .each_value { |ws| ws.size > 1 and index_fold_bucket(hash, ws) }
    end

    def index_fold_bucket(hash, words)
      head = index_fold_head(words)
      (words - [head]).each do |w|
        index_merge(hash[head], hash[w])
        hash.delete(w)
      end
    end

    def index_fold_head(words)
      words.find { |w| sortable(w) == sortable(w).downcase } || words.min
    end

    def index_merge(target, other)
      other.each do |k, v|
        if !target.key?(k) then target[k] = v
        elsif v.is_a?(Array) then target[k].concat(v)
        else index_merge(target[k], v)
        end
      end
    end

    def extract_indexsee(val, terms, label)
      terms.each_with_object(val) do |t, v|
        term, term2, term3 = extract_indexterms_init(t)
        term_hash_init(v, term, term2, term3, label)
        v[term][term2][term3][label] << to_xml(t.at(ns("./target"))&.children)
        t.remove
      end
    end

    def xml_encode_attr(str)
      HTMLEntities.new.encode(str, :basic, :hexadecimal)
        .gsub(/&#x([^;]+);/) do |_x|
        "&#x#{$1.upcase};"
      end
    end

    # attributes are decoded into UTF-8,
    # elements in extract_indexsee are still in entities
    def extract_indexterms(terms)
      terms.each_with_object({}) do |t, v|
        term, term2, term3 = extract_indexterms_init(t)
        to = t["to"] ? "to='#{t['to']}' " : ""
        index2bookmark(t)
        term_hash_init(v, term, term2, term3, :xref)
        v[term][term2][term3][:xref] << "<xref target='#{t['id']}' " \
                                        "#{to}pagenumber='true'/>"
      end
    end

    def extract_indexterms_init(term)
      %w(primary secondary tertiary).each_with_object([]) do |x, m|
        m << to_xml(term.at(ns("./#{x}"))&.children)
      end
    end

    def term_hash_init(hash, term, term2, term3, label)
      hash[term] ||= {}
      hash[term][term2] ||= {}
      hash[term][term2][term3] ||= {}
      hash[term][term2][term3][label] ||= []
    end

    def index2bookmark(node)
      node.name = "bookmark"
      node.children.each(&:remove)
      add_id(node)
      node.delete("to")
    end
  end
end
