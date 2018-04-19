require "uuidtools"

module IsoDoc
  class Convert
    def section_break(body)
      body.br
    end

    def page_break(out)
      out.br
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
      if node["citeas"].nil? && get_anchors.has_key?(node["bibitemid"])
        return get_anchors[node["bibitemid"]][:xref]
      elsif get_anchors.has_key?(node["target"])
        linkend = get_anchors[node["target"]][:xref]
        container = get_anchors[node["target"]][:container]
        (container && get_note_container_id(node) != container) &&
          linkend = l10n(get_anchors[container][:xref] + ", " + linkend)
      end
      linkend
    end

    def get_linkend(node)
      link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
      link += eref_localities(node.xpath(ns("./locality")))
      text = node.children.select { |c| c.text? && !c.text.empty? }
      link = text.join(" ") unless text.nil? || text.empty?
      # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
      # <locality type="section"><reference>3.1</reference></locality></origin>
      link
    end

    def xref_parse(node, out)
      linkend = get_linkend(node)
      out.a **{ "href": "#" + node["target"] } { |l| l << linkend }
    end

    def eref_localities(refs)
      ret = ""
      refs.each do |r|
        ret += if r["type"] == "whole" then l10n(", #{@whole_of_text}")
               else
                 eref_localities1(r["type"], r.at(ns("./referenceFrom")),
                                  r.at(ns("./referenceTo")), @lang)
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
      ooml = if node["type"] == "AsciiMath"
               "#{@openmathdelim}#{node.text}#{@closemathdelim}"
             elsif node["type"] == "MathML" then node.first_element_child.to_s
             else
               node.text
             end
      out.span **{ class: "stem" } do |span|
        span.parent.add_child ooml
      end
    end

    def error_parse(node, out)
      text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
      out.para do |p|
        p.b **{ role: "strong" } { |e| e << text }
      end
    end
  end
end
