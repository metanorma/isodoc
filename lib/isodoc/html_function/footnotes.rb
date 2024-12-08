module IsoDoc
  module HtmlFunction
    module Footnotes
      def footnotes(div)
        return if @footnotes.empty?

        @footnotes.each { |fn| div.parent << fn }
      end

      def make_table_footnote_link(out, fnid, fnref)
        attrs = { href: "##{fnid}", class: "TableFootnoteRef" }
        out.a **attrs do |a|
          a << fnref
        end
      end

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
      def make_table_footnote_text(node, fnid, fnref)
        attrs = { id: "fn:#{fnid}" }
        noko do |xml|
          xml.div **attr_code(attrs) do |div|
            make_table_footnote_target(div, fnid, fnref)
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def make_generic_footnote_text(node, fnid)
        noko do |xml|
          xml.aside id: "fn:#{fnid}", class: "footnote" do |div|
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def get_table_ancestor_id(node)
        table = node.ancestors("table") || node.ancestors("figure")
        return UUIDTools::UUID.random_create.to_s if table.empty?

        table.last["id"]
      end

      # @seen_footnote:
      # do not output footnote text if we have already seen it for this table

      def table_footnote_parse(node, out)
        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        tid = get_table_ancestor_id(node)
        make_table_footnote_link(out, tid + fn, fn)
        return if @seen_footnote.include?(tid + fn)

        @in_footnote = true
        out.aside class: "footnote" do |a|
          a << make_table_footnote_text(node, tid + fn, fn)
        end
        @in_footnote = false
        @seen_footnote << (tid + fn)
      end

      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if (@in_table || @in_figure) &&
          !node.ancestors.map(&:name).include?("fmt-name")

        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        attrs = { class: "FootnoteRef", href: "#fn:#{fn}" }
        out.a **attrs do |a|
          a.sup { |sup| sup << fn }
        end
        make_footnote(node, fn)
      end

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
