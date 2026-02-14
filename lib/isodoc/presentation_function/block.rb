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
      dl = elem.at(ns("./dl")) and dl.replace("<key>#{to_xml(dl)}</key>")
      formula_where(elem.at(ns("./key")))
      lbl = @xrefs.anchor(elem["id"], :label, false) ||
        @xrefs.anchor(elem["original-id"], :label, false)
      lbl.nil? || lbl.empty? or prefix_name(elem, {}, lbl, "name")
    end

    def formula_where(dlist)
      dlist or return
      dlist["class"] = "formula_dl"
      where = dlist.xpath(ns(".//dt")).size > 1 ? @i18n.where : @i18n.where_one
      dlist.previous = "<p keep-with-next='true'>#{where}</p>"
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each { |f| example1(f) }
    end

    def example1(elem)
      n = @xrefs.get[elem["id"]] || @xrefs.get[elem["original-id"]]
      lbl = labelled_autonum(@i18n.example, elem["id"] || elem["original-id"],
                             n&.dig(:label))
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
      n = @xrefs.get[elem["id"]] || @xrefs.get[elem["original-id"]]
      labelled_autonum(@i18n.note, elem["id"] || elem["original-id"],
                       n&.dig(:label))
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
      label = admonition_label(elem,
                               @xrefs.anchor(elem["id"] || elem["original-id"],
                                             :label, false))
      prefix_name(elem, { caption: block_delim }, label, "name")
    end

    def admonition_label(elem, num)
      lbl = if elem["type"] == "box" then @i18n.box
            else @i18n.admonition[elem["type"]]&.upcase
            end
      labelled_autonum(lbl, elem["id"] || elem["original-id"], num)
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
      n = @xrefs.anchor(elem["id"] || elem["original-id"], :label, false)
      lbl = labelled_autonum(lower2cap(@i18n.table),
                             elem["id"] || elem["original-id"], n)
      prefix_name(elem, { caption: table_delim }, lbl, "name")
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
      ret.xpath(ns("./locality | ./localityStack | .//autonumber | " \
                   "./classification | ./contributor | ./fmt-name | " \
                   "./fmt-xref-label")).each(&:remove)
      amend_newcontent(ret)
      ret.xpath(ns("./newcontent")).each { |a| a.name = "quote" }
      ret.xpath(ns("./description")).each { |a| a.replace(a.children) }
      elem.next = ret
    end

    def amend_newcontent(elem)
      elem.xpath(ns("./newcontent")).each do |a|
        a.name = "quote"
        a.xpath(ns("./clause")).each do |c|
          amend_subclause(c, 1)
          a.next = c
        end
      end
    end

    def amend_subclause(clause, depth)
      clause.xpath(ns("./title")).reverse_each do |t|
        # t.name = "floating-title"
        # t["depth"] ||= depth || "1"
        t.name = "p"
        t["type"] = "floating-title"
      end
      clause.name = depth == 1 ? "quote" : "quote" # "div"
      clause.xpath(ns("./clause")).each { |c| amend_subclause(c, depth + 1) }
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
