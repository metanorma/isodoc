require "isodoc/html_function/mathvariant_to_plain"
require_relative "postprocess_footnotes"

module IsoDoc::HtmlFunction
  module Html
    def postprocess(result, filename, _dir)
      result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
      toHTML(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def script_cdata(result)
      result.gsub(%r{<script([^>]*)>\s*<!\[CDATA\[}m, "<script\\1>")
        .gsub(%r{\]\]>\s*</script>}, "</script>")
        .gsub(%r{<!\[CDATA\[\s*<script([^>]*)>}m, "<script\\1>")
        .gsub(%r{</script>\s*\]\]>}, "</script>")
    end

    def toHTML(result, filename)
      result = from_xhtml(html_cleanup(to_xhtml(result)))
      # result = populate_template(result, :html)
      result = from_xhtml(move_images(to_xhtml(result)))
      result = html5(script_cdata(inject_script(result)))
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
    end

    def html5(doc)
      doc.sub(%r{<!DOCTYPE html [^>]+>}, "<!DOCTYPE html>")
        .sub(%r{<\?xml[^>]+>}, "")
    end

    def html_cleanup(html)
      mathml(
        footnote_format(
          footnote_backlinks(
            html_toc(
              term_header(html_footnote_filter(html_preface(htmlstyle(html)))),
            ),
          ),
        ),
      )
    end

    def mathml(docxml)
      IsoDoc::HtmlFunction::MathvariantToPlain.new(docxml).convert
    end

    def htmlstylesheet(file)
      return if file.nil?

      file.open if file.is_a?(Tempfile)
      stylesheet = file.read
      xml = Nokogiri::XML("<style/>")
      xml.children.first << Nokogiri::XML::Comment.new(xml, "\n#{stylesheet}\n")
      file.close
      file.unlink if file.is_a?(Tempfile)
      xml.root.to_s
    end

    def htmlstyle(docxml)
      return docxml unless @htmlstylesheet

      head = docxml.at("//*[local-name() = 'head']")
      head << htmlstylesheet(@htmlstylesheet)
      s = htmlstylesheet(@htmlstylesheet_override) and head << s
      docxml
    end

    def html_preface(docxml)
      html_cover(docxml) if @htmlcoverpage && !@bare
      html_intro(docxml) if @htmlintropage && !@bare
      docxml.at("//body") << mathjax(@openmathdelim, @closemathdelim)
      docxml.at("//body") << sourcecode_highlighter
      html_main(docxml)
      authority_cleanup(docxml)
      docxml
    end

    def authority_cleanup1(docxml, klass)
      dest = docxml.at("//div[@id = 'boilerplate-#{klass}-destination']")
      auth = docxml.at("//div[@id = 'boilerplate-#{klass}' or "\
                       "@class = 'boilerplate-#{klass}']")
      auth&.xpath(".//h1[not(text())] | .//h2[not(text())]")&.each(&:remove)
      auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
      dest and auth and dest.replace(auth.remove)
    end

    def authority_cleanup(docxml)
      %w(copyright license legal feedback).each do |t|
        authority_cleanup1(docxml, t)
      end
    end

    def html_cover(docxml)
      doc = to_xhtml_fragment(File.read(@htmlcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="title-section"]')
      # d.children.first.add_previous_sibling doc.to_xml(encoding: "US-ASCII")
      d.children.first.add_previous_sibling(
        populate_template(doc.to_xml(encoding: "US-ASCII"), :html),
      )
    end

    def html_intro(docxml)
      doc = to_xhtml_fragment(File.read(@htmlintropage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="prefatory-section"]')
      # d.children.first.add_previous_sibling doc.to_xml(encoding: "US-ASCII")
      d.children.first.add_previous_sibling(
        populate_template(doc.to_xml(encoding: "US-ASCII"), :html),
      )
    end

    def html_toc_entry(level, header)
      %(<li class="#{level}"><a href="##{header['id']}">\
      #{header_strip(header)}</a></li>)
    end

    def toclevel_classes
      (1..@htmlToClevels).reduce([]) { |m, i| m << "h#{i}" }
    end

    def toclevel
      ret = toclevel_classes.map do |l|
        "#{l}:not(:empty):not(.TermNum):not(.noTOC)"
      end
      <<~HEAD.freeze
        function toclevel() { return "#{ret.join(',')}";}
      HEAD
    end

    # needs to be same output as toclevel
    def html_toc(docxml)
      (idx = docxml.at("//div[@id = 'toc']")) or (return docxml)
      toc = "<ul>"
      path = toclevel_classes.map do |l|
        "//main//#{l}[not(@class = 'TermNum')][not(@class = 'noTOC')][text()]"
      end
      docxml.xpath(path.join(" | ")).each_with_index do |h, tocidx|
        h["id"] ||= "toc#{tocidx}"
        toc += html_toc_entry(h.name, h)
      end
      idx.children = "#{toc}</ul>"
      docxml
    end

    # presupposes that the image source is local
    def move_images(docxml)
      FileUtils.rm_rf tmpimagedir
      FileUtils.mkdir tmpimagedir
      docxml.xpath("//*[local-name() = 'img']").each do |i|
        i["width"], i["height"] = Html2Doc.image_resize(i, image_localfile(i),
                                                        @maxheight, @maxwidth)
        next if /^data:/.match? i["src"]

        @datauriimage ? datauri(i) : move_image1(i)
      end
      docxml
    end

    def datauri(img)
      type = img["src"].split(".")[-1]
      supertype = type == "xml" ? "application" : "image"
      bin = IO.binread(image_localfile(img))
      data = Base64.strict_encode64(bin)
      img["src"] = "data:#{supertype}/#{type};base64,#{data}"
    end

    def image_suffix(img)
      type = img["mimetype"]&.sub(%r{^[^/*]+/}, "")
      matched = /\.(?<suffix>[^. \r\n\t]+)$/.match img["src"]
      type and !type.empty? and return type

      !matched.nil? and matched[:suffix] and return matched[:suffix]
      "png"
    end

    def move_image1(img)
      suffix = image_suffix(img)
      uuid = UUIDTools::UUID.random_create.to_s
      fname = "#{uuid}.#{suffix}"
      new_full_filename = File.join(tmpimagedir, fname)
      local_filename = image_localfile(img)
      FileUtils.cp local_filename, new_full_filename
      img["src"] = File.join(rel_tmpimagedir, fname)
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

    def sourcecode_highlighter
      '<script src="https://cdn.rawgit.com/google/code-prettify/master/'\
        'loader/run_prettify.js"></script>'
    end

    MATHJAX_ADDR =
      "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js".freeze
    MATHJAX = <<~"MATHJAX".freeze
      <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
          "HTML-CSS": { preferredFont: "STIX" },
          asciimath2jax: { delimiters: [['OPEN', 'CLOSE']] }
       });
      </script>
      <script src="#{MATHJAX_ADDR}?config=MML_HTMLorMML-full" async="async"></script>
    MATHJAX

    def mathjax(open, close)
      MATHJAX.gsub("OPEN", open).gsub("CLOSE", close)
    end

    def term_header(docxml)
      %w(h1 h2 h3 h4 h5 h6 h7 h8).each do |h|
        docxml.xpath("//p[@class = 'TermNum'][../#{h}]").each do |p|
          p.name = "h#{h[1].to_i + 1}"
        end
      end
      docxml
    end
  end
end
