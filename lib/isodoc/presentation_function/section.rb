require_relative "refs"
require_relative "title"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def clause(docxml)
      docxml.xpath(ns("//clause | //terms | //definitions | //references | " \
                      "//introduction | //foreword | //preface/abstract | " \
                      "//acknowledgements | //colophon | //indexsect "))
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

    def clausedelim
      ret = super
      ret && !ret.empty? or return ret
      "<span class='fmt-autonum-delim'>#{ret}</span>"
    end

    def clause1(elem)
      level = @xrefs.anchor(elem["id"], :level, false) ||
        (elem.ancestors("clause, annex").size + 1)
      lbl = @xrefs.anchor(elem["id"], :label, !unnumbered_clause?(elem))
      if unnumbered_clause?(elem) || !lbl
        prefix_name(elem, {}, nil, "title")
      else
        prefix_name(elem, { caption: "<tab/>" }, "#{lbl}#{clausedelim}",
                    "title")
      end
      t = elem.at(ns("./fmt-title")) and t["depth"] = level
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
      lbl = @xrefs.anchor(elem["id"], :label, false)
      # TODO: do not alter title, alter semx/@element = title
      t = elem.at(ns("./title")) and
        t.children = "<strong>#{to_xml(t.children)}</strong>"
      if unnumbered_clause?(elem)
        prefix_name(elem, {}, nil, "title")
      else
        prefix_name(elem, { caption: annex_delim(elem) }, lbl, "title")
      end
    end

    def annex_delim(_elem)
      "<br/><br/>"
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
          tit = c.at(ns("./fmt-title")) or next
          tit["depth"] = tit["depth"].to_i - 1 unless tit["depth"] == "1"
        end
    end

    def skip_display_order?(node)
      node.name == "floating-title"
    end

    def display_order_at(docxml, xpath, idx)
      c = docxml.at(ns(xpath)) or return idx
      skip_display_order?(c) and return idx
      idx += 1
      idx = preceding_floating_titles(c, idx)
      c["displayorder"] = idx
      idx
    end

    def display_order_xpath(docxml, xpath, idx)
      docxml.xpath(ns(xpath)).each do |c|
        skip_display_order?(c) and next
        idx += 1
        idx = preceding_floating_titles(c, idx)
        c["displayorder"] = idx
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

    def preface_rearrange(doc)
      preface_move(doc.xpath(ns("//preface/abstract")),
                   %w(foreword introduction clause acknowledgements), doc)
      preface_move(doc.xpath(ns("//preface/foreword")),
                   %w(introduction clause acknowledgements), doc)
      preface_move(doc.xpath(ns("//preface/introduction")),
                   %w(clause acknowledgements), doc)
      preface_move(doc.xpath(ns("//preface/acknowledgements")),
                   %w(), doc)
    end

    def preface_move(clauses, after, _doc)
      clauses.empty? and return
      preface = clauses.first.parent
      clauses.each do |clause|
      float = preceding_floats(clause)
      xpath = after.map { |n| "./self::xmlns:#{n}" }.join(" | ")
      xpath.empty? and xpath = "./self::*[not(following-sibling::*)]"
      preface_move1(clause, preface, float, nil, xpath)
      end
    end

    def preface_move1(clause, preface, float, prev, xpath)
      preface.elements.each do |x|
        ((x.name == "floating-title" || x.at(xpath)) &&
        xpath != "./self::*[not(following-sibling::*)]") or prev = x
        x.at(xpath) or next
        clause == prev and break
        prev ||= preface.children.first
        prev.next = clause
        float.each { |n| prev.next = n }
        break
      end
    end

    def rearrange_clauses(docxml)
      preface_rearrange(docxml) # feeds toc_title
      toc_title(docxml)
    end

    def toc(docxml)
      toc_refs(docxml)
    end

    def toc_refs(docxml)
      docxml.xpath(ns("//toc//xref[text()]")).each do |x|
        lbl = @xrefs.anchor(x["target"], :label) or next
        x.add_first_child "#{lbl}<span class='fmt-caption-delim'><tab/></span>"
      end
    end
  end
end
