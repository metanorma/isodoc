module IsoDoc
  module HtmlFunction
    module Footnotes
      def make_table_footnote_link(out, fnid, node)
        attrs = { href: "##{fnid}", class: "TableFootnoteRef" }
        sup = node.at(ns("./sup")) and sup.replace(sup.children)
        out.a **attrs do |a|
          children_parse(node, a)
        end
      end

      # KILL
      def make_table_footnote_target(out, fnid, fnref)
        attrs = { id: fnid, class: "TableFootnoteRef" }
        out.span do |s|
          out.span **attrs do |a|
            a << fnref
          end
          insert_tab(s, 1)
        end
      end

      # Move to Presentation XML, as <fmt-footnote>: it's a footnote body
      # # KILL
      def make_table_footnote_text(node, fnid, fnref)
        attrs = { id: "fn:#{fnid}" }
        noko do |xml|
          xml.div **attr_code(attrs) do |div|
            make_table_footnote_target(div, fnid, fnref)
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      # KILL
      def make_generic_footnote_text(node, fnid)
        noko do |xml|
          xml.aside id: "fn:#{fnid}", class: "footnote" do |div|
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def get_table_ancestor_id(node)
        table = node.ancestors("table") || node.ancestors("figure")
        table.empty? and return [nil, UUIDTools::UUID.random_create.to_s]
        [table.last, table.last["id"]]
      end

      # @seen_footnote:
      # do not output footnote text if we have already seen it for this table

      def table_footnote_parse(node, out)
        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        table, tid = get_table_ancestor_id(node)
        make_table_footnote_link(out, tid + fn, node.at(ns("./fmt-fn-label")))
        return if @seen_footnote.include?(tid + fn)
        update_table_fn_body_ref(node, table, tid + fn)
=begin
        @in_footnote = true
        out.aside class: "footnote" do |a|
          a << make_table_footnote_text(node, tid + fn, fn)
        end
        @in_footnote = false
=end
        @seen_footnote << (tid + fn)
      end

      def update_table_fn_body_ref(fnote, table, reference)
        fnbody = table.at(ns("./fmt-footnote-container/" \
          "fmt-fn-body[@id = '#{fnote['target']}']"))
        fnbody["reference"] = reference
        sup = fnbody.at(ns(".//fmt-fn-label/sup")) and sup.replace(sup.children)
        fnbody.xpath(ns(".//fmt-fn-label")).each do |s|
          s["class"] = "TableFootnoteRef"
          s.name = "span"
          d = s.at(ns("./span[@class = 'fmt-caption-delim']")) and
            s.next = d
        end
      end

      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if (@in_table || @in_figure) &&
          !node.ancestors.map(&:name).include?("fmt-name")

        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        attrs = { class: "FootnoteRef", href: "#fn:#{fn}" }
        f = node.at(ns("./fmt-fn-label"))
        out.a **attrs do |a|
          #a.sup { |sup| sup << fn }
                          children_parse(f, a)
        end
        #make_footnote(node, fn)
      end

      # KILL
      def make_footnote(node, fnote)
        return if @seen_footnote.include?(fnote)

        @in_footnote = true
        @footnotes << make_generic_footnote_text(node, fnote)
        @in_footnote = false
        @seen_footnote << fnote
      end
    end
  end
end
