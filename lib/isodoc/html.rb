module IsoDoc
  class Convert

    def toHTML(result, filename)
      result = html_cleanup(Nokogiri::HTML(result)).to_xml
      result = populate_template(result, :html)
      File.open("#{filename}.html", "w") do |f|
        f.write(result)
      end
    end

    def html_cleanup(x)
      html_footnote_filter(htmlPreface(htmlstyle(x)))
    end

    def htmlPreface(docxml)
      cover = Nokogiri::HTML(File.read(@htmlcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: 'US-ASCII')
      cover = Nokogiri::HTML(File.read(@htmlintropage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection2"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: 'US-ASCII')
      body = docxml.at("//*[local-name() = 'body']")
      body << '<script src="https://cdn.mathjax.org/mathjax/latest/'\
        'MathJax.js?config=AM_HTMLorMML"></script>'
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

    def update_footnote_filter(x, i, seen)
      (fn = docxml("//*[@id = #{x['href'].sub(/^#/, "")}]")) || return
      if seen[fn.text]
        x.at("./sup").content = seen[fn.text][:num]
        x["href"] = seen[fn.remove.text][:href]
      else
        seen[fn.text] = { num: i, href: x["href"] }
        i += 1
      end
      [i, seen]
    end

    def html_footnote_filter(docxml)
      seen = {}
      i = 1
      docxml.xpath('//a[@epub:type = "footnote"]').each do |x|
        i, seen = update_footnote_filter(x, i, seen)
      end
      docxml
    end
  end
end
