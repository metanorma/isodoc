# frozen_string_literal: true

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
    attr_accessor :options, :i18n, :meta, :xrefs, :reqt_models, :requirements_processor

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
    # break_up_urls_in_tables: whether to insert spaces in URLs in tables
    #   every 40-odd chars
    # sectionsplit: split up HTML output on sections
    # bare: do not insert any prefatory material (coverpage, boilerplate)
    # tocfigures: add ToC for figures
    # toctables: add ToC for tables
    # tocrecommendations: add ToC for rcommendations
    # fonts: fontist fonts to install
    # fontlicenseagreement: fontist font license agreement
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
    end

    def options_preprocess(options)
      options.merge!(default_fonts(options)) do |_, old, new|
        old || new
      end.merge!(default_file_locations(options)) do |_, old, new|
        old || new
      end
      options
    end

    def init_rendering(options)
      @ulstyle = options[:ulstyle]
      @olstyle = options[:olstyle]
      @datauriimage = options[:datauriimage]
      @suppressheadingnumbers = options[:suppressheadingnumbers]
      @break_up_urls_in_tables = options[:break_up_urls_in_tables] == "true"
      @sectionsplit = options[:sectionsplit] == "true"
      @suppressasciimathdup = options[:suppressasciimathdup] == "true"
      @bare = options[:bare]
      @aligncrosselements = options[:aligncrosselements]
    end

    def init_i18n(options)
      @i18nyaml = options[:i18nyaml]
      @lang = options[:language] || "en"
      @script = options[:script] || "Latn"
    end

    def init_locations(options)
      @libdir ||= File.dirname(__FILE__)
      @baseassetpath = options[:baseassetpath]
      @tmpimagedir_suffix = tmpimagedir_suffix
      @tmpfilesdir_suffix = tmpfilesdir_suffix
      @sourcefilename = options[:sourcefilename]
      @files_to_delete = []
      @tempfile_cache = []
    end

    def init_processing
      @termdomain = ""
      @termexample = false
      @note = false
      @sourcecode = false
      @footnotes = []
      @comments = []
      @in_footnote = false
      @in_comment = false
      @in_table = false
      @in_figure = false
      @seen_footnote = Set.new
      @c = HTMLEntities.new
      @openmathdelim = "`"
      @closemathdelim = "`"
      @maxwidth = 1200
      @maxheight = 800
      @bookmarks_allocated = { "X" => true }
      @fn_bookmarks = {}
    end

    def init_fonts(options)
      @normalfontsize = options[:normalfontsize]
      @smallerfontsize = options[:smallerfontsize]
      @monospacefontsize = options[:monospacefontsize]
      @footnotefontsize = options[:footnotefontsize]
      @fontist_fonts = options[:fonts]
      @fontlicenseagreement = options[:fontlicenseagreement]
    end

    def init_covers(options)
      @header = options[:header]
      @htmlcoverpage = options[:htmlcoverpage]
      @wordcoverpage = options[:wordcoverpage]
      @htmlintropage = options[:htmlintropage]
      @wordintropage = options[:wordintropage]
      @scripts = options[:scripts] ||
        File.join(File.dirname(__FILE__), "base_style", "scripts.html")
      @scripts_pdf = options[:scripts_pdf]
      @scripts_override = options[:scripts_override]
    end

    def init_stylesheets(options)
      @htmlstylesheet_name = options[:htmlstylesheet]
      @wordstylesheet_name = options[:wordstylesheet]
      @htmlstylesheet_override_name = options[:htmlstylesheet_override]
      @wordstylesheet_override_name = options[:wordstylesheet_override]
      @standardstylesheet_name = options[:standardstylesheet]
    end

    def init_toc(options)
      @wordToClevels = options[:doctoclevels].to_i
      @wordToClevels = 2 if @wordToClevels.zero?
      @htmlToClevels = options[:htmltoclevels].to_i
      @htmlToClevels = 2 if @htmlToClevels.zero?
      @tocfigures = options[:tocfigures]
      @toctables = options[:toctables]
      @tocrecommendations = options[:tocrecommendations]
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

    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      bibitem_lookup(docxml)
      noko do |xml|
        xml.html **{ lang: @lang.to_s } do |html|
          html.parent.add_namespace("epub", "http://www.idpf.org/2007/ops")
          info docxml, nil
          populate_css
          html.head { |head| define_head head, filename, dir }
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def bibitem_lookup(docxml)
      @bibitems = docxml.xpath(ns("//references/bibitem"))
        .each_with_object({}) do |b, m|
        m[b["id"]] = b
      end
    end

    def convert_init(file, input_filename, debug)
      docxml = Nokogiri::XML(file) { |config| config.huge }
      filename, dir = init_file(input_filename, debug)
      docxml.root.default_namespace = ""
      convert_i18n_init(docxml)
      metadata_init(@lang, @script, @i18n)
      xref_init(@lang, @script, self, @i18n, {})
      [docxml, filename, dir]
    end

    def convert_i18n_init(docxml)
      lang = docxml&.at(ns("//bibdata/language"))&.text and @lang = lang
      script = docxml&.at(ns("//bibdata/script"))&.text and @script = script
      i18n_init(@lang, @script)
      @reqt_models = requirements_processor
        .new({ default: "default", lang: lang, script: script,
               labels: @i18n.get })
    end

    def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug

      output_filename ||= "#{filename}.#{@suffix}"
      postprocess(result, output_filename, dir)
      FileUtils.rm_rf dir
    end

    def middle_clause(_docxml = nil)
      "//clause[parent::sections][not(@type = 'scope')]"\
        "[not(descendant::terms)]"
    end

    def target_pdf(node)
      if /#/.match?(node["target"]) then node["target"].sub(/#/, ".pdf#")
      else "##{node['target']}"
      end
    end
  end
end
