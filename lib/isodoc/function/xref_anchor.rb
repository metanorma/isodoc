require "singleton"

module IsoDoc::Function
  module XrefGen
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

    @anchors = {}

    def get_anchors
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

    def anchor_struct_label(lbl, elem)
      case elem
      when @appendix_lbl then l10n("#{elem} #{lbl}")
      else
        lbl.to_s
      end
    end

    def anchor_struct_xref(lbl, elem)
      case elem
      when @formula_lbl then l10n("#{elem} (#{lbl})")
      when @inequality_lbl then l10n("#{elem} (#{lbl})")
      else
        l10n("#{elem} #{lbl}")
      end
    end

    def anchor_struct(lbl, container, elem, type, unnumbered = false)
      ret = {}
      ret[:label] = unnumbered == "true" ? nil : anchor_struct_label(lbl, elem)
      ret[:xref] = anchor_struct_xref(unnumbered == "true" ? "(??)" : lbl, elem)
      ret[:xref].gsub!(/ $/, "")
      ret[:container] = get_clause_id(container) unless container.nil?
      ret[:type] = type
      ret
    end
  end
end
