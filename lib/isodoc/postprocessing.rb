require "html2doc"
require "htmlentities"
require "nokogiri"
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
      result = from_xhtml(wordCleanup(to_xhtml(result)))
      result = populate_template(result)
      Html2Doc.process(result, filename, @wordstylesheet, "header.html", 
                       dir, ['`', '`'])
    end

    def wordCleanup(docxml)
      wordPreface(docxml)
      wordAnnexCleanup(docxml)
      docxml
    end

    # force Annex h2 to be p.h2Annex, so it is not picked up by ToC
    def wordAnnexCleanup(docxml)
      d = docxml.xpath("//h2[ancestor::*[@class = 'Section3']]").each do |h2|
        h2.name = "p"
        h2["class"] = "h2Annex"
      end
    end

    def wordPreface(docxml)
      cover = to_xhtml_fragment(File.read(@wordcoverpage, encoding: "UTF-8"))
      d = docxml.at('//div[@class="WordSection1"]')
      d.children.first.add_previous_sibling cover.to_xml(encoding: 'US-ASCII')
      intro = to_xhtml_fragment(
        File.read(@wordintropage, encoding: "UTF-8").
        sub(/WORDTOC/, makeWordToC(docxml)))
      d = docxml.at('//div[@class="WordSection2"]')
      d.children.first.add_previous_sibling intro.to_xml(encoding: 'US-ASCII')
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

    def wordTocEntry(toclevel, heading)
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

    WORD_TOC_PREFACE = <<~TOC
      <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span 
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\o &quot;1-2&quot; \\h \\z \\u <span 
        style='mso-element:field-separator'></span></span>
    TOC

    WORD_TOC_SUFFIX = <<~TOC
      <p class="MsoToc1"><span lang="EN-GB"><span 
        style='mso-element:field-end'></span></span><span 
        lang="EN-GB"><o:p>&nbsp;</o:p></span></p>
    TOC

    def header_strip(h)
      h.to_s.gsub(%r{<br/>}, " ").
        sub(/<h[12][^>]*>/, "").sub(%r{</h[12]>}, "")
    end

    def makeWordToC(docxml)
      toc = ""
      docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
        each do |h|
        toc += wordTocEntry(h.name == "h1" ? 1 : 2, header_strip(h))
      end
      toc.sub(/(<p class="MsoToc1">)/, 
              %{\\1#{WORD_TOC_PREFACE}}) + WORD_TOC_SUFFIX
    end

  end
end
