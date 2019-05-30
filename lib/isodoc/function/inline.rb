module IsoDoc::Function
  module Inline
    def section_break(body)
      body.br
    end

    def page_break(out)
      out.br
    end

    def link_parse(node, out)
      out.a **attr_code(href: node["target"], title: node["alt"]) do |l|
        if node.text.empty?
          l << node["target"].sub(/^mailto:/, "")
        else
          node.children.each { |n| parse(n, l) }
        end
      end
    end

    def callout_parse(node, out)
      out << " &lt;#{node.text}&gt;"
    end

    def prefix_container(container, linkend, _target)
      #l10n(get_anchors[container][:xref] + ", " + linkend)
      l10n(anchor(container, :xref) + ", " + linkend)
    end

    def anchor_linkend(node, linkend)
      if node["citeas"].nil? && node["bibitemid"] #&&
          #get_anchors.has_key?(node["bibitemid"])
        #return get_anchors.dig(node["bibitemid"] ,:xref)
        return anchor(node["bibitemid"] ,:xref) || "???"
      #elsif node["target"] && get_anchors.has_key?(node["target"])
      elsif node["target"] && !/.#./.match(node["target"])
        #linkend = get_anchors[node["target"]][:xref]
        linkend = anchor(node["target"], :xref)
        #container = get_anchors[node["target"]][:container]
        container = anchor(node["target"], :container, false)
        (container && get_note_container_id(node) != container) &&
          linkend = prefix_container(container, linkend, node["target"])
      end
      linkend || "???"
    end

    def get_linkend(node)
      link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
      link += eref_localities(node.xpath(ns("./locality")), link)
      #text = node.children.select { |c| c.text? && !c.text.empty? }
      #link = text.join(" ") unless text.nil? || text.empty?
      contents = node.children.select { |c| c.name != "locality" }
      return link if contents.nil? || contents.empty?
      Nokogiri::XML::NodeSet.new(node.document, contents).to_xml
      # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
      # <locality type="section"><reference>3.1</reference></locality></origin>
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".html#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end

    def eref_localities(refs, target)
      ret = ""
      refs.each do |r|
        ret += if r["type"] == "whole" then l10n(", #{@whole_of_text}")
               else
                 eref_localities1(target, r["type"], r.at(ns("./referenceFrom")),
                                  r.at(ns("./referenceTo")), @lang)
               end
      end
      ret
    end

    def eref_parse(node, out)
      linkend = get_linkend(node)
      if node["type"] == "footnote"
        out.sup do |s|
          s.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
        end
      else
        out.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
      end
    end

    def stem_parse(node, out)
      ooml = if node["type"] == "AsciiMath"
               "#{@openmathdelim}#{HTMLEntities.new.encode(node.text)}#{@closemathdelim}"
             elsif node["type"] == "MathML" then node.first_element_child.to_s
             else
               HTMLEntities.new.encode(node.text)
             end
      out.span **{ class: "stem" } do |span|
        span.parent.add_child ooml
      end
    end

    def error_parse(node, out)
      text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
      out.para do |p|
        p.b(**{ role: "strong" }) { |e| e << text }
      end
    end
  end
end
