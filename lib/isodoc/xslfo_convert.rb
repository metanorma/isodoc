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

    def pdf_stylesheet(docxml)
      nil
    end

    def pdf_options(docxml)
      if font_manifest_file = @options.dig(:mn2pdf, :font_manifest_file)
        "--font-manifest #{font_manifest_file}"
      else
        ""
      end
    end

    def convert(input_filename, file = nil, debug = false, output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      docxml, filename, dir = convert_init(file, input_filename, debug)
      /\.xml$/.match(input_filename) or
          input_filename = Tempfile.open([filename, ".xml"], encoding: "utf-8") do |f|
          f.write file
          f.path
        end
      FileUtils.rm_rf dir
      ::Metanorma::Output::XslfoPdf.new.convert(input_filename,
                                                output_filename || "#{filename}.#{@suffix}",
                                               File.join(@libdir, pdf_stylesheet(docxml)),
                                               pdf_options(docxml))
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".pdf#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
