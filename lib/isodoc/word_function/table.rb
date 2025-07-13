module IsoDoc
  module WordFunction
    module Body
      def remove_bottom_border(cell)
        cell["style"] =
          cell["style"].gsub(/border-bottom:[^;]+;/, "border-bottom:0pt;")
            .gsub(/mso-border-bottom-alt:[^;]+;/, "mso-border-bottom-alt:0pt;")
      end

      SW1 = "solid windowtext".freeze

      def new_fullcolspan_row(table, tfoot)
        # how many columns in the table?
        cols = 0
        table.at(".//tr").xpath("./td | ./th").each do |td|
          cols += (td["colspan"] ? td["colspan"].to_i : 1)
        end
        table["plain"] == "true" or
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
        opt[:bordered] && !cell["style"] or ret = ""
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
        c = node["class"]
        style = node["style"] || node["plain"] == "true" ? "" : "border-spacing:0;border-width:1px;"
        (%w(modspec).include?(c) || !c) or style = nil
        ret =
          { summary: node["summary"], width: node["width"],
            style: "mso-table-anchor-horizontal:column;mso-table-overlap:never;" \
                 "#{style}#{keep_style(node)}",
            class: (node.text.length > 4000 ? "MsoISOTableBig" : "MsoISOTable") }
        style or ret.delete(:class)
        super.merge(attr_code(ret))
      end

      def colgroup(node, table)
        colgroup = node.at(ns("./colgroup")) or return
        table.colgroup do |cg|
          colgroup.xpath(ns("./col")).each do |c|
            cg.col width: c["width"]
          end
        end
      end

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        out.div align: "center", class: "table_container" do |div|
          div.table **table_attrs(node) do |t|
            table_parse_core(node, t)
            table_parse_tail(node, t)
          end
        end
        @in_table = false
      end

      def table_parse_core(node, out)
        colgroup(node, out)
        thead_parse(node, out)
        tbody_parse(node, out)
        tfoot_parse(node, out)
      end
    end
  end
end
