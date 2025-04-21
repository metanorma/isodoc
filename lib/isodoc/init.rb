module IsoDoc
  class Convert < ::IsoDoc::Common
    def metadata_init(lang, script, locale, i18n)
      @meta = Metadata.new(lang, script, locale, i18n)
    end

    def xref_init(lang, script, _klass, i18n, options)
      html = HtmlConvert.new(language: @lang, script: @script)
      @xrefs = Xref.new(lang, script, html, i18n, options)
    end

    def i18n_init(lang, script, locale, i18nyaml = nil)
      @i18n = I18n.new(lang, script, locale: locale,
                                     i18nyaml: i18nyaml || @i18nyaml)
    end

    def l10n(expr, lang = @lang, script = @script, locale = @locale)
      @i18n.l10n(expr, lang, script, locale)
    end

    def toc_init(docxml)
      @doctype = docxml.at(ns("//bibdata/ext/doctype"))&.text
      @subdoctype = docxml.at(ns("//bibdata/ext/subdoctype"))&.text
      @xrefs.klass.doctype = @doctype
      x = "//metanorma-extension/presentation-metadata" \
          "[name[text() = 'TOC Heading Levels']]/value"
      n = docxml.at(ns(x.sub("TOC", "DOC TOC"))) and
        @wordToClevels = n.text.to_i
      n = docxml.at(ns(x.sub("TOC", "HTML TOC"))) and
        @htmlToClevels = n.text.to_i
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
      @break_up_urls_in_tables = options[:breakupurlsintables]
      @suppressasciimathdup = options[:suppressasciimathdup]
      @aligncrosselements = options[:aligncrosselements]
      @modspecidentifierbase = options[:modspecidentifierbase]
      @sourcehighlighter = options[:sourcehighlighter]
      @output_formats = options[:output_formats] || {}
    end

    def init_arrangement(options)
      @sectionsplit = options[:sectionsplit] == "true"
      @bare = options[:bare]
      @semantic_xml_insert = options[:semanticxmlinsert] != "false"
      @log = options[:log]
    end

    def init_i18n(options)
      @i18nyaml = options[:i18nyaml]
      @lang = options[:language] || "en"
      @script = options[:script] || "Latn"
      @locale = options[:locale]
      @localizenumber = options[:localizenumber]
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
      @htmlToClevels = 2
      @wordToClevels = 2
      @tocfigures = options[:tocfigures]
      @toctables = options[:toctables]
      @tocrecommendations = options[:tocrecommendations]
    end

    AGENCIES = %w(ISO IEC ITU IETF NIST OGC IEEE BIPM BSI BS JIS IANA UN W3C
                  IHO CSA IEV)
      .freeze

    def agency?(text)
      self.class::AGENCIES.include?(text)
    end

    def docid_l10n(text, citation: true)
      text.nil? and return text
      docid_all_parts(text, citation)
      x = Nokogiri::XML::DocumentFragment.parse(text)
      (x.xpath(".//text()") - x.xpath(".//fn//text()")).each do |n|
        n.replace(n.text.gsub(/ /, "&#xa0;"))
      end
      to_xml(x)
    end

    def docid_all_parts(text, citation)
      if citation
        text.sub!(%r{\p{Zs}\(all\p{Zs}parts\)}, "")
      else
        @i18n.all_parts && !citation and
          text.gsub!(/all\p{Zs}parts/, @i18n.all_parts.downcase)
      end
    end

    def docid_prefix(prefix, docid)
      docid = "#{prefix} #{docid}" if prefix && !omit_docid_prefix(prefix) &&
        !/^#{prefix}\b/.match(docid)
      docid_l10n(docid, citation: false)
    end

    def omit_docid_prefix(prefix)
      prefix.nil? || prefix.empty? and return true
      %w(ISO IEC IEV ITU W3C BIPM csd metanorma repository metanorma-ordinal)
        .include? prefix
    end

    def connectives_spans(text)
      text.gsub("<conn>", "<span class='fmt-conn'>")
        .gsub("</conn>", "</span>")
        .gsub("<enum-comma>", "<span class='fmt-enum-comma'>")
        .gsub("</enum-comma>", "</span>")
        .gsub("<comma>", "<span class='fmt-comma'>")
        .gsub("</comma>", "</span>")
    end
  end
end
