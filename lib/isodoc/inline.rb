require "uuidtools"

module IsoDoc
  class Convert
    def section_break(body)
      body.br **{ clear: "all", class: "section" }
    end

    def page_break(body)
      body.br **{
        clear: "all",
        style: "mso-special-character:line-break;page-break-before:always",
      }
    end

    def link_parse(node, out)
      linktext = node.text
      linktext = node["target"] if linktext.empty?
      out.a **{ "href": node["target"] } { |l| l << linktext }
    end

    def callout_parse(node, out)
      out << " &lt;#{node.text}&gt;"
    end

    def anchor_linkend(node, linkend)
      if get_anchors().has_key?(node["target"])
        linkend = get_anchors()[node["target"]][:xref]
        container = get_anchors()[node["target"]][:container]
        (container && get_note_container_id(node) != container) &&
          linkend = get_anchors()[container][:xref] + ", " + linkend
      end
      if node["citeas"].nil? && get_anchors().has_key?(node["bibitemid"])
        linkend = get_anchors()[node["bibitemid"]][:xref]
      end
      linkend
    end

    def get_linkend(node)
      clause_id = get_clause_id(node)
      linkend = node["target"] || node["citeas"]
      linkend = anchor_linkend(node, linkend)
      linkend += eref_localities(node.xpath(ns("./locality"))) 
      text = node.children.select { |c| c.text? && !c.text.empty? }
      linkend = text.join(" ") unless text.nil? || text.empty?
      # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
      # <locality type="section"><reference>3.1</reference></locality></origin>
      linkend
    end

    def xref_parse(node, out)
      linkend = get_linkend(node)
      out.a **{ "href": "#" + node["target"] } { |l| l << linkend }
    end

    def eref_localities(r)
      ret = ""
      r.each do |r|
        if r["type"] == "whole"
          ret += ", Whole of text"
        else
          ret += ", #{r["type"].capitalize}"
          refFrom = r.at(ns("./referenceFrom"))
          refTo = r.at(ns("./referenceTo"))
          ret += " #{refFrom.text}" if refFrom
          ret += "&ndash;#{refTo.text}" if refTo
        end
      end
      ret
    end

    def eref_parse(node, out)
      linkend = get_linkend(node)
      if node["type"] == "footnote"
        out.sup do |s|
          s.a **{ "href": "#" + node["bibitemid"] } { |l| l << linkend }
        end
      else
        out.a **{ "href": "#" + node["bibitemid"] } { |l| l << linkend }
      end
    end

    def stem_parse(node, out)
      ooml = if node["type"] == "AsciiMath" then "`#{node.text}`"
             elsif node["type"] == "MathML" then node.first_element_child.to_s
             else
               node.text
             end
      out.span **{ class: "stem" } do |span|
        span.parent.add_child ooml
      end
    end

    def pagebreak_parse(node, out)
      attrs = { clear: all, class: "pagebreak" }
      out.br **attrs
    end

    def error_parse(node, out)
      text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
      out.para do |p|
        p.b **{ role: "strong" } { |e| e << text }
      end
    end
  end
end
