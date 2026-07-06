module IsoDoc
  module WordFunction
    module Body
      def remove_bottom_border(cell)
        # [^;]* (not +): the preceding property name is the unambiguous
        # delimiter, so zero-or-more is equivalent and avoids polynomial
        # backtracking on the value portion.
        cell["style"] =
          cell["style"].gsub(/border-bottom:[^;]*;/, "border-bottom:0pt;")
            .gsub(/mso-border-bottom-alt:[^;]*;/, "mso-border-bottom-alt:0pt;")
      end

      SW1 = "solid windowtext".freeze

      def new_fullcolspan_row(table, tfoot)
        # how many columns in the table?
        cols = 0
        table.at(".//tr").xpath("./td | ./th").each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        table["plain"] == "true" || table["class"] == "dl" or
          s = "style='border-top:0pt;mso-border-top-alt:0pt;" \
              "border-bottom:#{SW1} 1.5pt;mso-border-bottom-alt:#{SW1} 1.5pt;'"
        tfoot.add_child("<tr><td colspan='#{cols}' #{s}/></tr>")
        tfoot.xpath(".//td").last
      end

      def make_tr_attr(cell, row, totalrows, header, bordered)
        style = cell.name == "th" ? "font-weight:bold;" : ""
        cell["style"] and style += "#{cell['style']};"
        rowmax = cell["rowspan"] ? row + cell["rowspan"].to_i - 1 : row
        style += make_tr_attr_style(cell, row, rowmax, totalrows,
                                    { header: header, bordered: bordered })
        { rowspan: cell["rowspan"], colspan: cell["colspan"],
          valign: cell["valign"], align: cell["align"], style: style,
          class: cell["class"] }
      end

      def make_tr_attr_style(cell, row, rowmax, totalrows, opt)
        top = row.zero? ? "#{SW1} 1.5pt;" : "none;"
        bottom = "#{SW1} #{rowmax >= totalrows ? '1.5' : '1.0'}pt;"
        ret = <<~STYLE.delete("\n")
          border-top:#{top}mso-border-top-alt:#{top}
          border-bottom:#{bottom}mso-border-bottom-alt:#{bottom}
        STYLE
        (opt[:bordered] && !cell["style"]) or ret = ""
        pb = keep_rows_together(cell, rowmax, totalrows, opt) ? "avoid" : "auto"
        "#{ret}page-break-after:#{pb};"
      end

      def keep_rows_together(_cell, rowmax, totalrows, opt)
        opt[:header] and return true
        @table_line_count > 15 and return false
        totalrows <= 10 && rowmax < totalrows
      end

      def tbody_parse(node, table)
        tbody = node.at(ns("./tbody")) or return
        @table_line_count = table_line_count(tbody)
        super
      end

      def table_line_count(tbody)
        sum = 0
        tbody.xpath(ns(".//tr")).size > 15 and return 16 # short-circuit
        tbody.xpath(ns(".//tr")).each do |r|
          i = 1
          r.xpath(ns(".//td | .//th")).each do |c|
            n = c.xpath(ns(".//li | .//p | .//br")).size
            n > i and i = n
          end
          sum += i
        end
        sum
      end

      def table_attrs(node)
        style = table_border_css(node)
        ret = { summary: node["summary"], width: node["width"],
                class: table_class(node),
                style: "mso-table-anchor-horizontal:column;" \
                       "mso-table-overlap:never;#{style}#{keep_style(node)}" }
        style or ret.delete(:class)
        super.merge(attr_code(ret))
      end

      # %plain or an explicit @style still suppresses the default border; a
      # custom @class no longer nulls it. The class is HTML-only and is not
      # emitted to Word output (Word CSS is too inflexible), but a custom-class
      # table must still render as a normal bordered ISO table.
      # Exception: the internal `rouge-line-table` (sourcecode line numbering)
      # takes no ISO border and keeps its own class -- returning nil drops the
      # Word MsoISOTable override (see table_attrs) so the HTML super class
      # survives. metanorma/metanorma-pdfa#33
      def table_border_css(node)
        style = "border-spacing:0;border-width:1px;"
        node["style"] || node["plain"] == "true" ||
          node["class"] == "dl" and style = ""
        node["class"] == "rouge-line-table" and style = nil
        style
      end

      # `dl` (definition list rendered as a table) is unbordered like %plain, and
      # takes the plain MsoNormalTable Word style rather than the bordered
      # MsoISOTable.
      def table_class(node)
        node["plain"] == "true" || node["class"] == "dl" and
          return "MsoNormalTable"
        node.text.length > 4000 ? "MsoISOTableBig" : "MsoISOTable"
      end

      def colgroup(node, table)
        colgroup = node.at(ns("./colgroup")) or return
        table.colgroup do |cg|
          colgroup.xpath(ns("./col")).each do |c|
            cg.col width: c["width"]
          end
        end
      end

      def table_title_parse(node, out)
        name = node.at(ns("./fmt-name")) or return
        out.p class: "TableTitle", style: "text-align:center;" do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        out.div align: "center", class: "table_container" do |div|
          div.table(**table_attrs(node)) do |t|
            table_parse_core(node, t)
            table_parse_tail(node, t)
          end
        end
        @in_table = false
      end
    end
  end
end
