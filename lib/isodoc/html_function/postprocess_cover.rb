require "isodoc/html_function/mathvariant_to_plain"
require_relative "postprocess_footnotes"
require "metanorma-utils"

module IsoDoc
  module HtmlFunction
    module Html
      def script_cdata(result)
        result.gsub(%r{<script([^<>]*)>\s*<!\[CDATA\[}m, "<script\\1>")
          .gsub(%r{\]\]>\s*</script>}, "</script>")
          .gsub(%r{<!\[CDATA\[\s*<script([^<>]*)>}m, "<script\\1>")
          .gsub(%r{</script>\s*\]\]>}, "</script>")
      end

      def htmlstylesheet(file)
        return if file.nil?

        file.open if file.is_a?(Tempfile)
        stylesheet = file.read
        xml = Nokogiri::XML("<style/>")
        xml.children.first << Nokogiri::XML::Comment
          .new(xml, "\n#{stylesheet}\n")
        file.close
        file.unlink if file.is_a?(Tempfile)
        xml.root.to_s
      end

      def htmlstyle(docxml)
        return docxml unless @htmlstylesheet

        head = docxml.at("//*[local-name() = 'head']")
        head << htmlstylesheet(@htmlstylesheet)
        s = htmlstylesheet(@htmlstylesheet_override) and head << s
        s = @meta.get[:code_css] and
          head << "<style><!--#{s.gsub(/sourcecode/,
                                       'pre.sourcecode')}--></style>"
        @bare and
          head << "<style>body {margin-left: 2em; margin-right: 2em;}</style>"
        docxml
      end

      def html_preface(docxml)
        @htmlcoverpage && !@htmlcoverpage.empty? && !@bare and
          html_cover(docxml)
        @htmlintropage && !@htmlintropage.empty? && !@bare and
          html_intro(docxml)
        docxml.at("//body") << mathjax(@openmathdelim, @closemathdelim)
        html_main(docxml)
        authority_cleanup(docxml)
        docxml
      end

      def authority_cleanup1(docxml, klass)
        dest = docxml.at("//div[@id = 'boilerplate-#{klass}-destination']")
        auth = docxml.at("//div[@id = 'boilerplate-#{klass}' or " \
                         "@class = 'boilerplate-#{klass}']")
        auth&.xpath(".//h1[not(text())] | .//h2[not(text())]")&.each(&:remove)
        auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
        dest and auth and dest.replace(auth.remove)
      end

      def authority_cleanup(docxml)
        %w(copyright license legal feedback).each do |t|
          authority_cleanup1(docxml, t)
        end
        coverpage_note_cleanup(docxml)
      end

      def coverpage_note_cleanup(docxml)
        if dest = docxml.at("//div[@id = 'coverpage-note-destination']")
          auth = docxml.xpath("//*[@coverpage]")
          if auth.empty? then dest.remove
          else
            auth.each do |x|
              dest << x.remove
            end
          end
        end
        docxml.xpath("//*[@coverpage]").each { |x| x.delete("coverpage") }
      end

      def html_cover(docxml)
        doc = to_xhtml_fragment(File.read(@htmlcoverpage, encoding: "UTF-8"))
        d = docxml.at('//div[@class="title-section"]')
        d.add_first_child(
          populate_template(doc.to_xml(encoding: "US-ASCII"), :html),
        )
      end

      def html_intro(docxml)
        doc = to_xhtml_fragment(File.read(@htmlintropage, encoding: "UTF-8"))
        d = docxml.at('//div[@class="prefatory-section"]')
        d.add_first_child(
          populate_template(doc.to_xml(encoding: "US-ASCII"), :html),
        )
      end

      def html_toc_entry(level, header)
        content = header.at("./following-sibling::p" \
                            "[@class = 'variant-title-toc']") || header
        id = header.at(".//a[@class = 'anchor']/@href")&.text&.sub(/^#/, "") ||
          header["id"]
        %(<li class="#{level}"><a href="##{id}">\
      #{header_strip(content)}</a></li>)
      end

      # array of arrays, one per level, containing XPath fragments for the elems
      # matching that ToC level
      def toclevel_classes
        (1..@htmlToClevels).reduce([]) { |m, i| m << ["h#{i}"] }
      end

      def toclevel
        ret = toclevel_classes.flatten.map do |l|
          "#{l}:not(:empty):not(.TermNum):not(.noTOC)"
        end
        <<~HEAD.freeze
          function toclevel() { return "#{ret.join(',')}";}
        HEAD
      end

      # needs to be same output as toclevel
      def html_toc(docxml)
        idx = html_toc_init(docxml) or return docxml
        path = toclevel_classes.map do |x|
          x.map { |l| "//main//#{l}#{toc_exclude_class}" }
        end
        toc = html_toc_entries(docxml, path)
          .map { |k| k[:entry] }.join("\n")
        idx << "<ul>#{toc}</ul>"
        docxml
      end

      def html_toc_init(docxml)
        dest = docxml.at("//div[@id = 'toc']") or return
        if source = docxml.at("//div[@class = 'TOC']")
          dest << to_xml(source.remove.children)
        end
        dest
      end

      def html_toc_entries(docxml, path)
        headers = html_toc_entries_prep(docxml, path)
        path.each_with_index.with_object([]) do |(p, i), m|
          docxml.xpath(p.join(" | ")).each do |h|
            m << { entry: html_toc_entry("h#{i + 1}", h),
                   line: headers[h["id"]] }
          end
        end.sort_by { |k| k[:line] }
      end

      def html_toc_entries_prep(docxml, path)
        docxml.xpath(path.join(" | "))
          .each_with_index.with_object({}) do |(h, i), m|
            h["id"] ||= "_#{UUIDTools::UUID.random_create}"
            m[h["id"]] = i
          end
      end

      def toc_exclude_class
        "[not(@class = 'TermNum')][not(@class = 'noTOC')]" \
          "[string-length(normalize-space(.))>0]"
      end

      def inject_script(doc)
        return doc unless @scripts

        scripts = File.read(@scripts, encoding: "UTF-8")
        scripts_override = ""
        @scripts_override and
          scripts_override = File.read(@scripts_override, encoding: "UTF-8")
        a = doc.split(%r{</body>})
        "#{a[0]}#{scripts}#{scripts_override}</body>#{a[1]}"
      end

      MATHJAX_ADDR =
        "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js".freeze
      MATHJAX = <<~"MATHJAX".freeze
        <script type="text/x-mathjax-config">
          MathJax.Hub.Config({
            "HTML-CSS": {
              preferredFont: "STIX",
              linebreaks: {
                automatic: true,
                width: "container"  // or specify something like "90%"/"30em"
              }
            },
            MathML: {
              linebreaks: {
                automatic: true
              }
            },
            asciimath2jax: { delimiters: [['(#(', ')#)']] }
          });
        </script>
        <script src="#{MATHJAX_ADDR}?config=MML_HTMLorMML-full" async="async"></script>
      MATHJAX

      def mathjax(open, close)
        MATHJAX.gsub("OPEN", open).gsub("CLOSE", close)
      end
    end
  end
end
