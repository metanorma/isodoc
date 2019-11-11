require "fileutils"

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
      header = generate_header(filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toWord(result, filename, dir, header)
      @files_to_delete.each { |f| FileUtils.rm_f f }
    end

    def toWord(result, filename, dir, header)
      result = populate_template(result, :word)
      result = from_xhtml(word_cleanup(to_xhtml(result)))
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
          Html2Doc.image_resize(i, File.join(@localdir, i["src"]),
                                @maxheight, 300)
      end
    end

    def word_cleanup(docxml)
      word_annex_cleanup(docxml)
      word_preface(docxml)
      word_table_align(docxml)
      word_table_separator(docxml)
      word_admonition_images(docxml)
      word_list_continuations(docxml)
      word_example_cleanup(docxml)
      word_pseudocode_cleanup(docxml)
      word_image_caption(docxml)
      docxml
    end

    def style_update(node, css)
      node["style"] = node["style"] ?  node["style"].sub(/;?$/, ";#{css}") : css
    end

    def word_image_caption(docxml)
      docxml.xpath("//p[@class = 'FigureTitle' or @class = 'SourceTitle']").
        each do |t|
        if t.previous_element.name == "img"
          img = t.previous_element
          t.previous_element.swap("<p class=\'figure\'>#{img.to_xml}</p>")
        end
        style_update(t.previous_element, "page-break-after:avoid;")
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

    def word_preface(docxml)
      word_cover(docxml) if @wordcoverpage
      word_intro(docxml, @wordToClevels) if @wordintropage
    end

    def word_cover(docxml)
      cover = File.read(@wordcoverpage, encoding: "UTF-8")
      cover = populate_template(cover, :word)
      coverxml = to_word_xhtml_fragment(cover)
      docxml.at('//div[@class="WordSection1"]').children.first.previous =
        coverxml.to_xml(encoding: "US-ASCII")
    end

    def insert_toc(intro, docxml, level)
      intro.sub(/WORDTOC/, make_WordToC(docxml, level))
    end

    def word_intro(docxml, level)
      intro = insert_toc(File.read(@wordintropage, encoding: "UTF-8"),
                         docxml, level)
      intro = populate_template(intro, :word)
      introxml = to_word_xhtml_fragment(intro)
      docxml.at('//div[@class="WordSection2"]').children.first.previous =
        introxml.to_xml(encoding: "US-ASCII")
    end

    def generate_header(filename, _dir)
      return nil unless @header
      template = IsoDoc::Common.liquid(File.read(@header, encoding: "UTF-8"))
      meta = @meta.get
      meta[:filename] = filename
      params = meta.map { |k, v| [k.to_s, v] }.to_h
      #headerfile = "header.html"
      #File.open(headerfile, "w:UTF-8") { |f| f.write(template.render(params)) }
      #@files_to_delete << headerfile
      #headerfile
      Tempfile.open(%w(header html), :encoding => "utf-8") do |f|
        f.write(template.render(params))
        f
      end
    end

    def word_toc_entry(toclevel, heading)
      bookmark = Random.rand(1000000000)
      <<~TOC
        <p class="MsoToc#{toclevel}"><span class="MsoHyperlink"><span
        lang="EN-GB" style='mso-no-proof:yes'>
        <a href="#_Toc#{bookmark}">#{heading}<span lang="EN-GB"
        class="MsoTocTextSpan">
        <span style='mso-tab-count:1 dotted'>. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan">
        <span style='mso-element:field-begin'></span></span>
        <span lang="EN-GB"
        class="MsoTocTextSpan"> PAGEREF _Toc#{bookmark} \\h </span>
          <span lang="EN-GB" class="MsoTocTextSpan"><span
          style='mso-element:field-separator'></span></span><span
          lang="EN-GB" class="MsoTocTextSpan">1</span>
          <span lang="EN-GB"
          class="MsoTocTextSpan"></span><span
          lang="EN-GB" class="MsoTocTextSpan"><span
          style='mso-element:field-end'></span></span></a></span></span></p>

      TOC
    end

    def word_toc_preface(level) 
      <<~TOC.freeze
      <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\o &quot;1-#{level}&quot; \\h \\z \\u <span
        style='mso-element:field-separator'></span></span>
      TOC
    end

    WORD_TOC_SUFFIX1 = <<~TOC.freeze
      <p class="MsoToc1"><span lang="EN-GB"><span
        style='mso-element:field-end'></span></span><span
        lang="EN-GB"><o:p>&nbsp;</o:p></span></p>
    TOC

    def make_WordToC(docxml, level)
      toc = ""
      #docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
      xpath = (1..level).each.map { |i| "//h#{i}" }.join (" | ")
      docxml.xpath(xpath).each do |h|
        toc += word_toc_entry(h.name[1].to_i, header_strip(h))
      end
      toc.sub(/(<p class="MsoToc1">)/,
              %{\\1#{word_toc_preface(level)}}) +  WORD_TOC_SUFFIX1
    end
  end
end
