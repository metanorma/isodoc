require_relative "clause_order"

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

      # preempt clause notes with all other types of note (ISO default)
      def asset_anchor_names(doc)
        (@parse_settings.empty? || @parse_settings[:assets]) or return
        middle_section_asset_names(doc)
        termnote_anchor_names(doc)
        termexample_anchor_names(doc)
        note_anchor_names(doc.xpath(ns("//table | //figure")))
        sections = doc.xpath(ns(sections_xpath))
        note_anchor_names(sections)
        admonition_anchor_names(sections)
        example_anchor_names(sections)
        list_anchor_names(sections)
        deflist_anchor_names(sections)
        bookmark_anchor_names(doc)
      end

      def clause_title(clause, use_elem_name: false)
        ret = clause.at(ns("./title"))&.text
        if use_elem_name && ret.blank?
          @i18n.labels[clause.name]&.capitalize ||
            clause.name.capitalize
        else ret
        end
      end

      SUBCLAUSES =
        "./clause | ./references | ./term  | ./terms | ./definitions".freeze

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
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          preface_names1(c, c.at(ns("./title"))&.text,
                         "#{title}, #{i + 1}", 2)
        end
      end

      def preface_names1(clause, title, parent_title, level)
        label = title || parent_title
        preface_name_anchors(clause, level, title || parent_title)
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          preface_names1(c, c.at(ns("./title"))&.text, "#{label} #{i + 1}",
                         level + 1)
        end
      end

      def preface_name_anchors(clause, level, title)
        xref = "<semx element='#{clause.name}' " \
          "source='#{clause['id']}'>#{title}</semx>"
        @anchors[clause["id"]] =
          { label: nil, level:,
            xref:, title: nil,
            type: "clause", elem: @labels["clause"] }
      end

      def middle_section_asset_names(doc)
        middle_sections =
          "//clause[@type = 'scope'] | #{@klass.norm_ref_xpath} | " \
          "//sections/terms | //preface/* | " \
          "//sections/definitions | //clause[parent::sections]"
        sequential_asset_names(doc.xpath(ns(middle_sections)))
      end

      def section_names(clause, num, lvl)
        unnumbered_section_name?(clause) and return num
        num.increment(clause)
        section_name_anchors(clause, num.print, lvl)
        clause.xpath(ns(SUBCLAUSES))
          .each_with_object(clause_counter(0, prefix: num.print)) do |c, i|
          section_names1(c, i.increment(c).print, lvl + 1)
        end
        num
      end

      def section_names1(clause, num, level)
        unnumbered_section_name?(clause) and return num
        section_name_anchors(clause, num, level)
        i = clause_counter(0, prefix: num)
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          section_names1(c, i.increment(c).print, level + 1)
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

      def labelled_autonum(label, elem, autonum)
        l10n(<<~SEMX)
          <span class='fmt-element-name'>#{label}</span> <semx element='autonum' source='#{elem['id']}'>#{autonum}</semx>
        SEMX
      end

      def section_name_anchors(clause, num, level)
        xref = labelled_autonum(@labels["clause"], clause, num)
        label = "<semx element='autonum' source='#{clause['id']}'>#{num}</semx>"
        @anchors[clause["id"]] =
          { label:, xref:,
            title: clause_title(clause), level:, type: "clause",
            elem: @labels["clause"] }
      end

      def annex_name_lbl(clause, num)
        obl = "(#{@labels['inform_annex']})"
        clause["obligation"] == "normative" and
          obl = "(#{@labels['norm_annex']})"
        title = Common::case_with_markup(@labels["annex"], "capital",
                                         @script)
        s = labelled_autonum(title, clause, num)
        "<strong>#{s}</strong><br/>#{obl}"
      end

      def annex_name_anchors(clause, num, level)
        label = "<semx element='autonum' source='#{clause['id']}'>#{num}</semx>"
        level == 1 && clause.name == "annex" and
          label = annex_name_lbl(clause, num)
        xref = labelled_autonum(@labels["annex"], clause, num)
        @anchors[clause["id"]] =
          { label:, xref:,
            elem: @labels["annex"], type: "clause",
            subtype: "annex", value: num.to_s, level:,
            title: clause_title(clause) }
      end

      def annex_names(clause, num)
        annex_name_anchors(clause, num, 1)
        if @klass.single_term_clause?(clause)
          annex_names1(clause.at(ns("./references | ./terms | ./definitions")),
                       num.to_s, 1)
        else
          clause.xpath(ns(SUBCLAUSES))
            .each_with_object(clause_counter(0, prefix: num)) do |c, i|
            annex_names1(c, i.increment(c).print, 2)
          end
        end
        hierarchical_asset_names(clause, num)
      end

      def annex_names1(clause, num, level)
        annex_name_anchors(clause, num, level)
        i = clause_counter(0, prefix: num)
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          annex_names1(c, i.increment(c).print, level + 1)
        end
      end
    end
  end
end
