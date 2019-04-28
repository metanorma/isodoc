require "roman-numerals"

module IsoDoc::Function
  module XrefGen

    @anchors = {}

    def get_anchors
      @anchors
    end

    def termnote_label(n)
      @termnote_lbl.gsub(/%/, n.to_s)
    end

    def termnote_anchor_names(docxml)
      docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
        t.xpath(ns(".//termnote")).each_with_index do |n, i|
          return if n["id"].nil? || n["id"].empty?
          @anchors[n["id"]] =
            { label: termnote_label(i + 1),
              type: "termnote",
              xref: l10n("#{@anchors.dig(t['id'], :xref)}, "\
                         "#{@note_xref_lbl} #{i + 1}") }
        end
      end
    end

    def termexample_anchor_names(docxml)
      docxml.xpath(ns("//term[descendant::termexample]")).each do |t|
        examples = t.xpath(ns(".//termexample"))
        examples.each_with_index do |n, i|
          return if n["id"].nil? || n["id"].empty?
          idx = examples.size == 1 ? "" : (i + 1).to_s
          @anchors[n["id"]] = {
            type: "termexample",
            label: idx, xref: l10n("#{@anchors.dig(t['id'], :xref)}, "\
                                   "#{@note_xref_lbl} #{i + 1}") }
        end
      end
    end

    SECTIONS_XPATH =
      "//foreword | //introduction | //sections/terms | //annex | "\
      "//sections/clause | //sections/definitions | "\
      "//bibliography/references | //bibliography/clause".freeze

    CHILD_NOTES_XPATH =
      "./*[not(self::xmlns:clause) and not(self::xmlns:appendix) and "\
      "not(self::xmlns:terms) and not(self::xmlns:definitions)]//xmlns:note | "\
      "./xmlns:note".freeze

    def note_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_NOTES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, n, @note_xref_lbl, "note")
        end
        note_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
      end
    end

    CHILD_EXAMPLES_XPATH =
      "./*[not(self::xmlns:clause) and not(self::xmlns:appendix) and "\
      "not(self::xmlns:terms) and not(self::xmlns:definitions)]//"\
      "xmlns:example | ./xmlns:example".freeze

    CHILD_SECTIONS = "./clause | ./appendix | ./terms | ./definitions"

    def example_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_EXAMPLES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, n, @example_xref_lbl,
                                            "example")
        end
        example_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
      end
    end

    def list_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
          s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
        notes.each_with_index do |n, i|
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, n, @list_lbl, "list")
          list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
        end
        list_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
      end
    end

    def listlabel(depth, i)
      return i.to_s if [2, 7].include? depth
      return (96 + i).chr.to_s if [1, 6].include? depth
      return (64 + i).chr.to_s if [4, 9].include? depth
      return RomanNumerals.to_roman(i).downcase if [3, 8].include? depth
      return RomanNumerals.to_roman(i).upcase if [5, 10].include? depth
      return i.to_s
    end

    def list_item_anchor_names(list, list_anchor, depth, prev_label, refer_list)
      list.xpath(ns("./li")).each_with_index do |li, i|
        label = listlabel(depth, i + 1)
        label = "#{prev_label}.#{label}" unless prev_label.empty?
        label = "#{list_anchor[:xref]} #{label}" if refer_list
        li["id"] && @anchors[li["id"]] = { xref: "#{label})",
                                           type: "listitem",
                                           container: list_anchor[:container] }
        li.xpath(ns("./ol")).each do |ol|
          list_item_anchor_names(ol, list_anchor, depth + 1, label, false)
        end
      end
    end

    # extract names for all anchors, xref and label
    def anchor_names(docxml)
      initial_anchor_names(docxml)
      back_anchor_names(docxml)
      # preempt clause notes with all other types of note
      note_anchor_names(docxml.xpath(ns("//table | //example | //formula | "\
                                        "//figure")))
      note_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      example_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      list_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
    end

    def sequential_figure_names(clause)
      i = j = 0
      clause.xpath(ns(".//figure")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          i += 1
        end
        label = i.to_s + (j.zero? ? "" : "-#{j}")
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl, "figure")
      end
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
      else
        l10n("#{elem} #{lbl}")
      end
    end

    def anchor_struct(lbl, container, elem, type)
      ret = {}
      ret[:label] = anchor_struct_label(lbl, elem)
      ret[:xref] = anchor_struct_xref(lbl, elem)
      ret[:xref].gsub!(/ $/, "")
      ret[:container] = get_clause_id(container) unless container.nil?
      ret[:type] = type
      ret
    end

    def sequential_table_names(clause)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, nil, @table_lbl, "table")
      end
    end

    def sequential_formula_names(clause)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, t, @formula_lbl, "formula")
      end
    end

    FIRST_LVL_REQ = "[not(ancestor::permission or ancestor::requirement or ancestor::recommendation)]".freeze

    def sequential_permission_names(clause)
      clause.xpath(ns(".//permission#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, t, @permission_lbl, "permission")
        sequential_permission_names1(t, i + 1)
        sequential_requirement_names1(t, i + 1)
        sequential_recommendation_names1(t, i + 1)
      end
    end

    def sequential_permission_names1(block, lbl)
      block.xpath(ns("./permission")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        newlbl = "#{lbl}#{hierfigsep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(newlbl, t, @permission_lbl, "permission")
        sequential_permission_names1(t, newlbl)
        sequential_requirement_names1(t, newlbl)
        sequential_recommendation_names1(t, newlbl)
      end
    end

    def sequential_requirement_names(clause)
      clause.xpath(ns(".//requirement#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, t, @requirement_lbl, "requirement")
        sequential_permission_names1(t, i + 1)
        sequential_requirement_names1(t, i + 1)
        sequential_recommendation_names1(t, i + 1)
      end
    end

    def sequential_requirement_names1(block, lbl)
      block.xpath(ns("./requirement")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        newlbl = "#{lbl}#{hierfigsep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(newlbl, t, @requirement_lbl, "requirement")
        sequential_permission_names1(t, newlbl)
        sequential_requirement_names1(t, newlbl)
        sequential_recommendation_names1(t, newlbl)
      end
    end

    def sequential_recommendation_names(clause)
      clause.xpath(ns(".//recommendation#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, t, @recommendation_lbl, "recommendation")
        sequential_permission_names1(t, i + 1)
        sequential_requirement_names1(t, i + 1)
        sequential_recommendation_names1(t, i + 1)
      end
    end

    def sequential_recommendation_names1(block, lbl)
      block.xpath(ns("./recommendation")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        newlbl = "#{lbl}#{hierfigsep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(newlbl, t, @recommendation_lbl, "recommendation")
        sequential_permission_names1(t, newlbl)
        sequential_requirement_names1(t, newlbl)
        sequential_recommendation_names1(t, newlbl)
      end
    end

    def sequential_asset_names(clause)
      sequential_table_names(clause)
      sequential_figure_names(clause)
      sequential_formula_names(clause)
      sequential_permission_names(clause)
      sequential_requirement_names(clause)
      sequential_recommendation_names(clause)
    end

    def hiersep
      "."
    end

    def hierfigsep
      "-"
    end

    def hierarchical_figure_names(clause, num)
      i = j = 0
      clause.xpath(ns(".//figure")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          i += 1
        end
        label = "#{num}#{hiersep}#{i}" + (j.zero? ? "" : "#{hierfigsep}#{j}")
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl, "figure")
      end
    end

    def hierarchical_table_names(clause, num)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct("#{num}#{hiersep}#{i + 1}",
                                          nil, @table_lbl, "table")
      end
    end

    def hierarchical_asset_names(clause, num)
      hierarchical_table_names(clause, num)
      hierarchical_figure_names(clause, num)
      hierarchical_formula_names(clause, num)
      hierarchical_permission_names(clause, num)
      hierarchical_requirement_names(clause, num)
      hierarchical_recommendation_names(clause, num)
    end

    def hierarchical_formula_names(clause, num)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct("#{num}#{hiersep}#{i + 1}",
                                          t, @formula_lbl, "formula")
      end
    end

    def hierarchical_permission_names(clause, num)
      clause.xpath(ns(".//permission#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        lbl = "#{num}#{hiersep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(lbl, t, @permission_lbl, "permission")
        sequential_permission_names1(t, lbl)
        sequential_requirement_names1(t, lbl)
        sequential_recommendation_names1(t, lbl)
      end
    end

    def hierarchical_requirement_names(clause, num)
      clause.xpath(ns(".//requirement#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        lbl = "#{num}#{hiersep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(lbl, t, @requirement_lbl, "requirement")
        sequential_permission_names1(t, lbl)
        sequential_requirement_names1(t, lbl)
        sequential_recommendation_names1(t, lbl)
      end
    end

    def hierarchical_recommendation_names(clause, num)
      clause.xpath(ns(".//recommendation#{FIRST_LVL_REQ}")).each_with_index do |t, i|
        next if t["id"].nil? || t["id"].empty?
        lbl = "#{num}#{hiersep}#{i + 1}"
        @anchors[t["id"]] = anchor_struct(lbl, t, @recommendation_lbl, "recommendation")
        sequential_permission_names1(t, lbl)
        sequential_requirement_names1(t, lbl)
        sequential_recommendation_names1(t, lbl)
      end
    end
  end
end
