module IsoDoc
  class Convert

    def toHTML(result, filename)
      result = htmlPreface(htmlstyle(Nokogiri::HTML(result))).to_xml
      result = populate_template(result)
      File.open("#{filename}.html", "w") do |f|
        f.write(result)
      end
    end

    def htmlPreface(docxml)
      cover = Nokogiri::HTML(File.read(@htmlcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: 'US-ASCII')
      cover = Nokogiri::HTML(File.read(@htmlntropage, encoding: "UTF-8"))
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
      if title.nil?
        head.children.first.add_previous_sibling css
      else
        title.add_next_sibling css
      end
      docxml
    end
  end
end
