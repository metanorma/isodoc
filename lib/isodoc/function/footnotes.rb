module IsoDoc
  module Function
    module Footnotes
      def make_table_footnote_link(out, fnid, node)
        attrs = { href: "##{fnid}", class: "TableFootnoteRef" }
        sup = node.at(ns(".//sup")) and sup.replace(sup.children)
        out.a **attrs do |a|
          children_parse(node, a)
        end
      end

      def get_table_ancestor_id(node)
        table = node.ancestors("table")
        table.empty? and table = node.ancestors("figure")
        table.empty? and return [nil, UUIDTools::UUID.random_create.to_s]
        [table.last, table.last["id"]]
      end

      # @seen_footnote:
      # do not output footnote text if we have already seen it for this table

      def table_footnote_parse(node, out)
        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        table, tid = get_table_ancestor_id(node)
        make_table_footnote_link(out, tid + fn, node.at(ns("./fmt-fn-label")))
        # do not output footnote text if we have already seen it for this table
        @seen_footnote.include?(tid + fn) and return
        update_table_fn_body_ref(node, table, tid + fn)
        @seen_footnote << (tid + fn)
      end

      def update_table_fn_body_ref(fnote, table, reference)
        fnbody = table.at(ns(".//fmt-fn-body[@id = '#{fnote['target']}']")) or
          return
        fnbody["reference"] = reference
        fnbody["is_table"] = true
        sup = fnbody.at(ns(".//fmt-fn-label//sup")) and sup.replace(sup.children)
        fnbody.xpath(ns(".//fmt-fn-label")).each do |s|
          s["class"] = "TableFootnoteRef"
          s.name = "span"
          d = s.at(ns("./span[@class = 'fmt-caption-delim']")) and s.next = d
        end
      end

      def table_footnote?(node)
        (@in_table || @in_figure) &&
          !node.ancestors.map(&:name).include?("fmt-name")
      end

      def footnote_parse(node, out)
        table_footnote?(node) and return table_footnote_parse(node, out)
        fn = node["target"] # || UUIDTools::UUID.random_create.to_s
        attrs = { class: "FootnoteRef", href: "#fn:#{fn}" }
        f = node.at(ns("./fmt-fn-label"))
        out.a **attrs do |a|
          children_parse(f, a)
        end
      end

      def fmt_annotation_body_parse(node, out); end
    end
  end
end
