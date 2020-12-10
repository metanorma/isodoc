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

    def anchor(id, lbl, warning = true)
      return nil if id.nil? || id.empty?
      unless @anchors[id]
        if warning
          @seen ||= Seen_Anchor.instance
          @seen.seen(id) or warn "No label has been processed for ID #{id}"
          @seen.add(id)
          return "[#{id}]"
        end
      end
      @anchors.dig(id, lbl)
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
      bookmark_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
    end

    def ns(xpath)
      Common::ns(xpath)
    end

    def l10n(a, lang = @lang, script = @script)
      @i18n.l10n(a, lang, script)
    end
  end
end
