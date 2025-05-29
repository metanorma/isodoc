require_relative "refs"
require_relative "title"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def clause(docxml)
      docxml.xpath(ns("//clause | //terms | //definitions | //references | " \
                      "//introduction | //foreword | //preface/abstract | " \
                      "//acknowledgements | //colophon | //indexsect | " \
                      "//executivesummary | //appendix")).each do |f|
        f.parent.name == "annex" &&
          @xrefs.klass.single_term_clause?(f.parent) and next
        clause1(f)
      end
    end

    def unnumbered_clause?(elem)
      numbered_clause_invalid_context?(elem) ||
        @suppressheadingnumbers || elem["unnumbered"] ||
        elem.at("./ancestor::*[@unnumbered = 'true']")
    end

    # context in which clause numbering is invalid:
    # metanorma-extension, boilerplate
    def numbered_clause_invalid_context?(elem)
      @ncic_cache ||= {}
      elem or return false
      @ncic_cache.key?(elem) and return @ncic_cache[elem]
      if ["metanorma-extension", "boilerplate"].include?(elem.name)
        @ncic_cache[elem] = true
      else
        elem.respond_to?(:parent) or return false
        @ncic_cache[elem] = numbered_clause_invalid_context?(elem.parent)
      end
    end

    def clausedelim
      ret = super
      ret && !ret.empty? or return ret
      "<span class='fmt-autonum-delim'>#{ret}</span>"
    end

    def clause1(elem)
      level = @xrefs.anchor(elem["id"], :level, false) ||
        (elem.ancestors("clause, annex").size + 1)
      is_unnumbered = unnumbered_clause?(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false)
      if is_unnumbered || !lbl
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
      [["//preface/abstract",
        %w(foreword introduction clause acknowledgements executivesummary)],
       ["//preface/foreword",
        %w(introduction clause acknowledgements executivesummary)],
       ["//preface/introduction", %w(clause acknowledgements executivesummary)],
       ["//preface/acknowledgements", %w(executivesummary)],
       ["//preface/executivesummary", %w()]].each do |x|
        preface_move(doc.xpath(ns(x[0])), x[1], doc)
      end
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
        lbl = @xrefs.anchor(x["target"], :label, false) or next
        x.add_first_child "#{lbl}<span class='fmt-caption-delim'><tab/></span>"
      end
    end
  end
end
