module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def annex(docxml)
      docxml.xpath(ns("//annex")).each do |f|
        @xrefs.klass.single_term_clause?(f) and single_term_clause_retitle(f)
        annex1(f)
        @xrefs.klass.single_term_clause?(f) and single_term_clause_unnest(f)
      end
      @xrefs.parse_inclusions(clauses: true).parse(docxml)
    end

    def annex1(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false)
      orig_title = annex1_title_fmt(elem)
      %w(title variant-title).each do |k|
        k == "variant-title" && (t = elem.at(ns("./variant-title"))) &&
          t["type"] != "_toc_temp" and next
        # we only prefix variant-title we have just copied from title
        annex1_title_prefix(elem, lbl, k)
      end
      annex1_title_postprocess(elem, orig_title)
    end

    def annex1_title_fmt(elem)
      t = elem.at(ns("./title")) or return nil
      unless elem.at(ns("./variant-title[@type='toc']"))
        t.next = to_xml(t)
        v = t.next
        v.name = "variant-title"
        v["type"] = "_toc_temp"
      end
      orig_title = to_xml(t.children)
      t.children = annex1_title_fmt_inline(t)
      orig_title
    end

    def annex1_title_fmt_inline(title)
      "<strong>#{to_xml(title.children)}</strong>"
    end

    def annex1_title_prefix(elem, lbl, tag)
      delim, lbl = annex1_title_prefix_prep(elem, lbl, tag)
      if unnumbered_clause?(elem)
        prefix_name(elem, {}, nil, tag)
      else
        prefix_name(elem, { caption: delim }, lbl, tag,
                    fmt_xref_label: tag == "title")
      end
    end

    def annex1_title_prefix_prep(elem, lbl, tag)
      delim = annex_delim_override(elem)
      if tag == "variant-title" # strip obligation, boldface
        lbl &&= lbl.gsub("<strong>", "").gsub("</strong>", "")
          # Use (?:<br/>)* (non-capturing) and [^<]* instead of .+? so the
          # obligation-span content is matched without polynomial backtracking.
          # fmt-obligation spans contain plain text, so [^<]* is equivalent.
          .sub(%r{(?:<br/>)*<span class=.fmt-obligation.>[^<]*</span>}, "")
        delim = "<tab/>"
      end
      [delim, lbl]
    end

    # only accept variant-title we have just copied from title and prefixed
    # into fmt-variant-title: that replaces the variant-title we have inserted
    def annex1_title_postprocess(elem, orig_title)
      v, t, v1 = annex1_variant_title_postprocess_prep(elem)
      t&.children = orig_title
      v1&.name == "fmt-variant-title" or return
      v&.remove
      v1.name = "variant-title"
      v1["type"] = "toc"
      s = v1.at(ns(".//semx[@element = 'variant-title']")) or return
      s["element"] = "title"
      t and s["source"] = t["id"]
    end

    def annex1_variant_title_postprocess_prep(elem)
      v = elem.at(ns("./variant-title[@type='_toc_temp']"))
      t = elem.at(ns("./title"))
      # fmt-variant-title generated from variant-title
      v1 = v&.next_element ||
        #  fmt-variant-title generated only from lbl
        elem.at(ns("./fmt-variant-title"))
      [v, t, v1]
    end

    def annex_delim_override(elem)
      m = elem.document.root.at(ns("//presentation-metadata/annex-delim"))
      m ? to_xml(m.children) : annex_delim(elem)
    end

    def annex_delim(_elem)
      "<br/><br/>"
    end
  end
end
