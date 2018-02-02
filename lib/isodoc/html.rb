module IsoDoc
  class Convert

    def self.toHTML(result, filename)
      result = htmlstyle(Nokogiri::HTML(result)).to_xml
      File.open("#{filename}.html", "w") do |f|
        f.write(result)
      end
    end

    def self.stylesheet(fn)
      (fn.nil? or fn.empty?) and
        fn = File.join(File.dirname(__FILE__), "wordstyle.css")
      stylesheet = File.read(fn, encoding: "UTF-8")
      xml = Nokogiri::XML("<style/>")
      xml.children.first << Nokogiri::XML::Comment.new(xml, "\n#{stylesheet}\n")
      xml.root.to_s
    end


    def self.htmlstyle(docxml)
      fn = File.join(File.dirname(__FILE__), "htmlstyle.css")
      title = docxml.at("//*[local-name() = 'head']/*[local-name() = 'title']")
      head = docxml.at("//*[local-name() = 'head']")
      css = stylesheet(fn)
      if title.nil?
        head.children.first.add_previous_sibling css
      else
        title.add_next_sibling css
      end
      docxml
    end
  end
end
