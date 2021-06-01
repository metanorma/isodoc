module IsoDoc::HtmlFunction
  module Html
    def update_footnote_filter(fn, x, i, seen)
      if seen[fn.text]
        x.at("./sup").content = seen[fn.text][:num].to_s
        fn.remove unless x["href"] == seen[fn.text][:href]
        x["href"] = seen[fn.text][:href]
      else
        seen[fn.text] = { num: i, href: x["href"] }
        x.at("./sup").content = i.to_s
        i += 1
      end
      [i, seen]
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

    def footnote_backlinks1(x, fn)
      xdup = x.dup
      xdup.remove["id"]
      if fn.elements.empty?
        fn.children.first.previous = xdup
      else
        fn.elements.first.children.first.previous = xdup
      end
    end

    def footnote_backlinks(docxml)
      seen = {}
      docxml.xpath('//a[@class = "FootnoteRef"]').each_with_index do |x, i|
        seen[x["href"]] and next or seen[x["href"]] = true
        fn = docxml.at(%<//*[@id = '#{x['href'].sub(/^#/, '')}']>) || next
        footnote_backlinks1(x, fn)
        x["id"] ||= "fnref:#{i + 1}"
        fn.add_child "<a href='##{x['id']}'>&#x21A9;</a>"
      end
      docxml
    end

    def footnote_format(docxml)
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
