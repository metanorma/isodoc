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

      def sequential_figure_names(clause)
        c = Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]"))
          .noblank.each do |t|
          j = subfigure_increment(j, c, t)
          label = c.print
          label &&= label + (j.zero? ? "" : "-#{j}")

          @anchors[t["id"]] = anchor_struct(
            label, nil, @labels["figure"], "figure", t["unnumbered"]
          )
        end
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

      def sequential_permission_names(clause)
        c = ReqCounter.new
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          id = c.increment(label, t).print
          sequential_permission_body(id, t, label, klass, m)
        end
      end

      def sequential_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns("./permission | ./requirement | ./recommendation"))
          .noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{hierfigsep}#{c.increment(label, t).print}"
          sequential_permission_body(id, t, label, klass, m)
        end
      end

      def sequential_permission_body(id, block, label, klass, model)
        @anchors[block["id"]] =
          anchor_struct(id, block, label, klass, block["unnumbered"])
        model.permission_parts(block, label, klass)
        sequential_permission_children(block, id)
      end

      def reqt2class_label(block, model)
        model.req_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          block.at("./self::#{v1}") and return [n[:klass], @labels[n[:label]]]
        end
        [nil, nil]
      end

      def reqt2class_nested_label(block, model)
        model.req_nested_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          block.at("./self::#{v1}") and return [n[:klass], @labels[n[:label]]]
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
        clause.xpath(ns(".//figure |  .//sourcecode[not(ancestor::example)]"))
          .each do |t|
          # next if labelled_ancestor(t) && t.ancestors("figure").empty?

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
          klass, label = reqt2class_nested_label(t, m)
          id = "#{num}#{hiersep}#{c.increment(label, t).print}"
          hierarchical_permission_body(id, t, label, klass, m)
        end
      end

      def hierarchical_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns("./permission | ./requirement | ./recommendation"))
          .noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{hierfigsep}#{c.increment(label, t).print}"
          hierarchical_permission_body(id, t, label, klass, m)
        end
      end

      def hierarchical_permission_body(id, block, label, klass, model)
        @anchors[block["id"]] =
          anchor_struct(id, nil, label, klass, block["unnumbered"])
        model.permission_parts(block, label, klass)
        hierarchical_permission_children(block, id)
      end
    end
  end
end
