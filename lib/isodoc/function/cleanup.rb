module IsoDoc::Function
  module Cleanup
    def textcleanup(docxml)
      docxml.
        gsub(/\[TERMREF\]\s*/, l10n("[#{@source_lbl}: ")).
        gsub(/\s*\[MODIFICATION\]\s*\[\/TERMREF\]/, l10n(", #{@modified_lbl} [/TERMREF]")).
        gsub(/\s*\[\/TERMREF\]\s*/, l10n("]")).
        gsub(/\s*\[MODIFICATION\]/, l10n(", #{@modified_lbl} &mdash; "))
    end

    def cleanup(docxml)
      comment_cleanup(docxml)
      footnote_cleanup(docxml)
      inline_header_cleanup(docxml)
      figure_cleanup(docxml)
      table_cleanup(docxml)
      symbols_cleanup(docxml)
      example_cleanup(docxml)
      admonition_cleanup(docxml)
    end

    def admonition_cleanup(docxml)
      docxml.xpath("//div[@class = 'Admonition'][title]").each do |d|
        title = d.at("./title")
        n = title.next_element
        n&.children&.first&.add_previous_sibling(title.remove.text + "&mdash;")
      end
      docxml
    end

    def example_cleanup(docxml)
      docxml.xpath("//table[@class = 'example']//p[not(@class)]").each do |p|
        p["class"] = "example"
      end
      docxml
    end

    def figure_get_or_make_dl(t)
      dl = t.at(".//dl")
      if dl.nil?
        t.add_child("<p><b>#{@key_lbl}</b></p><dl></dl>")
        dl = t.at(".//dl")
      end
      dl
    end

    FIGURE_WITH_FOOTNOTES =
      "//div[@class = 'figure'][descendant::aside]"\
      "[not(descendant::div[@class = 'figure'])]".freeze

    def figure_aside_process(f, aside, key)
      # get rid of footnote link, it is in diagram
      f&.at("./a[@class='TableFootnoteRef']")&.remove
      fnref = f.at(".//span[@class='TableFootnoteRef']/..")
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
      docxml.xpath('//a[@epub:type = "footnote"]/sup').each_with_index do |x, i|
        x.content = (i + 1).to_s
      end
      docxml
    end

    def merge_fnref_into_fn_text(a)
      fn = a.at('.//span[@class="TableFootnoteRef"]/..')
      n = fn.next_element
      n&.children&.first&.add_previous_sibling(fn.remove)
    end

    def table_footnote_cleanup(docxml)
      docxml.xpath("//table[descendant::aside]").each do |t|
        t.xpath(".//aside").each do |a|
          merge_fnref_into_fn_text(a)
          a.name = "div"
          a["class"] = "TableFootnote"
          t << a.remove
        end
      end
      # preempt html2doc putting MsoNormal there
      docxml.xpath("//p[not(self::*[@class])]"\
                   "[ancestor::*[@class = 'TableFootnote']]").each do |p|
        p["class"] = "TableFootnote"
      end
    end

    def remove_bottom_border(td)
      td["style"] =
        td["style"].gsub(/border-bottom:[^;]+;/, "border-bottom:0pt;")
    end

    def table_get_or_make_tfoot(t)
      tfoot = t.at(".//tfoot")
      if tfoot.nil?
        t.add_child("<tfoot></tfoot>")
        tfoot = t.at(".//tfoot")
      else
        tfoot.xpath(".//td | .//th").each { |td| remove_bottom_border(td) }
      end
      tfoot
    end

    def new_fullcolspan_row(t, tfoot)
      # how many columns in the table?
      cols = 0
      t.at(".//tr").xpath("./td | ./th").each do |td|
        cols += (td["colspan"] ? td["colspan"].to_i : 1)
      end
      style = %{border-top:0pt;border-bottom:#{IsoDoc::Function::Table::SW} 1.5pt;}
      tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
      tfoot.xpath(".//td").last
    end

    def table_note_cleanup(docxml)
      docxml.xpath("//table[div[@class = 'Note' or "\
                   "@class = 'TableFootnote']]").each do |t|
        tfoot = table_get_or_make_tfoot(t)
        insert_here = new_fullcolspan_row(t, tfoot)
        t.xpath("div[@class = 'Note' or @class = 'TableFootnote']").each do |d|
          d.parent = insert_here
        end
      end
    end

    def table_cleanup(docxml)
      table_footnote_cleanup(docxml)
      table_note_cleanup(docxml)
      docxml
    end

    # We assume AsciiMath is being used in the terms & definitions.
    # Indices sort after letter but before any following
    # letter (x, x_m, x_1, xa); we use colon to force that sort order.
    # Numbers sort *after* letters; we use thorn to force that sort order.
    def symbol_key(x)
      HTMLEntities.new.decode(x.text).gsub(/_/, ":").gsub(/`/, "").
        gsub(/[0-9]+/, "þ\\1")
    end

    def extract_symbols_list(dl)
      dl_out = []
      dl.xpath("./dt | ./dd").each do |dtd|
        if dtd.name == "dt"
          dl_out << { dt: dtd.remove, key: symbol_key(dtd) }
        else
          dl_out.last[:dd] = dtd.remove
        end
      end
      dl_out
    end

    def symbols_cleanup(docxml)
      dl = docxml.at("//div[@class = 'Symbols']/dl")
      return docxml unless dl
      dl_out = extract_symbols_list(dl)
      dl_out.sort! { |a, b| a[:key] <=> b[:key] }
      dl.children = dl_out.map { |d| d[:dt].to_s + d[:dd].to_s }.join("\n")
      docxml
    end
  end
end
