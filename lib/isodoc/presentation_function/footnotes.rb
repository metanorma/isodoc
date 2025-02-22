module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def footnote_collect(fnotes)
      seen = {}
      ret = fnotes.each_with_object([]) do |x, m|
        x["id"] ||= "_#{UUIDTools::UUID.random_create}"
        seen[x["reference"]] or m << fnbody(x, seen)
        x["target"] = seen[x["reference"]]
      end
      footnote_container(fnotes, ret)
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
      insert_fn_ref(fnote, body)
      seen[fnote["reference"]] = body["id"]
      body
    end

    def insert_fn_ref(fnote, body)
      ins = body.at(ns(".//p")) ||
        body.at(ns("./semx")).children.first.before("<p> </p>").previous
      lbl = fn_label(fnote)
      ins.children.first.previous = <<~FNOTE.strip
        <span class="fmt-footnote-label"><sup>#{lbl}</sup><span class="fmt-caption-delim"><tab/></span>
      FNOTE
    end

    def fn_label(fnote)
      <<~FNOTE.strip
        <semx element="autonum" source="#{fnote['id']}">#{fnote['reference']}</semx>
      FNOTE
    end

    def table_fn(elem)
      fns = footnote_collect((elem.xpath(ns(".//fn")) -
                              elem.xpath(ns("./name//fn")))) and
        elem << fns
    end

    def document_footnotes(docxml)
      sects = docxml.xpath(".//*[@displayorder]")
        .sort_by { |c| c["displayorder"].to_i }
      excl = non_document_footnotes(docxml)
      fns = filter_document_footnotes(sects, excl)
      fns = renumber_document_footnotes(fns, 1)
      fns = footnote_collect(fns)
      fns and docxml.root << fns
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
  end
end
