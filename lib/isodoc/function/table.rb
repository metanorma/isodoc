module IsoDoc::Function
  module Table

    def table_title_parse(node, out)
      name = node.at(ns("./name"))
      out.p **{ class: "TableTitle", align: "center" } do |p|
        p << l10n("#{@table_lbl} #{get_anchors[node['id']][:label]}")
        p << l10n("&nbsp;&mdash; #{name.text}") if name
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
      tbody = node.at(ns("./tbody"))
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

    def make_table_attr(node)
      {
        id: node["id"],
        class: "MsoISOTable",
        border: 1,
        cellspacing: 0,
        cellpadding: 0,
      }
    end

    def table_parse(node, out)
      @in_table = true
      table_title_parse(node, out)
      out.table **make_table_attr(node) do |t|
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

    def make_tr_attr(td, row, totalrows)
      style = td.name == "th" ? "font-weight:bold;" : ""
      rowmax = td["rowspan"] ? row + td["rowspan"].to_i - 1 : row
      style += <<~STYLE
        border-top:#{row.zero? ? "#{SW} 1.5pt;" : 'none;'}
        border-bottom:#{SW} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
      STYLE
      { rowspan: td["rowspan"], colspan: td["colspan"],
        align: td["align"], style: style.gsub(/\n/, "") }
    end

    def tr_parse(node, out, ord, totalrows, _header)
      out.tr do |r|
        node.elements.each do |td|
          attrs = make_tr_attr(td, ord, totalrows - 1)
          # i, node.elements.size - 1, header)
          r.send td.name, **attr_code(attrs) do |entry|
            td.children.each { |n| parse(n, entry) }
          end
        end
      end
    end
  end
end
