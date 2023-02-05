require_relative "./image"
require_relative "./sourcecode"
require "rouge"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def lower2cap(text)
      return text if /^[[:upper:]][[:upper:]]/.match?(text)

      text.capitalize
    end

    def block_delim
      "&#xa0;&#x2014; "
    end

    def prefix_name(node, delim, number, elem)
      number.nil? || number.empty? and return
      unless name = node.at(ns("./#{elem}"))
        (node.children.empty? and node.add_child("<#{elem}></#{elem}>")) or
          node.children.first.previous = "<#{elem}></#{elem}>"
        name = node.children.first
      end
      if name.children.empty? then name.add_child(cleanup_entities(number.strip))
      else (name.children.first.previous = "#{number.strip}#{delim}")
      end
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each { |f| formula1(f) }
    end

    def formula1(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, "", lbl, "name")
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each { |f| example1(f) }
    end

    def example1(elem)
      n = @xrefs.get[elem["id"]]
      lbl = if n.nil? || n[:label].nil? || n[:label].empty?
              @i18n.example
            else l10n("#{@i18n.example} #{n[:label]}")
            end
      prefix_name(elem, block_delim, lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each { |f| note1(f) }
    end

    def note1(elem)
      %w(bibdata bibitem).include?(elem.parent.name) ||
        elem["notag"] == "true" and return
      n = @xrefs.get[elem["id"]]
      lbl = @i18n.note
      (n.nil? || n[:label].nil? || n[:label].empty?) or
        lbl = l10n("#{lbl} #{n[:label]}")
      prefix_name(elem, "", lbl, "name")
    end

    def admonition(docxml)
      docxml.xpath(ns("//admonition")).each { |f| admonition1(f) }
    end

    def admonition1(elem)
      if elem["type"] == "box"
        admonition_numbered1(elem)
      else
        elem["notag"] == "true" || elem.at(ns("./name")) and return
        prefix_name(elem, "", @i18n.admonition[elem["type"]]&.upcase, "name")
      end
    end

    def admonition_numbered1(elem)
      elem["unnumbered"] && !elem.at(ns("./name")) and return
      n = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, block_delim, l10n("#{@i18n.box} #{n}"), "name")
    end

    def recommendation(docxml)
      docxml.xpath(ns("//recommendation")).each do |f|
        recommendation1(f, lower2cap(@i18n.recommendation))
      end
    end

    def requirement(docxml)
      docxml.xpath(ns("//requirement")).each do |f|
        recommendation1(f, lower2cap(@i18n.requirement))
      end
    end

    def permission(docxml)
      docxml.xpath(ns("//permission")).each do |f|
        recommendation1(f, lower2cap(@i18n.permission))
      end
    end

    def recommendation1(elem, type)
      lbl = @reqt_models.model(elem["model"])
        .recommendation_label(elem, type, xrefs)
      prefix_name(elem, "", l10n(lbl), "name")
    end

    def table(docxml)
      docxml.xpath(ns("//table")).each { |f| table1(f) }
    end

    def table1(elem)
      labelled_ancestor(elem) and return
      elem["unnumbered"] && !elem.at(ns("./name")) and return
      n = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, block_delim, l10n("#{lower2cap @i18n.table} #{n}"),
                  "name")
    end

    # we use this to eliminate the semantic amend blocks from rendering
    def amend(docxml)
      docxml.xpath(ns("//amend")).each { |f| amend1(f) }
    end

    def amend1(elem)
      elem.xpath(ns("./autonumber")).each(&:remove)
      elem.xpath(ns("./newcontent")).each { |a| a.name = "quote" }
      elem.xpath(ns("./description")).each { |a| a.replace(a.children) }
      elem.replace(elem.children)
    end

    def ol(docxml)
      docxml.xpath(ns("//ol")).each { |f| ol1(f) }
      @xrefs.list_anchor_names(docxml.xpath(ns(@xrefs.sections_xpath)))
    end

    # We don't really want users to specify type of ordered list;
    # we will use by default a fixed hierarchy as practiced by ISO (though not
    # fully spelled out): a) 1) i) A) I)
    def ol_depth(node)
      depth = node.ancestors("ul, ol").size + 1
      type = :alphabet
      type = :arabic if [2, 7].include? depth
      type = :roman if [3, 8].include? depth
      type = :alphabet_upper if [4, 9].include? depth
      type = :roman_upper if [5, 10].include? depth
      type
    end

    def ol1(elem)
      elem["type"] ||= ol_depth(elem).to_s
    end

    def requirement_render_preprocessing(docxml); end

    REQS = %w(requirement recommendation permission).freeze

    def requirement_render(docxml)
      requirement_render_preprocessing(docxml)
      REQS.each do |x|
        REQS.each do |y|
          docxml.xpath(ns("//#{x}//#{y}")).each { |r| requirement_render1(r) }
        end
      end
      docxml.xpath(ns("//requirement | //recommendation | //permission"))
        .each { |r| requirement_render1(r) }
    end

    def requirement_render1(node)
      node.replace(@reqt_models.model(node["model"])
        .requirement_render1(node))
    end
  end
end
