require "fileutils"
require_relative "./postprocess_cover.rb"

module IsoDoc::WordFunction
  module Postprocess
    # add namespaces for Word fragments
    WORD_NOKOHEAD = <<~HERE.freeze
    <!DOCTYPE html SYSTEM
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">
    <head> <title></title> <meta charset="UTF-8" /> </head>
    <body> </body> </html>
    HERE

    def to_word_xhtml_fragment(xml)
      doc = ::Nokogiri::XML.parse(WORD_NOKOHEAD)
      fragment = ::Nokogiri::XML::DocumentFragment.new(doc, xml, doc.root)
      fragment
    end

    def table_note_cleanup(docxml)
      super
      # preempt html2doc putting MsoNormal there
      docxml.xpath("//p[not(self::*[@class])]"\
                   "[ancestor::*[@class = 'Note']]").each do |p|
        p["class"] = "Note"
      end
    end

    def postprocess(result, filename, dir)
      filename = filename.sub(/\.doc$/, "")
      header = generate_header(filename, dir)
      result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
      toWord(result, filename, dir, header)
      @files_to_delete.each { |f| FileUtils.rm_f f }
    end

    def toWord(result, filename, dir, header)
      result = from_xhtml(word_cleanup(to_xhtml(result)))
      unless @landscapestyle.empty?
        @wordstylesheet&.open
        @wordstylesheet&.write(@landscapestyle)
        @wordstylesheet&.close
      end
      Html2Doc.process(result, filename: filename, stylesheet: @wordstylesheet&.path,
                       header_file: header&.path, dir: dir,
                       asciimathdelims: [@openmathdelim, @closemathdelim],
                       liststyles: { ul: @ulstyle, ol: @olstyle })
      header&.unlink
      @wordstylesheet&.unlink
    end

    def word_admonition_images(docxml)
      docxml.xpath("//div[@class = 'Admonition']//img").each do |i|
        i["width"], i["height"] =
          Html2Doc.image_resize(i, image_localfile(i), @maxheight, 300)
      end
    end

    def word_cleanup(docxml)
      word_annex_cleanup(docxml)
      word_preface(docxml)
      word_nested_tables(docxml)
      word_table_align(docxml)
      word_table_separator(docxml)
      word_admonition_images(docxml)
      word_list_continuations(docxml)
      word_example_cleanup(docxml)
      word_pseudocode_cleanup(docxml)
      word_image_caption(docxml)
      word_section_breaks(docxml)
      authority_cleanup(docxml)
      word_footnote_format(docxml)
      docxml
    end

    def word_nested_tables(docxml)
      docxml.xpath("//table").each do |t|
        t.xpath(".//table").reverse.each do |tt|
          t.next = tt.remove
        end
      end
    end

    def authority_cleanup1(docxml, klass)
      dest = docxml.at("//div[@id = 'boilerplate-#{klass}-destination']")
      auth = docxml.at("//div[@id = 'boilerplate-#{klass}' or @class = 'boilerplate-#{klass}']")
      auth&.xpath(".//h1[not(text())] | .//h2[not(text())]")&.each { |h| h.remove }
      auth&.xpath(".//h1 | .//h2")&.each do |h|
        h.name = "p"
        h["class"] = "TitlePageSubhead"
      end
      dest and auth and dest.replace(auth.remove)
    end

    def authority_cleanup(docxml)
      %w(copyright license legal feedback).each do |t|
        authority_cleanup1(docxml, t)
      end
    end

    def style_update(node, css)
      return unless node
      node["style"] = node["style"] ?  node["style"].sub(/;?$/, ";#{css}") : css
    end

    def word_image_caption(docxml)
      docxml.xpath("//p[@class = 'FigureTitle' or @class = 'SourceTitle']").
        each do |t|
        if t&.previous_element&.name == "img"
          img = t.previous_element
          t.previous_element.swap("<p class=\'figure\'>#{img.to_xml}</p>")
        end
        style_update(t&.previous_element, "page-break-after:avoid;")
      end
    end

    def word_list_continuations(docxml)
      list_add(docxml.xpath("//ul[not(ancestor::ul) and not(ancestor::ol)]"), 1)
      list_add(docxml.xpath("//ol[not(ancestor::ul) and not(ancestor::ol)]"), 1)
    end

    def list_add(xpath, lvl)
      xpath.each do |list|
        (list.xpath(".//li") - list.xpath(".//ol//li | .//ul//li")).each do |l|
          l.xpath("./p | ./div").each_with_index do |p, i|
            next if i == 0
            p.wrap(%{<div class="ListContLevel#{lvl}"/>})
          end
          list_add(l.xpath(".//ul") - l.xpath(".//ul//ul | .//ol//ul"), lvl + 1)
          list_add(l.xpath(".//ol") - l.xpath(".//ul//ol | .//ol//ol"), lvl + 1)
        end
      end
    end

    def word_table_align(docxml)
      docxml.xpath("//td[@align]/p | //th[@align]/p").each do |p|
        next if p["align"]
        style_update(p, "text-align: #{p.parent["align"]}")
      end
    end

=begin
    EMPTY_PARA = "<p style='margin-top:0cm;margin-right:0cm;"\
      "margin-bottom:0cm;margin-left:0.0pt;margin-bottom:.0001pt;"\
      "line-height:1.0pt;mso-line-height-rule:exactly'>"\
      "<span lang=EN-GB style='display:none;mso-hide:all'>&nbsp;</span></p>"

    def table_after_table(docxml)
     docxml.xpath("//table[following-sibling::*[1]/self::table]").each do |t|
        t.add_next_sibling(EMPTY_PARA)
      end
    end
=end

    def word_table_separator(docxml)
      docxml.xpath("//p[@class = 'TableTitle']").each do |t|
        next unless t.children.empty?
        t["style"] = t["style"].sub(/;?$/, ";font-size:0pt;")
        t.children = "&nbsp;"
      end
    end

    def word_annex_cleanup(docxml)
    end

    def word_example_cleanup(docxml)
      docxml.xpath("//div[@class = 'example']//p[not(@class)]").each do |p|
        p["class"] = "example"
      end
    end

    def word_pseudocode_cleanup(docxml)
      docxml.xpath("//div[@class = 'pseudocode']//p[not(@class)]").each do |p|
        p["class"] = "pseudocode"
      end
    end

    def generate_header(filename, _dir)
      return nil unless @header
      template = IsoDoc::Common.liquid(File.read(@header, encoding: "UTF-8"))
      meta = @meta.get
      meta[:filename] = filename
      params = meta.map { |k, v| [k.to_s, v] }.to_h
      Tempfile.open(%w(header html), :encoding => "utf-8") do |f|
        f.write(template.render(params))
        f
      end
    end

    def word_section_breaks(docxml)
      @landscapestyle = ""
      word_section_breaks1(docxml, "WordSection2")
      word_section_breaks1(docxml, "WordSection3")
      word_remove_pb_before_annex(docxml)
      docxml.xpath("//br[@orientation]").each { |br| br.delete("orientation") }
    end

    def word_section_breaks1(docxml, sect)
      docxml.xpath("//div[@class = '#{sect}']//br[@orientation]").reverse.
        each_with_index do |br, i|
        @landscapestyle += "\ndiv.#{sect}_#{i} {page:#{sect}"\
          "#{br["orientation"] == "landscape" ? "L" : "P"};}\n"
        split_at_section_break(docxml, sect, br, i)
      end
    end

    def split_at_section_break(docxml, sect, br, i)
      move = br.parent.xpath("following::node()") &
        br.document.xpath("//div[@class = '#{sect}']//*")
      ins = docxml.at("//div[@class = '#{sect}']").
        after("<div class='#{sect}_#{i}'/>").next_element
      move.each do |m|
        next if m.at("./ancestor::div[@class = '#{sect}_#{i}']")
        ins << m.remove
      end
    end

    # applies for <div class="WordSectionN_M"><p><pagebreak/></p>...
    def word_remove_pb_before_annex(docxml)
      docxml.xpath("//div[p/br]").each do |d|
        /^WordSection\d+_\d+$/.match(d["class"]) or next
        d.elements[0].name == "p" && !d.elements[0].elements.empty? or next
        d.elements[0].elements[0].name == "br" && d.elements[0].elements[0]["style"] ==
          "mso-special-character:line-break;page-break-before:always" or next
        d.elements[0].remove
      end
    end

    def word_footnote_format(docxml)
      # the content is in a[@epub:type = 'footnote']//sup, but in Word, 
      # we need to inject content around the autonumbered footnote reference
      docxml.xpath("//a[@epub:type = 'footnote']").each do |x|
        footnote_reference_format(x)
      end
      docxml.xpath("//a[@class = 'TableFootnoteRef'] | "\
                   "//span[@class = 'TableFootnoteRef']").each do |x|
        table_footnote_reference_format(x)
      end
      docxml
    end
  end
end
