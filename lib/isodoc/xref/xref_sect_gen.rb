require_relative "clause_order"
require_relative "xref_sect_asset"

module IsoDoc
  module XrefGen
    module Sections
      def back_anchor_names(xml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          annex_anchor_names(xml)
          back_clauses_anchor_names(xml)
        end
      end

      def annex_anchor_names(xml)
        i = Counter.new("@")
        clause_order_annex(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            unnumbered_section_name?(c) and next
            annex_names(c, i.increment(c).print)
            a[:multi] or break
          end
        end
      end

      def back_clauses_anchor_names(xml)
        clause_order_back(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            back_names(c)
            a[:multi] or break
          end
        end
      end

      # NOTE: references processing has moved to Presentation XML

      def initial_anchor_names(xml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          preface_anchor_names(xml)
          main_anchor_names(xml)
        end
      end

      def preface_anchor_names(xml)
        clause_order_preface(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            preface_names(c)
            a[:multi] or break
          end
        end
      end

      def main_anchor_names(xml)
        n = clause_counter
        clause_order_main(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            section_names(c, n, 1)
            a[:multi] or break
          end
        end
      end

      def clause_title(clause, use_elem_name: false)
        ret = clause.at(ns("./title"))&.text
        if use_elem_name && ret.blank?
          @i18n.labels[clause.name]&.capitalize ||
            clause.name.capitalize
        else ret
        end
      end

      # in StanDoc, prefaces have no numbering; they are referenced only by title
      def preface_names(clause)
        unnumbered_names(clause)
      end

      def back_names(clause)
        unnumbered_names(clause)
        sequential_asset_names(
          Nokogiri::XML::NodeSet.new(clause.document, [clause]),
          container: true,
        )
      end

      def unnumbered_names(clause)
        clause.nil? and return
        title = clause_title(clause, use_elem_name: true)
        preface_name_anchors(clause, 1, title)
        clause.xpath(ns(subclauses)).each_with_index do |c, i|
          t = c.at(ns("./title"))
          tt = "#{semx(clause, title, clause.name)}" \
            "<span class='fmt-comma'>,</span> #{semx(c, i + 1)}"
          preface_names1(c, t ? semx(c, t.text, c.name) : nil, tt, 2)
        end
      end

      def preface_names1(clause, title, parent_title, level)
        label = title || parent_title
        preface_name_anchors(clause, level, title || parent_title)
        clause.xpath(ns(subclauses)).each_with_index do |c, i|
          t = c.at(ns("./title"))
          preface_names1(c, t ? semx(c, t.text, c.name) : nil,
                         "#{label} #{semx(c, i + 1)}",
                         level + 1)
        end
      end

      def preface_name_anchors(clause, level, title)
        xref = semx(clause, title, clause.name)
        #clause["id"] ||= "_#{UUIDTools::UUID.random_create}"
        @anchors[clause["id"]] =
          { label: nil, level:,
            xref:, title: nil,
            type: "clause", elem: @labels["clause"] }
      end

      def section_names(clause, num, lvl)
        unnumbered_section_name?(clause) and return num
        num.increment(clause)
        lbl = semx(clause, num.print)
        section_name_anchors(clause, lbl, lvl)
        clause.xpath(ns(subclauses))
          .each_with_object(clause_counter(0)) do |c, i|
          section_names1(c, lbl, i.increment(c).print, lvl + 1)
        end
        num
      end

      def clause_number_semx(parentnum, clause, num)
        if clause["branch-number"]
          semx(clause, clause["branch-number"])
        elsif parentnum.nil?
          semx(clause, num)
        else
          "#{parentnum}#{delim_wrap(clausesep)}#{semx(clause, num)}"
        end
      end

      def section_names1(clause, parentnum, num, level)
        unnumbered_section_name?(clause) and return num
        lbl = clause_number_semx(parentnum, clause, num)
        section_name_anchors(clause, lbl, level)
        i = clause_counter(0)
        clause.xpath(ns(subclauses)).each do |c|
          section_names1(c, lbl, i.increment(c).print, level + 1)
        end
      end

      def unnumbered_section_name?(clause)
        clause.nil? and return true
        if clause["unnumbered"] == "true"
          unnumbered_names(clause)
          return true
        end
        false
      end

      def clausesep
        "."
      end

      def section_name_anchors(clause, num, level)
        xref = labelled_autonum(@labels["clause"], num)
        label = num
        c = clause_title(clause) and title = semx(clause, c, "title")
        #clause["id"] ||= "_#{UUIDTools::UUID.random_create}"
        @anchors[clause["id"]] =
          { label:, xref:, title:, level:, type: "clause",
            elem: @labels["clause"] }
      end

      def annex_name_lbl(clause, num)
        obl = "(#{@labels['inform_annex']})"
        clause["obligation"] == "normative" and
          obl = "(#{@labels['norm_annex']})"
        obl = "<span class='fmt-obligation'>#{l10n obl}</fmt>"
        title = Common::case_with_markup(@labels["annex"], "capital",
                                         @script)
        s = labelled_autonum(title, num)
        "<strong><span class='fmt-caption-label'>#{s}</span></strong><br/>#{obl}"
      end

      def annex_name_anchors(clause, num, level)
        label = num
        level == 1 && clause.name == "annex" and
          label = annex_name_lbl(clause, label)
        c = clause_title(clause) and title = semx(clause, c, "title")
        #clause["id"] ||= "_#{UUIDTools::UUID.random_create}"
        @anchors[clause["id"]] =
          { label:, xref: labelled_autonum(@labels["annex"], num), title:,
            elem: @labels["annex"], type: "clause",
            subtype: "annex", value: num.to_s, level: }
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        label = semx(clause, num)
        annex_name_anchors(clause, label, 1)
        if @klass.single_term_clause?(clause)
          annex_names1(clause.at(ns("./references | ./terms | ./definitions")),
                       nil, num.to_s, 1)
        else
          clause.xpath(ns(subclauses))
            .each_with_object(clause_counter(0)) do |c, i|
            annex_names1(c, label, i.increment(c).print, 2)
          end
        end
        hierarchical_asset_names(clause, label)
      end

      def annex_names1(clause, parentnum, num, level)
        lbl = clause_number_semx(parentnum, clause, num)
        annex_name_anchors1(clause, lbl, level)
        i = clause_counter(0)
        clause.xpath(ns(subclauses)).each do |c|
          annex_names1(c, lbl, i.increment(c).print, level + 1)
        end
      end

      # subclauses of Annexes
      def annex_name_anchors1(clause, num, level)
        annex_name_anchors(clause, num, level)
      end

      def appendix_names(clause, _num)
        i = clause_counter(0)
        clause.xpath(ns("./appendix")).each do |c|
          i.increment(c)
          num = semx(c, i.print)
          lbl = labelled_autonum(@labels["appendix"], num)
          @anchors[c["id"]] =
            anchor_struct(i.print, c, @labels["appendix"],
                          "clause").merge(level: 2, subtype: "annex",
                                          container: clause["id"])
          j = clause_counter(0)
          c.xpath(ns("./clause | ./references")).each do |c1|
            appendix_names1(c1, lbl, j.increment(c1).print, 3, clause["id"])
          end
        end
      end

      def appendix_names1(clause, parentnum, num, level, container)
        num = clause_number_semx(parentnum, clause, num)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   container: container }
        i = clause_counter(0)
        clause.xpath(ns("./clause | ./references")).each do |c|
          appendix_names1(c, num, i.increment(c).print, level + 1, container)
        end
      end
    end
  end
end
