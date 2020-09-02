module IsoDoc::Function
  module Table

    def table_title_parse(node, out)
      name = node.at(ns("./name")) or return
      out.p **{ class: "TableTitle", style: "text-align:center;" } do |p|
        name and name.children.each { |n| parse(n, p) }
      end
    end

    def thead_parse(node, t)
      thead = node.at(ns("./thead"))
      if thead
        t.thead do |h|
          thead.element_children.each_with_index do |n, i|
            tr_parse(n, h, i, thead.element_children.size, true)
          end
        end
      end
    end

    def tbody_parse(node, t)
      tbody = node.at(ns("./tbody")) || return
      t.tbody do |h|
        tbody.element_children.each_with_index do |n, i|
          tr_parse(n, h, i, tbody.element_children.size, false)
        end
      end
    end

    def tfoot_parse(node, t)
      tfoot = node.at(ns("./tfoot"))
      if tfoot
        t.tfoot do |h|
          tfoot.element_children.each_with_index do |n, i|
            tr_parse(n, h, i, tfoot.element_children.size, false)
          end
        end
      end
    end

    def table_attrs(node)
      width = node["width"] ? "width:#{node['width']};" : nil
      attr_code(
        id: node["id"],
        class: "MsoISOTable",
        style: "border-width:1px;border-spacing:0;#{width}#{keep_style(node)}",
        title: node["alt"]
      )
    end

    def tcaption(node, t)
      return unless node["summary"]
      t.caption do |c|
        c.span **{ style: "display:none" } do |s|
          s << node["summary"]
        end
      end
    end

    def table_parse(node, out)
      @in_table = true
      table_title_parse(node, out)
      out.table **table_attrs(node) do |t|
        tcaption(node, t)
        thead_parse(node, t)
        tbody_parse(node, t)
        tfoot_parse(node, t)
        (dl = node.at(ns("./dl"))) && parse(dl, out)
        node.xpath(ns("./note")).each { |n| parse(n, out) }
      end
      @in_table = false
      # out.p { |p| p << "&nbsp;" }
    end

    SW = "solid windowtext".freeze

    # def make_tr_attr(td, row, totalrows, cols, totalcols, header)
    # border-left:#{col.zero? ? "#{SW} 1.5pt;" : "none;"}
    # border-right:#{SW} #{col == totalcols && !header ? "1.5" : "1.0"}pt;

    def make_tr_attr(td, row, totalrows, header)
      style = td.name == "th" ? "font-weight:bold;" : ""
      td["align"] and style += "text-align:#{td['align']};"
      td["valign"] and style += "vertical-align:#{td['valign']};"
      rowmax = td["rowspan"] ? row + td["rowspan"].to_i - 1 : row
      style += <<~STYLE
        border-top:#{row.zero? ? "#{SW} 1.5pt;" : 'none;'}
        border-bottom:#{SW} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
      STYLE
      header and scope = (td["colspan"] ? "colgroup" : "col")
      !header and td.name == "th" and scope =
        (td["rowspan"] ? "rowgroup" : "row")
      { rowspan: td["rowspan"], colspan: td["colspan"],
        style: style.gsub(/\n/, ""), scope: scope }
    end

    def tr_parse(node, out, ord, totalrows, header)
      out.tr do |r|
        node.elements.each do |td|
          attrs = make_tr_attr(td, ord, totalrows - 1, header)
          r.send td.name, **attr_code(attrs) do |entry|
            td.children.each { |n| parse(n, entry) }
          end
        end
      end
    end
  end
end
