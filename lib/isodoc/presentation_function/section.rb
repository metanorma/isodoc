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

    def references(docxml)
    end

    def docid_prefixes(docxml)
      docxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
        i.children = @xrefs.klass.docid_prefix(i["type"], i.text)
      end
    end

    def index(docxml)
      docxml.xpath(ns("//index | //index-xref | //indexsect")).each(&:remove)
    end

    def display_order_at(docxml, xpath, idx)
      return idx unless c = docxml.at(ns(xpath))

      idx += 1
      c["displayorder"] = idx
      idx
    end

    def display_order_xpath(docxml, xpath, idx)
      docxml.xpath(ns(xpath)).each do |c|
        idx += 1
        c["displayorder"] = idx
      end
      idx
    end

    def display_order(docxml)
      i = 0
      i = display_order_xpath(docxml, "//preface/*", i)
      i = display_order_at(docxml, "//clause[@type = 'scope']", i)
      i = display_order_at(docxml, @xrefs.klass.norm_ref_xpath, i)
      i = display_order_at(docxml, "//sections/terms | "\
                           "//sections/clause[descendant::terms]", i)
      i = display_order_at(docxml, "//sections/definitions", i)
      i = display_order_xpath(docxml, @xrefs.klass.middle_clause(docxml), i)
      i = display_order_xpath(docxml, "//annex", i)
      i = display_order_xpath(docxml, @xrefs.klass.bibliography_xpath, i)
      display_order_xpath(docxml, "//indexsect", i)
    end
  end
end
