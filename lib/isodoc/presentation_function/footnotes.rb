module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def footnote_collect(fnotes)
      seen = {}
      fnotes.each_with_object([]) do |x, m|
        x["id"] ||= "_#{UUIDTools::UUID.random_create}"
        seen[x["reference"]] or m << fnbody(x, seen)
        x["target"] = seen[x["reference"]]
        ref = x["hiddenref"] == "true" ? "" : fn_ref_label(x)
        x << "<fmt-fn-label>#{ref}</fmt-fn-label>"
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
      body["id"] = "_#{UUIDTools::UUID.random_create}"
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
        <fmt-fn-label>#{lbl}<span class="fmt-caption-delim"><tab/></fmt-fn-label>
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
      fnotes = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn"))
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
      table_fns = docxml.xpath(ns("//table//fn")) -
        docxml.xpath(ns("//table/name//fn"))
      fig_fns = docxml.xpath(ns("//figure//fn")) -
        docxml.xpath(ns("//figure/name//fn"))
      table_fns + fig_fns
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
      fn = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn"))
      fn.empty? and return
      dl = figure_key_insert_pt(elem)
      footnote_collect(fn).each do |f|
        label, fbody = figure_fn_to_dt_dd(f)
        dl.previous = "<dt><p>#{to_xml(label)}</p></dt><dd>#{to_xml(fbody)}</dd>"
      end
    end

    def figure_fn_to_dt_dd(f)
      label = f.at(ns(".//fmt-fn-label")).remove
      label.at(ns(".//span[@class = 'fmt-caption-delim']"))&.remove
      [label, f]
    end

    def figure_key_insert_pt(elem)
      elem.at(ns("//dl/name"))&.next ||
        elem.at(ns("//dl"))&.children&.first ||
        elem.add_child("<dl> </dl>").first.children.first
    end
  end
end
