require_relative "xref/xref_anchor"
require_relative "xref/xref_counter"
require_relative "xref/xref_gen_seq"
require_relative "xref/xref_gen"
require_relative "xref/xref_sect_gen"
require_relative "class_utils"
require_relative "function/utils"

module IsoDoc
  class Xref
    include XrefGen::Anchor
    include XrefGen::Blocks
    include XrefGen::Sections
    include Function::Utils

    attr_reader :klass

    def initialize(lang, script, klass, i18n, options = {})
      @anchors = {}
      @lang = lang
      @script = script
      @klass = klass
      @options = options
      @i18n = i18n
      @labels = @i18n.get
      @klass.i18n = @i18n
      @reqt_models = @klass.requirements_processor
        .new({
               default: "default", lang: lang, script: script,
               labels: @i18n.get
             })
      @i18n
      @parse_settings = {}
    end

    def get
      @anchors
    end

    # parse only the elements set, if any are set
    # defined are: clause: true, refs: true
    def parse_inclusions(options)
      @parse_settings.merge!(options)
      self
    end

    def anchor(ident, lbl, warning = true)
      return nil if ident.nil? || ident.empty?

      if warning && !@anchors[ident]
        @seen ||= SeenAnchor.instance
        @seen.seen(ident) or warn "No label has been processed for ID #{ident}"
        @seen.add(ident)
        return "[#{ident}]"
      end
      @anchors.dig(ident, lbl)
    end

    # extract names for all anchors, xref and label
    def parse(docxml)
      amend_preprocess(docxml) if @parse_settings.empty?
      initial_anchor_names(docxml)
      back_anchor_names(docxml)
      asset_anchor_names(docxml)
      @parse_settings = {}
    end

    def ns(xpath)
      Common::ns(xpath)
    end

    def l10n(text, lang = @lang, script = @script)
      @i18n.l10n(text, lang, script)
    end
  end
end
