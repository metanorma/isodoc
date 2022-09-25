module IsoDoc
  module XrefGen
    module Sections
      def back_anchor_names(docxml)
        if @parse_settings.empty? || @parse_settings[:clauses]
          i = Counter.new("@")
          docxml.xpath(ns("//annex")).each do |c|
            annex_names(c, i.increment(c).print)
          end
          docxml.xpath(ns(@klass.bibliography_xpath)).each do |b|
            preface_names(b)
          end
        end
        references(docxml) if @parse_settings.empty? || @parse_settings[:refs]
      end

      def references(docxml)
        docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
          reference_names(ref)
        end
      end

      def initial_anchor_names(doc)
        if @parse_settings.empty? || @parse_settings[:clauses]
          doc.xpath(ns("//preface/*")).each do |c|
            c.element? and preface_names(c)
          end
          # potentially overridden in middle_section_asset_names()
          sequential_asset_names(doc.xpath(ns("//preface/*")))
          n = Counter.new
          n = section_names(doc.at(ns("//clause[@type = 'scope']")), n, 1)
          n = section_names(doc.at(ns(@klass.norm_ref_xpath)), n, 1)
          n = section_names(doc.at(ns("//sections/terms | "\
                                      "//sections/clause[descendant::terms]")), n, 1)
          n = section_names(doc.at(ns("//sections/definitions")), n, 1)
          clause_names(doc, n)
        end
      end

      # preempt clause notes with all other types of note (ISO default)
      def asset_anchor_names(doc)
        @parse_settings.empty? or return
        middle_section_asset_names(doc)
        termnote_anchor_names(doc)
        termexample_anchor_names(doc)
        note_anchor_names(doc.xpath(ns("//table | //figure")))
        note_anchor_names(doc.xpath(ns(sections_xpath)))
        example_anchor_names(doc.xpath(ns(sections_xpath)))
        list_anchor_names(doc.xpath(ns(sections_xpath)))
        deflist_anchor_names(doc.xpath(ns(sections_xpath)))
        bookmark_anchor_names(doc)
      end

      def preface_clause_name(clause)
        clause.at(ns("./title"))&.text || clause.name.capitalize
      end

      SUBCLAUSES =
        "./clause | ./references | ./term  | ./terms | ./definitions".freeze

      # in StanDoc, prefaces have no numbering; they are referenced only by title
      def preface_names(clause)
        return if clause.nil?

        @anchors[clause["id"]] =
          { label: nil, level: 1, xref: preface_clause_name(clause),
            type: "clause", elem: @labels["clause"] }
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          preface_names1(c, c.at(ns("./title"))&.text,
                         "#{preface_clause_name(clause)}, #{i + 1}", 2)
        end
      end

      def preface_names1(clause, title, parent_title, level)
        label = title || parent_title
        @anchors[clause["id"]] = { label: nil, level: level, xref: label,
                                   type: "clause", elem: @labels["clause"] }
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          preface_names1(c, c.at(ns("./title"))&.text, "#{label} #{i + 1}",
                         level + 1)
        end
      end

      def middle_section_asset_names(doc)
        middle_sections = "//clause[@type = 'scope'] | "\
                          "#{@klass.norm_ref_xpath} | "\
                          "//sections/terms | //preface/* | "\
                          "//sections/definitions | //clause[parent::sections]"
        sequential_asset_names(doc.xpath(ns(middle_sections)))
      end

      def clause_names(docxml, num)
        docxml.xpath(ns(@klass.middle_clause(docxml))).each_with_index do |c, _i|
          section_names(c, num, 1)
        end
      end

      def section_names(clause, num, lvl)
        return num if clause.nil?

        num.increment(clause)
        @anchors[clause["id"]] =
          { label: num.print, xref: l10n("#{@labels['clause']} #{num.print}"),
            level: lvl, type: "clause", elem: @labels["clause"] }
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          section_names1(c, "#{num.print}.#{i.increment(c).print}", lvl + 1)
        end
        num
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: l10n("#{@labels['clause']} #{num}"),
            type: "clause", elem: @labels["clause"] }
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          section_names1(c, "#{num}.#{i.increment(c).print}", level + 1)
        end
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        title = Common::case_with_markup(@labels["annex"], "capital", @script)
        l10n("<strong>#{title} #{num}</strong><br/>#{obl}")
      end

      def annex_name_anchors(clause, num)
        { label: annex_name_lbl(clause, num),
          elem: @labels["annex"], type: "clause",
          subtype: "annex", value: num.to_s, level: 1,
          xref: "#{@labels['annex']} #{num}" }
      end

      def annex_names(clause, num)
        @anchors[clause["id"]] = annex_name_anchors(clause, num)
        if @klass.single_term_clause?(clause)
          annex_names1(clause.at(ns("./references | ./terms | ./definitions")),
                       num.to_s, 1)
        else
          i = Counter.new
          clause.xpath(ns(SUBCLAUSES)).each do |c|
            annex_names1(c, "#{num}.#{i.increment(c).print}", 2)
          end
        end
        hierarchical_asset_names(clause, num)
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { xref: "#{@labels['annex']} #{num}",
                                   elem: @labels["annex"], type: "clause",
                                   label: num, level: level, subtype: "annex" }
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          annex_names1(c, "#{num}.#{i.increment(c).print}", level + 1)
        end
      end

      ISO_PUBLISHER_XPATH =
        "./contributor[xmlns:role/@type = 'publisher']/"\
        "organization[abbreviation = 'ISO' or xmlns:abbreviation = 'IEC' or "\
        "xmlns:name = 'International Organization for Standardization' or "\
        "xmlns:name = 'International Electrotechnical Commission']".freeze

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
