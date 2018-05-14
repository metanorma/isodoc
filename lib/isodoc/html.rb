module IsoDoc
  class Convert
    def postprocess(result, filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toHTML(result, filename)
      @files_to_delete.each { |f| system "rm #{f}" }
    end

    def toHTML(result, filename)
      result = from_xhtml(html_cleanup(to_xhtml(result))).
        gsub(%r{<script><!\[CDATA\[}, "<script>").
        gsub(%r{\]\]></script>}, "</script>")
      result = populate_template(result, :html)
      File.open("#{filename}.html", "w") do |f|
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
      d = docxml.at('//div[@class="WordSection3"]')
      d.name = "main"
      d.first.children.first.previous = html_button()
=begin
      d = docxml.at('//div[@class="WordSection3"]')
      s = d.replace("<main></main>")
      s.first.children = d
      s.first.children.first.previous = html_button()
=end
    end

    def html_preface(docxml)
      html_cover(docxml) if @htmlcoverpage
      html_intro(docxml) if @htmlintropage
      docxml.at("//body") << mathjax(@openmathdelim, @closemathdelim)
      if @scripts
        scripts = File.read(@scripts, encoding: "UTF-8")
        a = docxml.at("//body").add_child scripts #scripts.to_xml(encoding: "US-ASCII")
        a.first.inner_html = a.document.create_cdata(a.first.content)
      end
      html_main(docxml)
      docxml
    end

    def html_cover(docxml)
      cover = File.read(@htmlcoverpage, encoding: "UTF-8")
      coverxml = to_xhtml_fragment(cover)
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling coverxml.to_xml(encoding: "US-ASCII")
    end

    def html_intro(docxml)
      intro = File.read(@htmlintropage, encoding: "UTF-8")
      introxml = to_xhtml_fragment(intro)
      d = docxml.at('//div[@class="WordSection2"]')
      d.children.first.add_previous_sibling introxml.to_xml(encoding: "US-ASCII")
    end

    def htmlstylesheet
      stylesheet = File.read(@htmlstylesheet, encoding: "UTF-8")
      xml = Nokogiri::XML("<style/>")
      xml.children.first << Nokogiri::XML::Comment.new(xml, "\n#{stylesheet}\n")
      xml.root.to_s
    end

    def htmlstyle(docxml)
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
        x["id"] || x["id"] = "_footnote#{i + 1}"
        fn.elements.first.children.first.previous =
          "<a href='##{x['id']}'>#{x.at('./sup').text}) </a>"
      end
      docxml
    end

    # presupposes that the image source is local
    def move_images(docxml)
      system "rm -r _images; mkdir _images"
      docxml.xpath("//*[local-name() = 'img']").each do |i|
        matched = /\.(?<suffix>\S+)$/.match i["src"]
        uuid = UUIDTools::UUID.random_create.to_s
        new_full_filename = File.join("_images", "#{uuid}.#{matched[:suffix]}")
        system "cp #{i['src']} #{new_full_filename}"
        i["src"] = new_full_filename
        i["width"], i["height"] = Html2Doc.image_resize(i, 800, 1200)
      end
      docxml
    end

    def html_toc1(h, ret, prevname)
      h["id"] = UUIDTools::UUID.random_create.to_s unless h["id"]
      li = "<li><a href='##{h["id"]}'>#{header_strip(h)}</a></li>"
      if h.name == "h1"
        ret += "</ul>" if prevname == "h2"
      else
        ret += "<ul>" if prevname == "h1"
      end
      ret + li
    end

    def html_toc_obsolete(docxml)
      return docxml unless @htmlintropage
      ret = ""
      prevname = ""
      docxml.xpath("//h1 | //h2").each do |h|
        next if ["toc-contents", "TermNum"].include? h["class"]
        ret = html_toc1(h, ret, prevname)
        prevname = h.name
      end
      ret += "<ul>" if prevname == "h2"
      docxml.at("//*[@id='toc-list']").replace("<ul>#{ret}</ret>")
      docxml
    end

    def html_toc(docxml)
      docxml
    end
  end
end
