require "fileutils"
require "base64"

module IsoDoc::HtmlFunction
  module Html
    def convert1(docxml, filename, dir)
      noko do |xml|
        xml.html **{ lang: @lang.to_s } do |html|
          info docxml, nil
          populate_css
          html.head { |head| define_head head, filename, dir }
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def make_body1(body, _docxml)
      return if @bare

      body.div **{ class: "title-section" } do |div1|
        div1.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body2(body, _docxml)
      return if @bare

      body.div **{ class: "prefatory-section" } do |div2|
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body3(body, docxml)
      body.div **{ class: "main-section" } do |div3|
        boilerplate docxml, div3
        preface_block docxml, div3
        abstract docxml, div3
        foreword docxml, div3
        introduction docxml, div3
        preface docxml, div3
        acknowledgements docxml, div3
        middle docxml, div3
        footnotes div3
        comments div3
      end
    end

    def googlefonts
      <<~HEAD.freeze
        <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Lato:400,400i,700,900" rel="stylesheet">
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
        <link rel="preconnect" href="https://fonts.gstatic.com">#{' '}
        #{googlefonts}
        <!--Font awesome import for the link icon-->
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/solid.css" integrity="sha384-v2Tw72dyUXeU3y4aM2Y0tBJQkGfplr39mxZqlTBDUZAb9BGoC40+rdFCG0m10lXk" crossorigin="anonymous">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/fontawesome.css" integrity="sha384-q3jl8XQu1OpdLgGFvNRnPdj5VIlCvgsDQTQB6owSOHWlAurxul7f+JpUOVdAiJ5P" crossorigin="anonymous">
        <style class="anchorjs"></style>
      HEAD
    end

    def html_button
      return "" if @bare

      '<button onclick="topFunction()" id="myBtn" '\
        'title="Go to top">Top</button>'.freeze
    end

    def html_main(docxml)
      docxml.at("//head").add_child(html_head)
      d = docxml.at('//div[@class="main-section"]')
      d.name = "main"
      d.children.empty? or d.children.first.previous = html_button
    end

    def sourcecodelang(lang)
      return unless lang

      case lang.downcase
      when "javascript" then "lang-js"
      when "c" then "lang-c"
      when "c+" then "lang-cpp"
      when "console" then "lang-bsh"
      when "ruby" then "lang-rb"
      when "html" then "lang-html"
      when "java" then "lang-java"
      when "xml" then "lang-xml"
      when "perl" then "lang-perl"
      when "python" then "lang-py"
      when "xsl" then "lang-xsl"
      else
        ""
      end
    end

    def sourcecode_parse(node, out)
      name = node.at(ns("./name"))
      class1 = "prettyprint #{sourcecodelang(node&.at(ns('./@lang'))&.value)}"
      out.pre **sourcecode_attrs(node).merge(class: class1) do |div|
        @sourcecode = true
        node.children.each { |n| parse(n, div) unless n.name == "name" }
        @sourcecode = false
      end
      sourcecode_name_parse(node, out, name)
    end

    def underline_parse(node, out)
      out.span **{ style: "text-decoration: underline;" } do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def table_long_strings_cleanup(docxml); end
  end
end
