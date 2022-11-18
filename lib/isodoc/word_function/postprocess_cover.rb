module IsoDoc
  module WordFunction
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
        toc = ""
        toc += make_WordToC(docxml, level)
        toc += make_table_word_toc(docxml)
        toc += make_figure_word_toc(docxml)
        toc += make_recommendation_word_toc(docxml)
        intro.sub(/WORDTOC/, toc)
      end

      def word_toc_entry(toclevel, heading)
        bookmark = bookmarkid # Random.rand(1000000000)
        <<~TOC
          <p class="MsoToc#{toclevel}"><span class="MsoHyperlink"><span lang="EN-GB" style='mso-no-proof:yes'>
          <a href="#_Toc#{bookmark}">#{heading}<span lang="EN-GB" class="MsoTocTextSpan">
          <span style='mso-tab-count:1 dotted'>. </span>
          </span><span lang="EN-GB" class="MsoTocTextSpan">
          <span style='mso-element:field-begin'></span></span>
          <span lang="EN-GB" class="MsoTocTextSpan"> PAGEREF _Toc#{bookmark} \\h </span>
            <span lang="EN-GB" class="MsoTocTextSpan"><span style='mso-element:field-separator'></span></span><span
            lang="EN-GB" class="MsoTocTextSpan">1</span>
            <span lang="EN-GB" class="MsoTocTextSpan"></span><span
            lang="EN-GB" class="MsoTocTextSpan"><span style='mso-element:field-end'></span></span></a></span></span></p>

        TOC
      end

      def word_toc_preface(level)
        <<~TOC
          <span lang="EN-GB"><span style='mso-element:field-begin'></span><span
            style='mso-spacerun:yes'>&#xA0;</span>TOC \\o "1-#{level}" \\h \\z \\u <span
            style='mso-element:field-separator'></span></span>
        TOC
      end

      WORD_TOC_SUFFIX1 = <<~TOC.freeze
        <p class="MsoToc1"><span lang="EN-GB"><span
          style='mso-element:field-end'></span></span><span
          lang="EN-GB"><o:p>&#xA0;</o:p></span></p>
      TOC

      def make_WordToC(docxml, level)
        toc = ""
        # docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
        xpath = (1..level).each.map { |i| "//h#{i}" }.join (" | ")
        docxml.xpath(xpath).each do |h|
          toc += word_toc_entry(h.name[1].to_i, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_preface(level)}}) + WORD_TOC_SUFFIX1
      end

      WORD_TOC_RECOMMENDATION_PREFACE1 = <<~TOC.freeze
        <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\h \\z \\t "RecommendationTitle,RecommendationTestTitle,recommendationtitle,recommendationtesttitle"
        <span style='mso-element:field-separator'></span></span>
      TOC

      WORD_TOC_TABLE_PREFACE1 = <<~TOC.freeze
        <span lang="EN-GB"><span style='mso-element:field-begin'></span><span style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\h \\z \\t "TableTitle,tabletitle" <span style='mso-element:field-separator'></span></span>
      TOC

      WORD_TOC_FIGURE_PREFACE1 = <<~TOC.freeze
        <span lang="EN-GB"><span style='mso-element:field-begin'></span><span style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\h \\z \\t "FigureTitle,figuretitle" <span style='mso-element:field-separator'></span></span>
      TOC

      # inheriting gems need to add native Word name of style, if different
      def table_toc_xpath
        "//p[@class = 'TableTitle']"
      end

      def make_table_word_toc(docxml)
        (docxml.at(table_toc_xpath) && @toctablestitle) or return ""
        toc = %{<p class="TOCTitle">#{@toctablestitle}</p>}
        docxml.xpath(table_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{WORD_TOC_TABLE_PREFACE1}}) + WORD_TOC_SUFFIX1
      end

      def figure_toc_xpath
        "//p[@class = 'FigureTitle']"
      end

      def make_figure_word_toc(docxml)
        (docxml.at(figure_toc_xpath) && @tocfigurestitle) or
          return ""
        toc = %{<p class="TOCTitle">#{@tocfigurestitle}</p>}
        docxml.xpath(figure_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{WORD_TOC_FIGURE_PREFACE1}}) + WORD_TOC_SUFFIX1
      end

      def reqt_toc_xpath
        "//p[@class = 'RecommendationTitle' or " \
          "@class = 'RecommendationTestTitle']"
      end

      def make_recommendation_word_toc(docxml)
        (docxml.at(reqt_toc_xpath) && @tocrecommendationstitle) or return ""
        toc = %{<p class="TOCTitle">#{@tocrecommendationstitle}</p>}
        docxml.xpath(reqt_toc_xpath).sort_by do |h|
          recommmendation_sort_key(h.text)
        end.each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{WORD_TOC_RECOMMENDATION_PREFACE1}}) + WORD_TOC_SUFFIX1
      end

      def recommmendation_sort_key(header)
        m = /^([^0-9]+) (\d+)/.match(header) || /^([^:]+)/.match(header)
        m ||= [header, nil]
        ret = "#{recommmendation_sort_key1(m[1])}::"
        m[2] and ret += ("%04d" % m[2].to_i).to_s
        ret
      end

      def recommmendation_sort_key1(type)
        case type&.downcase
        when "requirement" then "04"
        when "recommendation" then "05"
        when "permission" then "06"
        else type
        end
      end

      def authority_cleanup1(docxml, klass)
        dest = docxml.at("//div[@id = 'boilerplate-#{klass}-destination']")
        auth = docxml.at("//div[@id = 'boilerplate-#{klass}' " \
                         "or @class = 'boilerplate-#{klass}']")
        auth&.xpath(".//h1[not(text())] | .//h2[not(text())]")&.each(&:remove)
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
        coverpage_note_cleanup(docxml)
      end

      def coverpage_note_cleanup(docxml)
        if dest = docxml.at("//div[@id = 'coverpage-note-destination']")
          auth = docxml.xpath("//*[@coverpage]")
          if auth.empty? then dest.remove
          else
            auth.each do |x|
              dest << x.remove
            end
          end
        end
        docxml.xpath("//*[@coverpage]").each { |x| x.delete("coverpage") }
      end

      def generate_header(filename, _dir)
        return nil unless @header

        template = IsoDoc::Common.liquid(File.read(@header, encoding: "UTF-8"))
        meta = @meta.get.merge(@labels ? { labels: @labels } : {})
          .merge(@meta.labels ? { labels: @meta.labels } : {})
        meta[:filename] = filename
        params = meta.transform_keys(&:to_s)
        Tempfile.open(%w(header html), encoding: "utf-8") do |f|
          f.write(template.render(params))
          f
        end
      end

      def word_section_breaks(docxml)
        @landscapestyle = ""
        word_section_breaks1(docxml, "WordSection2")
        word_section_breaks1(docxml, "WordSection3")
        word_remove_pb_before_annex(docxml)
        docxml.xpath("//br[@orientation]").each do |br|
          br.delete("orientation")
        end
      end

      def word_section_breaks1(docxml, sect)
        docxml.xpath("//div[@class = '#{sect}']//br[@orientation]").reverse
          .each_with_index do |br, i|
          @landscapestyle +=
            "\ndiv.#{sect}_#{i} {page:#{sect}" \
            "#{br['orientation'] == 'landscape' ? 'L' : 'P'};}\n"
          split_at_section_break(docxml, sect, br, i)
        end
      end

      def split_at_section_break(docxml, sect, brk, idx)
        move = brk.parent.xpath("following::node()") &
          brk.document.xpath("//div[@class = '#{sect}']//*")
        ins = docxml.at("//div[@class = '#{sect}']")
          .after("<div class='#{sect}_#{idx}'/>").next_element
        move.each do |m|
          next if m.at("./ancestor::div[@class = '#{sect}_#{idx}']")

          ins << m.remove
        end
      end
    end
  end
end
