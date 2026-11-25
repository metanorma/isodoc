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

    # The intermediate HTML handed to the PDF renderer is a transient
    # artifact inside the compile's work root, where it resolves the
    # store's assets beside itself (rel_asset_path default); the work
    # root teardown removes it with the compile. Ruby-side naming only,
    # the PDF rendering pipeline itself is untouched.
    def convert(input_filename, file = nil, debug = false, output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug

      tmp_html = File.join(leg_workdir, "#{File.basename(filename)}.tmp.html")
      postprocess(result, tmp_html, dir)
      ::Metanorma::Output::Pdf.new.convert(
        tmp_html,
        output_filename || "#{filename}.#{@suffix}",
      )
    ensure
      teardown_workdir unless debug
    end

    def xref_parse(node, out)
      out.a(**{ "href": target_pdf(node) }) { |l| l << get_linkend(node) }
    end
  end
end
