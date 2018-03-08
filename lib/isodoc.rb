require_relative "isodoc/version"

require "nokogiri"
require "asciimath"
require "xml/xslt"
require "uuidtools"
require "base64"
require "mime/types"
require "image_size"
require "set"
require_relative "isodoc/iso2wordhtml"
require_relative "isodoc/cleanup"
require_relative "isodoc/postprocessing"
require_relative "isodoc/utils"
require_relative "isodoc/metadata"
require_relative "isodoc/section"
require_relative "isodoc/references"
require_relative "isodoc/terms"
require_relative "isodoc/blocks"
require_relative "isodoc/lists"
require_relative "isodoc/table"
require_relative "isodoc/inline"
require_relative "isodoc/notes"
require_relative "isodoc/xref_gen"
require_relative "isodoc/xref_sect_gen"
require_relative "isodoc/html"
require_relative "isodoc/i18n"
require "pp"

module IsoDoc
  class Convert

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
    def initialize(options)
      @htmlstylesheet = options[:htmlstylesheet]
      @wordstylesheet = options[:wordstylesheet]
      @standardstylesheet = options[:standardstylesheet]
      @header = options[:header]
      @htmlcoverpage = options[:htmlcoverpage]
      @wordcoverpage = options[:wordcoverpage]
      @htmlintropage = options[:htmlintropage]
      @wordintropage = options[:wordintropage]
      @i18nyaml = options[:i18nyaml]
      @ulstyle = options[:ulstyle]
      @olstyle = options[:olstyle]
      @termdomain = ""
      @termexample = false
      @note = false
      @sourcecode = false
      @anchors = {}
      @meta = {}
      init_metadata
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
    end

    def convert1(docxml, filename, dir)
      noko do |xml|
        xml.html do |html|
          html.parent.add_namespace("epub", "http://www.idpf.org/2007/ops")
          html_header(html, docxml, filename, dir)
          make_body(html, docxml)
        end
      end.join("\n")
    end

    def convert_init(file, filename, debug)
      docxml = Nokogiri::XML(file)
      filename, dir = init_file(filename, debug)
      docxml.root.default_namespace = ""
      i18n_init(docxml&.at(ns("//bibdata/language"))&.text || "en",
                docxml&.at(ns("//bibdata/script"))&.text || "Latn")
      [docxml, filename, dir]
    end

    def convert(filename, debug = false)
      convert_file(File.read(filename), filename, debug)
    end

    def convert_file(file, filename, debug)
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug
      postprocess(result, filename, dir)
    end
  end
end
