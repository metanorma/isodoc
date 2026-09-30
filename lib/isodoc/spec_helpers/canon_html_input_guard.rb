# frozen_string_literal: true

require "canon"
require "nokogiri"

# Guards Canon's serialization matchers against input shapes that
# Canon's XML pretty-printer (preprocessing: :format in the metanorma
# profile) and the moxml/leptris backend cannot digest.
#
# 1. Leading "<?xml ?>" processing instructions in HTML input strings
#    passed to Canon's be_html_equivalent_to / be_html4_equivalent_to /
#    be_html5_equivalent_to matchers.
#
#    WHY: Nokogiri::HTML5.fragment parses a leading "<?xml ?>" as a
#    bogus Nokogiri::XML::Comment at index 0 of the fragment.  In
#    Canon's verbose mode (used by the matchers) comments are
#    intentionally not filtered, so the bogus comment shifts fragment
#    child indices and causes Canon's diff report to blame elements at
#    the tail of the document for an offence at the head — an
#    "uninterpretable report" remote from the actual cause.  Canon's
#    maintainer has chosen not to normalise this at the input boundary
#    (closed PR lutaml/canon#124); this guard is the local defence.
#
# 2. XML fragments (zero or many top-level nodes) and recoverable
#    malformations (unclosed tags) passed to be_xml_equivalent_to.
#    IsoDoc specs routinely compare such input — e.g. "<span>…</span>
#    <semx>…</semx>" anchor labels, a Word <body> extract with the
#    closing tag stripped, or an empty string for "nothing left after
#    stripping Word chrome".  Canon.format / PrettyPrinter::Xml#moxml_format
#    runs Moxml::Context#parse in strict mode, which raises
#    Moxml::ParseError ("malformed input" at the second root, "empty
#    input", or an unclosed tag) instead of comparing the fragments.
#    Wrapping both sides in a synthetic root makes them
#    single-document inputs; when the wrapped form is still not
#    well-formed, a Nokogiri recover-mode round-trip closes the
#    unclosed tags.  The transformation is identical on both sides, so
#    equivalence of the original fragments is preserved.
#
# WHEN: required for the side effect.  Requiring this file installs a
# Module#prepend on Canon::RSpecMatchers::SerializationMatcher that
# raises IsoDoc::SpecHelpers::CanonGuardError on the HTML PI condition
# and wraps XML-fragment inputs before comparison.
#
# REUSE: downstream gems that build on isodoc's spec idioms (metanorma
# family, mn2pdf, etc.) can opt in by adding a single line to their
# own spec_helper:
#
#   require "isodoc/spec_helpers/canon_html_input_guard"
#
# No further setup is needed — the module installs on require.

module IsoDoc
  module SpecHelpers
    class CanonGuardError < StandardError; end

    # Prepended onto Canon::RSpecMatchers::SerializationMatcher to
    # intercept matches? / compute_equivalent before Canon's own
    # implementation runs.
    module CanonHtmlInputGuard
      ILLEGAL_HTML_PREFIX = /\A\s*<\?xml\b/i.freeze

      # Synthetic root used to give multi-node / empty XML fragments a
      # single document element. Deliberately ugly so it cannot be
      # confused with real IsoDoc vocabulary.
      XML_FRAG_ROOT = "canon-xml-frag-root"

      def matches?(target)
        if html_format? &&
            (illegal_prefix?(@expected) || illegal_prefix?(target))
          side = illegal_prefix?(@expected) ? "expected" : "received"
          raise CanonGuardError, build_message(side)
        end
        super
      end

      private

      # Canon's Comparison already understands DocumentFragment nodes,
      # but NodeParser parses strings as full documents — a multi-root
      # fragment or an empty string then blows up in the :format
      # preprocessing pretty-printer (strict Moxml parse) before the
      # comparator ever runs. Wrap both sides so they parse as one
      # document; the wrapper is shared, so it cannot create false
      # equivalences.
      def compute_equivalent(target)
        if xml_format?
          @expected = wrap_xml_fragment(@expected)
          target = wrap_xml_fragment(target)
        end
        super(target)
      end

      def xml_format?
        @format == :xml
      end

      def wrap_xml_fragment(value)
        return value unless value.is_a?(String)
        return value if already_wrapped?(value)

        wrapped = "<#{XML_FRAG_ROOT}>#{value}</#{XML_FRAG_ROOT}>"
        strict_parse_ok?(wrapped) ? wrapped : recover_wrap(wrapped)
      end

      # Nokogiri's recover-mode parse closes unclosed tags (Word body
      # extracts routinely omit "</body>"). Applied only when the
      # wrapped input is not already well-formed, because the recover
      # round-trip also rewrites entities and can add xml:lang — both
      # harmless when the input is already broken, both destructive
      # when it is not.
      def recover_wrap(wrapped)
        Nokogiri::XML(wrapped).to_xml
      rescue StandardError
        wrapped
      end

      def strict_parse_ok?(xml)
        Canon::XmlParsing.moxml_context.parse(xml, readonly: true, strict: true)
        true
      rescue StandardError
        false
      end

      def already_wrapped?(value)
        value.include?("<#{XML_FRAG_ROOT}") ||
          value.match?(/\A\s*<\?xml\b[^>]*>\s*<#{XML_FRAG_ROOT}/)
      end

      def html_format?
        %i[html html4 html5].include?(@format)
      end

      def illegal_prefix?(value)
        value.is_a?(String) && value.match?(ILLEGAL_HTML_PREFIX)
      end

      def matcher_label
        case @format
        when :html4 then "be_html4_equivalent_to"
        when :html5 then "be_html5_equivalent_to"
        else "be_html_equivalent_to"
        end
      end

      def build_message(side)
        <<~MSG
          #{matcher_label}: the #{side} side begins with an XML
          processing instruction (<?xml ?>).

          Nokogiri::HTML5.fragment parses this as a bogus comment node,
          which shifts fragment child indices and causes Canon's diff
          report to blame elements remote from the actual offending
          node.

          Strip the PI before comparing — e.g. use
          Nokogiri::HTML(...).to_xhtml in place of
          Nokogiri::XML(...).to_xml, or sub it away explicitly.

          This guard is enforced by
          isodoc/spec_helpers/canon_html_input_guard because Canon
          does not surface this condition (see closed PR
          lutaml/canon#124).
        MSG
      end
    end
  end
end

Canon::RSpecMatchers::SerializationMatcher
  .prepend(IsoDoc::SpecHelpers::CanonHtmlInputGuard)
