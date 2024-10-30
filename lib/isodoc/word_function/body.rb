require_relative "table"
require_relative "inline"
require_relative "lists"

module IsoDoc
  module WordFunction
    module Body
      def convert1_namespaces(html)
        super
        html.add_namespace("v", "urn:schemas-microsoft-com:vml")
        html.add_namespace("o", "urn:schemas-microsoft-com:office:office")
        html.add_namespace("w", "urn:schemas-microsoft-com:office:word")
        html.add_namespace("m", "http://schemas.microsoft.com/office/2004/12/omml")
      end

      def define_head(head, filename, _dir)
        head.style do |style|
          loc = File.join(File.dirname(__FILE__), "..", "base_style",
                          "metanorma_word.scss")
          stylesheet = File.read(loc, encoding: "utf-8")
          style.comment "\n#{stylesheet}\n"
        end
        super
      end

      def body_attr
        { lang: "EN-US", link: "blue", vlink: "#954F72" }
      end

      def make_body1(body, _docxml)
        body.div class: "WordSection1" do |div1|
          div1.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      def make_body2(body, docxml)
        body.div class: "WordSection2" do |div2|
          boilerplate docxml, div2
          content(div2, docxml, ns("//preface/*[@displayorder]"))
          div2.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      MAIN_ELEMENTS =
        "//sections/*[@displayorder] | //annex[@displayorder] | " \
        "//bibliography/*[@displayorder] | //colophon/*[@displayorder] | " \
        "//indexsect[@displayorder]".freeze

      def make_body3(body, docxml)
        body.div class: "WordSection3" do |div3|
          content(div3, docxml, ns(self.class::MAIN_ELEMENTS))
          footnotes div3
          comments div3
        end
      end

      def para_class(node)
        return "Sourcecode" if @annotation
        return "MsoCommentText" if @in_comment
        return "Note" if @note
        if node["type"] == "floating-title"
          return "h#{node['depth']}"
        end

        n = node["class"] and return n
        nil
      end

      def para_parse(node, out)
        out.p **attr_code(para_attrs(node)) do |p|
          unless @termdomain.empty?
            p << "&#x3c;#{@termdomain}&#x3e; "
            @termdomain = ""
          end
          node.children.each { |n| parse(n, p) unless n.name == "note" }
        end
        node.xpath(ns("./note")).each { |n| parse(n, out) }
      end

      def figure_get_or_make_dl(node)
        dl = node.at(".//table[@class = 'dl']")
        if dl.nil?
          node.add_child("<p><b>#{@i18n.key}</b></p><table class='dl'></table>")
          dl = node.at(".//table[@class = 'dl']")
        end
        dl
      end

      # get rid of footnote link, it is in diagram
      def figure_aside_process(fig, aside, key)
        fig.at("./a[@class='TableFootnoteRef']")&.remove
        fnref = fig.at(".//span[@class='TableFootnoteRef']/..")
        tr = key.add_child("<tr></tr>").first
        dt = tr.add_child("<td valign='top' align='left'></td>").first
        dd = tr.add_child("<td valign='top'></td>").first
        fnref.parent = dt
        aside.xpath(".//p").each do |a|
          a.delete("class")
          a.parent = dd
        end
      end

      def note_p_parse(node, div)
        name = node.at(ns("./name"))&.remove
        div.p class: "Note" do |p|
          p.span class: "note_label" do |s|
            name&.children&.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        name = node.at(ns("./name"))&.remove
        div.p class: "Note" do |p|
          p.span class: "note_label" do |s|
            name&.children&.each { |n| parse(n, s) }
          end
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) }
      end

      def termnote_parse(node, out)
        name = node&.at(ns("./name"))&.remove
        out.div **note_attrs(node) do |div|
          div.p class: "Note" do |p|
            if name
              name.children.each { |n| parse(n, p) }
              p << termnote_delim
            end
            para_then_remainder(node.first_element_child, node, p, div)
          end
        end
      end

      def para_attrs(node)
        attrs = { class: para_class(node), id: node["id"], style: "" }
        unless node["align"].nil?
          attrs[:align] = node["align"] unless node["align"] == "justify"
          attrs[:style] += "text-align:#{node['align']};"
        end
        attrs[:style] += keep_style(node).to_s
        attrs[:style] = nil if attrs[:style].empty?
        attrs
      end

      def example_table_attr(node)
        super.merge(
          style: "mso-table-lspace:15.0cm;margin-left:423.0pt;" \
                 "mso-table-rspace:15.0cm;margin-right:423.0pt;" \
                 "mso-table-anchor-horizontal:column;" \
                 "mso-table-overlap:never;border-collapse:collapse;" \
                 "#{keep_style(node)}",
        )
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p do |_p|
            parse(node.at(ns("./stem")), div)
            insert_tab(div, 1)
            if lbl = node&.at(ns("./name"))&.text
              div << lbl
            end
          end
        end
      end

      def info(xml, out)
        @tocfigurestitle =
          xml.at(ns("//metanorma-extension/toc[@type = 'figure']/title"))&.text
        @toctablestitle =
          xml.at(ns("//metanorma-extension/toc[@type = 'table']/title"))&.text
        @tocrecommendationstitle = xml
          .at(ns("//metanorma-extension/toc[@type = 'recommendation']/title"))&.text
        super
      end

      def table_of_contents(clause, out)
        page_break(out)
        out.div **attr_code(preface_attrs(clause)) do |div|
          div.p class: "zzContents" do |p|
            clause.at(ns("./title"))&.children&.each { |c| parse(c, p) }
          end
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end
    end
  end
end
