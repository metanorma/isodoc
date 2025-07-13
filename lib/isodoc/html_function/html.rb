require "fileutils"
require "base64"

module IsoDoc
  module HtmlFunction
    module Html
      def convert1(docxml, filename, dir)
        noko do |xml|
          xml.html lang: @lang.to_s do |html|
            info docxml, nil
            populate_css
            html.head { |head| define_head head, filename, dir }
            make_body(html, docxml)
          end
        end.join("\n")
      end

      def make_body1(body, _docxml)
        return if @bare

        body.div class: "title-section" do |div1|
          div1.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      def make_body2(body, _docxml)
        return if @bare

        body.div class: "prefatory-section" do |div2|
          div2.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      def googlefonts
        <<~HEAD.freeze
          <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet"/>
          <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet"/>
        HEAD
      end

      def html_head
        <<~HEAD.freeze
          <title>#{@meta&.get&.dig(:doctitle)}</title>
          <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

          <!--TOC script import-->
          <script type="text/javascript"  src="https://cdn.rawgit.com/jgallen23/toc/0.3.2/dist/toc.min.js"></script>
          <script type="text/javascript">#{toclevel}</script>

          <!--Google fonts-->
          <link rel="preconnect" href="https://fonts.gstatic.com"/>
          #{googlefonts}
          <!--Font awesome import for the link icon-->
          <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/solid.css" integrity="sha384-v2Tw72dyUXeU3y4aM2Y0tBJQkGfplr39mxZqlTBDUZAb9BGoC40+rdFCG0m10lXk" crossorigin="anonymous"/>
          <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/fontawesome.css" integrity="sha384-q3jl8XQu1OpdLgGFvNRnPdj5VIlCvgsDQTQB6owSOHWlAurxul7f+JpUOVdAiJ5P" crossorigin="anonymous"/>
          <style class="anchorjs"></style>
        HEAD
      end

      def html_button
        return "" if @bare

        '<button onclick="topFunction()" id="myBtn" ' \
        'title="Go to top">Top</button>'.freeze
      end

      def html_main(docxml)
        docxml.at("//head").add_child(html_head)
        d = docxml.at('//div[@class="main-section"]')
        d.name = "main"
        d.children.empty? or d.children.first.previous = html_button
      end

      def sourcecode_parse(node, out)
        name = node.at(ns("./fmt-name"))
        tag = node.at(ns(".//sourcecode | .//table")) ? "div" : "pre"
        n = node.at(ns("./fmt-sourcecode"))
        s = n || node
        attr = sourcecode_attrs(node).merge(class: "sourcecode")
        out.send tag, **attr do |div|
          sourcecode_parse1(s, div)
        end
        annotation_parse(s, out)
        sourcecode_name_parse(node, out, name)
      end

      def underline_parse(node, out)
        style = node["style"] ? " #{node['style']}" : ""
        attr = { style: "text-decoration: underline#{style}" }
        out.span **attr do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def table_attrs(node)
        ret = super
        if node.at(ns("./colgroup"))
          ret[:style] ||= ""
          ret[:style] += "table-layout:fixed;"
        end
        ret
      end

      def svg_supply_viewbox(svg)
        svg["viewbox"] and return
        svg["height"] && svg["width"] or return
        h = svg["height"].sub(/[^0-9]+$/, "")
        w = svg["width"].sub(/[^0-9]+$/, "")
        h.to_i.positive? && w.to_i.positive? or return
        svg["viewbox"] = "0 0 #{w} #{h}"
      end

      def image_body_parse(node, attrs, out)
        if svg = node.at("./m:svg", "m" => "http://www.w3.org/2000/svg")
          svg_supply_viewbox(svg)
          out.div class: "svg-container" do |div|
            div.parent.add_child(svg)
          end
        else super
        end
      end

      def in_comment
        @in_comment
      end

      def comments(docxml, div); end
      def comment_cleanup(docxml); end
    end
  end
end
