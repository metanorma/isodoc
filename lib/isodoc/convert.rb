require "isodoc/common"
require "sassc"
require "fileutils"

module IsoDoc
  class Convert < ::IsoDoc::Common
    attr_reader :options

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
      @libdir = File.dirname(__FILE__) unless @libdir
      options.merge!(default_fonts(options)) { |_, old, new| old || new }.
        merge!(default_file_locations(options)) { |_, old, new| old || new }
      @options = options
      @files_to_delete = []
      @htmlstylesheet = generate_css(options[:htmlstylesheet], true, extract_fonts(options))
      @wordstylesheet = generate_css(options[:wordstylesheet], false, extract_fonts(options))
      @standardstylesheet = generate_css(options[:standardstylesheet], false, extract_fonts(options))
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
      @termdomain = ""
      @termexample = false
      @note = false
      @sourcecode = false
      @anchors = {}
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
      @lang = "en"
      @script = "Latn"
      @maxwidth = 1200
      @maxheight = 800
      @wordToClevels = options[:doctoclevels].to_i
      @wordToClevels = 2 if @wordToClevels == 0
      @htmlToClevels = options[:htmltoclevels].to_i
      @htmlToClevels = 2 if @htmlToClevels == 0
    end

    def tmpimagedir_suffix
      "_images"
    end

    def default_fonts(_options)
      {
        bodyfont: "Arial",
        headerfont: "Arial",
        monospacefont: "Courier",
      }
    end

    # none for this parent gem, but will be populated in child gems which have access to stylesheets &c; e.g.
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

    # extract fonts for use in generate_css
    def extract_fonts(options)
      b = options[:bodyfont] || "Arial"
      h = options[:headerfont] || "Arial"
      m = options[:monospacefont] || "Courier"
      "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
    end

    def html_doc_path(file)
      File.join(@libdir, File.join("html", file))
    end

    def generate_css(filename, stripwordcss, fontheader)
      return nil unless filename
      stylesheet = File.read(filename, encoding: "UTF-8")
      stylesheet.gsub!(/(\s|\{)mso-[^:]+:[^;]+;/m, "\\1") if stripwordcss
      engine = SassC::Engine.new(fontheader + stylesheet, syntax: :scss)
      outname = File.basename(filename, ".*") + ".css"
      File.open(outname, "w:UTF-8") { |f| f.write(engine.render) }
      @files_to_delete << outname
      outname
    end

    def convert1(docxml, filename, dir)
      anchor_names docxml
      noko do |xml|
        xml.html do |html|
          html.parent.add_namespace("epub", "http://www.idpf.org/2007/ops")
          define_head html, filename, dir
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def metadata_init(lang, script, labels)
      @meta = Metadata.new(lang, script, labels)
    end

    def convert_init(file, filename, debug)
      docxml = Nokogiri::XML(file)
      filename, dir = init_file(filename, debug)
      docxml.root.default_namespace = ""
      lang = docxml&.at(ns("//bibdata/language"))&.text || @lang
      script = docxml&.at(ns("//bibdata/script"))&.text || @script
      i18n_init(lang, script)
      metadata_init(lang, script, @labels)
      [docxml, filename, dir]
    end

    def convert(filename, file = nil, debug = false)
      file = File.read(filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      postprocess(result, filename, dir)
      FileUtils.rm_rf dir
    end
  end
end
