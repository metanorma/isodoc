module IsoDoc
  module XrefGen
    module Sections
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

      def middle_section_asset_names(doc)
        middle_sections =
          "//clause[@type = 'scope'] | #{@klass.norm_ref_xpath} | " \
          "//sections/terms | //preface/* | " \
          "//sections/definitions | //clause[parent::sections]"
        sequential_asset_names(doc.xpath(ns(middle_sections)))
      end

      # container makes numbering be prefixed with the parent clause reference
      def sequential_asset_names(clause, container: false)
        sequential_table_names(clause, container:)
        sequential_figure_names(clause, container:)
        sequential_formula_names(clause, container:)
        sequential_permission_names(clause, container:)
      end

      def hierarchical_asset_names(clause, num)
        hierarchical_table_names(clause, num)
        hierarchical_figure_names(clause, num)
        hierarchical_formula_names(clause, num)
        hierarchical_permission_names(clause, num)
      end
    end
  end
end
