module IsoDoc::Function
  module XrefGen
    def sequential_figure_names(clause)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).
        each do |t|
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
        sequential_permission_names2(t, id)
      end
    end

    def sequential_permission_names2(t, id)
      sequential_permission_names1(t, id, "permission", @permission_lbl)
      sequential_permission_names1(t, id, "requirement", @requirement_lbl)
      sequential_permission_names1(t, id, "recommendation", @recommendation_lbl)
    end

    def sequential_permission_names1(block, lbl, klass, label)
      c = Counter.new
      block.xpath(ns("./#{klass}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        id = "#{lbl}#{hierfigsep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(id, t, label, klass, t["unnumbered"])
        sequential_permission_names2(t, id)
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

    def hierarchical_figure_names(clause, num)
      c = Counter.new
      j = 0
      clause.xpath(ns(".//figure |  .//sourcecode[not(ancestor::example)]")).
        each do |t|
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
          anchor_struct("#{num}#{hiersep}#{c.increment(t).print}", nil,
                        t["inequality"] ? @inequality_lbl : @formula_lbl,
                        "formula", t["unnumbered"])
      end
    end

    def hierarchical_permission_names(clause, num, klass, label)
      c = Counter.new
      clause.xpath(ns(".//#{klass}#{FIRST_LVL_REQ}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        id = "#{num}#{hiersep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(id, nil, label, klass, t["unnumbered"])
        hierarchical_permission_names2(t, id)
      end
    end

     def hierarchical_permission_names2(t, id)
      hierarchical_permission_names1(t, id, "permission", @permission_lbl)
      hierarchical_permission_names1(t, id, "requirement", @requirement_lbl)
      hierarchical_permission_names1(t, id, "recommendation", @recommendation_lbl)
    end

     def hierarchical_permission_names1(block, lbl, klass, label)
      c = Counter.new
      block.xpath(ns("./#{klass}")).each do |t|
        next if t["id"].nil? || t["id"].empty?
        id = "#{lbl}#{hierfigsep}#{c.increment(t).print}"
        @anchors[t["id"]] = anchor_struct(id, nil, label, klass, t["unnumbered"])
        hierarchical_permission_names2(t, id)
      end
    end
  end
end
