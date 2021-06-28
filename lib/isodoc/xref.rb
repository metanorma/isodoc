require_relative "xref/xref_anchor"
require_relative "xref/xref_counter"
require_relative "xref/xref_gen_seq"
require_relative "xref/xref_gen"
require_relative "xref/xref_sect_gen"
require_relative "class_utils"

module IsoDoc
  class Xref
    include XrefGen::Anchor
    include XrefGen::Blocks
    include XrefGen::Sections

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
    end

    def get
      @anchors
    end

    def anchor(ident, lbl, warning = true)
      return nil if ident.nil? || ident.empty?

      if warning && !@anchors[ident]
        @seen ||= Seen_Anchor.instance
        @seen.seen(ident) or warn "No label has been processed for ID #{ident}"
        @seen.add(ident)
        return "[#{ident}]"
      end
      @anchors.dig(ident, lbl)
    end

    # extract names for all anchors, xref and label
    def parse(docxml)
      amend_preprocess(docxml)
      initial_anchor_names(docxml)
      back_anchor_names(docxml)
      # preempt clause notes with all other types of note (ISO default)
      note_anchor_names(docxml.xpath(ns("//table | //figure")))
      note_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      example_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      list_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      deflist_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      bookmark_anchor_names(docxml)
    end

    def ns(xpath)
      Common::ns(xpath)
    end

    def l10n(text, lang = @lang, script = @script)
      @i18n.l10n(text, lang, script)
    end
  end
end
