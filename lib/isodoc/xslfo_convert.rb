require "metanorma"

module IsoDoc
  class XslfoPdfConvert < ::IsoDoc::Convert
    MN2PDF_OPTIONS = :mn2pdf
    MN2PDF_FONT_MANIFEST = :font_manifest
    MN2PDF_OPTIONS = { pdfencryptionlength: "--encryption-length",
                       pdfownerpassword: "--owner-password",
                       pdfuserpassword: "--user-password",
                       pdfallowprint: "--allow-print",
                       pdfallowcopycontent: "--allow-copy-content",
                       pdfalloweditcontent: "--allow-edit-content",
                       pdfalloweditannotations: "--allow-edit-annotations",
                       pdfallowfillinforms: "--allow-fill-in-forms",
                       pdfallowaccesscontent: "--allow-access-content",
                       pdfallowassembledocument: "--allow-assemble-document",
                       pdfallowprinthq: "--allow-print-hq",
                       pdfencryptmetadata: "--encrypt-metadata" }.freeze
    MN2PDF_DEFAULT_ARGS = { "--syntax-highlight": nil }.freeze

    def initialize(options)
      @format = :pdf
      @suffix = "pdf"
      @pdf_cmd_options = extract_cmd_options(options)
      super
    end

    def extract_cmd_options(options)
      ret = MN2PDF_DEFAULT_ARGS.dup
      MN2PDF_OPTIONS.each do |key, opt|
        value = options[key] and ret[opt] = value
      end
      ret
    end

    def tmpimagedir_suffix
      "_#{SecureRandom.hex(8)}_pdfimages"
    end

    def pdf_stylesheet(_docxml)
      nil
    end

    def pdf_options(_docxml)
      ret = {}
      font_manifest = @options.dig(MN2PDF_OPTIONS,
                                   MN2PDF_FONT_MANIFEST) and
        ret[MN2PDF_FONT_MANIFEST] = font_manifest
      @aligncrosselements && !@aligncrosselements.empty? and
        ret["--param align-cross-elements="] =
          @aligncrosselements.gsub(/,/, " ")
      @baseassetpath and
        ret["--param baseassetpath="] = @baseassetpath
      ret.merge(@pdf_cmd_options)
    end

    def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      input_filename, docxml, filename = input_xml_path(input_filename,
                                                        file, debug)
      ::Metanorma::Output::XslfoPdf.new.convert(
        input_filename,
        output_filename || "#{filename}.#{@suffix}",
        File.join(@libdir, pdf_stylesheet(docxml)),
        pdf_options(docxml),
      )
    end

    def xref_parse(node, out)
      out.a(**{ href: target_pdf(node) }) { |l| l << get_linkend(node) }
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

      [input_filename, docxml, filename]
    end
  end
end
