require_relative "html_function/comments.rb"
require_relative "html_function/footnotes.rb"
require_relative "html_function/html.rb"
require "metanorma"

module IsoDoc
  class PdfConvert < ::IsoDoc::Convert

    include HtmlFunction::Comments
    include HtmlFunction::Footnotes
    include HtmlFunction::Html

    def initialize(options)
      @standardstylesheet = nil
      super
      @scripts = @scripts_pdf if @scripts_pdf
      @maxwidth = 500
      @maxheight = 800
    end

    def tmpimagedir_suffix
      "_pdfimages"
    end

    def initialize(options)
      @format = :pdf
      super
    end

    def convert(filename, file = nil, debug = false)
      file = File.read(filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, outname_html, dir = convert_init(file, filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      postprocess(result, filename, dir)
      FileUtils.rm_rf dir
      ::Metanorma::Output::Pdf.new.convert("#{filename}.html", outname_html + ".pdf")
      FileUtils.rm_rf ["#{filename}.html", tmpimagedir]
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".pdf#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
