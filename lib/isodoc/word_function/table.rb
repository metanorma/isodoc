module IsoDoc::WordFunction
  module Body
    def remove_bottom_border(td)
      td["style"] =
        td["style"].gsub(/border-bottom:[^;]+;/, "border-bottom:0pt;")
          .gsub(/mso-border-bottom-alt:[^;]+;/, "mso-border-bottom-alt:0pt;")
    end

    SW1 = "solid windowtext".freeze

    def new_fullcolspan_row(t, tfoot)
      # how many columns in the table?
      cols = 0
      t.at(".//tr").xpath("./td | ./th").each do |td|
        cols += (td["colspan"] ? td["colspan"].to_i : 1)
      end
      style = "border-top:0pt;mso-border-top-alt:0pt;"\
              "border-bottom:#{SW1} 1.5pt;mso-border-bottom-alt:#{SW1} 1.5pt;"
      tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
      tfoot.xpath(".//td").last
    end

    def make_tr_attr(td, row, totalrows, _header)
      style = td.name == "th" ? "font-weight:bold;" : ""
      rowmax = td["rowspan"] ? row + td["rowspan"].to_i - 1 : row
      style += <<~STYLE
        border-top:#{row.zero? ? "#{SW1} 1.5pt;" : 'none;'}
        mso-border-top-alt:#{row.zero? ? "#{SW1} 1.5pt;" : 'none;'}
        border-bottom:#{SW1} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
        mso-border-bottom-alt:#{SW1} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
      STYLE
      { rowspan: td["rowspan"], colspan: td["colspan"], valign: td["valign"],
        align: td["align"], style: style.gsub(/\n/, "") }
    end

    def table_attrs(node)
      super.merge(attr_code(
                    {
                      summary: node["summary"],
                      width: node["width"],
                      style: "mso-table-anchor-horizontal:column;"\
                             "mso-table-overlap:never;border-spacing:0;border-width:1px;#{keep_style(node)}",
                      class: (node.text.length > 4000 ? "MsoISOTableBig" : "MsoISOTable"),
                    },
                  ))
    end

    def colgroup(node, t)
      colgroup = node.at(ns("./colgroup")) or return
      t.colgroup do |cg|
        colgroup.xpath(ns("./col")).each do |c|
          cg.col **{ width: c["width"] }
        end
      end
    end

    def table_parse(node, out)
      @in_table = true
      table_title_parse(node, out)
      out.div **{ align: "center", class: "table_container" } do |div|
        div.table **table_attrs(node) do |t|
          colgroup(node, t)
          thead_parse(node, t)
          tbody_parse(node, t)
          tfoot_parse(node, t)
          (dl = node.at(ns("./dl"))) && parse(dl, out)
          node.xpath(ns("./note")).each { |n| parse(n, out) }
        end
      end
      @in_table = false
    end
  end
end
