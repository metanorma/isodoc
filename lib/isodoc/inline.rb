require "uuidtools"

module IsoDoc
  class Convert

    def in_footnote
      @in_footnote
    end

    def in_comment
      @in_comment
    end

    def section_break(body)
      body.br **{ clear: "all", class: "section" }
    end

    def page_break(body)
      body.br **{
        clear: "all",
        style: "mso-special-character:line-break;page-break-before:always",
      }
    end

    def link_parse(node, out)
      linktext = node.text
      linktext = node["target"] if linktext.empty?
      out.a **{ "href": node["target"] } { |l| l << linktext }
    end

    def callout_parse(node, out)
      out << " &lt;#{node.text}&gt;"
    end

    def get_linkend(node)
      linkend = node["target"] || node["citeas"]
      if get_anchors().has_key? node["target"]
        linkend = get_anchors()[node["target"]][:xref]
      end
      if node["citeas"].nil? && get_anchors().has_key?(node["bibitemid"])
        linkend = get_anchors()[node["bibitemid"]][:xref]
      end
      text = node.children.select { |c| c.text? && !c.text.empty? }
      linkend = text.join(" ") unless text.nil? || text.empty?
      # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
      # <locality type="section"><reference>3.1</reference></locality></origin>
      linkend
    end

    def xref_parse(node, out)
      linkend = get_linkend(node)
      out.a **{ "href": node["target"] } { |l| l << linkend }
    end

    def eref_parse(node, out)
      linkend = get_linkend(node)
      r = node.at(ns("./locality/reference"))
      r.nil? || linkend += ", #{r.parent["type"].capitalize} #{r.text}"
      if node["type"] == "footnote"
        out.sup do |s|
          s.a **{ "href": node["bibitemid"] } { |l| l << linkend }
        end
      else
        out.a **{ "href": node["bibitemid"] } { |l| l << linkend }
      end
    end

    def stem_parse(node, out)
      ooml = if node["type"] == "AsciiMath" then "`#{node.text}`"
             elsif node["type"] == "MathML" then node.first_element_child.to_s
             else
               node.text
             end
        out.span **{ class: "stem" } do |span|
          span.parent.add_child ooml
        end
      end

      def pagebreak_parse(node, out)
        attrs = { clear: all, class: "pagebreak" }
        out.br **attrs
      end

      def error_parse(node, out)
        text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
        out.para do |p|
          p.b **{ role: "strong" } { |e| e << text }
        end
      end

      def footnotes(div)
        return if @footnotes.empty?
        div.div **{ style: "mso-element:footnote-list" } do |div1|
          @footnotes.each { |fn| div1.parent << fn }
        end
      end

      def footnote_attributes(fn, is_footnote)
        style = nil
        style = "mso-footnote-id:ftn#{fn}" if is_footnote
        { style: style,
          href: "#_ftn#{fn}",
          name: "_ftnref#{fn}",
          title: "",
          class: "zzFootnote" }
      end

      def make_footnote_link(a, fnid, fnref, is_footnote)
        a.span **{ class: "MsoFootnoteReference" } do |s|
          if is_footnote
            s.span **{ style: "mso-special-character:footnote" }
          else
            s.a **{href: fnid} { a << fnref }
          end
        end
      end

      def make_footnote_target(a, fnid, fnref, is_footnote)
        a.span **{ class: "MsoFootnoteReference" } do |s|
          if is_footnote
            s.span **{ style: "mso-special-character:footnote" }
          else
            s.a **{name: fnid} { a << fnref }
          end
        end
      end

      def make_footnote_text(node, fnid, fnref, is_footnote)
        attrs = { style: "mso-element:footnote", id: "ftn#{fnid}" }
        attrs[:style] = nil unless is_footnote
        noko do |xml|
          xml.div **attr_code(attrs) do |div|
            div.a **footnote_attributes(fnid, is_footnote) do |a|
              make_footnote_target(a, fnid, fnref, is_footnote)
              insert_tab(a, 1) unless is_footnote
            end
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
        out.a **footnote_attributes(tid + fn, false) do |a|
          make_footnote_link(a, tid + fn, fn, false)
        end
        # do not output footnote text if we have already seen it for this table
        return if @seen_footnote.include?(tid + fn)
        @in_footnote = true
        out.aside { |a| a << make_footnote_text(node, tid + fn, fn, false) }
        @in_footnote = false
        @seen_footnote << (tid + fn)
      end

      def footnote_parse(node, out)
        return table_footnote_parse(node, out) if @in_table || @in_figure
        fn = node["reference"]
        out.a **footnote_attributes(fn, true) do |a|
          make_footnote_link(a, nil, nil, true)
        end
        @in_footnote = true
        @footnotes << make_footnote_text(node, fn, fn, true)
        @in_footnote = false
      end

      def comments(div)
        return if @comments.empty?
        div.div **{ style: "mso-element:comment-list" } do |div1|
          @comments.each { |fn| div1.parent << fn }
        end
      end

      # add in from and to links to move the comment into place
      def make_comment_link(out, fn, node)
        out.span **{ style: "MsoCommentReference" } do |s1|
          s1.span **{ lang: "EN-GB", style: "font-size:9.0pt"} do |s2|
            s2.a **{ style: "mso-comment-reference:SMC_#{fn};"\
                     "mso-comment-date:#{node['date']}",
                     class: "commentLink", from: node['from'], to: node['to']} 
            s2.span **{ style: "mso-special-character:comment" } do |s|
              s << "&nbsp;"
            end
          end
        end
      end

     def make_comment_target(out, fn, date)
        out.span **{ style: "MsoCommentReference" } do |s1|
          s1.span **{ lang: "EN-GB", style: "font-size:9.0pt"} do |s2|
            s2.span **{ style: "mso-special-character:comment" } do |s|
              s << "&nbsp;"
            end
          end
        end
      end

      def make_comment_text(node, fn)
        noko do |xml|
          xml.div **{ style: "mso-element:comment" } do |div|
            div.span **{ style: %{mso-comment-author:"#{node["reviewer"]}"} }
              make_comment_target(div, fn, node["date"])
              node.children.each { |n| parse(n, div) }
          end
        end.join("\n")
      end

      def review_note_parse(node, out)
        fn = @comments.length + 1
        make_comment_link(out, fn, node)
        @in_comment = true
        @comments << make_comment_text(node, fn)
        @in_comment = false
      end
  end
end
