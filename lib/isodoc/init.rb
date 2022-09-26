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
  end
end
