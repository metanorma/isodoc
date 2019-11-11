require_relative "xref_counter"
require_relative "xref_anchor"

module IsoDoc::Function
  module XrefGen
    def termnote_label(n)
      @termnote_lbl.gsub(/%/, n.to_s)
    end

    def termnote_anchor_names(docxml)
      docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
        c = Counter.new
        t.xpath(ns(".//termnote")).each do |n|
          return if n["id"].nil? || n["id"].empty?
          c.increment(n)
          @anchors[n["id"]] =
            { label: termnote_label(c.print), type: "termnote",
              xref: l10n("#{anchor(t['id'], :xref)}, "\
                         "#{@note_xref_lbl} #{c.print}") }
        end
      end
    end

    def termexample_anchor_names(docxml)
      docxml.xpath(ns("//term[descendant::termexample]")).each do |t|
        examples = t.xpath(ns(".//termexample"))
        c = Counter.new
        examples.each do |n|
          return if n["id"].nil? || n["id"].empty?
          c.increment(n)
          idx = examples.size == 1 ? "" : c.print
          @anchors[n["id"]] = {
            type: "termexample", label: idx, 
            xref: l10n("#{anchor(t['id'], :xref)}, "\
                                   "#{@example_xref_lbl} #{c.print}") }
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
        c = Counter.new
        notes.each do |n|
          next if @anchors[n["id"]] || n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
          @anchors[n["id"]] = anchor_struct(idx, n, @note_xref_lbl, 
                                            "note", false)
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
        c = Counter.new
        notes.each do |n|
          next if @anchors[n["id"]]
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
          @anchors[n["id"]] = anchor_struct(idx, n, @example_xref_lbl,
                                            "example", n["unnumbered"])
        end
        example_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
      end
    end

    def list_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
          s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
        c = Counter.new
        notes.each do |n|
          next if n["id"].nil? || n["id"].empty?
          idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
          @anchors[n["id"]] = anchor_struct(idx, n, @list_lbl, "list", false)
          list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
        end
        list_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
      end
    end

    def list_item_anchor_names(list, list_anchor, depth, prev_label, refer_list)
      c = Counter.new
      list.xpath(ns("./li")).each do |li|
        label = c.increment(li).listlabel(depth)
        label = "#{prev_label}.#{label}" unless prev_label.empty?
        label = "#{list_anchor[:xref]} #{label}" if refer_list
        li["id"] and @anchors[li["id"]] =
          { xref: "#{label})", type: "listitem", 
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
      # preempt clause notes with all other types of note (ISO default)
      note_anchor_names(docxml.xpath(ns("//table | //figure")))
      note_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      example_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
      list_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
    end

    def sequential_figure_names(clause)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure[not(@class = 'pseudocode')]")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          c.increment(t)
        end
        label = c.print + (j.zero? ? "" : "-#{j}")
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] =
          anchor_struct(label, nil, @figure_lbl, "figure", t["unnumbered"])
      end
    end

    def sequential_table_names(clause)
      c = Counter.new
      clause.xpath(ns(".//table")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(c.increment(t).print, nil, 
                                          @table_lbl, "table", t["unnumbered"])
      end
    end

    def sequential_formula_names(clause)
      c = Counter.new
      clause.xpath(ns(".//formula")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] =
          anchor_struct(c.increment(t).print, t, 
                        t["inequality"] ? @inequality_lbl : @formula_lbl,
                        "formula", t["unnumbered"])
      end
    end

    FIRST_LVL_REQ = "[not(ancestor::permission or ancestor::requirement or "\
      "ancestor::recommendation)]".freeze

    def sequential_permission_names(clause, klass, label)
      c = Counter.new
      clause.xpath(ns(".//#{klass}#{FIRST_LVL_REQ}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        id = c.increment(t).print
        @anchors[t["id"]] = anchor_struct(id, t, label, klass, t["unnumbered"])
        sequential_permission_names1(t, id, "permission", @permission_lbl)
        sequential_permission_names1(t, id, "requirement", @requirement_lbl)
        sequential_permission_names1(t, id, "recommendation",
                                     @recommendation_lbl)
      end
    end

    def sequential_permission_names1(block, lbl, klass, label)
      c = Counter.new
      block.xpath(ns("./#{klass}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        id = "#{lbl}#{hierfigsep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(id, t, label, klass, t["unnumbered"])
        sequential_permission_names1(t, id, "permission", @permission_lbl)
        sequential_permission_names1(t, id, "requirement", @requirement_lbl)
        sequential_permission_names1(t, id, "recommendation",
                                     @recommendation_lbl)
      end
    end

    def sequential_asset_names(clause)
      sequential_table_names(clause)
      sequential_figure_names(clause)
      sequential_formula_names(clause)
      sequential_permission_names(clause, "permission", @permission_lbl)
      sequential_permission_names(clause, "requirement", @requirement_lbl)
      sequential_permission_names(clause, "recommendation", @recommendation_lbl)
    end

    def hiersep
      "."
    end

    def hierfigsep
      "-"
    end

    def hierarchical_figure_names(clause, num)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure[not(@class = 'pseudocode')]")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          c.increment(t)
        end
        label = "#{num}#{hiersep}#{c.print}" +
          (j.zero? ? "" : "#{hierfigsep}#{j}")
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl, "figure",
                                          t["unnumbered"])
      end
    end

    def hierarchical_table_names(clause, num)
      c = Counter.new
      clause.xpath(ns(".//table")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] =
          anchor_struct("#{num}#{hiersep}#{c.increment(t).print}",
                        nil, @table_lbl, "table", t["unnumbered"])
      end
    end

    def hierarchical_asset_names(clause, num)
      hierarchical_table_names(clause, num)
      hierarchical_figure_names(clause, num)
      hierarchical_formula_names(clause, num)
      hierarchical_permission_names(clause, num, "permission", @permission_lbl)
      hierarchical_permission_names(clause, num, "requirement",
                                    @requirement_lbl)
      hierarchical_permission_names(clause, num, "recommendation",
                                    @recommendation_lbl)
    end

    def hierarchical_formula_names(clause, num)
      c = Counter.new
      clause.xpath(ns(".//formula")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        @anchors[t["id"]] =
          anchor_struct("#{num}#{hiersep}#{c.increment(t).print}", t,
                        t["inequality"] ? @inequality_lbl : @formula_lbl,
                        "formula", t["unnumbered"])
      end
    end

    def hierarchical_permission_names(clause, num, klass, label)
      c = Counter.new
      clause.xpath(ns(".//#{klass}#{FIRST_LVL_REQ}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        lbl = "#{num}#{hiersep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(lbl, t, label, klass, t["unnumbered"])
        sequential_permission_names1(t, lbl, "permission", @permission_lbl)
        sequential_permission_names1(t, lbl, "requirement", @requirement_lbl)
        sequential_permission_names1(t, lbl, "recommendation",
                                     @recommendation_lbl)
      end
    end
  end
end
