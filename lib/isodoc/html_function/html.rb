require "fileutils"
require "base64"

module IsoDoc::HtmlFunction
  module Html
    def make_body1(body, _docxml)
      body.div **{ class: "title-section" } do |div1|
        div1.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body2(body, docxml)
      body.div **{ class: "prefatory-section" } do |div2|
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body3(body, docxml)
      body.div **{ class: "main-section" } do |div3|
        abstract docxml, div3
        foreword docxml, div3
        introduction docxml, div3
        middle docxml, div3
        footnotes div3
        comments div3
      end
    end

    def postprocess(result, filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toHTML(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def script_cdata(result)
      result.gsub(%r{<script([^>]*)>\s*<!\[CDATA\[}m, "<script\\1>").
        gsub(%r{\]\]>\s*</script>}, "</script>").
        gsub(%r{<!\[CDATA\[\s*<script([^>]*)>}m, "<script\\1>").
        gsub(%r{</script>\s*\]\]>}, "</script>")
    end

    def toHTML(result, filename)
      result = (from_xhtml(html_cleanup(to_xhtml(result))))
      result = populate_template(result, :html)
      result = from_xhtml(move_images(to_xhtml(result)))
      result = script_cdata(inject_script(result))
      File.open("#{filename}.html", "w:UTF-8") { |f| f.write(result) }
    end

    def html_cleanup(x)
      footnote_backlinks(html_toc(
        term_header((html_footnote_filter(html_preface(htmlstyle(x))))))
                        )
    end

    MATHJAX_ADDR =
      "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js".freeze
    MATHJAX = <<~"MATHJAX".freeze
      <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
          asciimath2jax: { delimiters: [['OPEN', 'CLOSE']] }
       });
      </script>
      <script src="#{MATHJAX_ADDR}?config=AM_HTMLorMML" async="async"></script>
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

    def googlefonts()
      <<~HEAD.freeze
      <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet">
      HEAD
    end

    def html_head()
      <<~HEAD.freeze
    <title>{{ doctitle }}</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!--TOC script import-->
    <script type="text/javascript"  src="https://cdn.rawgit.com/jgallen23/toc/0.3.2/dist/toc.min.js"></script>
    <script type="text/javascript">#{toclevel}</script>

    <!--Google fonts-->
      #{googlefonts}
    <!--Font awesome import for the link icon-->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/solid.css" integrity="sha384-v2Tw72dyUXeU3y4aM2Y0tBJQkGfplr39mxZqlTBDUZAb9BGoC40+rdFCG0m10lXk" crossorigin="anonymous">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/fontawesome.css" integrity="sha384-q3jl8XQu1OpdLgGFvNRnPdj5VIlCvgsDQTQB6owSOHWlAurxul7f+JpUOVdAiJ5P" crossorigin="anonymous">
    <style class="anchorjs"></style>
      HEAD
    end

    def html_button()
      '<button onclick="topFunction()" id="myBtn" '\
        'title="Go to top">Top</button>'.freeze
    end

    def html_main(docxml)
      docxml.at("//head").add_child(html_head())
      d = docxml.at('//div[@class="main-section"]')
      d.name = "main"
      d.children.empty? or d.children.first.previous = html_button()
    end

    def sourcecode_highlighter
      '<script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>'
    end

    def sourcecodelang(lang)
      return unless lang
      case lang.downcase
      when "javascript" then "lang-js"
      when "c" then "lang-c"
      when "c+" then "lang-cpp"
      when "console" then "lang-bsh"
      when "ruby" then "lang-rb"
      when "html" then "lang-html"
      when "java" then "lang-java"
      when "xml" then "lang-xml"
      when "perl" then "lang-perl"
      when "python" then "lang-py"
      when "xsl" then "lang-xsl"
      else
        ""
      end
    end

    def sourcecode_parse(node, out)
      name = node.at(ns("./name"))
      class1 = "prettyprint #{sourcecodelang(node&.at(ns('./@lang'))&.value)}"
      out.pre **attr_code(id: node["id"], class: class1) do |div|
        @sourcecode = true
        node.children.each { |n| parse(n, div) unless n.name == "name" }
        @sourcecode = false
        sourcecode_name_parse(node, div, name) if name
      end
    end

    def html_preface(docxml)
      html_cover(docxml) if @htmlcoverpage
      html_intro(docxml) if @htmlintropage
      docxml.at("//body") << mathjax(@openmathdelim, @closemathdelim)
      docxml.at("//body") << sourcecode_highlighter
      html_main(docxml)
      docxml
    end

    def inject_script(doc)
      return doc unless @scripts
      scripts = File.read(@scripts, encoding: "UTF-8")
      doc.sub("</body>", scripts + "\n</body>")
    end

    def html_cover(docxml)
      doc = to_xhtml_fragment(File.read(@htmlcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="title-section"]')
      d.children.first.add_previous_sibling doc.to_xml(encoding: "US-ASCII")
    end

    def html_intro(docxml)
      doc = to_xhtml_fragment(File.read(@htmlintropage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="prefatory-section"]')
      d.children.first.add_previous_sibling doc.to_xml(encoding: "US-ASCII")
    end

    def htmlstylesheet
      stylesheet = File.read(@htmlstylesheet, encoding: "UTF-8")
      xml = Nokogiri::XML("<style/>")
      xml.children.first << Nokogiri::XML::Comment.new(xml, "\n#{stylesheet}\n")
      xml.root.to_s
    end

    def htmlstyle(docxml)
      return docxml unless @htmlstylesheet
      title = docxml.at("//*[local-name() = 'head']/*[local-name() = 'title']")
      head = docxml.at("//*[local-name() = 'head']")
      css = htmlstylesheet
      if title.nil? then head.children.first.add_previous_sibling css
      else
        title.add_next_sibling css
      end
      docxml
    end

    def update_footnote_filter(fn, x, i, seen)
      if seen[fn.text]
        x.at("./sup").content = seen[fn.text][:num].to_s
        fn.remove unless x["href"] == seen[fn.text][:href]
        x["href"] = seen[fn.text][:href]
      else
        seen[fn.text] = { num: i, href: x["href"] }
        x.at("./sup").content = i.to_s
        i += 1
      end
      [i, seen]
    end

    def html_footnote_filter(docxml)
      seen = {}
      i = 1
      docxml.xpath('//a[@epub:type = "footnote"]').each do |x|
        fn = docxml.at(%<//*[@id = '#{x['href'].sub(/^#/, '')}']>) || next
        i, seen = update_footnote_filter(fn, x, i, seen)
      end
      docxml
    end

    def footnote_backlinks(docxml)
      seen = {}
      docxml.xpath('//a[@epub:type = "footnote"]').each_with_index do |x, i|
        next if seen[x["href"]]
        seen[x["href"]] = true
        fn = docxml.at(%<//*[@id = '#{x['href'].sub(/^#/, '')}']>) || next
        x["id"] || x["id"] = "fnref:#{i + 1}"
        fn.elements.first.children.first.previous = x.dup
        fn.add_child "<a href='##{x['id']}'>&#x21A9;</a>"
      end
      docxml
    end

    # presupposes that the image source is local
    def move_images(docxml)
      FileUtils.rm_rf tmpimagedir
      FileUtils.mkdir tmpimagedir
      docxml.xpath("//*[local-name() = 'img']").each do |i|
        i["width"], i["height"] = Html2Doc.image_resize(i, image_localfile(i),
                                                        @maxheight, @maxwidth)
        next if /^data:image/.match i["src"]
        @datauriimage ? datauri(i) : move_image1(i)
      end
      docxml
    end

    def image_localfile(i)
      if /^data:image/.match i["src"]
        save_dataimage(i["src"], false)
      else
        File.join(@localdir, i["src"])
      end
    end

    def datauri(i)
      type = i["src"].split(".")[-1]
      bin = IO.binread(File.join(@localdir, i["src"]))
      data = Base64.strict_encode64(bin)
      i["src"] = "data:image/#{type};base64,#{data}"
    end

    def move_image1(i)
      matched = /\.(?<suffix>[^. \r\n\t]+)$/.match i["src"]
      uuid = UUIDTools::UUID.random_create.to_s
      fname = "#{uuid}.#{matched[:suffix]}"
      new_full_filename = File.join(tmpimagedir, fname)
      local_filename = image_localfile(i)
      FileUtils.cp local_filename, new_full_filename
      i["src"] = File.join(rel_tmpimagedir, fname)
    end

    def html_toc_entry(level, header)
      %(<li class="#{level}"><a href="##{header['id']}">\
      #{header_strip(header)}</a></li>)
    end

    def toclevel_classes
      (1..@htmlToClevels).inject([]) { |m, i| m << "h#{i}" }
    end

    def toclevel
      ret = toclevel_classes.map { |l| "#{l}:not(:empty):not(.TermNum)" }
      <<~HEAD.freeze
    function toclevel() { return "#{ret.join(',')}";}
      HEAD
    end

    # needs to be same output as toclevel
    def html_toc(docxml)
      idx = docxml.at("//div[@id = 'toc']") or return docxml
      toc = "<ul>"
      path = toclevel_classes.map do |l|
        "//main//#{l}[not(@class = 'TermNum')][not(text())]"
      end
      docxml.xpath(path.join(" | ")).each_with_index do |h, tocidx|
        h["id"] ||= "toc#{tocidx}"
        toc += html_toc_entry(h.name, h)
      end
      idx.children = "#{toc}</ul>"
      docxml
    end
  end
end
