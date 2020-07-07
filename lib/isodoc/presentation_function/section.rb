module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def clause(docxml)
      docxml.xpath(ns("//clause | "\
                      "//terms | //definitions | //references")).
                     each do |f|
        clause1(f)
      end
    end

    def clause1(f)
      level = @xrefs.anchor(f['id'], :level, false) || "1"
      t = f.at(ns("./title")) and t["depth"] = level
      return if !f.ancestors("boilerplate").empty?
      return if @suppressheadingnumbers || f["unnumbered"]
      lbl = @xrefs.anchor(f['id'], :label,
                          f.parent.name != "sections") or return
      prefix_name(f, "<tab/>", "#{lbl}#{clausedelim}", "title")
    end

    def annex(docxml)
      docxml.xpath(ns("//annex")).each do |f|
        annex1(f)
      end
    end

    def annex1(f)
      lbl = @xrefs.anchor(f['id'], :label)
      if t = f.at(ns("./title"))
        t.children = "<strong>#{t.children.to_xml}</strong>"
      end
      prefix_name(f, "<br/><br/>", lbl, "title")
    end

    def term(docxml)
      docxml.xpath(ns("//term")).each do |f|
        term1(f)
      end
    end

    def term1(f)
      lbl = @xrefs.get[f["id"]][:label] or return
      prefix_name(f, "", "#{lbl}#{clausedelim}", "name")
    end
  end
end
