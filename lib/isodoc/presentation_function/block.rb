require_relative "./image"
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
      return if number.nil? || number.empty?

      unless name = node.at(ns("./#{elem}"))
        (node.children.empty? and node.add_child("<#{elem}></#{elem}>")) or
          node.children.first.previous = "<#{elem}></#{elem}>"
        name = node.children.first
      end
      if name.children.empty? then name.add_child(cleanup_entities(number.strip))
      else (name.children.first.previous = "#{number.strip}#{delim}")
      end
    end

    def sourcehighlighter_theme
      "igorpro"
    end

    def sourcehighlighter_css(docxml)
      @sourcehighlighter or return
      ins = docxml.at(ns("//misc-container")) ||
        docxml.at(ns("//bibdata")).after("<misc-container/>").next_element
      x = Rouge::Theme.find(sourcehighlighter_theme)
        .render(scope: "sourcecode")
      ins << "<source-highlighter-css>#{x}</source-highlighter-css>"
    end

    def sourcehighlighter
      @sourcehighlighter or return
      f = Rouge::Formatters::HTML.new
      { formatter: f,
        formatter_line: Rouge::Formatters::HTMLTable.new(f, {}) }
    end

    def sourcecode(docxml)
      sourcehighlighter_css(docxml)
      @highlighter = sourcehighlighter
      docxml.xpath(ns("//sourcecode")).each do |f|
        sourcecode1(f)
      end
    end

    def sourcecode1(elem)
      source_highlight(elem)
      source_label(elem)
    end

    def source_highlight(elem)
      @highlighter or return
      name = elem.at(ns("./name"))&.remove
      p = source_lex(elem)
      if elem["linenums"] == "true"
        pre = sourcecode_table_to_elem(elem, p)
        elem.children = "#{name}#{pre}"
      else
        elem.children = "#{name}#{@highlighter[:formatter].format(p)}"
      end
    end

    def sourcecode_table_to_elem(elem, tokens)
      r = Nokogiri::XML(@highlighter[:formatter_line].format(tokens)).root
      pre = r.at("//td[@class = 'rouge-code']/pre")
      %w(style).each { |n| elem[n] and pre[n] = elem[n] }
      r
    end

    def source_lex(elem)
      l = (Rouge::Lexer.find(elem["lang"] || "plaintext") ||
       Rouge::Lexer.find("plaintext"))
      l.lex(@c.decode(elem.children.to_xml))
    end

    def source_label(elem)
      return if labelled_ancestor(elem)

      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, block_delim,
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each do |f|
        formula1(f)
      end
    end

    def formula1(elem)
      lbl = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, "", lbl, "name")
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each do |f|
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
      prefix_name(elem, block_delim, lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each do |f|
        note1(f)
      end
    end

    def note1(elem)
      return if elem.parent.name == "bibitem" || elem["notag"] == "true"

      n = @xrefs.get[elem["id"]]
      lbl = if n.nil? || n[:label].nil? || n[:label].empty?
              @i18n.note
            else
              l10n("#{@i18n.note} #{n[:label]}")
            end
      prefix_name(elem, "", lbl, "name")
    end

    def admonition(docxml)
      docxml.xpath(ns("//admonition")).each do |f|
        admonition1(f)
      end
    end

    def admonition1(elem)
      return if elem.at(ns("./name")) || elem["notag"] == "true"

      prefix_name(elem, "", @i18n.admonition[elem["type"]]&.upcase, "name")
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
      docxml.xpath(ns("//table")).each do |f|
        table1(f)
      end
    end

    def table1(elem)
      return if labelled_ancestor(elem)
      return if elem["unnumbered"] && !elem.at(ns("./name"))

      n = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, block_delim, l10n("#{lower2cap @i18n.table} #{n}"),
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

    def ol(docxml)
      docxml.xpath(ns("//ol")).each do |f|
        ol1(f)
      end
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
