module IsoDoc
  module Function
    module Cleanup
      def textcleanup(docxml)
        passthrough_cleanup(docxml)
      end

      def passthrough_cleanup(docxml)
        docxml.split(%r{(<passthrough>|</passthrough>)}).each_slice(4)
          .map do |a|
          a.size > 2 and a[2] = HTMLEntities.new.decode(a[2])
          [a[0], a[2]]
        end.join
      end

      def cleanup(docxml)
        @i18n ||= i18n_init(@lang, @script, @locale)
        comment_cleanup(docxml)
        inline_header_cleanup(docxml)
        figure_cleanup(docxml)
        table_cleanup(docxml)
        symbols_cleanup(docxml)
        example_cleanup(docxml)
        admonition_cleanup(docxml)
      end

      # todo PRESENTATION XML
      def admonition_cleanup(docxml)
        docxml.xpath("//div[@class = 'Admonition'][title]").each do |d|
          title = d.at("./title")
          n = title.next_element
          n&.children&.first
            &.add_previous_sibling("#{title.remove.text}&#x2014;")
        end
        docxml
      end

      def example_cleanup(docxml)
        docxml.xpath("//table[@class = 'example']//p[not(@class)]").each do |p|
          p["class"] = "example"
        end
        docxml
      end

      def figure_cleanup(docxml); end

      def inline_header_cleanup(docxml)
        docxml.xpath('//span[@class="zzMoveToFollowing"]').each do |x|
          x.delete("class")
          n = x.next_element
          if n.nil?
            x.name = "p"
          else
            n.add_first_child(x.remove)
          end
        end
        docxml
      end

      def merge_fnref_into_fn_text(elem)
        fn = elem.at('.//span[@class="TableFootnoteRef"]/..') or return
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
            t << a.remove # this is redundant
          end
        end
        table_footnote_cleanup_propagate(docxml)
      end

      def table_footnote_cleanup_propagate(docxml)
        docxml.xpath("//p[not(self::*[@class])]" \
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
        table["class"].nil? or # = plain table
          s = "style='border-top:0pt;border-bottom:#{IsoDoc::Function::Table::SW} 1.5pt;'"
        tfoot.add_child("<tr><td colspan='#{cols}' #{s}/></tr>")
        tfoot.xpath(".//td").last
      end

      TABLENOTE_CSS = "div[@class = 'Note' or @class = 'BlockSource' " \
        "or @class = 'TableFootnote' or @class = 'figdl']".freeze

      def table_note_cleanup(docxml)
        docxml.xpath("//table[dl or #{TABLENOTE_CSS}]").each do |t|
          tfoot = table_get_or_make_tfoot(t)
          insert_here = new_fullcolspan_row(t, tfoot)
          t.xpath("dl | p[@class = 'ListTitle'] | #{TABLENOTE_CSS}")
            .each do |d|
            d.parent = insert_here
          end
        end
      end

      def table_cleanup(docxml)
        table_footnote_cleanup(docxml)
        table_note_cleanup(docxml)
        docxml
      end

      def symbols_cleanup(docxml); end
    end
  end
end
