require "singleton"
require_relative "xref_util"

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

      def anchor_struct_label(lbl, node, elem)
        case elem
        when @labels["appendix"]
          s = "<semx element='autonum' source='#{node['id'] || node[:id]}'>" \
            "#{lbl}</semx>"
          "<span class='fmt-element-name'>#{elem}</span> #{s}"
        else
          anchor_struct_value(lbl, elem)
        end
      end

      def anchor_struct_xref(lbl, node, elem)
        unless lbl.blank?
          lbl = semx(node, lbl)
          s = " #{anchor_struct_value(lbl, elem)}"
        end
        "<span class='fmt-element-name'>#{elem}</span>#{s}".gsub(/ $/, "")
      end

      def anchor_struct_value(lbl, elem)
        case elem
          # TODO hardcoded ( ) ?
        when @labels["formula"], @labels["inequality"] then <<~SPAN.strip
          #{delim_wrap('(')}#{lbl}#{delim_wrap(')')}
        SPAN
        else
          lbl.to_s
        end
      end

      # def anchor_struct(lbl, container, elem, type, unnumb = false)
      def anchor_struct(lbl, node, elem_name, type, opt = {})
        ret = { type: type, elem: elem_name, label: nil }
        opt[:unnumb] != "true" and
          ret[:label] = anchor_struct_label(lbl, node, elem_name)
        ret[:xref] =
          anchor_struct_xref(opt[:unnumb] == "true" ? "(??)" : lbl, node,
                             elem_name)
        ret[:container] = @klass.get_clause_id(node) if opt[:container]
        ret[:value] = stripsemx(lbl)
        t = asset_title(node) and ret[:title] = t
        ret
      end

      # Caption of a numbered asset (its <name>, or a modspec requirement's
      # <title>), semx-wrapped, so that xrefstyle=full can render
      # "Table 3, caption" the way clauses render "Clause 6, Title". Returns nil
      # when the asset has no caption, so anchor_xref_full falls back to short.
      def asset_title(node)
        n = node.at(ns("./name")) || node.at(ns("./title")) or return nil
        semx(node, n.children.to_xml, n.name)
      end

      include ::IsoDoc::XrefGen::Util
    end
  end
end
