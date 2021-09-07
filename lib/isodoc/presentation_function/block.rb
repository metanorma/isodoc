require "base64"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def lower2cap(text)
      return text if /^[[:upper:]][[:upper:]]/.match?(text)

      text.capitalize
    end

    def figure(docxml)
      docxml.xpath(ns("//image")).each { |f| svg_extract(f) }
      docxml.xpath(ns("//figure")).each { |f| figure1(f) }
      docxml.xpath(ns("//svgmap")).each do |s|
        if f = s.at(ns("./figure")) then s.replace(f)
        else s.remove
        end
      end
    end

    def svg_extract(elem)
      return unless %r{^data:image/svg\+xml;base64,}.match?(elem["src"])

      svg = Base64.strict_decode64(elem["src"]
        .sub(%r{^data:image/svg\+xml;base64,}, ""))
      x = Nokogiri::XML.fragment(svg.sub(/<\?xml[^>]*>/, "")) do |config|
        config.huge
      end
      elem.replace(x)
    end

    def figure1(elem)
      return sourcecode1(elem) if elem["class"] == "pseudocode" ||
        elem["type"] == "pseudocode"
      return if labelled_ancestor(elem) && elem.ancestors("figure").empty? ||
        elem.at(ns("./figure")) && !elem.at(ns("./name"))

      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, "&nbsp;&mdash; ",
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end

    def prefix_name(node, delim, number, elem)
      return if number.nil? || number.empty?

      unless name = node.at(ns("./#{elem}"))
        node.children.empty? and node.add_child("<#{elem}></#{elem}>") or
          node.children.first.previous = "<#{elem}></#{elem}>"
        name = node.children.first
      end
      if name.children.empty? then name.add_child(number)
      else (name.children.first.previous = "#{number}#{delim}")
      end
    end

    def sourcecode(docxml)
      docxml.xpath(ns("//sourcecode")).each do |f|
        sourcecode1(f)
      end
    end

    def sourcecode1(elem)
      return if labelled_ancestor(elem)
      return unless elem.ancestors("example").empty?

      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, "&nbsp;&mdash; ",
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each do |f|
        formula1(f)
      end
    end

    # introduce name element
    def formula1(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, "", lbl, "name")
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each do |f|
        example1(f)
      end
    end

    def termexample(docxml)
      docxml.xpath(ns("//termexample")).each do |f|
        example1(f)
      end
    end

    def example1(elem)
      n = @xrefs.get[elem["id"]]
      lbl = if n.nil? || n[:label].nil? || n[:label].empty?
              @i18n.example
            else
              l10n("#{@i18n.example} #{n[:label]}")
            end
      prefix_name(elem, "&nbsp;&mdash; ", lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each do |f|
        note1(f)
      end
    end

    # introduce name element
    def note1(elem)
      return if elem.parent.name == "bibitem"

      n = @xrefs.get[elem["id"]]
      lbl = if n.nil? || n[:label].nil? || n[:label].empty?
              @i18n.note
            else
              l10n("#{@i18n.note} #{n[:label]}")
            end
      prefix_name(elem, "", lbl, "name")
    end

    def termnote(docxml)
      docxml.xpath(ns("//termnote")).each do |f|
        termnote1(f)
      end
    end

    # introduce name element
    def termnote1(elem)
      lbl = l10n(@xrefs.anchor(elem["id"], :label) || "???")
      prefix_name(elem, "", lower2cap(lbl), "name")
    end

    def termdefinition(docxml)
      docxml.xpath(ns("//term[definition]")).each do |f|
        termdefinition1(f)
      end
    end

    def termdefinition1(elem)
      return unless elem.xpath(ns("./definition")).size > 1

      d = elem.at(ns("./definition"))
      d = d.replace("<ol><li>#{d.children.to_xml}</li></ol>").first
      elem.xpath(ns("./definition")).each do |f|
        f = f.replace("<li>#{f.children.to_xml}</li>").first
        d << f
      end
      d.wrap("<definition></definition>")
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

    # introduce name element
    def recommendation1(elem, type)
      n = @xrefs.anchor(elem["id"], :label, false)
      lbl = (n.nil? ? type : l10n("#{type} #{n}"))
      prefix_name(elem, "", lbl, "name")
    end

    def table(docxml)
      docxml.xpath(ns("//table")).each do |f|
        table1(f)
      end
    end

    def table1(elem)
      return if labelled_ancestor(elem)
      return if elem["unnumbered"] && !elem.at(ns("./name"))

      n = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, "&nbsp;&mdash; ", l10n("#{lower2cap @i18n.table} #{n}"),
                  "name")
    end

    # we use this to eliminate the semantic amend blocks from rendering
    def amend(docxml)
      docxml.xpath(ns("//amend")).each do |f|
        amend1(f)
      end
    end

    def amend1(elem)
      elem.xpath(ns("./autonumber")).each(&:remove)
      elem.xpath(ns("./newcontent")).each { |a| a.name = "quote" }
      elem.xpath(ns("./description")).each { |a| a.replace(a.children) }
      elem.replace(elem.children)
    end
  end
end
