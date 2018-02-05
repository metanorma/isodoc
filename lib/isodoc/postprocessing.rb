require "html2doc"
require "htmlentities"
require "nokogiri"
require "pp"

module IsoDoc
  class Convert

    NOKOHEAD = <<~HERE
          <!DOCTYPE html SYSTEM
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head> <title></title> <meta charset="UTF-8" /> </head>
          <body> </body> </html>
    HERE

    def to_xhtml(xml)
      xml.gsub!(/<\?xml[^>]*>/, "")
      unless /<!DOCTYPE /.match? xml
        xml = '<!DOCTYPE html SYSTEM
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' + xml
      end
      Nokogiri::XML.parse(xml)
    end

    def to_xhtml_fragment(xml)
      doc = ::Nokogiri::XML.parse(NOKOHEAD)
      fragment = doc.fragment(xml)
      fragment
    end

    def from_xhtml(xml)
      xml.to_xml.sub(%r{ xmlns="http://www.w3.org/1999/xhtml"}, "")
    end

    def postprocess(result, filename, dir)
      generate_header(filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toWord(result, filename, dir)
      toHTML(result, filename)
    end

    def toWord(result, filename, dir)
      result = from_xhtml(wordPreface(to_xhtml(result)))
      result = populate_template(result)
      Html2Doc.process(result, filename, @wordstylesheet, "header.html", 
                       dir, ['`', '`'])
    end

    def wordPreface(docxml)
      cover = to_xhtml_fragment(File.read(@wordcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: 'US-ASCII')
      intro = to_xhtml_fragment(File.read(@wordintropage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection2"]')
      d.children.first.add_previous_sibling intro.to_xml(encoding: 'US-ASCII')
      docxml
    end

    def cleanup(docxml)
      comment_cleanup(docxml)
      footnote_cleanup(docxml)
      inline_header_cleanup(docxml)
      docxml
    end

    def inline_header_cleanup(docxml)
      docxml.xpath('//span[@class="zzMoveToFollowing"]').each do |x|
        n = x.next_element
        if n.nil?
          html = Nokogiri::XML.fragment("<p></p>")
          html.parent = x.parent
          x.parent = html
        else
          n.children.first.add_previous_sibling(x.remove)
        end
      end
    end

    def comment_cleanup(docxml)
      docxml.xpath('//div/span[@style="MsoCommentReference"]').
        each do |x|
        prev = x.previous_element
        if !prev.nil?
          x.parent = prev
        end
      end
      docxml
    end

    def footnote_cleanup(docxml)
      docxml.xpath('//div[@style="mso-element:footnote"]/a').
        each do |x|
        n = x.next_element
        if !n.nil?
          n.children.first.add_previous_sibling(x.remove)
        end
      end
      docxml
    end

    def populate_template(docxml)
      meta = get_metadata
      docxml.
        gsub(/DOCYEAR/, meta[:docyear]).
        gsub(/DOCNUMBER/, meta[:docnumber]).
        gsub(/TCNUM/, meta[:tc]).
        gsub(/SCNUM/, meta[:sc]).
        gsub(/WGNUM/, meta[:wg]).
        gsub(/DOCTITLE/, meta[:doctitle]).
        gsub(/DOCSUBTITLE/, meta[:docsubtitle]).
        gsub(/SECRETARIAT/, meta[:secretariat]).
        gsub(/[ ]?DRAFTINFO/, meta[:draftinfo]).
        gsub(/\[TERMREF\]\s*/, "[SOURCE: ").
        gsub(/\s*\[\/TERMREF\]\s*/, "]").
        gsub(/\s*\[ISOSECTION\]/, ", ").
        gsub(/\s*\[MODIFICATION\]/, ", modified &mdash; ").
        gsub(%r{WD/CD/DIS/FDIS}, meta[:stageabbr])
    end

    def generate_header(filename, dir)
      header = File.read(@header, encoding: "UTF-8").
        gsub(/FILENAME/, filename).
        gsub(/DOCYEAR/, get_metadata()[:docyear]).
        gsub(/[ ]?DRAFTINFO/, get_metadata()[:draftinfo]).
        gsub(/DOCNUMBER/, get_metadata()[:docnumber])
      File.open("header.html", "w") do |f|
        f.write(header)
      end
    end

    # these are in fact preprocess,
    # but they are extraneous to main HTML file
    def html_header(html, docxml, filename, dir)
      anchor_names docxml
      define_head html, filename, dir
    end

    # isodoc.css overrides any CSS injected by Html2Doc, which
    # is inserted before this CSS.
    def define_head(html, filename, dir)
      html.head do |head|
        head.title { |t| t << filename }
        head.style do |style|
          stylesheet = File.read(@standardstylesheet).
            gsub("FILENAME", filename)
          style.comment "\n#{stylesheet}\n"
        end
      end
    end

    def titlepage(_docxml, div)
      titlepage = File.read(@wordcoverpage, encoding: "UTF-8")
      div.parent.add_child titlepage
    end
  end
end
