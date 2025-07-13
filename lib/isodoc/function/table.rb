module IsoDoc
  module Function
    module Table
      def table_title_parse(node, out)
        name = node.at(ns("./fmt-name")) or return
        out.p class: "TableTitle", style: "text-align:center;" do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def thead_parse(node, table)
        thead = node.at(ns("./thead"))
        if thead
          table.thead do |h|
            thead.element_children.each_with_index do |n, i|
              tr_parse(n, h, i, thead.xpath(ns("./tr")).size, true)
            end
          end
        end
      end

      def tbody_parse(node, table)
        tbody = node.at(ns("./tbody")) or return
        rowcount = tbody.xpath(ns("./tr")).size
        table.tbody do |h|
          tbody.element_children.each_with_index do |n, i|
            tr_parse(n, h, i, rowcount, false)
          end
        end
      end

      def tfoot_parse(node, table)
        tfoot = node.at(ns("./tfoot"))
        if tfoot
          table.tfoot do |h|
            tfoot.element_children.each_with_index do |n, i|
              tr_parse(n, h, i, tfoot.xpath(ns("./tr")).size, false)
            end
          end
        end
      end

      def bordered_table_style(node, klass)
        bordered = "border-width:1px;border-spacing:0;"
        (node["plain"] != "true" && (%w(modspec).include?(klass) || !klass)) or
          bordered = ""
        bordered
      end

      def table_attrs(node)
        c = node["class"]
        style = table_attrs_style(node, c)
        attr_code(id: node["id"],
                  class: node["plain"] == "true" ? nil : (c || "MsoISOTable"),
                  style: style, title: node["alt"])
      end

      def table_attrs_style(node, klass)
        width = node["width"] ? "width:#{node['width']};" : nil
        bordered = bordered_table_style(node, klass)
        style = node["style"] ? "" : "#{bordered}#{width}"
        style += keep_style(node) || ""
        style.empty? and style = nil
        style
      end

      def tcaption(node, table)
        node["summary"] or return
        table.caption do |c|
          c.span style: "display:none" do |s|
            s << node["summary"]
          end
        end
      end

      def colgroup(node, table)
        colgroup = node.at(ns("./colgroup")) or return
        table.colgroup do |cg|
          colgroup.xpath(ns("./col")).each do |c|
            cg.col style: "width: #{c['width']};"
          end
        end
      end

      def table_parse(node, out)
        @in_table = true
        table_title_parse(node, out)
        out.table **table_attrs(node) do |t|
          table_parse_core(node, t)
          table_parse_tail(node, t)
        end
        @in_table = false
      end

      def table_parse_tail(node, out)
        (dl = node.at(ns("./dl"))) && parse(dl, out)
        node.xpath(ns("./fmt-source")).each { |n| parse(n, out) }
        node.xpath(ns("./note")).each { |n| parse(n, out) }
        node.xpath(ns("./fmt-footnote-container/fmt-fn-body"))
          .each { |n| parse(n, out) }
      end

      def table_parse_core(node, out)
        tcaption(node, out)
        colgroup(node, out)
        thead_parse(node, out)
        tbody_parse(node, out)
        tfoot_parse(node, out)
      end

      SW = "solid windowtext".freeze

      # def make_tr_attr(td, row, totalrows, cols, totalcols, header)
      # border-left:#{col.zero? ? "#{SW} 1.5pt;" : "none;"}
      # border-right:#{SW} #{col == totalcols && !header ? "1.5" : "1.0"}pt;

      def make_tr_attr(cell, row, totalrows, header, bordered)
        style = cell.name == "th" ? "font-weight:bold;" : ""
        cell["style"] and style += "#{cell['style']};"
        cell["align"] and style += "text-align:#{cell['align']};"
        cell["valign"] and style += "vertical-align:#{cell['valign']};"
        rowmax = cell["rowspan"] ? row + cell["rowspan"].to_i - 1 : row
        style += make_tr_attr_style(row, rowmax, totalrows, header, bordered)
        header and scope = (cell["colspan"] ? "colgroup" : "col")
        !header && cell.name == "th" and
          scope = (cell["rowspan"] ? "rowgroup" : "row")
        { rowspan: cell["rowspan"], colspan: cell["colspan"],
          style: style.delete("\n"), scope: scope, class: cell["class"] }
      end

      def make_tr_attr_style(row, rowmax, totalrows, _header, bordered)
        bordered or return ""
        <<~STYLE.delete("\n")
          border-top:#{row.zero? ? "#{SW} 1.5pt;" : 'none;'}
          border-bottom:#{SW} #{rowmax >= totalrows ? '1.5' : '1.0'}pt;
        STYLE
      end

      def table_bordered?(node)
        node.parent.parent["plain"] == "true" and return false
        c = node.parent.parent["class"]
        %w(modspec).include?(c) || !c
      end

      def tr_parse(node, out, ord, totalrows, header)
        bordered = table_bordered?(node)
        out.tr **attr_code(style: node["style"]) do |r|
          node.elements.each do |td|
            attrs = make_tr_attr(td, ord, totalrows - 1, header, bordered)
            r.send td.name, **attr_code(attrs) do |entry|
              td.children.each { |n| parse(n, entry) }
            end
          end
        end
      end
    end
  end
end
