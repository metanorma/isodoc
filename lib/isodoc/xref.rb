require_relative "xref/xref_anchor"
require_relative "xref/xref_counter"
require_relative "xref/xref_counter_types"
require_relative "xref/xref_gen_seq"
require_relative "xref/xref_gen"
require_relative "xref/xref_sect_gen"
require_relative "xref/xref_util"
require_relative "class_utils"
require_relative "function/utils"

module IsoDoc
  class Xref
    include XrefGen::Anchor
    include XrefGen::Blocks
    include XrefGen::Sections
    include Function::Utils

    attr_reader :klass

    # Note: if bibrender is no passed in, do not parse references
    def initialize(lang, script, klass, i18n, options = {})
      initialize_empty
      @lang = lang
      @script = script
      @klass = klass
      @options = options
      initialize_i18n(i18n)
      @klass.bibrender ||= options[:bibrender]
      @reqt_models = @klass.requirements_processor
        .new({ default: "default", lang:, script:,
               labels: @i18n.get })
    end

    def initialize_empty
      @c = HTMLEntities.new
      @anchors = {}
      @parse_settings = {}
    end

    def initialize_i18n(i18n)
      @i18n = i18n
      @labels = @i18n.get
      @klass.i18n = @i18n
      @locale = @options[:locale]
    end

    def get
      @anchors
    end

    # parse only the elements set, if any are set
    # defined are: clause: true, refs: true, assets: true
    def parse_inclusions(options)
      @parse_settings.merge!(options)
      self
    end

    def anchor(ident, lbl, warning = true)
      return nil if ident.nil? || ident.empty?

      if warning && !@anchors[ident]
        @seen.seen(ident) or warn "No label has been processed for ID #{ident}"
        @seen.add(ident)
        return "[#{ident}]"
      end
      @anchors.dig(ident, lbl)
    end

    # extract names for all anchors, xref and label
    def parse(docxml)
      @doctype = docxml.at(ns("//bibdata/ext/doctype"))&.text
      @seen = SeenAnchor.new(docxml)
      amend_preprocess(docxml) if @parse_settings.empty?
      initial_anchor_names(docxml)
      back_anchor_names(docxml)
      asset_anchor_names(docxml)
      localise_anchors
      @parse_settings = {}
    end

    def localise_anchors
      @anchors.each_value do |v|
        v[:label] &&= l10n(v[:label])
        v[:value] &&= l10n(v[:value])
        v[:xref] &&= l10n(v[:xref])
      end
    end

    def ns(xpath)
      Common::ns(xpath)
    end

    def l10n(text, lang = @lang, script = @script, locale = @locale)
      @i18n.l10n(text, lang, script, locale)
    end

    include ::IsoDoc::XrefGen::Util
  end
end
