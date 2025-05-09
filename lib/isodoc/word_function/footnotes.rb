module IsoDoc
  module WordFunction
    module Footnotes
      def bookmarkid
        ret = "X"
        until !@bookmarks_allocated[ret]
          ret = Random.rand(1000000000)
        end
        @bookmarks_allocated[ret] = true
        sprintf "%09d", ret
      end

      # KILL
      def make_table_footnote_linkx(out, fnid, node)
        attrs = { href: "##{fnid}", class: "TableFootnoteRef" }
        sup = node.at(ns(".//sup")) and sup.replace(sup.children)
        out.a **attrs do |a|
          children_parse(node, a)
        end
      end

      def fmt_fn_body_parse(node, out)
        node.at(ns(".//fmt-fn-label"))&.remove
        aside = node.parent.name == "fmt-footnote-container"
        tag = aside ? "aside" : "div"
        id = node["is_table"] ? node["reference"] : node["id"]
        out.send tag, id: "ftn#{id}" do |div|
          node.children.each { |n| parse(n, div) }
        end
      end

      # KILL
      def get_table_ancestor_idx(node)
        table = node.ancestors("table")
        table.empty? and table = node.ancestors("figure")
        table.empty? and return [nil,
                                 UUIDTools::UUID.random_create.to_s]
        [table.last, table.last["id"]]
      end

      # KILL
      def table_footnote_parsex(node, out)
        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        table, tid = get_table_ancestor_id(node)
        make_table_footnote_link(out, tid + fn, node.at(ns("./fmt-fn-label")))
        # do not output footnote text if we have already seen it for this table
        return if @seen_footnote.include?(tid + fn)

        update_table_fn_body_ref(node, table, tid + fn)
        @seen_footnote << (tid + fn)
      end

      def seen_footnote_parse(node, out, footnote)
        f = node.at(ns("./fmt-fn-label"))
        sup = f.at(ns(".//sup")) and sup.replace(sup.children)
        s = f.at(ns(".//semx[@source = '#{node['id']}']"))
        semx = <<~SPAN.strip
          <span style="mso-element:field-begin"/> NOTEREF _Ref#{@fn_bookmarks[footnote]} \\f \\h<span style="mso-element:field-separator"/>#{footnote}<span style="mso-element:field-end"/>
        SPAN
        s.replace(semx)
        out.span class: "MsoFootnoteReference" do |fn|
          children_parse(f, fn)
        end
      end

      def footnote_parse(node, out)
        table_footnote?(node) and return table_footnote_parse(node, out)
        fn = node["reference"] # || UUIDTools::UUID.random_create.to_s
        @seen_footnote.include?(fn) and return seen_footnote_parse(node, out, fn)
        @fn_bookmarks[fn] = bookmarkid
        f = footnote_label_process(node)
        out.span style: "mso-bookmark:_Ref#{@fn_bookmarks[fn]}",
                 class: "MsoFootnoteReference" do |s|
          children_parse(f, s)
        end
        footnote_hyperlink(node, out)
        @seen_footnote << fn
      end

      def footnote_label_process(node)
        f = node.at(ns("./fmt-fn-label"))
        sup = f.at(ns(".//sup")) and sup.replace(sup.children)
        if semx = f.at(ns(".//semx[@element = 'autonum']"))
          semx.name = "span"
          semx["class"] = "FMT-PLACEHOLDER"
        end
        f
      end

      def footnote_hyperlink(node, out)
        if semx = out.parent.at(".//span[@class = 'FMT-PLACEHOLDER']")
          semx.name = "a"
          semx["class"] = "FootnoteRef"
          semx["epub:type"] = "footnote"
          semx["href"] = "#ftn#{node['target']}"
        end
      end
    end
  end
end
