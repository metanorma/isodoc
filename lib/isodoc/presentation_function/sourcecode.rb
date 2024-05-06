module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def sourcehighlighter_css(docxml)
      ret = custom_css(docxml)
      ret.empty? and return
      ins = extension_insert(docxml)
      ins << "<source-highlighter-css>#{ret}" \
             "</source-highlighter-css>"
    end

    def custom_css(docxml)
      ret = ""
      @sourcehighlighter and ret += rouge_css_location
      a = docxml.at(ns("//metanorma-extension/" \
                       "clause[title = 'user-css']/sourcecode")) and
        ret += "\n#{to_xml(a.children)}"
      ret
    end

    # replace in local gem rather than specify overrides of default
    def rouge_css_location
      File.read(File.join(File.dirname(__FILE__), "..", "base_style",
                          "rouge.css"))
    end

    def sourcehighlighter
      @sourcehighlighter or return
      Rouge::Formatter.enable_escape!
      f = Rouge::Formatters::HTML.new
      opts = { gutter_class: "rouge-gutter", code_class: "rouge-code" }
      f1 = Rouge::Formatters::HTMLLineTable.new(f, opts)
      { formatter: f, formatter_line: f1 }
    end

    def callouts(elem)
      elem.xpath(ns(".//callout")).each do |c|
        @callouts[c["target"]] = c.children.to_xml
      end
    end

    def sourcecode(docxml)
      sourcehighlighter_css(docxml)
      @highlighter = sourcehighlighter
      @callouts = {}
      docxml.xpath(ns("//sourcecode")).each do |f|
        sourcecode1(f)
      end
    end

    def sourcecode1(elem)
      source_highlight(elem)
      source_label(elem)
      callouts(elem)
      annotations(elem)
    end

    def annotations(elem)
      elem.at(ns("./annotation")) or return
      ret = ""
      elem.xpath(ns("./annotation")).each do |a|
        a.remove
        ret += <<~OUT
          <dt id='#{a['id']}'><span class='c'>#{@callouts[a['id']]}</span></dt>
          <dd>#{a.children.to_xml}</dd>
        OUT
      end
      elem << "<dl><name>#{@i18n.key}</name>#{ret}</dl>"
    end

    def source_highlight(elem)
      @highlighter or return
      markup = source_remove_markup(elem)
      p = source_lex(elem)
      elem.children = if elem["linenums"] == "true"
                        r = sourcecode_table_to_elem(elem, p)
                        source_restore_markup_table(r, markup)
                      else
                        r = @highlighter[:formatter].format(p)
                        source_restore_markup(Nokogiri::XML.fragment(r), markup)
                      end
    end

    def source_remove_markup(elem)
      ret = {}
      name = elem.at(ns("./name")) and ret[:name] = name.remove.to_xml
      source_remove_annotations(ret, elem)
      ret
    end

    def source_remove_annotations(ret, elem)
      ret[:ann] = elem.xpath(ns("./annotation")).each(&:remove)
      ret[:call] = elem.xpath(ns("./callout")).each_with_object([]) do |c, m|
        m << { xml: c.remove, line: c.line - elem.line }
      end
      ret
    end

    def source_restore_markup(wrapper, markup)
      ret = source_restore_callouts(wrapper, markup[:call])
      "#{markup[:name]}#{ret}#{markup[:ann]}"
    end

    def source_restore_markup_table(wrapper, markup)
      source_restore_callouts_table(wrapper, markup[:call])
      ret = to_xml(wrapper)
      "#{markup[:name]}#{ret}#{markup[:ann]}"
    end

    def source_restore_callouts(code, callouts)
      text = to_xml(code)
      text.split(/[\n\r]/).each_with_index do |c, i|
        while !callouts.empty? && callouts[0][:line] == i
          c.sub!(/\s+$/, " #{reinsert_callout(callouts[0][:xml])} ")
          callouts.shift
        end
      end.join("\n")
    end

    def source_restore_callouts_table(table, callouts)
      table.xpath(".//td[@class = 'rouge-code']/sourcecode")
        .each_with_index do |c, i|
        while !callouts.empty? && callouts[0][:line] == i
          c << " #{reinsert_callout(callouts[0][:xml])} "
          callouts.shift
        end
      end
    end

    def reinsert_callout(xml)
      "<span class='c'>#{to_xml(xml)}</span>"
    end

    def sourcecode_table_to_elem(elem, tokens)
      r = Nokogiri::XML(@highlighter[:formatter_line].format(tokens)).root
      r.xpath(".//td[@class = 'rouge-code']/pre").each do |pre|
        %w(style).each { |n| elem[n] and pre[n] = elem[n] }
        pre.name = "sourcecode"
        pre.children = to_xml(pre.children).sub(/\s+$/, "")
      end
      r
    end

    def source_lex(elem)
      lexer = Rouge::Lexer.find(elem["lang"] || "plaintext") ||
        Rouge::Lexer.find("plaintext")
      l = Rouge::Lexers::Escape.new(start: "{^^{", end: "}^^}", lang: lexer)
      source = to_xml(elem.children).gsub(/</, "{^^{<").gsub(/>/, ">}^^}")
      l.lang.reset!
      l.lex(@c.decode(source))
    end

    def source_label(elem)
      labelled_ancestor(elem) and return
      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, block_delim,
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end
  end
end
