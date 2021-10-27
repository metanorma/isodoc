module IsoDoc::XrefGen
  module Blocks
    def hiersep
      "."
    end

    def hierfigsep
      "-"
    end

    def subfigure_increment(idx, counter, elem)
      if elem.parent.name == "figure" then idx += 1
      else
        idx = 0
        counter.increment(elem)
      end
      idx
    end

    def sequential_figure_names(clause)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]"))
        .each do |t|
        j = subfigure_increment(j, c, t)
        label = c.print + (j.zero? ? "" : "-#{j}")
        next if t["id"].nil? || t["id"].empty?

        @anchors[t["id"]] = anchor_struct(
          label, nil, @labels["figure"], "figure", t["unnumbered"]
        )
      end
    end

    def sequential_table_names(clause)
      c = Counter.new
      clause.xpath(ns(".//table")).reject { |n| blank?(n["id"]) }.each do |t|

        @anchors[t["id"]] = anchor_struct(
          c.increment(t).print, nil,
          @labels["table"], "table", t["unnumbered"]
        )
      end
    end

    def sequential_formula_names(clause)
      c = Counter.new
      clause.xpath(ns(".//formula")).reject { |n| blank?(n["id"]) }.each do |t|

        @anchors[t["id"]] = anchor_struct(
          c.increment(t).print, t,
          t["inequality"] ? @labels["inequality"] : @labels["formula"],
          "formula", t["unnumbered"]
        )
      end
    end

    FIRST_LVL_REQ = "[not(ancestor::permission or ancestor::requirement or "\
      "ancestor::recommendation)]".freeze

    def sequential_permission_names(clause, klass, label)
      c = Counter.new
      clause.xpath(ns(".//#{klass}#{FIRST_LVL_REQ}"))
        .reject { |n| blank?(n["id"]) }.each do |t|

        id = c.increment(t).print
        @anchors[t["id"]] = anchor_struct(id, t, label, klass, t["unnumbered"])
        sequential_permission_names2(t, id)
      end
    end

    def sequential_permission_names2(elem, ident)
      sequential_permission_names1(elem, ident, "permission",
                                   @labels["permission"])
      sequential_permission_names1(elem, ident, "requirement",
                                   @labels["requirement"])
      sequential_permission_names1(elem, ident, "recommendation",
                                   @labels["recommendation"])
    end

    def sequential_permission_names1(block, lbl, klass, label)
      c = Counter.new
      block.xpath(ns("./#{klass}")).reject { |n| blank?(n["id"]) }.each do |t|

        id = "#{lbl}#{hierfigsep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(id, t, label, klass, t["unnumbered"])
        sequential_permission_names2(t, id)
      end
    end

    def sequential_asset_names(clause)
      sequential_table_names(clause)
      sequential_figure_names(clause)
      sequential_formula_names(clause)
      sequential_permission_names(clause, "permission", @labels["permission"])
      sequential_permission_names(clause, "requirement", @labels["requirement"])
      sequential_permission_names(clause, "recommendation",
                                  @labels["recommendation"])
    end

    def hierarchical_figure_names(clause, num)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure |  .//sourcecode[not(ancestor::example)]"))
        .each do |t|
        j = subfigure_increment(j, c, t)
        label = "#{num}#{hiersep}#{c.print}" +
          (j.zero? ? "" : "#{hierfigsep}#{j}")
        next if t["id"].nil? || t["id"].empty?

        @anchors[t["id"]] = anchor_struct(label, nil, @labels["figure"],
                                          "figure", t["unnumbered"])
      end
    end

    def hierarchical_table_names(clause, num)
      c = Counter.new
      clause.xpath(ns(".//table")).reject { |n| blank?(n["id"]) }.each do |t|

        @anchors[t["id"]] =
          anchor_struct("#{num}#{hiersep}#{c.increment(t).print}",
                        nil, @labels["table"], "table", t["unnumbered"])
      end
    end

    def hierarchical_asset_names(clause, num)
      hierarchical_table_names(clause, num)
      hierarchical_figure_names(clause, num)
      hierarchical_formula_names(clause, num)
      hierarchical_permission_names(clause, num, "permission",
                                    @labels["permission"])
      hierarchical_permission_names(clause, num, "requirement",
                                    @labels["requirement"])
      hierarchical_permission_names(clause, num, "recommendation",
                                    @labels["recommendation"])
    end

    def hierarchical_formula_names(clause, num)
      c = Counter.new
      clause.xpath(ns(".//formula")).reject { |n| blank?(n["id"]) }.each do |t|

        @anchors[t["id"]] = anchor_struct(
          "#{num}#{hiersep}#{c.increment(t).print}", nil,
          t["inequality"] ? @labels["inequality"] : @labels["formula"],
          "formula", t["unnumbered"]
        )
      end
    end

    def hierarchical_permission_names(clause, num, klass, label)
      c = Counter.new
      clause.xpath(ns(".//#{klass}#{FIRST_LVL_REQ}"))
        .reject { |n| blank?(n["id"]) }.each do |t|

        id = "#{num}#{hiersep}#{c.increment(t).print}"
        @anchors[t["id"]] =
          anchor_struct(id, nil, label, klass, t["unnumbered"])
        hierarchical_permission_names2(t, id)
      end
    end

    def hierarchical_permission_names2(elem, ident)
      hierarchical_permission_names1(elem, ident, "permission",
                                     @labels["permission"])
      hierarchical_permission_names1(elem, ident, "requirement",
                                     @labels["requirement"])
      hierarchical_permission_names1(elem, ident, "recommendation",
                                     @labels["recommendation"])
    end

    def hierarchical_permission_names1(block, lbl, klass, label)
      c = Counter.new
      block.xpath(ns("./#{klass}")).reject { |n| blank?(n["id"]) }.each do |t|

        id = "#{lbl}#{hierfigsep}#{c.increment(t).print}"
        @anchors[t["id"]] =
          anchor_struct(id, nil, label, klass, t["unnumbered"])
        hierarchical_permission_names2(t, id)
      end
    end
  end
end
