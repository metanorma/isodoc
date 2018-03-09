require "html2doc"
require "htmlentities"
require "nokogiri"
require "liquid"
require "pp"

module IsoDoc
  class Convert
    def postprocess(result, filename, dir)
      generate_header(filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toWord(result, filename, dir)
      toHTML(result, filename)
    end

    def toWord(result, filename, dir)
      result = from_xhtml(word_cleanup(to_xhtml(result)))
      result = populate_template(result, :word)
      Html2Doc.process(result, filename: filename, stylesheet: @wordstylesheet,
                       header_file: "header.html", dir: dir,
                       asciimathdelims: [@openmathdelim, @closemathdelim],
                       liststyles: { ul: @ulstyle, ol: @olstyle })
    end

    def word_cleanup(docxml)
      word_preface(docxml)
      word_annex_cleanup(docxml)
      word_dl_cleanup(docxml)
      docxml
    end

    def word_dl_cleanup1(dtd, tr)
      dtd[:dt].name = "td"
      dtd[:dt]["valign"] = "top"
      dtd[:dt]["align"] = "left"
      dtd[:dt].parent = tr
      dtd[:dd].name = "td"
      dtd[:dd]["valign"] = "top"
      dtd[:dd].parent = tr
    end

    def word_dl_cleanup(docxml)
      docxml.xpath("//dl").each do |dl|
        dl.name = "table"
        dl["class"] = "dl"
        extract_symbols_list(dl).each do |dtd|
          tr = dl.add_child("<tr></tr>").first
          word_dl_cleanup1(dtd, tr)
        end
      end
    end

    # force Annex h2 to be p.h2Annex, so it is not picked up by ToC
    def word_annex_cleanup(docxml)
      docxml.xpath("//h2[ancestor::*[@class = 'Section3']]").each do |h2|
        h2.name = "p"
        h2["class"] = "h2Annex"
      end
    end

    def word_preface(docxml)
      cover = to_xhtml_fragment(File.read(@wordcoverpage, encoding: "UTF-8"))
      docxml.at('//div[@class="WordSection1"]').children.first.previous =
        cover.to_xml(encoding: "US-ASCII")
      intro = to_xhtml_fragment(File.read(@wordintropage, encoding: "UTF-8").
                                sub(/WORDTOC/, make_WordToC(docxml)))
      docxml.at('//div[@class="WordSection2"]').children.first.previous =
        intro.to_xml(encoding: "US-ASCII")
    end

    def populate_template(docxml, _format)
      meta = get_metadata
      docxml = docxml.
        gsub(/\[TERMREF\]\s*/, l10n("[#{@source_lbl}: ")).
        gsub(/\s*\[\/TERMREF\]\s*/, l10n("]")).
        gsub(/\s*\[ISOSECTION\]/, l10n(", ")).
        gsub(/\s*\[MODIFICATION\]/, l10n(", #{@modified_lbl} &mdash; "))
      template = Liquid::Template.parse(docxml)
      template.render(meta.map { |k, v| [k.to_s, v] }.to_h)
    end

    def generate_header(filename, _dir)
      template = Liquid::Template.parse(File.read(@header, encoding: "UTF-8"))
      meta = get_metadata
      meta[:filename] = filename
      params = meta.map { |k, v| [k.to_s, v] }.to_h
      File.open("header.html", "w") do |f|
        f.write(template.render(params))
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
    def define_head(html, filename, _dir)
      html.head do |head|
        head.title { |t| t << filename }
        return unless @standardstylesheet
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

    WORD_TOC_PREFACE = <<~TOC.freeze
      <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\o &quot;1-2&quot; \\h \\z \\u <span
        style='mso-element:field-separator'></span></span>
    TOC

    WORD_TOC_SUFFIX = <<~TOC.freeze
      <p class="MsoToc1"><span lang="EN-GB"><span
        style='mso-element:field-end'></span></span><span
        lang="EN-GB"><o:p>&nbsp;</o:p></span></p>
    TOC

    def header_strip(h)
      h = h.to_s.gsub(%r{<br/>}, " ").
        sub(/<h[12][^>]*>/, "").sub(%r{</h[12]>}, "")
      h1 = to_xhtml_fragment(h)
      h1.xpath(".//*").each do |x|
        if x.name == "span" && x["style"] == "MsoCommentReference"
          x.children.remove
          x.content = ""
        end
      end
      from_xhtml(h1)
    end

    def make_WordToC(docxml)
      toc = ""
      docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
        each do |h|
        toc += word_toc_entry(h.name == "h1" ? 1 : 2, header_strip(h))
      end
      toc.sub(/(<p class="MsoToc1">)/,
              %{\\1#{WORD_TOC_PREFACE}}) + WORD_TOC_SUFFIX
    end
  end
end
