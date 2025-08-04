require "isodoc/common"
require "fileutils"
require "tempfile"
require_relative "i18n"
require_relative "css"
require_relative "init"
require "securerandom"
require "mn-requirements"

module IsoDoc
  class Convert < ::IsoDoc::Common
    attr_accessor :options, :i18n, :meta, :xrefs, :reqt_models,
                  :requirements_processor, :doctype, :bibrender,
                  :tempfile_cache, :wordcoverpage, :wordintropage, :localdir

    # htmlstylesheet: Generic stylesheet for HTML
    # htmlstylesheet_override: Override stylesheet for HTML
    # wordstylesheet: Generic stylesheet for Word
    # wordstylesheet_override: Override stylesheet for Word
    # standardsheet: Stylesheet specific to Standard
    # header: Header file for Word
    # htmlcoverpage: Cover page for HTML
    # wordcoverpage: Cover page for Word
    # htmlintropage: Introductory page for HTML
    # wordintropage: Introductory page for Word
    # normalfontsize: Font size for body text
    # smallerfontsize: Font size for smaller than body text
    # monospacefontsize: Font size for monospace font
    # footnotefontsize: Font size for footnotes
    # i18nyaml: YAML file for internationalisation of text
    # ulstyle: list style in Word CSS for unordered lists
    # olstyle: list style in Word CSS for ordered lists
    # bodyfont: font to use for body text
    # headerfont: font to use for header text
    # monospace: font to use for monospace text
    # suppressheadingnumbers: suppress heading numbers for clauses
    # scripts: Scripts file for HTML
    # scripts_override: Override scripts file for HTML
    # scripts_pdf: Scripts file for PDF (not used in XSLT PDF)
    # datauriimage: Encode images in HTML output as data URIs
    # breakupurlsintables: whether to insert spaces in URLs in tables
    #   every 40-odd chars
    # sectionsplit: split up HTML output on sections
    # bare: do not insert any prefatory material (coverpage, boilerplate)
    # tocfigures: add ToC for figures
    # toctables: add ToC for tables
    # tocrecommendations: add ToC for rcommendations
    # fonts: fontist fonts to install
    # fontlicenseagreement: fontist font license agreement
    # modspecidentifierbase: base prefix for any Modspec identifiers
    # sourcehighlighter: whether to apply sourcecode highlighting
    # semantic_xml_insert: whether to insert into presentation XML
    #   a copy of semantic XML
    # output_formats: hash of supported output formats and suffixes
    def initialize(options) # rubocop:disable Lint/MissingSuper
      @options = options_preprocess(options)
      init_stylesheets(@options)
      init_covers(@options)
      init_toc(@options)
      init_fonts(@options)
      init_processing
      init_locations(@options)
      init_i18n(@options)
      init_rendering(@options)
      init_arrangement(@options)
    end

    def tmpimagedir_suffix
      "_#{SecureRandom.hex(8)}_images"
    end

    def tmpfilesdir_suffix
      "_#{SecureRandom.hex(8)}_files"
    end

    def html_doc_path(*file)
      file.each do |f|
        ret = File.join(@libdir, File.join("html", f))
        File.exist?(ret) and return ret
      end
      nil
    end

    def requirements_processor
      Metanorma::Requirements
    end

    def bibrenderer(options = {})
      ::Relaton::Render::IsoDoc::General.new(options.merge(language: @lang,
                                                           i18nhash: @i18n.get))
    end

    def convert1_namespaces(html)
      html.add_namespace("epub", "http://www.idpf.org/2007/ops")
    end

    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      noko do |xml|
        xml.html lang: @lang.to_s do |html|
          convert1_namespaces(html.parent)
          info docxml, nil
          populate_css
          html.head { |head| define_head head, filename, dir }
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def convert_init(file, input_filename, debug)
      docxml = Nokogiri::XML(file, &:huge)
      filename, dir = init_file(input_filename, debug)
      docxml.root.default_namespace = ""
      convert_i18n_init(docxml)
      metadata_init(@lang, @script, @locale, @i18n)
      xref_init(@lang, @script, self, @i18n,
                { locale: @locale, bibrender: @bibrender })
      toc_init(docxml)
      [docxml, filename, dir]
    end

    def convert_i18n_init(docxml)
      convert_i18n_init1(docxml)
      i18n_init(@lang, @script, @locale)
      @bibrender ||= bibrenderer
      @reqt_models = requirements_processor
        .new({ default: "default", lang: @lang, script: @script,
               locale: @locale, labels: @i18n.get,
               modspecidentifierbase: @modspecidentifierbase })
    end

    def convert_i18n_init1(docxml)
      lang = docxml.at(ns("//bibdata/language")) and @lang = lang.text
      if script = docxml.at(ns("//bibdata/script"))
        @script = script.text
      elsif lang
        @script = ::Metanorma::Utils::default_script(@lang)
      end
      locale = docxml.at(ns("//bibdata/locale")) and @locale = locale.text
    end

    def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      debug and return result
      output_filename ||= "#{filename}.#{@suffix}"
      postprocess(result, output_filename, dir)
      FileUtils.rm_rf dir
    end

    def middle_clause(_docxml = nil)
      "//clause[parent::sections][not(@type = 'scope')]" \
        "[not(descendant::terms)][not(descendant::references)]"
    end

    def target_pdf(node)
      if node["target"].include?("#") then node["target"].sub("#", ".pdf#")
      else "##{node['target']}"
      end
    end

    # use a different class than self for rendering, as a result
    # of document-specific criteria
    # but pass on any singleton methods defined on top of the self instance
    def swap_renderer(oldklass, newklass, file, input_filename, debug)
      ref = oldklass # avoid oldklass == self for indirection of methods
      oldklass.singleton_methods.each do |x|
        newklass.define_singleton_method(x) do |*args|
          ref.public_send(x, *args)
        end
      end
      oldklass.singleton_methods.empty? or
        newklass.convert_init(file, input_filename, debug)
    end
  end
end
