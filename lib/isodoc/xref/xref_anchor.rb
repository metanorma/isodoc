require "singleton"

module IsoDoc::XrefGen
  module Anchor
    class Seen_Anchor
      include Singleton

      def initialize
        @seen = {}
      end

      def seen(x)
        @seen.has_key?(x)
      end

      def add(x)
        @seen[x] = true
      end
    end

    def initialize()
      @anchors = {}
    end

    def get_anchors
      @anchors
    end

    def anchor_struct_label(lbl, elem)
      case elem
      when @labels["appendix"] then l10n("#{elem} #{lbl}")
      else
        lbl.to_s
      end
    end

    def anchor_struct_xref(lbl, elem)
      case elem
      when @labels["formula"] then l10n("#{elem} (#{lbl})")
      when @labels["inequality"] then l10n("#{elem} (#{lbl})")
      else
        l10n("#{elem} #{lbl}")
      end
    end

    def anchor_struct(lbl, container, elem, type, unnumbered = false)
      ret = {}
      ret[:label] = unnumbered == "true" ? nil : anchor_struct_label(lbl, elem)
      ret[:xref] = anchor_struct_xref(unnumbered == "true" ? "(??)" : lbl, elem)
      ret[:xref].gsub!(/ $/, "")
      ret[:container] = @klass.get_clause_id(container) unless container.nil?
      ret[:type] = type
      ret
    end
  end
end
