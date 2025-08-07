module IsoDoc
  class XslfoPdfConvert < ::IsoDoc::Convert
    MN_OPTIONS_KEY = :mn2pdf
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
                       pdfstylesheet: "--xsl-file",
                       pdfstylesheet_override: "--xsl-file-override",
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

    def baseassetpath(filename)
      !@baseassetpath && filename and
        @baseassetpath = File.expand_path(Pathname.new(filename).parent.to_s)
    end

    def pdf_options(_docxml, filename)
      baseassetpath(filename)
      ret = {}
      font_manifest = @options.dig(MN_OPTIONS_KEY, MN2PDF_FONT_MANIFEST) and
        ret[MN2PDF_FONT_MANIFEST] = font_manifest
      @aligncrosselements && !@aligncrosselements.empty? and
        ret["--param align-cross-elements="] =
          @aligncrosselements.tr(",", " ")
      @baseassetpath and
        ret["--param baseassetpath="] = @baseassetpath
      ret = ret.merge(@pdf_cmd_options)
      %w(--xsl-file --xsl-file-override).each do |x|
        if ret[x]
          ret[x] = if File.absolute_path?(ret[x])
                     Pathname.new(ret[x]).to_s
                   else
                     Pathname.new(
                       File.expand_path(File.join(@baseassetpath, ret[x])),
                     ).to_s
                   end
        end
      end
      if ret["--xsl-file"]
        @xsl = ret["--xsl-file"]
        ret.delete("--xsl-file")
      end
      ret
    end

    # input_file: keep-alive tempfile
    def convert(input_fname, file = nil, debug = false,
                output_fname = nil)
      _, docxml, filename = convert_prep(input_fname, file, debug)
      opts = pdf_options(docxml, input_fname)
      ::Metanorma::Output::XslfoPdf.new.convert(
        filename, output_fname || output_filename(input_fname),
        @xsl, opts
      )
    end

    def convert_prep(input_fname, file, debug)
      file ||= File.read(input_fname, encoding: "utf-8")
      _, docxml, filename = input_xml_path(input_fname, file, debug)
      @xsl = pdf_stylesheet(docxml) or return
      Pathname.new(@xsl).absolute? or @xsl = File.join(@libdir, @xsl)
      @doctype = docxml.at(ns("//bibdata/ext/doctype"))&.text
      [file, docxml, filename]
    end

    def output_filename(input_fname)
      out = input_fname.sub(/\.presentation\.xml$/, ".xml")
      File.join(File.dirname(input_fname),
                "#{File.basename(out, '.*')}.#{@suffix}")
    end

    def xref_parse(node, out)
      out.a(href: target_pdf(node)) { |l| l << get_linkend(node) }
    end

    def input_xml_path(input_filename, xml_file, debug)
      docxml, filename, dir = convert_init(xml_file, input_filename, debug)
      temp_file = Tempfile.open([File.basename(filename), ".xml"],
                                mode: File::BINARY | File::SHARE_DELETE,
                                encoding: "utf-8")
      temp_file.write docxml
      temp_file.flush
      @tempfile_cache << temp_file # Add to cache to prevent garbage collection
      FileUtils.rm_rf dir

      [temp_file, docxml, temp_file.path]
    end
  end
end
