module IsoDoc
  class Convert
    def toHTML(result, filename)
      result = from_xhtml(html_cleanup(to_xhtml(result)))
      result = populate_template(result, :html)
      File.open("#{filename}.html", "w") do |f|
        f.write(result)
      end
    end

    def html_cleanup(x)
      footnote_backlinks(
        html_toc(move_images(html_footnote_filter(html_preface(htmlstyle(x)))))
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

    def html_preface(docxml)
      cover = Nokogiri::HTML(File.read(@htmlcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: "US-ASCII")
      cover = Nokogiri::HTML(File.read(@htmlintropage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection2"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: "US-ASCII")
      docxml.at("//*[local-name() = 'body']") << mathjax(@openmathdelim,
                                                         @closemathdelim)
      docxml
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
      li = "<li><a href='##{h["id"]}'>#{h.text}</a></li>"
      if h.name == "h1"
        ret += "</ul>" if prevname == "h2"
      else
        ret += "<ul>" if prevname == "h1"
      end
      ret + li
    end

    def html_toc(docxml)
      ret = ""
      prevname = ""
      docxml.xpath("//h1 | //h2").each do |h|
        ret = html_toc1(h, ret, prevname) unless h["class"] == "toc-contents"
        prevname = h.name
      end
      ret += "<ul>" if prevname == "h2"
      docxml.at("//*[@id='toc-list']").replace("<ul>#{ret}</ret>")
      docxml
    end
  end
end
