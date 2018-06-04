module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      #include IsoDoc::WordConvertModule

      def default_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Cambria",serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Cambria",serif')
        m = options[:monospacefont] || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def initialize(options)
        super
        @wordstylesheet = generate_css(html_doc_path("wordstyle.scss"), false, default_fonts(options))
        @standardstylesheet = generate_css(html_doc_path("isodoc.scss"), false, default_fonts(options))
        @header = html_doc_path("header.html")
        @wordcoverpage = html_doc_path("word_iso_titlepage.html")
        @wordintropage = html_doc_path("word_iso_intro.html")
        @ulstyle = "l3"
        @olstyle = "l2"
      end

    end
  end
end
