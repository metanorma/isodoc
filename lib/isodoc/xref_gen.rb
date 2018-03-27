require "roman-numerals"

module IsoDoc
  class Convert
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
          @anchors[n["id"]] =
            { label: (i + 1).to_s,
              xref: l10n("#{@anchors[t['id']][:xref]}, "\
                         "#{@note_xref_lbl} #{i + 1}") }
        end
      end
    end

    SECTIONS_XPATH =
      "//foreword | //introduction | //sections/terms | //annex | "\
      "//sections/clause | //references[not(ancestor::clause)] | "\
      "//clause[descendant::references][not(ancestor::clause)]".freeze

    CHILD_NOTES_XPATH =
      "./*[not(self::xmlns:subclause)]//xmlns:note | ./xmlns:note".freeze

    def note_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_NOTES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          next if n["id"].nil?
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @note_xref_lbl)
        end
        note_anchor_names(s.xpath(ns("./subclause")))
      end
    end

    CHILD_EXAMPLES_XPATH =
      "./*[not(self::xmlns:subclause)]//xmlns:example | "\
      "./xmlns:example".freeze

    def example_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_EXAMPLES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @example_xref_lbl)
        end
        example_anchor_names(s.xpath(ns("./subclause")))
      end
    end

    def list_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//subclause//ol")) -
          s.xpath(ns(".//ol//ol"))
        notes.each_with_index do |n, i|
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = anchor_struct(idx, s, @list_lbl)
          list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
        end
        list_anchor_names(s.xpath(ns("./subclause")))
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

    def middle_anchor_names(docxml)
      symbols_abbrevs = docxml.at(ns("//sections/symbols-abbrevs"))
      sect_num = 4
      if symbols_abbrevs
        section_names(symbols_abbrevs, sect_num.to_s, 1)
        sect_num += 1
      end
      clause_names(docxml, sect_num)
      termnote_anchor_names(docxml)
      termexample_anchor_names(docxml)
    end

    # extract names for all anchors, xref and label
    def anchor_names(docxml)
      initial_anchor_names(docxml)
      middle_anchor_names(docxml)
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
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl)
      end
    end

    def anchor_struct(lbl, container, elem)
      ret = { label: lbl.to_s }
      ret[:xref] =
        elem == "Formula" ? l10n("#{elem} (#{lbl})") : l10n("#{elem} #{lbl}")
      ret[:xref].gsub!(/ $/, "")
      ret[:container] = get_clause_id(container) unless container.nil?
      ret
    end

    def sequential_asset_names(clause)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        @anchors[t["id"]] = anchor_struct(i + 1, nil, @table_lbl)
      end
      sequential_figure_names(clause)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
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
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl)
      end
    end

    def hierarchical_asset_names(clause, num)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        @anchors[t["id"]] = anchor_struct("#{num}.#{i + 1}", nil, @table_lbl)
      end
      hierarchical_figure_names(clause, num)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
        @anchors[t["id"]] = anchor_struct("#{num}.#{i + 1}", t, @formula_lbl)
      end
    end
  end
end
