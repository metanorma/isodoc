require_relative "clause_order"

module IsoDoc
  module XrefGen
    module Sections
      def back_anchor_names(xml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          annex_anchor_names(xml)
          back_clauses_anchor_names(xml)
        end
        if @klass.bibrender && (@parse_settings.empty? || @parse_settings[:refs])
          references(xml)
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

      def references(docxml)
        docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
          reference_names(ref)
        end
      end

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
        n = Counter.new
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
        if use_elem_name && !ret
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
        preface_name_anchors(clause, 1,
                             clause_title(clause, use_elem_name: true))
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          preface_names1(c, c.at(ns("./title"))&.text,
                         "#{clause_title(clause)}, #{i + 1}", 2)
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
        @anchors[clause["id"]] =
          { label: nil, level:,
            xref: title, title: nil,
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
          .each_with_object(Counter.new(0, prefix: "#{num.print}.")) do |c, i|
          section_names1(c, i.increment(c).print, lvl + 1)
        end
        num
      end

      def section_names1(clause, num, level)
        unnumbered_section_name?(clause) and return num
        section_name_anchors(clause, num, level)
        i = Counter.new(0, prefix: "#{num}.")
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

      def section_name_anchors(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, xref: l10n("#{@labels['clause']} #{num}"),
            title: clause_title(clause), level:, type: "clause",
            elem: @labels["clause"] }
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        title = Common::case_with_markup(@labels["annex"], "capital",
                                         @script)
        l10n("<strong>#{title} #{num}</strong><br/>#{obl}")
      end

      def annex_name_anchors(clause, num, level)
        label = num
        level == 1 && clause.name == "annex" and
          label = annex_name_lbl(clause, num)
        @anchors[clause["id"]] =
          { label:,
            elem: @labels["annex"], type: "clause",
            subtype: "annex", value: num.to_s, level:,
            title: clause_title(clause),
            xref: "#{@labels['annex']} #{num}" }
      end

      def annex_names(clause, num)
        annex_name_anchors(clause, num, 1)
        if @klass.single_term_clause?(clause)
          annex_names1(clause.at(ns("./references | ./terms | ./definitions")),
                       num.to_s, 1)
        else
          clause.xpath(ns(SUBCLAUSES))
            .each_with_object(Counter.new(0, prefix: "#{num}.")) do |c, i|
            annex_names1(c, i.increment(c).print, 2)
          end
        end
        hierarchical_asset_names(clause, num)
      end

      def annex_names1(clause, num, level)
        annex_name_anchors(clause, num, level)
        i = Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          annex_names1(c, i.increment(c).print, level + 1)
        end
      end

      def reference_names(ref)
        ids = @klass.bibitem_ref_code(ref)
        identifiers = @klass.render_identifier(ids)
        reference = @klass
          .docid_l10n(identifiers[:metanorma] || identifiers[:sdo] ||
                      identifiers[:ordinal] || identifiers[:doi])
        @anchors[ref["id"]] = { xref: reference }
      end
    end
  end
end
