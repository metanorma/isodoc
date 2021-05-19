module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def clause(docxml)
      docxml.xpath(ns("//clause | "\
                      "//terms | //definitions | //references"))
        .each do |f|
        clause1(f)
      end
    end

    def clause1(elem)
      level = @xrefs.anchor(elem["id"], :level, false) || "1"
      t = elem.at(ns("./title")) and t["depth"] = level
      return if !elem.ancestors("boilerplate").empty? ||
        @suppressheadingnumbers || elem["unnumbered"]

      lbl = @xrefs.anchor(elem["id"], :label,
                          elem.parent.name != "sections") or return
      prefix_name(elem, "<tab/>", "#{lbl}#{clausedelim}", "title")
    end

    def annex(docxml)
      docxml.xpath(ns("//annex")).each do |f|
        annex1(f)
      end
    end

    def annex1(elem)
      lbl = @xrefs.anchor(elem["id"], :label)
      if t = elem.at(ns("./title"))
        t.children = "<strong>#{t.children.to_xml}</strong>"
      end
      prefix_name(elem, "<br/><br/>", lbl, "title")
    end

    def term(docxml)
      docxml.xpath(ns("//term")).each do |f|
        term1(f)
      end
    end

    def term1(elem)
      lbl = @xrefs.get[elem["id"]][:label] or return
      prefix_name(elem, "", "#{lbl}#{clausedelim}", "name")
    end

    def references(docxml); end

    def index(docxml)
      docxml.xpath(ns("//index | //index-xref | //indexsect")).each(&:remove)
    end
  end
end
