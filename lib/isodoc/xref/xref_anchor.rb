require "singleton"

module IsoDoc
  module XrefGen
    module Anchor
      class SeenAnchor
        def initialize(xmldoc)
          @seen = {}
          # ignore all metanorma-extension ids
          xmldoc.xpath("//xmlns:metanorma-extension//*[@id]").each do |x|
            add(x["id"])
          end
        end

        def seen(elem)
          @seen.has_key?(elem)
        end

        def add(elem)
          @seen[elem] = true
        end
      end

      def initialize
        @anchors = {}
      end

      def get_anchors
        @anchors
      end

      def anchor_struct_label(lbl, elem)
        case elem
        when @labels["appendix"] then "#{elem} #{lbl}"
        else
          lbl.to_s
        end
      end

      def anchor_struct_xref(lbl, elem)
        l10n("#{elem} #{anchor_struct_value(lbl, elem)}")
      end

      def anchor_struct_value(lbl, elem)
        case elem
        when @labels["formula"], @labels["inequality"] then "(#{lbl})"
        else
          lbl
        end
      end

      def anchor_struct(lbl, container, elem, type, unnumb = false)
        ret = {}
        ret[:label] = unnumb == "true" ? nil : anchor_struct_label(lbl, elem)
        ret[:xref] = anchor_struct_xref(unnumb == "true" ? "(??)" : lbl, elem)
        ret[:xref].gsub!(/ $/, "")
        ret[:container] = @klass.get_clause_id(container) unless container.nil?
        ret[:type] = type
        ret[:elem] = elem
        ret[:value] = anchor_struct_value(lbl, elem)
        ret
      end
    end
  end
end
