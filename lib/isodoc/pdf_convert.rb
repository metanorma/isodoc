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
      @suffix = "pdf"
      super
    end

    def convert(input_filename, file = nil, debug = false, output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      postprocess(result, filename + ".tmp.html", dir)
      FileUtils.rm_rf dir
      ::Metanorma::Output::Pdf.new.convert("#{filename}.tmp.html",
                                           output_filename || "#{filename}.#{@suffix}")
      FileUtils.rm_rf ["#{filename}.tmp.html", tmpimagedir]
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".pdf#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
