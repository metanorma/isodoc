module IsoDoc
  module WordFunction
    module Postprocess
      def insert_toc(intro, docxml, level)
        toc = assemble_toc(docxml, level)
        if intro&.include?("WORDTOC")
          remove_toc_div(docxml)
          intro.sub("WORDTOC", toc)
        else
          source = docxml.at("//div[@class = 'TOC']") and
            source.children = toc
          intro
        end
      end

      def remove_toc_div(docxml)
        s = docxml.at("//div[@class = 'TOC']") or return
        prev = s.previous_element
        prev&.elements&.first&.name == "br" and
          prev&.remove # page break
        s.remove
      end

      def assemble_toc(docxml, level)
        toc = ""
        toc += make_WordToC(docxml, level)
        toc += make_table_word_toc(docxml)
        toc += make_figure_word_toc(docxml)
        toc += make_recommendation_word_toc(docxml)
        toc
      end

      def word_toc_entry(toclevel, heading)
        bookmark = bookmarkid # Random.rand(1000000000)
        <<~TOC
          <p class="MsoToc#{toclevel}"><span class="MsoHyperlink"><span lang="EN-GB" style='mso-no-proof:yes'>
          <a href="#_Toc#{bookmark}">#{heading}<span lang="EN-GB" class="MsoTocTextSpan">
          <span style='mso-tab-count:1 dotted'>. </span></span><span lang="EN-GB" class="MsoTocTextSpan">
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
        if source = docxml.at("//div[@class = 'TOC']")
          toc = to_xml(source.children)
        end
        # docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
        xpath = (1..level).each.map { |i| "//h#{i}" }.join (" | ")
        docxml.xpath(xpath).each do |h|
          toc += word_toc_entry(h.name[1].to_i, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_preface(level)}}) + WORD_TOC_SUFFIX1
      end

      # inheriting gems need to add native Word name of style, if different
      # including both CSS style name and human readable style name.
      # Any human readable style name needs to come first for the Word template
      # to work in regenerating the ToC
      def table_toc_class
        %w(TableTitle tabletitle)
      end

      def figure_toc_class
        %w(FigureTitle figuretitle)
      end

      def reqt_toc_class
        %w(RecommendationTitle RecommendationTestTitle
           recommendationtitle recommendationtesttitle)
      end

      def toc_word_class_list(classes)
        classes.map { |x| "#{x},1" }.join(",")
      end

      def word_toc_reqt_preface1
        <<~TOC
          <span lang="EN-GB"><span style='mso-element:field-begin'></span><span
          style='mso-spacerun:yes'>&#xA0;</span>TOC \\h \\z \\t "#{toc_word_class_list reqt_toc_class}"
          <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def word_toc_table_preface1
        <<~TOC
          <span lang="EN-GB"><span style='mso-element:field-begin'></span><span style='mso-spacerun:yes'>&#xA0;</span>TOC
          \\h \\z \\t "#{toc_word_class_list table_toc_class}" <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def word_toc_figure_preface1
        <<~TOC
          <span lang="EN-GB"><span style='mso-element:field-begin'></span><span style='mso-spacerun:yes'>&#xA0;</span>TOC
          \\h \\z \\t "#{toc_word_class_list figure_toc_class}" <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def table_toc_xpath
        attr = table_toc_class.map { |x| "@class = '#{x}'" }
        "//p[#{attr.join(' or ')}]"
      end

      def make_table_word_toc(docxml)
        (docxml.at(table_toc_xpath) && @toctablestitle) or return ""
        toc = %{<p class="TOCTitle">#{@toctablestitle}</p>}
        docxml.xpath(table_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_table_preface1}}) + WORD_TOC_SUFFIX1
      end

      def figure_toc_xpath
        attr = figure_toc_class.map { |x| "@class = '#{x}'" }
        "//p[#{attr.join(' or ')}]"
      end

      def make_figure_word_toc(docxml)
        (docxml.at(figure_toc_xpath) && @tocfigurestitle) or return ""
        toc = %{<p class="TOCTitle">#{@tocfigurestitle}</p>}
        docxml.xpath(figure_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_figure_preface1}}) + WORD_TOC_SUFFIX1
      end

      def reqt_toc_xpath
        attr = reqt_toc_class.map { |x| "@class = '#{x}'" }
        "//p[#{attr.join(' or ')}]"
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
                %{\\1#{word_toc_reqt_preface1}}) + WORD_TOC_SUFFIX1
      end

      def recommmendation_sort_key(header)
        m = /^([^0-9]+) (\d+)/.match(header) || /^([^:]+)/.match(header)
        m ||= [header, nil]
        ret = "#{recommmendation_sort_key1(m[1]&.strip)}::"
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
    end
  end
end
