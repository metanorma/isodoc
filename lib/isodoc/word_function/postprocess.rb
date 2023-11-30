require "fileutils"
require_relative "postprocess_cover"
require_relative "postprocess_toc"
require_relative "postprocess_table"

module IsoDoc
  module WordFunction
    module Postprocess
      def postprocess(result, filename, dir)
        filename = filename.sub(/\.doc$/, "")
        header = generate_header(filename, dir)
        result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
        toWord(result, filename, dir, header)
        @files_to_delete.each { |f| FileUtils.rm_f f }
      end

      def toWord(result, filename, dir, header)
        result = from_xhtml(word_cleanup(to_xhtml(result)))
          .gsub("-DOUBLE_HYPHEN_ESCAPE-", "--")
        @wordstylesheet = wordstylesheet_update
        Html2Doc.new(
          filename: filename, imagedir: @localdir,
          stylesheet: @wordstylesheet&.path,
          header_file: header&.path, dir: dir,
          asciimathdelims: [@openmathdelim, @closemathdelim],
          liststyles: { ul: @ulstyle, ol: @olstyle }
        ).process(result)
        header&.unlink
        @wordstylesheet.unlink if @wordstylesheet.is_a?(Tempfile)
      end

      def sourcecode_style
        "Sourcecode"
      end

      def word_admonition_images(docxml)
        docxml.xpath("//div[@class = 'Admonition']//img").each do |i|
          i["width"], i["height"] =
            Html2Doc.new({}).image_resize(i, image_localfile(i), @maxheight,
                                          300)
        end
      end

      def word_cleanup(docxml)
        word_annex_cleanup(docxml)
        word_preface(docxml)
        word_sourcecode_annotations(docxml)
        word_sourcecode_table(docxml)
        word_nested_tables(docxml)
        word_colgroup(docxml)
        word_table_align(docxml)
        word_table_pagebreak(docxml)
        word_table_separator(docxml)
        word_admonition_images(docxml)
        word_list_continuations(docxml)
        word_example_cleanup(docxml)
        word_pseudocode_cleanup(docxml)
        word_image_caption(docxml)
        word_floating_titles(docxml)
        word_section_breaks(docxml)
        word_tab_clean(docxml)
        authority_cleanup(docxml)
        word_footnote_format(docxml)
        docxml
      end

      def word_sourcecode_annotations(html)
        ann = ".//div[@class = 'annotation']"
        html.xpath("//p[@class = '#{sourcecode_style}'][#{ann}]")
          .each do |p|
          ins = p.after("<p class='#{sourcecode_style}'/>").next_element
          p.xpath(ann).each do |d|
            ins << d.remove.children
          end
        end
      end

      def word_sourcecode_table(docxml)
        s = "p[@class='#{sourcecode_style}']"
        docxml.xpath("//#{s}/div[@class='table_container']").each do |d|
          pre = d.at(".//#{s}")
          to_sourcecode_para(pre)
          d["id"] = d.parent["id"]
          d.parent.replace(d)
        end
      end

      def to_sourcecode_para(pre)
        @sourcecode = "pre"
        pre.traverse do |x|
          x.text? or next
          ret = []
          text_parse(x, ret)
          x.replace(ret.join)
        end
        @sourcecode = false
      end

      def word_tab_clean(docxml)
        docxml.xpath("//p[@class='Biblio']//span[@style='mso-tab-count:1']")
          .each do |s|
          s.next.text? or next
          s.next.replace(@c.encode(s.next.text.sub(/^\s+/, ""), :hexadecimal))
        end
      end

      def word_image_caption(docxml)
        docxml.xpath("//p[@class = 'FigureTitle' or @class = 'SourceTitle']")
          .each do |t|
          if t.previous_element&.name == "img"
            img = t.previous_element
            t.previous_element.swap("<p class='figure'>#{img.to_xml}</p>")
          end
          style_update(t.previous_element, "page-break-after:avoid;")
        end
      end

      def word_list_continuations(docxml)
        list_add(docxml.xpath("//ul[not(ancestor::ul) and not(ancestor::ol)]"),
                 1)
        list_add(docxml.xpath("//ol[not(ancestor::ul) and not(ancestor::ol)]"),
                 1)
      end

      def list_add(xpath, lvl)
        xpath.each do |list|
          (list.xpath(".//li") - list.xpath(".//ol//li | .//ul//li")).each do |l|
            l.xpath("./p | ./div | ./table").each_with_index do |p, i|
              i.zero? or p.wrap(%{<div class="ListContLevel#{lvl}"/>})
            end
            list_add(l.xpath(".//ul") - l.xpath(".//ul//ul | .//ol//ul"),
                     lvl + 1)
            list_add(l.xpath(".//ol") - l.xpath(".//ul//ol | .//ol//ol"),
                     lvl + 1)
          end
        end
      end

      def word_annex_cleanup(docxml); end

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
          (d.elements[0].name == "p" && !d.elements[0].elements.empty?) or next
          (d.elements[0].elements[0].name == "br" &&
            d.elements[0].elements[0]["style"] ==
              "mso-special-character:line-break;page-break-before:always") or next
          d.elements[0].remove
        end
      end

      def word_footnote_format(docxml)
        # the content is in a[@epub:type = 'footnote']//sup, but in Word,
        # we need to inject content around the autonumbered footnote reference
        docxml.xpath("//a[@epub:type = 'footnote']").each do |x|
          footnote_reference_format(x)
        end
        docxml.xpath("//a[@class = 'TableFootnoteRef'] | " \
                     "//span[@class = 'TableFootnoteRef']").each do |x|
          table_footnote_reference_format(x)
        end
        docxml
      end

      # move p.h1 (floating title) after any page, section breaks
      def word_floating_titles(docxml)
        docxml.xpath("//p[@class = 'section-break' or @class = 'page-break']")
          .each do |b|
          out = b.xpath("./preceding-sibling::*").reverse
            .each_with_object([]) do |p, m|
            (p.name == "p" && p["class"] == "h1") or break m
            m << p
          end
          b.delete("class")
          out.empty? and next
          out[-1].previous = b.remove
        end
      end
    end
  end
end
