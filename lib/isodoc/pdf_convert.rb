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
      super
      @tmpimagedir = "_pdfimages"
      @maxwidth = 500
      @maxheight = 800
    end

    def convert(filename, file = nil, debug = false)
      file = File.read(filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, outname_html, dir = convert_init(file, filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      postprocess(result, filename, dir)
      system "rm -fr #{dir}"
      ::Metanorma::Output::Pdf.new.convert(filename + ".html", outname_html + ".pdf")
      system "rm -r #{filename + '.html'} #{@tmpimagedir}"
    end
  end
end
