module IsoDoc
  module HtmlFunction
    module Html
      def html_footnote(html)
        footnote_delimit(footnote_backlinks(html))
      end

      def footnote_delimit(docxml)
        k = %w(FootnoteRef TableFootnoteRef)
        docxml.xpath("//a").each do |a|
          k.include?(a["class"]) or next
          a1 = a.next_element or next
          k.include?(a1["class"]) or next
          sup = a.at("./sup") and a = sup
          a << ", "
        end
        docxml
      end

      def footnote_backlinks1(xref, footnote)
        xdup = xref.dup
        xdup.remove["id"]
        if footnote.elements.empty?
          footnote.add_first_child xdup
        else
          footnote.elements.first.add_first_child xdup
        end
      end

      def footnote_backlinks(docxml)
        seen = {}
        docxml.xpath('//a[@class = "FootnoteRef"]').each_with_index do |x, i|
          fn = footnote_backlink?(x, docxml, seen) or next
          seen[x["href"]] = true
          footnote_backlinks1(x, fn)
          x["id"] ||= "fnref:#{i + 1}"
          fn.add_child "<a href='##{x['id']}'>&#x21A9;</a>"
        end
        docxml
      end

      def footnote_backlink?(elem, docxml, seen)
        seen[elem["href"]] and return
        docxml.at(%<//*[@id = '#{elem['href'].sub(/^#/, '')}']>)
      end
    end
  end
end
