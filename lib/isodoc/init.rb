module IsoDoc
  class Convert < ::IsoDoc::Common
    def metadata_init(lang, script, i18n)
      @meta = Metadata.new(lang, script, i18n)
    end

    def xref_init(lang, script, _klass, i18n, options)
      html = HtmlConvert.new(language: @lang, script: @script)
      @xrefs = Xref.new(lang, script, html, i18n, options)
    end

    def i18n_init(lang, script, i18nyaml = nil)
      @i18n = I18n.new(lang, script, i18nyaml: i18nyaml || @i18nyaml)
      @reqt_models = Metanorma::Requirements
        .new({
               default: "default", lang: lang, script: script,
               labels: @i18n.get
             })
    end

    def l10n(expr, lang = @lang, script = @script)
      @i18n.l10n(expr, lang, script)
    end
  end
end
