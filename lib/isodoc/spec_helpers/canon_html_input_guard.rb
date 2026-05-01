# frozen_string_literal: true

require "canon"

# Guard against leading "<?xml ?>" processing instructions in HTML
# input strings passed to Canon's be_html_equivalent_to /
# be_html4_equivalent_to / be_html5_equivalent_to matchers.
#
# WHY: Nokogiri::HTML5.fragment parses a leading "<?xml ?>" as a bogus
# Nokogiri::XML::Comment at index 0 of the fragment.  In Canon's
# verbose mode (used by the matchers) comments are intentionally not
# filtered, so the bogus comment shifts fragment child indices and
# causes Canon's diff report to blame elements at the tail of the
# document for an offence at the head — an "uninterpretable report"
# remote from the actual cause.  Canon's maintainer has chosen not to
# normalise this at the input boundary (closed PR lutaml/canon#124);
# this guard is the local defence.
#
# WHEN: required for the side effect.  Requiring this file installs a
# Module#prepend on Canon::RSpecMatchers::SerializationMatcher's
# matches? method that raises IsoDoc::SpecHelpers::CanonGuardError if
# either side of an HTML-format comparison begins with an XML PI.
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
    # intercept matches? before Canon's own implementation runs.
    module CanonHtmlInputGuard
      ILLEGAL_HTML_PREFIX = /\A\s*<\?xml\b/i.freeze

      def matches?(target)
        if html_format? &&
            (illegal_prefix?(@expected) || illegal_prefix?(target))
          side = illegal_prefix?(@expected) ? "expected" : "received"
          raise CanonGuardError, build_message(side)
        end
        super
      end

      private

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
