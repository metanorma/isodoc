module IsoDoc
  module HtmlFunction
    module Html
      def update_footnote_filter(fnote, xref, idx, seen)
        if seen[fnote.text]
          xref.at("./sup").content = seen[fnote.text][:num].to_s
          fnote.remove unless xref["href"] == seen[fnote.text][:href]
          xref["href"] = seen[fnote.text][:href]
        else
          seen[fnote.text] = { num: idx, href: xref["href"] }
          xref.at("./sup").content = idx.to_s
          idx += 1
        end
        [idx, seen]
      end

      def html_footnote_filter(docxml)
        seen = {}
        i = 1
        docxml.xpath('//a[@class = "FootnoteRef"]').each do |x|
          fn = docxml.at(%<//*[@id = '#{x['href'].sub(/^#/, '')}']>) || next
          i, seen = update_footnote_filter(fn, x, i, seen)
        end
        docxml
      end

      def footnote_backlinks1(xref, footnote)
        xdup = xref.dup
        xdup.remove["id"]
        if footnote.elements.empty?
          #footnote.children.empty? and footnote << " "
          #footnote.children.first.previous = xdup
          footnote.add_first_child xdup
        else
          #footnote.elements.first.children.first.previous = xdup
          footnote.elements.first.add_first_child xdup
        end
      end

      def footnote_backlinks(docxml)
        seen = {}
        docxml.xpath('//a[@class = "FootnoteRef"]').each_with_index do |x, i|
          (seen[x["href"]] and next) or seen[x["href"]] = true
          fn = docxml.at(%<//*[@id = '#{x['href'].sub(/^#/, '')}']>) || next
          footnote_backlinks1(x, fn)
          x["id"] ||= "fnref:#{i + 1}"
          fn.add_child "<a href='##{x['id']}'>&#x21A9;</a>"
        end
        docxml
      end

      # KILL
      def footnote_formatx(docxml)
        docxml.xpath("//a[@class = 'FootnoteRef']/sup").each do |x|
          footnote_reference_format(x)
        end
        docxml.xpath("//a[@class = 'TableFootnoteRef'] | "\
                     "//span[@class = 'TableFootnoteRef']").each do |x|
          table_footnote_reference_format(x)
        end
        docxml
      end
    end
  end
end
