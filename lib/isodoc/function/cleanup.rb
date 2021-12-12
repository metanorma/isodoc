module IsoDoc
  module Function
    module Cleanup
      def textcleanup(docxml)
        passthrough_cleanup(docxml)
      end

      def termref_cleanup(docxml)
        docxml
          .gsub(/\s*\[MODIFICATION\]\s*\[\/TERMREF\]/,
                l10n(", #{@i18n.modified} [/TERMREF]"))
          .gsub(%r{\s*\[/TERMREF\]\s*</p>\s*<p>\s*\[TERMREF\]}, "; ")
          .gsub(/\[TERMREF\]\s*/, l10n("[#{@i18n.source}: "))
          .gsub(%r{\s*\[/TERMREF\]\s*}, l10n("]"))
          .gsub(/\s*\[MODIFICATION\]/, l10n(", #{@i18n.modified} &mdash; "))
      end

      def passthrough_cleanup(docxml)
        docxml.split(%r{(<passthrough>|</passthrough>)}).each_slice(4)
          .map do |a|
          a.size > 2 and a[2] = HTMLEntities.new.decode(a[2])
          [a[0], a[2]]
        end.join
      end

      def cleanup(docxml)
        @i18n ||= i18n_init(@lang, @script)
        comment_cleanup(docxml)
        footnote_cleanup(docxml)
        inline_header_cleanup(docxml)
        figure_cleanup(docxml)
        table_cleanup(docxml)
        symbols_cleanup(docxml)
        example_cleanup(docxml)
        admonition_cleanup(docxml)
      end

      def table_long_strings_cleanup(docxml)
        return unless @break_up_urls_in_tables == true

        docxml.xpath("//td | //th").each do |d|
          d.traverse do |n|
            next unless n.text?

            n.replace(HTMLEntities.new.encode(
                        break_up_long_strings(n.text),
                      ))
          end
        end
      end

      def break_up_long_strings(text)
        return text if /^\s*$/.match?(text)

        text.split(/(?=\s)/).map do |w|
          if /^\s*$/.match(text) || (w.size < 30) then w
          else
            w.scan(/.{,30}/).map do |w1|
              w1.size < 30 ? w1 : break_up_long_strings1(w1)
            end.join
          end
        end.join
      end

      def break_up_long_strings1(text)
        s = text.split(%r{(?<=[,.?+;/=])})
        if s.size == 1 then "#{text} "
        else
          s[-1] = " #{s[-1]}"
          s.join
        end
      end

      def admonition_cleanup(docxml)
        docxml.xpath("//div[@class = 'Admonition'][title]").each do |d|
          title = d.at("./title")
          n = title.next_element
          n&.children&.first
            &.add_previous_sibling("#{title.remove.text}&mdash;")
        end
        docxml
      end

      def example_cleanup(docxml)
        docxml.xpath("//table[@class = 'example']//p[not(@class)]").each do |p|
          p["class"] = "example"
        end
        docxml
      end

      def figure_get_or_make_dl(elem)
        dl = elem.at(".//dl")
        if dl.nil?
          elem.add_child("<p><b>#{@i18n.key}</b></p><dl></dl>")
          dl = elem.at(".//dl")
        end
        dl
      end

      FIGURE_WITH_FOOTNOTES =
        "//div[@class = 'figure'][descendant::aside]"\
        "[not(descendant::div[@class = 'figure'])]".freeze

      def figure_aside_process(elem, aside, key)
        # get rid of footnote link, it is in diagram
        elem&.at("./a[@class='TableFootnoteRef']")&.remove
        fnref = elem.at(".//span[@class='TableFootnoteRef']/..")
        dt = key.add_child("<dt></dt>").first
        dd = key.add_child("<dd></dd>").first
        fnref.parent = dt
        aside.xpath(".//p").each do |a|
          a.delete("class")
          a.parent = dd
        end
      end

      # move footnotes into key, and get rid of footnote reference
      # since it is in diagram
      def figure_cleanup(docxml)
        docxml.xpath(FIGURE_WITH_FOOTNOTES).each do |f|
          next unless f.at(".//aside[not(ancestor::p[@class = 'FigureTitle'])]")

          key = figure_get_or_make_dl(f)
          f.xpath(".//aside").each do |aside|
            figure_aside_process(f, aside, key)
          end
        end
        docxml
      end

      def inline_header_cleanup(docxml)
        docxml.xpath('//span[@class="zzMoveToFollowing"]').each do |x|
          x.delete("class")
          n = x.next_element
          if n.nil?
            x.name = "p"
          else
            n.children.first.previous = x.remove
          end
        end
        docxml
      end

      def footnote_cleanup(docxml)
        docxml.xpath('//a[@class = "FootnoteRef"]/sup')
          .each_with_index do |x, i|
          x.content = (i + 1).to_s
        end
        docxml
      end

      def merge_fnref_into_fn_text(elem)
        fn = elem.at('.//span[@class="TableFootnoteRef"]/..')
        n = fn.next_element
        n&.children&.first&.add_previous_sibling(fn.remove)
      end

      # preempt html2doc putting MsoNormal under TableFootnote class
      def table_footnote_cleanup(docxml)
        docxml.xpath("//table[descendant::aside]").each do |t|
          t.xpath(".//aside").each do |a|
            merge_fnref_into_fn_text(a)
            a.name = "div"
            a["class"] = "TableFootnote"
            t << a.remove
          end
        end
        table_footnote_cleanup_propagate(docxml)
      end

      def table_footnote_cleanup_propagate(docxml)
        docxml.xpath("//p[not(self::*[@class])]"\
                     "[ancestor::*[@class = 'TableFootnote']]").each do |p|
          p["class"] = "TableFootnote"
        end
      end

      def remove_bottom_border(cell)
        cell["style"] =
          cell["style"].gsub(/border-bottom:[^;]+;/, "border-bottom:0pt;")
      end

      def table_get_or_make_tfoot(table)
        tfoot = table.at(".//tfoot")
        if tfoot.nil?
          table.add_child("<tfoot></tfoot>")
          tfoot = table.at(".//tfoot")
        else
          tfoot.xpath(".//td | .//th").each { |td| remove_bottom_border(td) }
        end
        tfoot
      end

      def new_fullcolspan_row(table, tfoot)
        # how many columns in the table?
        cols = 0
        table.at(".//tr").xpath("./td | ./th").each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        style =
          %{border-top:0pt;border-bottom:#{IsoDoc::Function::Table::SW} 1.5pt;}
        tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
        tfoot.xpath(".//td").last
      end

      def table_note_cleanup(docxml)
        docxml.xpath("//table[div[@class = 'Note' or "\
                     "@class = 'TableFootnote']]").each do |t|
          tfoot = table_get_or_make_tfoot(t)
          insert_here = new_fullcolspan_row(t, tfoot)
          t.xpath("div[@class = 'Note' or @class = 'TableFootnote']")
            .each do |d|
            d.parent = insert_here
          end
        end
      end

      def table_cleanup(docxml)
        table_footnote_cleanup(docxml)
        table_note_cleanup(docxml)
        table_long_strings_cleanup(docxml)
        docxml
      end

      def symbols_cleanup(docxml); end

      def table_footnote_reference_format(link)
        link
      end

      def footnote_reference_format(link)
        link
      end
    end
  end
end
