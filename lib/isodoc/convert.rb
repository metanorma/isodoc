# frozen_string_literal: true

require 'isodoc/common'
require 'fileutils'
require 'tempfile'

module IsoDoc
  class Convert < ::IsoDoc::Common
    attr_reader :options
    attr_accessor :labels

    # htmlstylesheet: Generic stylesheet for HTML
    # wordstylesheet: Generic stylesheet for Word
    # standardsheet: Stylesheet specific to Standard
    # header: Header file for Word
    # htmlcoverpage: Cover page for HTML
    # wordcoverpage: Cover page for Word
    # htmlintropage: Introductory page for HTML
    # wordintropage: Introductory page for Word
    # i18nyaml: YAML file for internationalisation of text
    # ulstyle: list style in Word CSS for unordered lists
    # olstyle: list style in Word CSS for ordered lists
    # bodyfont: font to use for body text
    # headerfont: font to use for header text
    # monospace: font to use for monospace text
    # suppressheadingnumbers: suppress heading numbers for clauses
    # scripts: Scripts file for HTML
    # scripts_pdf: Scripts file for PDF
    # datauriimage: Encode images in HTML output as data URIs
    def initialize(options)
      @libdir ||= File.dirname(__FILE__)
      options.merge!(default_fonts(options)) do |_, old, new|
        old || new
      end
             .merge!(default_file_locations(options)) do |_, old, new|
        old || new
      end
      @options = options
      @files_to_delete = []
      @tempfile_cache = []
      @htmlstylesheet_name = precompiled_style_or_original(
        options[:htmlstylesheet]
      )
      @wordstylesheet_name = precompiled_style_or_original(
        options[:wordstylesheet]
      )
      @standardstylesheet_name = precompiled_style_or_original(
        options[:standardstylesheet]
      )
      @header = options[:header]
      @htmlcoverpage = options[:htmlcoverpage]
      @wordcoverpage = options[:wordcoverpage]
      @htmlintropage = options[:htmlintropage]
      @wordintropage = options[:wordintropage]
      @scripts = options[:scripts]
      @scripts_pdf = options[:scripts_pdf]
      @i18nyaml = options[:i18nyaml]
      @ulstyle = options[:ulstyle]
      @olstyle = options[:olstyle]
      @datauriimage = options[:datauriimage]
      @suppressheadingnumbers = options[:suppressheadingnumbers]
      @break_up_urls_in_tables = options[:break_up_urls_in_tables] == 'true'
      @termdomain = ''
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
      @openmathdelim = '`'
      @closemathdelim = '`'
      @lang = 'en'
      @script = 'Latn'
      @maxwidth = 1200
      @maxheight = 800
      @wordToClevels = options[:doctoclevels].to_i
      @wordToClevels = 2 if @wordToClevels.zero?
      @htmlToClevels = options[:htmltoclevels].to_i
      @htmlToClevels = 2 if @htmlToClevels.zero?
      @bookmarks_allocated = { 'X' => true }
      @fn_bookmarks = {}
    end

    # Check if already compiled version(.css) exists,
    #   if not, return original scss file. During release
    #   we compile scss into css files in order to not depend on scss
    def precompiled_style_or_original(stylesheet_path)
      # Already have compiled stylesheet, use it
      return stylesheet_path if stylesheet_path.nil? ||
                                File.extname(stylesheet_path) == '.css'

      basename = File.basename(stylesheet_path, '.*')
      compiled_path = File.join(File.dirname(stylesheet_path),
                                "#{basename}.css")
      return stylesheet_path unless File.file?(compiled_path)

      compiled_path
    end

    # run this after @meta is populated
    def populate_css
      @htmlstylesheet = generate_css(@htmlstylesheet_name, true)
      @wordstylesheet = generate_css(@wordstylesheet_name, false)
      @standardstylesheet = generate_css(@standardstylesheet_name, false)
    end

    def tmpimagedir_suffix
      '_images'
    end

    def default_fonts(_options)
      {
        bodyfont: 'Arial',
        headerfont: 'Arial',
        monospacefont: 'Courier'
      }
    end

    # none for this parent gem, but will be populated in child
    #   gems which have access to stylesheets &c; e.g.
    # {
    #      htmlstylesheet: html_doc_path("htmlstyle.scss"),
    #      htmlcoverpage: html_doc_path("html_rsd_titlepage.html"),
    #      htmlintropage: html_doc_path("html_rsd_intro.html"),
    #      scripts: html_doc_path("scripts.html"),
    #      wordstylesheet: html_doc_path("wordstyle.scss"),
    #      standardstylesheet: html_doc_path("rsd.scss"),
    #      header: html_doc_path("header.html"),
    #      wordcoverpage: html_doc_path("word_rsd_titlepage.html"),
    #      wordintropage: html_doc_path("word_rsd_intro.html"),
    #      ulstyle: l3
    #      olstyle: l2
    # }
    def default_file_locations(_options)
      {}
    end

    def fonts_options
      {
        'bodyfont' => options[:bodyfont] || 'Arial',
        'headerfont' => options[:headerfont] || 'Arial',
        'monospacefont' => options[:monospacefont] || 'Courier'
      }
    end

    def scss_fontheader
      b = options[:bodyfont] || 'Arial'
      h = options[:headerfont] || 'Arial'
      m = options[:monospacefont] || 'Courier'
      "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
    end

    def html_doc_path(file)
      File.join(@libdir, File.join('html', file))
    end

    def convert_scss(filename, stylesheet)
      require 'sassc'
      require 'isodoc/sassc_importer'

      [File.join(Gem.loaded_specs['isodoc'].full_gem_path,
                 'lib', 'isodoc'),
       File.dirname(filename)].each do |name|
        SassC.load_paths << name
      end
      SassC::Engine.new(scss_fontheader + stylesheet, syntax: :scss,
                                                      importer: SasscImporter)
                   .render
    end

    def generate_css(filename, stripwordcss)
      return nil if filename.nil?

      stylesheet = File.read(filename, encoding: 'UTF-8')
      stylesheet = populate_template(stylesheet, :word)
      stylesheet.gsub!(/(\s|\{)mso-[^:]+:[^;]+;/m, '\\1') if stripwordcss
      if File.extname(filename) == '.scss'
        stylesheet = convert_scss(filename, stylesheet)
      end
      Tempfile.open([File.basename(filename, '.*'), 'css'],
                    encoding: 'utf-8') do |f|
        f.write(stylesheet)
        f
      end
    end

    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      noko do |xml|
        xml.html **{ lang: @lang.to_s } do |html|
          html.parent.add_namespace('epub', 'http://www.idpf.org/2007/ops')
          info docxml, nil
          populate_css
          html.head { |head| define_head head, filename, dir }
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def metadata_init(lang, script, labels)
      @meta = Metadata.new(lang, script, labels)
    end

    def xref_init(lang, script, klass, labels, options)
      @xrefs = Xref.new(lang, script, klass, labels, options)
    end

    def convert_init(file, input_filename, debug)
      docxml = Nokogiri::XML(file)
      filename, dir = init_file(input_filename, debug)
      docxml.root.default_namespace = ''
      lang = docxml&.at(ns('//bibdata/language'))&.text || @lang
      script = docxml&.at(ns('//bibdata/script'))&.text || @script
      i18n_init(lang, script)
      metadata_init(lang, script, @labels)
      @meta.fonts_options = fonts_options
      xref_init(lang, script, self, @labels, {})
      [docxml, filename, dir]
    end

    def convert(input_filename,
                file = nil,
                debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: 'utf-8') if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      output_filename ||= "#{filename}.#{@suffix}"
      postprocess(result, output_filename, dir)
      FileUtils.rm_rf dir
    end

    def middle_clause
      "//clause[parent::sections][not(xmlns:title = 'Scope')]"\
      '[not(descendant::terms)]'
    end
  end
end
