require_relative "refs"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def middle_title(docxml)
      s = docxml.at(ns("//sections")) or return
      t = @meta.get[:doctitle]
      t.nil? || t.empty? and return
      s.add_first_child "<p class='zzSTDTitle1'>#{t}</p>"
    end

    def clause(docxml)
      docxml.xpath(ns("//clause | " \
                      "//terms | //definitions | //references"))
        .each do |f|
        f.parent.name == "annex" &&
          @xrefs.klass.single_term_clause?(f.parent) and next
        clause1(f)
      end
    end

    def unnumbered_clause?(elem)
      !elem.ancestors("boilerplate, metanorma-extension").empty? ||
        @suppressheadingnumbers || elem["unnumbered"] ||
        elem.at("./ancestor::*[@unnumbered = 'true']")
    end

    def clause1(elem)
      level = @xrefs.anchor(elem["id"], :level, false) ||
        (elem.ancestors("clause, annex").size + 1)
      t = elem.at(ns("./title")) and t["depth"] = level
      unnumbered_clause?(elem) and return
      lbl = @xrefs.anchor(elem["id"], :label,
                          elem.parent.name != "sections") or return
      prefix_name(elem, "<tab/>", "#{lbl}#{clausedelim}", "title")
    end

    def floattitle(docxml)
      p = "//clause | //annex | //appendix | //introduction | //foreword | " \
          "//preface/abstract | //acknowledgements | //terms | " \
          "//definitions | //references | //colophon | //indexsect"
      docxml.xpath(ns(p)).each { |f| floattitle1(f) }
      # top-level
      docxml.xpath(ns("//sections | //preface | //colophon"))
        .each { |f| floattitle1(f) }
    end

    # TODO not currently doing anything with the @depth attribute of floating-title
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
      t = elem.at(ns("./title")) and
        t.children = "<strong>#{to_xml(t.children)}</strong>"
      unnumbered_clause?(elem) and return
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
      c = docxml.at(ns(xpath)) or return idx
      idx += 1
      idx = preceding_floating_titles(c, idx)
      c["displayorder"] = idx
      idx
    end

    def display_order_xpath(docxml, xpath, idx)
      docxml.xpath(ns(xpath)).each do |c|
        idx += 1
        idx = preceding_floating_titles(c, idx)
        c["displayorder"] = idx
      end
      idx
    end

    def preceding_floating_titles(node, idx)
      out = node.xpath("./preceding-sibling::*")
        .reverse.each_with_object([]) do |p, m|
        %w(note admonition p).include?(p.name) or break m
        m << p
      end
      out.reject { |c| c["displayorder"] }.reverse_each do |c|
        c["displayorder"] = idx
        idx += 1
      end
      idx
    end

    def display_order(docxml)
      i = 0
      d = @xrefs.clause_order(docxml)
      %i(preface main annex back).each do |s|
        d[s].each do |a|
          i = if a[:multi]
                display_order_xpath(docxml, a[:path], i)
              else display_order_at(docxml, a[:path], i)
              end
        end
      end
    end

    def clausetitle(docxml)
      cjk_extended_title(docxml)
    end

    def cjk_search
      lang = %w(zh ja ko).map { |x| "@language = '#{x}'" }.join(" or ")
      %(Hans Hant Jpan Hang Kore).include?(@script) and
        lang += " or not(@language)"
      lang
    end

    def cjk_extended_title(docxml)
      l = cjk_search
      docxml.xpath(ns("//bibdata/title[#{l}] | //floating-title[#{l}] | " \
                      "//title[@depth = '1' or not(@depth)][#{l}]")).each do |t|
        t.text.size < 4 or next
        t.elements.empty? or next # can't be bothered
        t.children = @i18n.cjk_extend(t.text)
      end
    end

    def preface_rearrange(doc)
      preface_move(doc.at(ns("//preface/abstract")),
                   %w(foreword introduction clause acknowledgements), doc)
      preface_move(doc.at(ns("//preface/foreword")),
                   %w(introduction clause acknowledgements), doc)
      preface_move(doc.at(ns("//preface/introduction")),
                   %w(clause acknowledgements), doc)
      preface_move(doc.at(ns("//preface/acknowledgements")),
                   %w(), doc)
    end

    def preface_move(clause, after, _doc)
      clause or return
      preface = clause.parent
      float = preceding_floats(clause)
      prev = nil
      xpath = after.map { |n| "./self::xmlns:#{n}" }.join(" | ")
      xpath.empty? and xpath = "./self::*[not(following-sibling::*)]"
      preface_move1(clause, preface, float, prev, xpath)
    end

    def preface_move1(clause, preface, float, prev, xpath)
      preface.elements.each do |x|
        ((x.name == "floating-title" || x.at(xpath)) &&
        xpath != "./self::*[not(following-sibling::*)]") or prev = x
        x.at(xpath) or next
        clause == prev and break
        prev ||= preface.children.first
        float << clause
        float.each { |n| prev.next = n }
        break
      end
    end

    def preceding_floats(clause)
      ret = []
      p = clause
      while prev = p.previous_element
        if prev.name == "floating-title"
          ret << prev
          p = prev
        else break
        end
      end
      ret
    end

    def rearrange_clauses(docxml)
      preface_rearrange(docxml) # feeds toc_title
      toc_title(docxml)
    end

    def toc_title(docxml)
      docxml.at(ns("//preface/clause[@type = 'toc']")) and return
      ins = toc_title_insert_pt(docxml) or return
      id = UUIDTools::UUID.random_create.to_s
      ins.previous = <<~CLAUSE
        <clause type = 'toc' id='_#{id}'><title depth='1'>#{@i18n.table_of_contents}</title></clause>
      CLAUSE
    end

    def toc_title_insert_pt(docxml)
      ins = docxml.at(ns("//preface")) ||
        docxml.at(ns("//sections | //annex | //bibliography"))
          &.before("<preface> </preface>")
          &.previous_element or return nil
      ins.children.empty? and ins << " "
      ins.children.first
    end

    def toc(docxml)
      toc_refs(docxml)
    end

    def toc_refs(docxml)
      docxml.xpath(ns("//toc//xref[text()]")).each do |x|
        lbl = @xrefs.anchor(x["target"], :label) or next
        x.add_first_child "#{lbl}<tab/>"
      end
    end
  end
end
