require_relative "./table.rb"

module IsoDoc::WordFunction
  module Body
    def define_head(head, filename, _dir)
      head.style do |style|
        loc = File.join(File.dirname(__FILE__), "..", "base_style",
                        "metanorma_word.scss")
        stylesheet = File.read(loc, encoding: "utf-8")
        style.comment "\n#{stylesheet}\n"
      end
      super
    end

    def body_attr
      { lang: "EN-US", link: "blue", vlink: "#954F72" }
    end

    def make_body1(body, _docxml)
      #FileUtils.rm_rf tmpimagedir
      #FileUtils.mkdir tmpimagedir
      body.div **{ class: "WordSection1" } do |div1|
        div1.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body2(body, docxml)
      body.div **{ class: "WordSection2" } do |div2|
        boilerplate docxml, div2
        abstract docxml, div2
        foreword docxml, div2
        introduction docxml, div2
        preface docxml, div2
        acknowledgements docxml, div2
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body3(body, docxml)
      body.div **{ class: "WordSection3" } do |div3|
        middle docxml, div3
        footnotes div3
        comments div3
      end
    end

    def insert_tab(out, n)
      out.span **attr_code(style: "mso-tab-count:#{n}") do |span|
        [1..n].each { span << "&#xA0; " }
      end
    end

    def para_class(_node)
      classtype = nil
      classtype = "Note" if @note
      classtype = "MsoCommentText" if in_comment
      classtype = "Sourcecode" if @annotation
      classtype
    end

    def para_parse(node, out)
      out.p **attr_code(para_attrs(node)) do |p|
        unless @termdomain.empty?
          p << "&lt;#{@termdomain}&gt; "
          @termdomain = ""
        end
        node.children.each { |n| parse(n, p) unless n.name == "note" }
      end
      node.xpath(ns("./note")).each { |n| parse(n, out) }
    end

    def section_break(body)
      body.p do |p|
        p.br **{ clear: "all", class: "section" }
      end
    end

    def page_break(out)
      out.p do |p|
        p.br **{ clear: "all",
                 style: "mso-special-character:line-break;"\
                 "page-break-before:always" }
      end
    end

    def pagebreak_parse(node, out)
      return page_break(out) if node["orientation"].nil?
      out.p do |p|
        p.br **{clear: "all", class: "section", 
                orientation: node["orientation"] }
      end
    end

    WORD_DT_ATTRS = {class: @note ? "Note" : nil, align: "left",
                     style: "margin-left:0pt;text-align:left;"}.freeze

    def dt_parse(dt, term)
      term.p **attr_code(WORD_DT_ATTRS) do |p|
        if dt.elements.empty?
          p << dt.text
        else
          dt.children.each { |n| parse(n, p) }
        end
      end
    end

    def dl_parse(node, out)
      out.table **{ class: "dl" } do |v|
        node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
          v.tr do |tr|
            tr.td **{ valign: "top", align: "left" } do |term|
              dt_parse(dt, term)
            end
            tr.td **{ valign: "top" } do |listitem|
              dd.children.each { |n| parse(n, listitem) }
            end
          end
        end
        dl_parse_notes(node, v)
      end
    end

    def dl_parse_notes(node, v)
      return if node.elements.reject { |n| dt_dd? n }.empty?
      v.tr do |tr|
        tr.td **{ colspan: 2 } do |td|
          node.elements.reject { |n| dt_dd? n }.each { |n| parse(n, td) }
        end
      end
    end

    def figure_get_or_make_dl(t)
      dl = t.at(".//table[@class = 'dl']")
      if dl.nil?
        t.add_child("<p><b>#{@key_lbl}</b></p><table class='dl'></table>")
        dl = t.at(".//table[@class = 'dl']")
      end
      dl
    end

    def figure_aside_process(f, aside, key)
      # get rid of footnote link, it is in diagram
      f&.at("./a[@class='TableFootnoteRef']")&.remove
      fnref = f.at(".//span[@class='TableFootnoteRef']/..")
      tr = key.add_child("<tr></tr>").first
      dt = tr.add_child("<td valign='top' align='left'></td>").first
      dd = tr.add_child("<td valign='top'></td>").first
      fnref.parent = dt
      aside.xpath(".//p").each do |a|
        a.delete("class")
        a.parent = dd
      end
    end

    def note_p_parse(node, div)
      div.p **{ class: "Note" } do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
        node.first_element_child.children.each { |n| parse(n, p) }
      end
      node.element_children[1..-1].each { |n| parse(n, div) }
    end

    def note_parse1(node, div)
      div.p **{ class: "Note" } do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
      end
      node.children.each { |n| parse(n, div) }
    end

    def termnote_parse(node, out)
      out.div **{ class: "Note" } do |div|
        first = node.first_element_child
        div.p **{ class: "Note" } do |p|
          anchor = get_anchors[node['id']]
          p << "#{anchor&.dig(:label) || '???'}: "
          para_then_remainder(first, node, p, div)
        end
      end
    end

    def para_attrs(node)
      attrs = { class: para_class(node), id: node["id"] }
      unless node["align"].nil?
        attrs[:align] = node["align"] unless node["align"] == "justify"
        attrs[:style] = "text-align:#{node['align']}"
      end
      attrs
    end

    def imgsrc(uri)
      return uri unless %r{^data:image/}.match uri
      save_dataimage(uri)
    end

    def image_parse(node, out, caption)
      attrs = { src: imgsrc(node["src"]),
                height: node["height"],
                alt: node["alt"],
                title: node["title"],
                width: node["width"] }
      if node["height"] == "auto" || node["width"] == "auto"
        attrs[:height] = nil
        attrs[:width] = nil
      end
      out.img **attr_code(attrs)
      image_title_parse(out, caption)
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".doc#") :
        "##{node["target"]}"
        out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end

    def example_table_attr(node)
      super.merge({
        style: "mso-table-lspace:15.0cm;margin-left:423.0pt;"\
        "mso-table-rspace:15.0cm;margin-right:423.0pt;"\
        "mso-table-anchor-horizontal:column;"\
        "mso-table-overlap:never;border-collapse:collapse;"
      })
    end

    def formula_where(dl, out)
      return unless dl
      out.p { |p| p << @where_lbl }
      parse(dl, out)
      out.parent.at("./table")["class"] = "formula_dl"
    end
  end
end
