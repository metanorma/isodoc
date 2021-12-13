require "metanorma"

module IsoDoc
  class XslfoPdfConvert < ::IsoDoc::Convert
    MN2PDF_OPTIONS = :mn2pdf
    MN2PDF_FONT_MANIFEST = :font_manifest

    def initialize(options)
      @format = :pdf
      @suffix = "pdf"
      @pdf_cmd_options = extract_cmd_options(options)
      super
    end

    def extract_cmd_options(options)
      ret = {}
      a = options[:pdfencryptionlength] and ret["--encryption-length"] = a
      a = options[:pdfownerpassword] and ret["--owner-password"] = a
      a = options[:pdfuserpassword] and ret["--user-password"] = a
      a = options[:pdfallowprint] and ret["--allow-print"] = a
      a = options[:pdfallowcopycontent] and ret["--allow-copy-content"] = a
      a = options[:pdfalloweditcontent] and ret["--allow-edit-content"] = a
      a = options[:pdfalloweditannotations] and
        ret["--allow-edit-annotations"] = a
      a = options[:pdfallowfillinforms] and ret["--allow-fill-in-forms"] = a
      a = options[:pdfallowaccesscontent] and
        ret["--allow-access-content"] = a
      a = options[:pdfallowassembledocument] and
        ret["--allow-assemble-document"] = a
      a = options[:pdfallowprinthq] and ret["--allow-print-hq"] = a
      a = options[:pdfencryptmetadata] and ret["--encrypt-metadata"] = a
      ret
    end

    def tmpimagedir_suffix
      "_pdfimages"
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
