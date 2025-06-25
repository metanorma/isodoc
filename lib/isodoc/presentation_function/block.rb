require_relative "image"
require_relative "sourcecode"
require_relative "autonum"
require "rouge"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def lower2cap(text)
      text.nil? and return text
      x = Nokogiri::XML("<a>#{text}</a>")
      firsttext = x.at(".//text()[string-length(normalize-space(.))>0]") or
        return text
      /^[[:upper:]][[:upper:]]/.match?(firsttext.text) and return text
      firsttext.replace(firsttext.text.capitalize)
      to_xml(x.root.children)
    end

    def block_delim
      "&#xa0;&#x2014; "
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each { |f| formula1(f) }
    end

    def formula1(elem)
      formula_where(elem.at(ns("./dl")))
      lbl = @xrefs.anchor(elem["id"], :label, false)
      lbl.nil? || lbl.empty? or prefix_name(elem, {}, lbl, "name")
    end

    def formula_where(dlist)
      dlist or return
      dlist["class"] = "formula_dl"
      where = dlist.xpath(ns("./dt")).size > 1 ? @i18n.where : @i18n.where_one
      dlist.previous = "<p keep-with-next='true'>#{where}</p>"
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each { |f| example1(f) }
    end

    def example1(elem)
      n = @xrefs.get[elem["id"]]
      lbl = labelled_autonum(@i18n.example, elem["id"], n&.dig(:label))
      prefix_name(elem, { caption: block_delim }, lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each { |f| note1(f) }
    end

    def note_delim(_elem)
      "<tab/>"
    end

    def note1(elem)
      %w(bibdata bibitem).include?(elem.parent.name) ||
        elem["notag"] == "true" or lbl = note_label(elem)
      prefix_name(elem, { label: note_delim(elem) }, lbl, "name")
    end

    def note_label(elem)
      n = @xrefs.get[elem["id"]]
      labelled_autonum(@i18n.note, elem["id"], n&.dig(:label))
    end

    def admonition(docxml)
      docxml.xpath(ns("//admonition")).each { |f| admonition1(f) }
    end

    def admonition1(elem)
      if elem["type"] == "box"
        admonition_numbered1(elem)
      elsif elem["notag"] == "true" || elem.at(ns("./name"))
        prefix_name(elem, { label: admonition_delim(elem) }, nil, "name")
      else
        label = admonition_label(elem, nil)
        prefix_name(elem, { label: admonition_delim(elem) }, label, "name")
      end
    end

    def admonition_numbered1(elem)
      label = admonition_label(elem, @xrefs.anchor(elem["id"], :label, false))
      prefix_name(elem, { caption: block_delim }, label, "name")
    end

    def admonition_label(elem, num)
      lbl = if elem["type"] == "box" then @i18n.box
            else @i18n.admonition[elem["type"]]&.upcase end
      labelled_autonum(lbl, elem["id"], num)
    end

    def admonition_delim(_elem)
      ""
    end

    def table(docxml)
      table_long_strings_cleanup(docxml)
      docxml.xpath(ns("//table")).each { |f| table1(f) }
    end

    def table1(elem)
      table_fn(elem)
      table_css(elem)
      labelled_ancestor(elem) and return
      elem["unnumbered"] && !elem.at(ns("./name")) and return
      n = @xrefs.anchor(elem["id"], :label, false)
      lbl = labelled_autonum(lower2cap(@i18n.table), elem["id"], n)
      prefix_name(elem, { caption: table_delim }, l10n(lbl), "name")
    end

    def table_css(elem)
      parser = IsoDoc::CssBorderParser::BorderParser.new
      elem.xpath(ns(".//tr | .//th | .//td | .//table")).each do |n|
        n["style"] or next
        parsed_properties = parser.parse_declaration(n["style"])
        new_style = parser.to_css_string(parsed_properties)
        n["style"] = new_style
      end
    end

    def table_delim
      block_delim
    end

    def table_long_strings_cleanup(docxml)
      @break_up_urls_in_tables or return
      docxml.xpath(ns("//td | //th")).each do |d|
        d.traverse do |n|
          n.text? or next
          ret = Metanorma::Utils::break_up_long_str(n.text)
          n.content = ret
        end
      end
    end

    def amend(docxml)
      docxml.xpath(ns("//amend")).each { |f| amend1(f) }
    end

    def amend1(elem)
      ret = semx_fmt_dup(elem)
      ret.xpath(ns("./locality | ./localityStack | ./autonumber | " \
                   "./classification | ./contributor")).each(&:remove)
      ret.xpath(ns("./newcontent")).each { |a| a.name = "quote" }
      ret.xpath(ns("./description")).each { |a| a.replace(a.children) }
      elem.xpath(ns(".//fmt-name | .//fmt-xref-label")).each(&:remove)
      elem.next = ret
    end

    # TODO will go back to just one source/modification, preserving it
    def source(docxml)
      fmt_source(docxml)
      docxml.xpath(ns("//fmt-source/source/modification")).each do |f|
        source_modification(f)
      end
      source_types(docxml)
      docxml.xpath(ns("//fmt-source/source")).each do |f|
        f.replace(semx_fmt_dup(f))
      end
    end

    def source_types(docxml)
      docxml.xpath(ns("//table/fmt-source")).each { |f| tablesource(f) }
      docxml.xpath(ns("//figure/fmt-source")).each { |f| figuresource(f) }
    end

    def fmt_source(docxml)
      n = docxml.xpath(ns("//source")) - docxml.xpath(ns("//term//source")) -
        docxml.xpath(ns("//quote/source"))
      n.each do |s|
        dup = s.clone
        modification_dup_align(s, dup)
        s.next = "<fmt-source>#{to_xml(dup)}</fmt-source>"
      end
    end

    def tablesource(elem)
      source1(elem, :table)
    end

    def figuresource(elem)
      source1(elem, :figure)
    end

    def source1(elem, ancestor)
      n = elem
      while n = n&.next_element
        case n.name
        when "source"
        when "fmt-source"
          elem << "; #{to_xml(n.remove.children)}"
        else break
        end
      end
      source1_label(elem, to_xml(elem.children).strip, ancestor)
    end

    def source1_label(elem, sources, _ancestor)
      elem.children = l10n("[#{@i18n.source}: #{sources}]")
    end

    def source_modification(mod)
      termsource_modification(mod.parent)
    end

    def quote(docxml)
      docxml.xpath(ns("//quote")).each { |f| quote1(f) }
    end

    def quote1(elem)
      author = elem.at(ns("./author"))
      source = elem.at(ns("./source"))
      author.nil? && source.nil? and return
      p = quote_attribution(author, source, elem)
      elem << "<attribution><p>#{l10n p}</p></attribution>"
    end

    # e["deleteme"]: duplicate of source, will be duplicated in fmt-eref,
    # need to delete after
    def quote_attribution(author, source, elem)
      p = "&#x2014; "
      p += to_xml(semx_fmt_dup(author)) if author
      p += ", " if author && source
      source or return p
      p + to_xml(quote_source(source, elem))
    end

    def quote_source(source, elem)
      s = semx_fmt_dup(source)
      e = Nokogiri::XML::Node.new("eref", elem.document)
      e << s.children
      s << e
      source.attributes.each_key { |k| e[k] = source[k] }
      e["deleteme"] = "true"
      s
    end
  end
end
