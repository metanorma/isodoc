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
      docxml.xpath(ns("//term[termnote]")).each do |t|
        t.xpath(ns("./termnote")).each_with_index do |n, i|
          return if n["id"].nil? || n["id"].empty?
          @anchors[n["id"]] =
            { label: termnote_label(i + 1),
              xref: l10n("#{@anchors[t['id']][:xref]}, "\
                         "#{@note_xref_lbl} #{i + 1}") }
        end
      end
    end

    def termexample_anchor_names(docxml)
      docxml.xpath(ns("//term[termexample]")).each do |t|
        t.xpath(ns("./termexample")).each_with_index do |n, i|
          return if n["id"].nil? || n["id"].empty?
          @anchors[n["id"]] =
            { label: (i + 1).to_s,
              xref: l10n("#{@anchors[t['id']][:xref]}, "\
                         "#{@note_xref_lbl} #{i + 1}") }
        end
      end
    end

    SECTIONS_XPATH =
      "//foreword | //introduction | //sections/terms | //annex | "\
      "//sections/clause | //bibliography/references | "\
      "//bibliography/clause".freeze

    CHILD_NOTES_XPATH =
      "./*[not(self::xmlns:clause) and "\
      "not(self::xmlns:appendix)]//xmlns:note | ./xmlns:note".freeze

    def note_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_NOTES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @note_xref_lbl)
        end
        note_anchor_names(s.xpath(ns("./clause | ./appendix")))
      end
    end

    CHILD_EXAMPLES_XPATH =
      "./*[not(self::xmlns:clause) and not(self::xmlns:appendix)]//"\
      "xmlns:example | ./xmlns:example".freeze

    def example_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_EXAMPLES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @example_xref_lbl)
        end
        example_anchor_names(s.xpath(ns("./clause | ./appendix")))
      end
    end

    def list_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
          s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
        notes.each_with_index do |n, i|
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @list_lbl)
          list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
        end
        list_anchor_names(s.xpath(ns("./clause | ./appendix")))
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
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl)
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

    def anchor_struct(lbl, container, elem)
      ret = {}
      ret[:label] = anchor_struct_label(lbl, elem)
      ret[:xref] = anchor_struct_xref(lbl, elem)
      ret[:xref].gsub!(/ $/, "")
      ret[:container] = get_clause_id(container) unless container.nil?
      ret
    end

    def sequential_asset_names(clause)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
          next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, nil, @table_lbl)
      end
      sequential_figure_names(clause)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
          next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(i + 1, t, @formula_lbl)
      end
    end

    def hierarchical_figure_names(clause, num)
      i = j = 0
      clause.xpath(ns(".//figure")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          i += 1
        end
        label = "#{num}.#{i}" + (j.zero? ? "" : "-#{j}")
          next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl)
      end
    end

    def hierarchical_asset_names(clause, num)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
          next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct("#{num}.#{i + 1}", nil, @table_lbl)
      end
      hierarchical_figure_names(clause, num)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
          next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct("#{num}.#{i + 1}", t, @formula_lbl)
      end
    end
  end
end
