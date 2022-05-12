require_relative "../../relaton/render/general"

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

    def floattitle(docxml)
      docxml.xpath(ns("//clause | //annex | //appendix | //introduction | "\
                      "//foreword | //preface/abstract | //acknowledgements | "\
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
        annex1(f)
        @xrefs.klass.single_term_clause?(f) and single_term_clause(f)
      end
    end

    def annex1(elem)
      lbl = @xrefs.anchor(elem["id"], :label)
      if t = elem.at(ns("./title"))
        t.children = "<strong>#{t.children.to_xml}</strong>"
      end
      prefix_name(elem, "<br/><br/>", lbl, "title")
    end

    def single_term_clause(elem)
      t = elem.at(ns("./terms | ./definitions | ./references"))
      t.at(ns("./title"))&.remove
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
      lbl = @xrefs.get[elem["id"]][:label] or return
      prefix_name(elem, "", "#{lbl}#{clausedelim}", "name")
    end

    def references(docxml)
      bibliography_bibitem_number(docxml)
      docxml.xpath(ns("//references/bibitem")).each do |x|
        bibitem(x)
      end
      @xrefs.parse_inclusions(refs: true).parse(docxml)
    end

    def bibitem(xml)
      bibrender(xml)
    end

    def bibrender(xml)
      if f = xml.at(ns("./formattedref"))
        code = render_identifier(bibitem_ref_code(xml))
        f << " [#{code[:sdo]}] " if code[:sdo]
      else
        xml.children =
          "#{bibrenderer.render(xml.to_xml)}"\
          "#{xml.xpath(ns('./docidentifier | ./uri | ./note')).to_xml}"
      end
    end

    def bibrenderer
      ::Relaton::Render::IsoDoc::General.new(language: @lang)
    end

    def bibliography_bibitem_number_skip(bibitem)
      @xrefs.klass.implicit_reference(bibitem) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma']")) ||
        bibitem.at(ns(".//docidentifier[@type = 'metanorma-ordinal']")) ||
        bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
    end

    def bibliography_bibitem_number(docxml)
      i = 0
      docxml.xpath(ns("//references[@normative = 'false']/bibitem")).each do |b|
        i = bibliography_bibitem_number1(b, i)
      end
      @xrefs.references docxml
    end

    def bibliography_bibitem_number1(bibitem, idx)
      if mn = bibitem.at(ns(".//docidentifier[@type = 'metanorma']"))
        /^\[?\d\]?$/.match?(mn&.text) and
          idx = mn.text.sub(/^\[/, "").sub(/\]$/, "").to_i
      end
      unless bibliography_bibitem_number_skip(bibitem)

        idx += 1
        bibitem.at(ns(".//docidentifier")).previous =
          "<docidentifier type='metanorma-ordinal'>[#{idx}]</docidentifier>"
      end
      idx
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

    def clausetitle(docxml); end

    def toc(docxml)
      docxml.xpath(ns("//toc//xref[text()]")).each do |x|
        lbl = @xrefs.get[x["target"]][:label] or next
        x.children.first.previous = "#{lbl}<tab/>"
      end
    end
  end
end
