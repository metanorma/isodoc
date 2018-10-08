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
        info docxml, div2
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body3(body, docxml)
      body.div **{ class: "main-section" } do |div3|
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
      result.gsub(%r{<script>\s*<!\[CDATA\[}m, "<script>").
        gsub(%r{\]\]>\s*</script>}, "</script>").
        gsub(%r{<!\[CDATA\[\s*<script>}m, "<script>").
        gsub(%r{</script>\s*\]\]>}, "</script>")
    end

    def toHTML(result, filename)
      result = script_cdata(from_xhtml(html_cleanup(to_xhtml(result))))
      result = populate_template(result, :html)
      File.open("#{filename}.html", "w:UTF-8") do |f|
        f.write(result)
      end
    end

    def html_cleanup(x)
      footnote_backlinks(html_toc(
        term_header(move_images(html_footnote_filter(html_preface(htmlstyle(x))))))
                        )
    end

    MATHJAX_ADDR =
      "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js".freeze
    MATHJAX = <<~"MATHJAX".freeze
      <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
          asciimath2jax: {
            delimiters: [['OPEN', 'CLOSE']]
          }
       });
      </script>
      <script src="#{MATHJAX_ADDR}?config=AM_HTMLorMML"></script>
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

    def html_head()
      <<~HEAD.freeze
    <title>{{ doctitle }}</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!--TOC script import-->
    <script type="text/javascript"  src="https://cdn.rawgit.com/jgallen23/toc/0.3.2/dist/toc.min.js"></script>

    <!--Google fonts-->
    <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet">
    <!--Font awesome import for the link icon-->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/solid.css" integrity="sha384-v2Tw72dyUXeU3y4aM2Y0tBJQkGfplr39mxZqlTBDUZAb9BGoC40+rdFCG0m10lXk" crossorigin="anonymous">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/fontawesome.css" integrity="sha384-q3jl8XQu1OpdLgGFvNRnPdj5VIlCvgsDQTQB6owSOHWlAurxul7f+JpUOVdAiJ5P" crossorigin="anonymous">
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
      d.children.first.previous = html_button()
    end

    def html_preface(docxml)
      html_cover(docxml) if @htmlcoverpage
      html_intro(docxml) if @htmlintropage
      docxml.at("//body") << mathjax(@openmathdelim, @closemathdelim)
      if @scripts
        scripts = File.read(@scripts, encoding: "UTF-8")
        a = docxml.at("//body").add_child docxml.create_cdata(scripts) #scripts.to_xml(encoding: "US-ASCII")
      end
      html_main(docxml)
      docxml
    end

    def html_cover(docxml)
      cover = File.read(@htmlcoverpage, encoding: "UTF-8")
      coverxml = to_xhtml_fragment(cover)
      d = docxml.at('//div[@class="title-section"]')
      d.children.first.add_previous_sibling coverxml.to_xml(encoding: "US-ASCII")
    end

    def html_intro(docxml)
      intro = File.read(@htmlintropage, encoding: "UTF-8")
      introxml = to_xhtml_fragment(intro)
      d = docxml.at('//div[@class="prefatory-section"]')
      d.children.first.add_previous_sibling introxml.to_xml(encoding: "US-ASCII")
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
        next if /^data:image/.match i["src"]
        @datauriimage ? datauri(i) : move_image1(i)
      end
      docxml
    end

    def datauri(i)
      type = i["src"].split(".")[-1]
      #bin = open(i["src"]).read(encoding: "utf-8")
      bin = File.read(i["src"], encoding: "utf-8")
      data = Base64.strict_encode64(bin)
      i["src"] = "data:image/#{type};base64,#{data}"
    end

    def move_image1(i)
      matched = /\.(?<suffix>\S+)$/.match i["src"]
      uuid = UUIDTools::UUID.random_create.to_s
      new_full_filename = File.join(tmpimagedir, "#{uuid}.#{matched[:suffix]}")
      FileUtils.cp i["src"], new_full_filename
      i["src"] = new_full_filename
      i["width"], i["height"] = Html2Doc.image_resize(i, @maxheight, @maxwidth)
    end

    def html_toc(docxml)
      docxml
    end
  end
end
