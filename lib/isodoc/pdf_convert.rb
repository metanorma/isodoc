require_relative "html_function/html"

module IsoDoc
  class PdfConvert < ::IsoDoc::Convert
    include HtmlFunction::Html

    def initialize(options)
      @standardstylesheet = nil
      super
      @format = :pdf
      @suffix = "pdf"
      @scripts = @scripts_pdf if @scripts_pdf
      @maxwidth = 500
      @maxheight = 800
    end

    def tmpimagedir_suffix
      "_#{SecureRandom.hex(8)}_pdfimages"
    end

    def convert(input_filename, file = nil, debug = false, output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug

      postprocess(result, "#{filename}.tmp.html", dir)
      FileUtils.rm_rf dir
      ::Metanorma::Output::Pdf.new.convert(
        "#{filename}.tmp.html",
        output_filename || "#{filename}.#{@suffix}",
      )
      FileUtils.rm_rf ["#{filename}.tmp.html", tmpimagedir]
    end

    def xref_parse(node, out)
      out.a(**{ "href": target_pdf(node) }) { |l| l << get_linkend(node) }
    end
  end
end
