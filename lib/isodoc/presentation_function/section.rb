require_relative "refs"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def clause(docxml)
      docxml.xpath(ns("//clause | " \
                      "//terms | //definitions | //references"))
        .each do |f|
        f.parent.name == "annex" &&
          @xrefs.klass.single_term_clause?(f.parent) and next

        clause1(f)
      end
    end

    def clause1(elem)
      level = @xrefs.anchor(elem["id"], :level, false) ||
        (elem.ancestors("clause, annex").size + 1)
      t = elem.at(ns("./title")) and t["depth"] = level
      return if !elem.ancestors("boilerplate").empty? ||
        @suppressheadingnumbers || elem["unnumbered"]

      lbl = @xrefs.anchor(elem["id"], :label,
                          elem.parent.name != "sections") or return
      prefix_name(elem, "<tab/>", "#{lbl}#{clausedelim}", "title")
    end

    def floattitle(docxml)
      docxml.xpath(ns("//clause | //annex | //appendix | //introduction | " \
                      "//foreword | //preface/abstract | //acknowledgements | " \
                      "//terms | //definitions | //references"))
        .each do |f|
        floattitle1(f)
      end
      # top-level
      docxml.xpath(ns("//sections | //preface")).each { |f| floattitle1(f) }
    end

    def floattitle1(elem)
      elem.xpath(ns(".//floating-title")).each do |p|
        p.name = "p"
        p["type"] = "floating-title"
      end
    end

    def annex(docxml)
      docxml.xpath(ns("//annex")).each do |f|
        @xrefs.klass.single_term_clause?(f) and single_term_clause_retitle(f)
        annex1(f)
        @xrefs.klass.single_term_clause?(f) and single_term_clause_unnest(f)
      end
      @xrefs.parse_inclusions(clauses: true).parse(docxml)
    end

    def annex1(elem)
      lbl = @xrefs.anchor(elem["id"], :label)
      if t = elem.at(ns("./title"))
        t.children = "<strong>#{t.children.to_xml}</strong>"
      end
      prefix_name(elem, "<br/><br/>", lbl, "title")
    end

    def single_term_clause_retitle(elem)
      t = elem.at(ns("./terms | ./definitions | ./references"))
      title1 = elem.at(ns("./title"))
      title2 = t.at(ns("./title"))&.remove
      !title1 && title2 and
        elem.first_element_child.previous = title2
    end

    def single_term_clause_unnest(elem)
      t = elem.at(ns("./terms | ./definitions | ./references"))
      t.xpath(ns(".//clause | .//terms | .//definitions | .//references"))
        .each do |c|
          tit = c.at(ns("./title")) or return
          tit["depth"] = tit["depth"].to_i - 1 unless tit["depth"] == "1"
        end
    end

    def term(docxml)
      docxml.xpath(ns("//term")).each do |f|
        term1(f)
      end
    end

    def term1(elem)
      lbl = @xrefs.anchor(elem["id"], :label) or return
      prefix_name(elem, "", "#{lbl}#{clausedelim}", "name")
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
      i = display_order_at(docxml, "//sections/terms | " \
                                   "//sections/clause[descendant::terms]", i)
      i = display_order_at(docxml, "//sections/definitions", i)
      i = display_order_xpath(docxml, @xrefs.klass.middle_clause(docxml), i)
      i = display_order_xpath(docxml, "//annex", i)
      i = display_order_xpath(docxml, @xrefs.klass.bibliography_xpath, i)
      display_order_xpath(docxml, "//indexsect", i)
    end

    def clausetitle(docxml); end

    def toc(docxml)
      docxml.xpath(ns("//toc//xref[text()]")).each do |x|
        lbl = @xrefs.anchor(x["target"], :label) or next
        x.children.first.previous = "#{lbl}<tab/>"
      end
    end
  end
end
