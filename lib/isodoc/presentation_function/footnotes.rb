module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def footnote_collect(fnotes)
      seen = {}
      fnotes.each_with_object([]) do |x, m|
        seen[x["reference"]] or m << fnbody(x, seen)
        x["target"] = seen[x["reference"]]
        ref = x["hiddenref"] == "true" ? "" : fn_ref_label(x)
        x << <<~FNOTE.strip
          <fmt-fn-label><span class='fmt-caption-label'>#{ref}</span</fmt-fn-label>
        FNOTE
      end
    end

    def footnote_container(fnotes, fnbodies)
      fnbodies.empty? and return
      ctr = Nokogiri::XML::Node.new("fmt-footnote-container",
                                    fnotes.first.document)
      fnbodies.each { |x| ctr << x }
      ctr
    end

    def fnbody(fnote, seen)
      body = Nokogiri::XML::Node.new("fmt-fn-body", fnote.document)
      add_id(body)
      body["target"] = fnote["id"]
      body["reference"] = fnote["reference"]
      body << semx_fmt_dup(fnote)
      insert_fn_body_ref(fnote, body)
      seen[fnote["reference"]] = body["id"]
      body
    end

    def insert_fn_body_ref(fnote, body)
      ins = body.at(ns(".//p")) ||
        body.at(ns("./semx")).children.first.before("<p> </p>").previous
      lbl = fn_body_label(fnote)
      ins.children.first.previous = <<~FNOTE.strip
        <fmt-fn-label><span class='fmt-caption-label'>#{lbl}</span><span class="fmt-caption-delim"><tab/></fmt-fn-label>
      FNOTE
    end

    def fn_ref_label(fnote)
      "<sup>#{fn_label(fnote)}</sup>"
    end

    def fn_body_label(fnote)
      "<sup>#{fn_label(fnote)}</sup>"
    end

    def fn_label(fnote)
      <<~FNOTE.strip
        <semx element="autonum" source="#{fnote['id']}">#{fnote['reference']}</semx>
      FNOTE
    end

    def table_fn(elem)
      fnotes = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn")) -
        elem.xpath(ns("./fmt-name//fn"))
      ret = footnote_collect(fnotes)
      f = footnote_container(fnotes, ret) and elem << f
    end

    def document_footnotes(docxml)
      sects = sort_footnote_sections(docxml)
      excl = non_document_footnotes(docxml)
      fns = filter_document_footnotes(sects, excl)
      fns = renumber_document_footnotes(fns, 1)
      ret = footnote_collect(fns)
      f = footnote_container(fns, ret) and docxml.root << f
    end

    # bibdata, boilerplate, @displayorder sections
    def sort_footnote_sections(docxml)
      sects = docxml.xpath(".//*[@displayorder]")
        .sort_by { |c| c["displayorder"].to_i }
      b = docxml.at(ns("//boilerplate")) and sects.unshift b
      b = docxml.at(ns("//bibdata")) and sects.unshift b
      sects
    end

    def non_document_footnotes(docxml)
      table_footnotes(docxml) + figure_footnotes(docxml)
    end

    def table_footnotes(docxml)
      docxml.xpath(ns("//table//fn")) -
        docxml.xpath(ns("//table/name//fn")) -
        docxml.xpath(ns("//table/fmt-name//fn")) -
        docxml.xpath(ns("//fmt-provision/table//fn")) +
        docxml.xpath(ns("//fmt-provision/table//table//fn"))
    end

    def figure_footnotes(docxml)
      docxml.xpath(ns("//figure//fn")) -
        docxml.xpath(ns("//figure/name//fn")) -
        docxml.xpath(ns("//figure/fmt-name//fn"))
    end

    def filter_document_footnotes(sects, excl)
      sects.each_with_object([]) do |s, m|
        docfns = s.xpath(ns(".//fn")) - excl
        m << docfns
      end
    end

    # can instead restart at i=1 each section
    def renumber_document_footnotes(fns_by_section, idx)
      fns_by_section.reject(&:empty?).each_with_object({}) do |s, seen|
        s.each do |f|
          idx = renumber_document_footnote(f, idx, seen)
        end
      end
      fns_by_section.flatten
    end

    def renumber_document_footnote(fnote, idx, seen)
      fnote["original-reference"] = fnote["reference"]
      if seen[fnote["reference"]]
        fnote["reference"] = seen[fnote["reference"]]
      else
        seen[fnote["reference"]] = idx
        fnote["reference"] = idx
        idx += 1
      end
      idx
    end

    # move footnotes into key
    def figure_fn(elem)
      fn = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn")) -
        elem.xpath(ns("./fmt-name//fn"))
      fn.empty? and return
      dl = figure_key_insert_pt(elem)
      footnote_collect(fn).each do |f|
        label, fbody = figure_fn_to_dt_dd(f)
        dl.previous = "<dt><p>#{to_xml(label)}</p></dt><dd>#{to_xml(fbody)}</dd>"
      end
    end

    def figure_fn_to_dt_dd(fnote)
      label = fnote.at(ns(".//fmt-fn-label")).remove
      label.at(ns(".//span[@class = 'fmt-caption-delim']"))&.remove
      [label, fnote]
    end

    def figure_key_insert_pt(elem)
      elem.at(ns(".//dl/name"))&.next ||
        elem.at(ns(".//dl"))&.children&.first ||
        elem.add_child("<dl> </dl>").first.children.first
    end

    def comments(docxml)
      global_display = display_comments_global?(docxml)
      docxml.xpath(ns("//annotation")).each do |c|
        global_display || display_comment_override?(c) or next
        c1 = comment_body(c)
        comment_bookmarks(c1)
      end
    end

    # if false, then decision on displaying comment is only dependent on
    # display_comments_global? . display_comment_override? overrides that
    def display_comment_override?(_comment)
      false
    end

    def comment_body(elem)
      c1 = elem.after("<fmt-annotation-body/>").next
      elem.attributes.each_key { |k| k == "id" or c1[k] = elem[k] }
      add_id(c1)
      c1 << semx_fmt_dup(elem)
    end

    def comment_bookmarks(elem)
      from, to = comment_bookmarks_locate(elem)
      new_from = comment_bookmark_start(from, elem)
      new_to = comment_bookmark_end(to, elem)
      elem["from"] = new_from["id"]
      elem["to"] = new_to["id"]
    end

    # Do not insert a comment bookmark inside another comment bookmark
    # Also avoid list labels, which are typically not rendered downstream
    # as selectable text
    AVOID_COMMENT_BOOKMARKS = <<~XPATH.freeze
      [not(ancestor::xmlns:fmt-annotation-start)][not(ancestor::xmlns:fmt-annotation-end)][not(ancestor::xmlns:fmt-name[parent::xmlns:li])]
    XPATH

    def comment_bookmarks_locate(elem)
      from = elem.document.at("//*[@id = '#{elem['from']}']")
      f = from.at(".//text()#{AVOID_COMMENT_BOOKMARKS}") and from = f
      to = elem.document.at("//*[@id = '#{elem['to']}']") || from
      f = to.at(".//text()[last()]#{AVOID_COMMENT_BOOKMARKS}") and to = f
      [from, to]
    end

    def comment_to_bookmark_attrs(elem, bookmark, start: true)
      bookmark["target"] = elem["id"]
      if start then bookmark["end"] = elem["to"]
      else bookmark["start"] = elem["from"]
      end
      %w(author date).each { |k| bookmark[k] = elem[k] }
    end

    def comment_bookmark_start(from, elem)
      ret = from.before("<fmt-annotation-start/>").previous
      add_id(ret)
      ret["source"] = elem["from"]
      comment_to_bookmark_attrs(elem, ret, start: true)
      ret << comment_bookmark_start_label(elem)
      ret
    end

    def comment_bookmark_end(to, elem)
      ret = to.after("<fmt-annotation-end/>").next
      add_id(ret)
      ret["source"] = elem["to"]
      comment_to_bookmark_attrs(elem, ret, start: false)
      ret << comment_bookmark_end_label(elem)
      ret
    end

    def comment_bookmark_start_label(_elem)
      ""
    end

    def comment_bookmark_end_label(_elem)
      ""
    end

    def display_comments_global?(docxml)
      m = docxml.at(ns("//presentation-metadata/render-document-annotations"))
      m&.text and return m.text != "false"
      @meta.get[:unpublished]
    end
  end
end
