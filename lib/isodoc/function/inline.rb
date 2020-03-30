module IsoDoc::Function
  module Inline
    def section_break(body)
      body.br
    end

    def page_break(out)
      out.br
    end

    def pagebreak_parse(_node, out)
      out.br
    end

    def hr_parse(node, out)
      out.hr
    end

    def br_parse(node, out)
      out.br
    end

    def index_parse(node, out)
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
      l10n(anchor(container, :xref) + ", " + linkend)
    end

    def anchor_linkend(node, linkend)
      if node["citeas"].nil? && node["bibitemid"] 
        return anchor(node["bibitemid"] ,:xref) || "???"
      elsif node["target"] && !/.#./.match(node["target"])
        linkend = anchor(node["target"], :xref)
        container = anchor(node["target"], :container, false)
        (container && get_note_container_id(node) != container &&
         @anchors[node["target"]]) &&
        linkend = prefix_container(container, linkend, node["target"])
      end
      linkend || "???"
    end

    def get_linkend(node)
      contents = node.children.select { |c| c.name != "locality" }.
        select { |c| !c.text? || /\S/.match(c) }
      !contents.empty? and
        return Nokogiri::XML::NodeSet.new(node.document, contents).to_xml
      link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
      link + eref_localities(node.xpath(ns("./locality")), link)
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

    def termrefelem_parse(node, out)
      out << "Termbase #{node['base']}, term ID #{node['target']}"
    end

    def concept_parse(node, out)
      content = node.first_element_child.children.select { |c| c.name != "locality" }.
        select { |c| !c.text? || /\S/.match(c) }
      if content.empty?
        out << "[Term defined in "
        parse(node.first_element_child, out)
        out << "]"
      else
        content.each { |n| parse(n, out) }
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

    def image_title_parse(out, caption)
      unless caption.nil?
        out.p **{ class: "FigureTitle", style: "text-align:center;" } do |p|
          p.b { |b| b << caption.to_s }
        end
      end
    end

    def image_parse(node, out, caption)
      attrs = { src: node["src"],
                height: node["height"] || "auto",
                width: node["width"] || "auto",
                title: node["title"],
                alt: node["alt"]  }
      out.img **attr_code(attrs)
      image_title_parse(out, caption)
    end

    def smallcap_parse(node, xml)
      xml.span **{ style: "font-variant:small-caps;" } do |s|
        node.children.each { |n| parse(n, s) }
      end
    end

    def text_parse(node, out)
      return if node.nil? || node.text.nil?
      text = node.to_s
      text = text.gsub("\n", "<br/>").gsub("<br/> ", "<br/>&nbsp;").
        gsub(/[ ](?=[ ])/, "&nbsp;") if in_sourcecode
      out << text
    end

    def bookmark_parse(node, out)
      out.a **attr_code(id: node["id"])
    end

    def keyword_parse(node, out)
      out.span **{ class: "keyword" } do |s|
        node.children.each { |n| parse(n, s) }
      end
    end

    def em_parse(node, out)
      out.i do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strong_parse(node, out)
      out.b do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sup_parse(node, out)
      out.sup do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sub_parse(node, out)
      out.sub do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def tt_parse(node, out)
      out.tt do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strike_parse(node, out)
      out.s do |e|
        node.children.each { |n| parse(n, e) }
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
