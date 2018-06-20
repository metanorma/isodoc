module IsoDoc::WordFunction
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
      out.a **attrs do |a|
        a << fnref
        insert_tab(a, 1)
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
        xml.aside **{ id: "ftn#{fnid}" } do |div|
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
      fn = node["reference"]
      tid = get_table_ancestor_id(node)
      make_table_footnote_link(out, tid + fn, fn)
      # do not output footnote text if we have already seen it for this table
      return if @seen_footnote.include?(tid + fn)
      @in_footnote = true
      out.aside { |a| a << make_table_footnote_text(node, tid + fn, fn) }
      @in_footnote = false
      @seen_footnote << (tid + fn)
    end

    def footnote_parse(node, out)
      return table_footnote_parse(node, out) if @in_table || @in_figure
      fn = node["reference"]
      out.a **{ "epub:type": "footnote", href: "#ftn#{fn}" } do |a|
        a.sup { |sup| sup << fn }
      end
      return if @seen_footnote.include?(fn)
      @in_footnote = true
      @footnotes << make_generic_footnote_text(node, fn)
      @in_footnote = false
      @seen_footnote << fn
    end

    def make_footnote(node, fn)
      return if @seen_footnote.include?(fn)
      @in_footnote = true
      @footnotes << make_generic_footnote_text(node, fn)
      @in_footnote = false
      @seen_footnote << fn
    end
  end
end
