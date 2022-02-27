require_relative "./table"
require_relative "./inline"

module IsoDoc
  module WordFunction
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
        body.div **{ class: "WordSection1" } do |div1|
          div1.p { |p| p << "&nbsp;" } # placeholder
        end
        section_break(body)
      end

      def make_body2(body, docxml)
        body.div **{ class: "WordSection2" } do |div2|
          boilerplate docxml, div2
          preface_block docxml, div2
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

      def insert_tab(out, count)
        out.span **attr_code(style: "mso-tab-count:#{count}") do |span|
          [1..count].each { span << "&#xA0; " }
        end
      end

      def para_class(_node)
        return "Sourcecode" if @annotation
        return "MsoCommentText" if @in_comment
        return "Note" if @note

        nil
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

      WORD_DT_ATTRS = { class: @note ? "Note" : nil, align: "left",
                        style: "margin-left:0pt;text-align:left;" }.freeze

      def dt_parse(dterm, term)
        term.p **attr_code(WORD_DT_ATTRS) do |p|
          if dterm.elements.empty?
            p << dterm.text
          else
            dterm.children.each { |n| parse(n, p) }
          end
        end
      end

      def dl_parse(node, out)
        return super unless node.ancestors("table, dl").empty?

        dl_parse_table(node, out)
      end

      def dl_parse_table(node, out)
        out.table **{ class: "dl" } do |v|
          node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
            dl_parse_table1(v, dt, dd)
          end
          dl_parse_notes(node, v)
        end
      end

      def dl_parse_table1(table, dterm, ddefn)
        table.tr do |tr|
          tr.td **{ valign: "top", align: "left" } do |term|
            dt_parse(dterm, term)
          end
          tr.td **{ valign: "top" } do |listitem|
            ddefn.children.each { |n| parse(n, listitem) }
          end
        end
      end

      def dl_parse_notes(node, out)
        return if node.elements.reject { |n| dt_dd? n }.empty?

        out.tr do |tr|
          tr.td **{ colspan: 2 } do |td|
            node.elements.reject { |n| dt_dd? n }.each { |n| parse(n, td) }
          end
        end
      end

      def figure_get_or_make_dl(node)
        dl = node.at(".//table[@class = 'dl']")
        if dl.nil?
          node.add_child("<p><b>#{@i18n.key}</b></p><table class='dl'></table>")
          dl = node.at(".//table[@class = 'dl']")
        end
        dl
      end

      # get rid of footnote link, it is in diagram
      def figure_aside_process(fig, aside, key)
        fig&.at("./a[@class='TableFootnoteRef']")&.remove
        fnref = fig.at(".//span[@class='TableFootnoteRef']/..")
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
        name = node&.at(ns("./name"))&.remove
        div.p **{ class: "Note" } do |p|
          p.span **{ class: "note_label" } do |s|
            name&.children&.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        name = node&.at(ns("./name"))&.remove
        div.p **{ class: "Note" } do |p|
          p.span **{ class: "note_label" } do |s|
            name&.children&.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) }
      end

      def termnote_parse(node, out)
        name = node&.at(ns("./name"))&.remove
        out.div **note_attrs(node) do |div|
          div.p **{ class: "Note" } do |p|
            if name
              name.children.each { |n| parse(n, p) }
              p << l10n(": ")
            end
            para_then_remainder(node.first_element_child, node, p, div)
          end
        end
      end

      def para_attrs(node)
        attrs = { class: para_class(node), id: node["id"], style: "" }
        unless node["align"].nil?
          attrs[:align] = node["align"] unless node["align"] == "justify"
          attrs[:style] += "text-align:#{node['align']};"
        end
        attrs[:style] += keep_style(node).to_s
        attrs[:style] = nil if attrs[:style].empty?
        attrs
      end

      def example_table_attr(node)
        super.merge(
          style: "mso-table-lspace:15.0cm;margin-left:423.0pt;"\
                 "mso-table-rspace:15.0cm;margin-right:423.0pt;"\
                 "mso-table-anchor-horizontal:column;"\
                 "mso-table-overlap:never;border-collapse:collapse;"\
                 "#{keep_style(node)}",
        )
      end

      def formula_where(deflist, out)
        return unless deflist

        out.p { |p| p << @i18n.where }
        parse(deflist, out)
        out.parent.at("./table")["class"] = "formula_dl"
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p do |_p|
            parse(node.at(ns("./stem")), div)
            insert_tab(div, 1)
            if lbl = node&.at(ns("./name"))&.text
              div << "(#{lbl})"
            end
          end
        end
      end

      def li_parse(node, out)
        out.li **attr_code(id: node["id"]) do |li|
          if node["uncheckedcheckbox"] == "true"
            li << '<span class="zzMoveToFollowing">&#x2610; </span>'
          elsif node["checkedcheckbox"] == "true"
            li << '<span class="zzMoveToFollowing">&#x2611; </span>'
          end
          node.children.each { |n| parse(n, li) }
        end
      end

      def suffix_url(url)
        return url if %r{^https?://}.match?(url)
        return url unless File.extname(url).empty?

        url.sub(/#{File.extname(url)}$/, ".doc")
      end

      def info(isoxml, out)
        @tocfigurestitle =
          isoxml&.at(ns("//misc-container/toc[@type = 'figure']/title"))&.text
        @toctablestitle =
          isoxml&.at(ns("//misc-container/toc[@type = 'table']/title"))&.text
        @tocrecommendationstitle = isoxml
          &.at(ns("//misc-container/toc[@type = 'recommendation']/title"))&.text
        super
      end
    end
  end
end
