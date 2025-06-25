require_relative "./table"
require_relative "./inline"

module IsoDoc
  module WordFunction
    module Body
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
        node.ancestors("table, dl").empty? or
          return dl_parse_nontable(node, out)
        dl_parse_table(node, out)
      end

      def dl_parse_nontable(node, out)
        out.div **attr_code(class: "figdl") do |div|
          node["id"] and bookmark_parse(node, div)
          list_title_parse(node, div)
          node.elements.select { |n| dt_dd?(n) }
            .each_slice(2) do |dt, dd|
            dl_parse_nontable1(div, dt, dd)
          end
          dl_parse_notes(node, div)
        end
      end

      WORD_EMBED_DL_ATTRS =
        "text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;".freeze

      def dl_parse_nontable1(out, dterm, ddef)
        out.p **attr_code(style: WORD_EMBED_DL_ATTRS, id: dterm["id"]) do |p|
          dterm.children.each { |n| parse(n, p) }
          insert_tab(p, 1)
          ddef["id"] and bookmark_parse(ddef, out)
          ddef_first_para(out, ddef)
        end
        ddef_other_paras(out, ddef)
      end

      def ddef_first_para(out, ddef)
        if ddef.elements&.first&.name == "p"
          ddef.children.first.children.each { |n| parse(n, out) }
        else
          ddef.children.each { |n| parse(n, out) }
        end
      end

      def ddef_other_paras(out, ddef)
        ddef.elements&.first&.name == "p" or return
        ddef.children[1..].each { |n| parse(n, out) }
      end

      def dl_table_attrs(node)
        { id: node["id"],
          align: node["class"] == "formula_dl" ? "left" : nil,
          class: node["class"] || "dl" }
      end

      def dl_parse_table(node, out)
        list_title_parse(node, out)
        out.table **attr_code(dl_table_attrs(node)) do |v|
          node.elements.select { |n| dt_dd?(n) }
            .each_slice(2) do |dt, dd|
            dl_parse_table1(v, dt, dd)
          end
          dl_parse_table_notes(node, v)
        end
      end

      def dl_parse_table1(table, dterm, ddefn)
        table.tr do |tr|
          tr.td valign: "top", align: "left" do |term|
            dt_parse(dterm, term)
          end
          tr.td valign: "top" do |listitem|
            ddefn.children.each { |n| parse(n, listitem) }
          end
        end
      end

      def dl_parse_table_notes(node, out)
        remainder = node.elements.reject do |n|
          dt_dd?(n) || n.name == "fmt-name"
        end
        remainder.empty? and return
        out.tr do |tr|
          tr.td colspan: 2 do |td|
            remainder.each { |n| parse(n, td) }
          end
        end
      end

      def li_checkbox(node)
        if node["uncheckedcheckbox"] == "true"
          '<span class="zzMoveToFollowing">&#x2610; </span>'
        elsif node["checkedcheckbox"] == "true"
          '<span class="zzMoveToFollowing">&#x2611; </span>'
        else ""
        end
      end
    end
  end
end
