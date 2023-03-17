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

      def make_table_footnote_text(node, fnid, fnref)
        attrs = { id: "ftn#{fnid}" }
        noko do |xml|
          xml.div **attr_code(attrs) do |div|
            make_table_footnote_target(div, fnid, fnref)
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def make_generic_footnote_text(node, fnid)
        noko do |xml|
          xml.aside id: "ftn#{fnid}" do |div|
            node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def get_table_ancestor_id(node)
        table = node.ancestors("table") || node.ancestors("figure")
        return UUIDTools::UUID.random_create.to_s if table.empty?

        table.last["id"]
      end

      def table_footnote_parse(node, out)
        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        tid = get_table_ancestor_id(node)
        make_table_footnote_link(out, tid + fn, fn)
        # do not output footnote text if we have already seen it for this table
        return if @seen_footnote.include?(tid + fn)

        @in_footnote = true
        out.aside { |a| a << make_table_footnote_text(node, tid + fn, fn) }
        @in_footnote = false
        @seen_footnote << (tid + fn)
      end

      def seen_footnote_parse(_node, out, footnote)
        out.span style: "mso-element:field-begin"
        out << " NOTEREF _Ref#{@fn_bookmarks[footnote]} \\f \\h"
        out.span style: "mso-element:field-separator"
        out.span class: "MsoFootnoteReference" do |s|
          s << footnote
        end
        out.span style: "mso-element:field-end"
      end

      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if (@in_table || @in_figure) &&
          !node.ancestors.map(&:name).include?("name")

        fn = node["reference"] || UUIDTools::UUID.random_create.to_s
        return seen_footnote_parse(node, out, fn) if @seen_footnote.include?(fn)

        @fn_bookmarks[fn] = bookmarkid
        out.span style: "mso-bookmark:_Ref#{@fn_bookmarks[fn]}" do |s|
          s.a class: "FootnoteRef", "epub:type": "footnote",
              href: "#ftn#{fn}" do |a|
            a.sup { |sup| sup << fn }
          end
        end
        @in_footnote = true
        @footnotes << make_generic_footnote_text(node, fn)
        @in_footnote = false
        @seen_footnote << fn
      end

      def make_footnote(node, footnote)
        return if @seen_footnote.include?(footnote)

        @in_footnote = true
        @footnotes << make_generic_footnote_text(node, footnote)
        @in_footnote = false
        @seen_footnote << footnote
      end
    end
  end
end
