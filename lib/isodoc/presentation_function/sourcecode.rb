module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
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
      opts = { gutter_class: "rouge-gutter", code_class: "rouge-code" }
      { formatter: f,
        formatter_line: Rouge::Formatters::HTMLLineTable.new(f, opts) }
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
      markup = source_remove_markup(elem)
      p = source_lex(elem)
      wrapper, code =
        if elem["linenums"] == "true" then sourcecode_table_to_elem(elem, p)
        else
          r = Nokogiri::XML.fragment(@highlighter[:formatter].format(p))
          [r, r]
        end
      elem.children = source_restore_markup(wrapper, code, markup)
    end

    def source_remove_markup(elem)
      ret = {}
      name = elem.at(ns("./name")) and ret[:name] = name.remove.to_xml
      ret[:ann] = elem.xpath(ns("./annotation")).each(&:remove)
      ret[:call] = elem.xpath(ns("./callout")).each_with_object([]) do |c, m|
        m << { xml: c.remove.to_xml, line: c.line - elem.line }
      end
      ret
    end

    def source_restore_markup(wrapper, code, markup)
      text = source_restore_callouts(code, markup[:call])
      ret = if code == wrapper
              text
            else
              code.replace(text)
              to_xml(wrapper)
            end
      "#{markup[:name]}#{ret}#{markup[:ann]}"
    end

    def source_restore_callouts(code, callouts)
      text = to_xml(code)
      text.split(/[\n\r]/).each_with_index do |c, i|
        while !callouts.empty? && callouts[0][:line] == i
          c.sub!(/\s+$/, " #{callouts[0][:xml]} ")
          callouts.shift
        end
      end.join("\n")
    end

    def sourcecode_table_to_elem(elem, tokens)
      r = Nokogiri::XML(@highlighter[:formatter_line].format(tokens)).root
      pre = r.at(".//td[@class = 'rouge-code']/pre")
      %w(style).each { |n| elem[n] and pre[n] = elem[n] }
      pre.name = "sourcecode"
      [r, pre]
    end

    def source_lex(elem)
      l = (Rouge::Lexer.find(elem["lang"] || "plaintext") ||
       Rouge::Lexer.find("plaintext"))
      l.lex(@c.decode(elem.children.to_xml))
    end

    def source_label(elem)
      labelled_ancestor(elem) and return
      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, block_delim,
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end
  end
end
