require "fileutils"
require_relative "./postprocess_cover.rb"

module IsoDoc::WordFunction
  module Postprocess
    # add namespaces for Word fragments
    WORD_NOKOHEAD = <<~HERE.freeze
    <!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">
    <head> <title></title> <meta charset="UTF-8" /> </head>
    <body> </body> </html>
    HERE

    def to_word_xhtml_fragment(xml)
      doc = ::Nokogiri::XML.parse(WORD_NOKOHEAD)
      ::Nokogiri::XML::DocumentFragment.new(doc, xml, doc.root)
    end

    def table_note_cleanup(docxml)
      super
      # preempt html2doc putting MsoNormal there
      docxml.xpath("//p[not(self::*[@class])][ancestor::*[@class = 'Note']]").each do |p|
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
      @wordstylesheet = wordstylesheet_update
      Html2Doc.process(result, filename: filename, stylesheet: @wordstylesheet&.path,
                       header_file: header&.path, dir: dir,
                       asciimathdelims: [@openmathdelim, @closemathdelim],
                       liststyles: { ul: @ulstyle, ol: @olstyle })
      header&.unlink
      @wordstylesheet&.unlink if @wordstylesheet&.is_a?(Tempfile)
    end

    def wordstylesheet_update()
      return if @wordstylesheet.nil?
      f = File.open(@wordstylesheet.path, "a")
      @landscapestyle.empty? or f.write(@landscapestyle)
      if @wordstylesheet_override && @wordstylesheet
        f.write(@wordstylesheet_override.read)
        @wordstylesheet_override.close
      elsif @wordstylesheet_override && !@wordstylesheet
        @wordstylesheet = @wordstylesheet_override
      end
      f.close
      @wordstylesheet
    end

    def word_admonition_images(docxml)
      docxml.xpath("//div[@class = 'Admonition']//img").each do |i|
        i["width"], i["height"] = Html2Doc.image_resize(i, image_localfile(i), @maxheight, 300)
      end
    end

    def word_cleanup(docxml)
      word_annex_cleanup(docxml)
      word_preface(docxml)
      word_nested_tables(docxml)
      word_colgroup(docxml)
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

    def word_colgroup(docxml)
      cells2d = {}
      docxml.xpath("//table[colgroup]").each do |t|
        w = colgroup_widths(t)
        t.xpath(".//tr").each_with_index { |tr, r| cells2d[r] = {} }
        t.xpath(".//tr").each_with_index do |tr, r|
          tr.xpath("./td | ./th").each_with_index do |td, i|
            x = 0
            rs = td&.attr("rowspan")&.to_i || 1
            cs = td&.attr("colspan")&.to_i || 1
            while cells2d[r][x] do
              x += 1 
            end
            for y2 in r..(r + rs - 1)
              for x2 in x..(x + cs - 1)
                cells2d[y2][x2] = 1
              end
            end
            width = (x..(x+cs-1)).each_with_object({width: 0}) { |z, m| m[:width] += w[z] }
            td["width"] = "#{width[:width]}%"
            x += cs
          end
        end
      end
    end

    # assume percentages
    def colgroup_widths(t)
      t.xpath("./colgroup/col").each_with_object([]) do |c, m|
        m << c["width"].sub(/%$/, "").to_f
      end
    end

    def word_nested_tables(docxml)
      docxml.xpath("//table").each do |t|
        t.xpath(".//table").reverse.each do |tt|
          t.next = tt.remove
        end
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
          l.xpath("./p | ./div | ./table").each_with_index do |p, i|
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
      docxml.xpath("//a[@class = 'TableFootnoteRef'] | //span[@class = 'TableFootnoteRef']").each do |x|
        table_footnote_reference_format(x)
      end
      docxml
    end
  end
end
