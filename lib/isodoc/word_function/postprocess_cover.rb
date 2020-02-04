module IsoDoc::WordFunction
  module Postprocess
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

    def word_intro(docxml, level)
      intro = insert_toc(File.read(@wordintropage, encoding: "UTF-8"),
                         docxml, level)
      intro = populate_template(intro, :word)
      introxml = to_word_xhtml_fragment(intro)
      docxml.at('//div[@class="WordSection2"]').children.first.previous =
        introxml.to_xml(encoding: "US-ASCII")
    end

    def insert_toc(intro, docxml, level)
      intro.sub(/WORDTOC/, make_WordToC(docxml, level))
    end

    def word_toc_entry(toclevel, heading)
      bookmark = bookmarkid # Random.rand(1000000000)
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
