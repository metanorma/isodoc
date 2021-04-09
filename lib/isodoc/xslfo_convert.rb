require "metanorma"

module IsoDoc
  class XslfoPdfConvert < ::IsoDoc::Convert
    def initialize(options)
      super
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

    def pdf_stylesheet(_docxml)
      nil
    end

    def pdf_options(_docxml)
      if font_manifest_file = @options.dig(:mn2pdf, :font_manifest_file)
        "--font-manifest #{font_manifest_file}"
      else
        ""
      end
    end

    def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      input_filename, docxml = input_xml_path(input_filename, file, debug)
      ::Metanorma::Output::XslfoPdf.new.convert(
        input_filename,
        output_filename || "#{filename}.#{@suffix}",
        File.join(@libdir, pdf_stylesheet(docxml)),
        pdf_options(docxml)
      )
    end

    def xref_parse(node, out)
      out.a(**{ "href": target_pdf(node) }) { |l| l << get_linkend(node) }
    end

    def input_xml_path(input_filename, xml_file, debug)
      docxml, filename, dir = convert_init(xml_file, input_filename, debug)
      unless /\.xml$/.match?(input_filename)
        input_filename = Tempfile.open([filename, ".xml"],
                                       encoding: "utf-8") do |f|
          f.write xml_file
          f.path
        end
      end
      FileUtils.rm_rf dir

      [input_filename, docxml]
    end
  end
end
