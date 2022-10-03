require_relative "../function/utils"

module IsoDoc
  module XrefGen
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

      FIGURE_NO_CLASS = <<~XPATH.freeze
        .//figure[not(@class)] | .//figure[@class = 'pseudocode'] | .//sourcecode[not(ancestor::example)]
      XPATH

      def sequential_figure_names(clause)
        c = Counter.new
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank.each do |t|
          j = subfigure_increment(j, c, t)
          sequential_figure_body(j, c, t, "figure")
        end
        sequential_figure_class_names(clause)
      end

      def sequential_figure_class_names(clause)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .each do |t|
          c[t["class"]] ||= Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sequential_figure_body(j, c[t["class"]], t, t["class"])
        end
      end

      def sequential_figure_body(subfignum, counter, block, klass)
        label = counter.print
        label &&= label + (subfignum.zero? ? "" : "-#{subfignum}")

        @anchors[block["id"]] = anchor_struct(
          label, nil, @labels[klass] || klass.capitalize, klass,
          block["unnumbered"]
        )
      end

      def sequential_table_names(clause)
        c = Counter.new
        clause.xpath(ns(".//table")).noblank.each do |t|
          next if labelled_ancestor(t)

          @anchors[t["id"]] = anchor_struct(
            c.increment(t).print, nil,
            @labels["table"], "table", t["unnumbered"]
          )
        end
      end

      def sequential_formula_names(clause)
        c = Counter.new
        clause.xpath(ns(".//formula")).noblank.each do |t|
          @anchors[t["id"]] = anchor_struct(
            c.increment(t).print, t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", t["unnumbered"]
          )
        end
      end

      FIRST_LVL_REQ_RULE = <<~XPATH.freeze
        [not(ancestor::permission or ancestor::requirement or ancestor::recommendation)]
      XPATH

      FIRST_LVL_REQ = <<~XPATH.freeze
        .//permission#{FIRST_LVL_REQ_RULE} | .//requirement#{FIRST_LVL_REQ_RULE} | .//recommendation#{FIRST_LVL_REQ_RULE}
      XPATH

      REQ_CHILDREN = <<~XPATH.freeze
        ./permission | ./requirement | ./recommendation
      XPATH

      def sequential_permission_names(clause)
        c = ReqCounter.new
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          id = c.increment(label, t).print
          sequential_permission_body(id, t, label, klass, m)
          sequential_permission_children(t, id)
        end
      end

      def sequential_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns(REQ_CHILDREN)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{hierfigsep}#{c.increment(label, t).print}"
          sequential_permission_body(id, t, label, klass, m)
          sequential_permission_children(t, id)
        end
      end

      def sequential_permission_body(id, block, label, klass, model)
        @anchors[block["id"]] = model.postprocess_anchor_struct(
          block, anchor_struct(id, block,
                               label, klass, block["unnumbered"])
        )

        model.permission_parts(block, id, label, klass).each do |n|
          @anchors[n[:id]] = anchor_struct(n[:number], n[:elem], n[:label],
                                           n[:klass], false)
        end
      end

      def reqt2class_label(block, model)
        model.req_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          block.at("./self::#{v1}") and return [n[:klass], n[:label]]
        end
        [nil, nil]
      end

      def reqt2class_nested_label(block, model)
        model.req_nested_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          block.at("./self::#{v1}") and return [n[:klass], n[:label]]
        end
        [nil, nil]
      end

      def sequential_asset_names(clause)
        sequential_table_names(clause)
        sequential_figure_names(clause)
        sequential_formula_names(clause)
        sequential_permission_names(clause)
      end

      def hierarchical_figure_names(clause, num)
        c = Counter.new
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank.each do |t|
          # next if labelled_ancestor(t) && t.ancestors("figure").empty?
          j = subfigure_increment(j, c, t)
          hierarchical_figure_body(num, j, c, t, "figure")
        end
        hierarchical_figure_class_names(clause, num)
      end

      def hierarchical_figure_class_names(clause, num)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .noblank.each do |t|
          c[t["class"]] ||= Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          hierarchical_figure_body(num, j, c[t["class"]], t, t["class"])
        end
      end

      def hierarchical_figure_body(num, subfignum, counter, block, klass)
        label = "#{num}#{hiersep}#{counter.print}" +
          (subfignum.zero? ? "" : "#{hierfigsep}#{subfignum}")

        @anchors[block["id"]] =
          anchor_struct(label, nil, @labels[klass] || klass.capitalize,
                        klass, block["unnumbered"])
      end

      def hierarchical_table_names(clause, num)
        c = Counter.new
        clause.xpath(ns(".//table")).noblank.each do |t|
          next if labelled_ancestor(t)

          @anchors[t["id"]] =
            anchor_struct("#{num}#{hiersep}#{c.increment(t).print}",
                          nil, @labels["table"], "table", t["unnumbered"])
        end
      end

      def hierarchical_asset_names(clause, num)
        hierarchical_table_names(clause, num)
        hierarchical_figure_names(clause, num)
        hierarchical_formula_names(clause, num)
        hierarchical_permission_names(clause, num)
      end

      def hierarchical_formula_names(clause, num)
        c = Counter.new
        clause.xpath(ns(".//formula")).noblank.each do |t|
          @anchors[t["id"]] = anchor_struct(
            "#{num}#{hiersep}#{c.increment(t).print}", nil,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", t["unnumbered"]
          )
        end
      end

      def hierarchical_permission_names(clause, num)
        c = ReqCounter.new
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          id = "#{num}#{hiersep}#{c.increment(label, t).print}"
          hierarchical_permission_body(id, t, label, klass, m)
          hierarchical_permission_children(t, id)
        end
      end

      def hierarchical_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns(REQ_CHILDREN)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{hierfigsep}#{c.increment(label, t).print}"
          hierarchical_permission_body(id, t, label, klass, m)
          hierarchical_permission_children(t, id)
        end
      end

      def hierarchical_permission_body(id, block, label, klass, model)
        @anchors[block["id"]] = model.postprocess_anchor_struct(
          block, anchor_struct(id, nil,
                               label, klass, block["unnumbered"])
        )

        model.permission_parts(block, id, label, klass).each do |n|
          @anchors[n[:id]] = anchor_struct(n[:number], nil, n[:label],
                                           n[:klass], false)
        end
      end
    end
  end
end
