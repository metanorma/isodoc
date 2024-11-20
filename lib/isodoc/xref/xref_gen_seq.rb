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

      def sequential_figure_names(clause, container: false)
        c = Counter.new
        j = 0
        clause.xpath(ns(self.class::FIGURE_NO_CLASS)).noblank.each do |t|
          # labelled_ancestor(t, %w(figure)) and next # disable nested figure labelling
          j = subfigure_increment(j, c, t)
          sublabel = subfigure_label(j)
          # sequential_figure_body(j, c, t, "figure", container:)
          figure_anchor(t, sublabel, c.print, "figure", container: container)
        end
        sequential_figure_class_names(clause, container:)
      end

      def sequential_figure_class_names(clause, container: false)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .each do |t|
          c[t["class"]] ||= Counter.new
          # labelled_ancestor(t, %w(figure)) and next
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = subfigure_label(j)
          figure_anchor(t, sublabel, c[t["class"]].print, t["class"],
                        container: container)
          # sequential_figure_body(j, c[t["class"]], t, t["class"],
          # container:)
        end
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return
        subfignum.to_s
      end

      def subfigure_separator(markup: false)
        h = hierfigsep
        h.blank? || !markup or h = "<span class='fmt-autonum-delim'>#{h}</span>"
        h
      end

      def subfigure_delim
        ""
      end

      # TODO delete
      def sequential_figure_body(subfig, counter, elem, klass, container: false)
        label = counter.print
        label &&= label + subfigure_label(subfig)
        @anchors[elem["id"]] = anchor_struct(
          label, elem,
          @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"], container: container }
        )
      end

      def figure_anchor(elem, sublabel, label, klass, container: false)
        if sublabel
          subfigure_anchor(elem, sublabel, label, klass, container: false)
        else
          @anchors[elem["id"]] = anchor_struct(
            label, elem, @labels[klass] || klass.capitalize, klass,
            { unnumb: elem["unnumbered"], container: }
          )
        end
      end

      def subfigure_anchor(elem, sublabel, label, klass, container: false)
        figlabel = "#{label}#{subfigure_separator}#{sublabel}"
        @anchors[elem["id"]] = anchor_struct(
          figlabel, elem, @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"], container: }
        )
        if elem["unnumbered"] != "true"
          x = "#{subfigure_separator(markup: true)}#{semx(elem, sublabel)}"
          @anchors[elem["id"]][:label] = "#{semx(elem.parent, label)}#{x}"
          @anchors[elem["id"]][:xref] = @anchors[elem.parent["id"]][:xref] + x +
            subfigure_delim
        end
      end

      def sequential_table_names(clause, container: false)
        c = Counter.new
        clause.xpath(ns(".//table")).noblank.each do |t|
          # labelled_ancestor(t) and next
          @anchors[t["id"]] = anchor_struct(
            c.increment(t).print, t,
            @labels["table"], "table", { unnumb: t["unnumbered"], container: container }
          )
        end
      end

      def sequential_formula_names(clause, container: false)
        c = Counter.new
        clause.xpath(ns(".//formula")).noblank.each do |t|
          @anchors[t["id"]] = anchor_struct(
            c.increment(t).print, t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", { unnumb: t["unnumbered"], container: true }
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

      def sequential_permission_names(clause, container: true)
        c = ReqCounter.new
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          id = c.increment(label, t).print
          sequential_permission_body(id, nil, t, label, klass, m,
                                     container:)
          sequential_permission_children(t, id, klass, container:)
        end
      end

      def sequential_permission_children(elem, lbl, klass, container: false)
        c = ReqCounter.new
        elem.xpath(ns(REQ_CHILDREN)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          ctr = c.increment(label, t).print
          id = "#{lbl}#{hierfigsep}#{ctr}"
          sequential_permission_body(ctr, lbl, t, label, klass, m,
                                     container:)
          sequential_permission_children(t, id, klass, container:)
        end
      end

      def sequential_permission_body(id, parent_id, elem, label, klass, model,
container: false)
        lbl = parent_id ? "#{parent_id}#{hierfigsep}#{id}" : id
        @anchors[elem["id"]] = model.postprocess_anchor_struct(
          elem, anchor_struct(lbl, elem,
                              label, klass, { unnumb: elem["unnumbered"], container: })
        )
        @anchors[elem["id"]][:semx] = semx(elem, lbl)
        if parent_id
          x = "#{subfigure_separator(markup: true)}#{semx(elem, id)}"
          @anchors[elem["id"]][:semx] = @anchors[elem.parent["id"]][:semx] + x
          @anchors[elem["id"]][:label] =
            "<span class='fmt-element-name'>#{label}</span> #{@anchors[elem["id"]][:semx]}"
          @anchors[elem["id"]][:xref] =  "<span class='fmt-element-name'>#{label}</span> #{@anchors[elem["id"]][:semx]}"
        end
        model.permission_parts(elem, id, label, klass).each do |n|
          @anchors[n[:id]] = anchor_struct(n[:number], n[:elem], n[:label],
                                           n[:klass], { unnumb: false, container: })
        end
      end

      def reqt2class_label(elem, model)
        elem["class"] and return [elem["class"], elem["class"]]
        model.req_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          elem.at("./self::#{v1}") and return [n[:klass], n[:label]]
        end
        [nil, nil]
      end

      def reqt2class_nested_label(elem, model)
        model.req_nested_class_paths.each do |n|
          v1 = ns("/#{n[:xpath]}").sub(%r{^/}, "")
          elem.at("./self::#{v1}") and return [n[:klass], n[:label]]
        end
        [nil, nil]
      end

      # container makes numbering be prefixed with the parent clause reference
      def sequential_asset_names(clause, container: false)
        sequential_table_names(clause, container:)
        sequential_figure_names(clause, container:)
        sequential_formula_names(clause, container:)
        sequential_permission_names(clause, container:)
      end

      def hierarchical_figure_names(clause, num)
        c = Counter.new
        j = 0
        clause.xpath(ns(self.class::FIGURE_NO_CLASS)).noblank.each do |t|
          # labelled_ancestor(t, %w(figure)) and next
          j = subfigure_increment(j, c, t)
          sublabel = subfigure_label(j)
          # hierarchical_figure_body(num, j, c, t, "figure")
          figure_anchor(t, sublabel, "#{num}#{hiersep}#{c.print}", "figure")
        end
        hierarchical_figure_class_names(clause, num)
      end

      def hierarchical_figure_class_names(clause, num)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .noblank.each do |t|
          # labelled_ancestor(t, %w(figure)) and next
          c[t["class"]] ||= Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = subfigure_label(j)
          # hierarchical_figure_body(num, j, c[t["class"]], t, t["class"])
          figure_anchor(t, sublabel, "#{num}#{hiersep}#{c[t['class']].print}",
                        t["class"])
        end
      end

      # TODO delete
      def hierarchical_figure_body(num, subfignum, counter, block, klass)
        label = "#{num}#{hiersep}#{counter.print}" +
          subfigure_label(subfignum)
        @anchors[block["id"]] =
          anchor_struct(label, block, @labels[klass] || klass.capitalize,
                        klass, { unnumb: block["unnumbered"], container: false })
      end

      def hierarchical_table_names(clause, num)
        c = Counter.new
        clause.xpath(ns(".//table")).noblank.each do |t|
          # labelled_ancestor(t) and next
          @anchors[t["id"]] =
            anchor_struct("#{num}#{hiersep}#{c.increment(t).print}",
                          t, @labels["table"], "table", { unnumb: t["unnumbered"], container: false })
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
            "#{num}#{hiersep}#{c.increment(t).print}", t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", { unnumb: t["unnumbered"], container: false }
          )
        end
      end

      def hierarchical_permission_names(clause, num)
        c = ReqCounter.new
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          id = "#{num}#{hiersep}#{c.increment(label, t).print}"
          sequential_permission_body(id, nil, t, label, klass, m, container: false)
          sequential_permission_children(t, id, klass, container: false)
        end
      end

      # TODO remove
      def hierarchical_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns(REQ_CHILDREN)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{hierfigsep}#{c.increment(label, t).print}"
          sequential_permission_body(c.print, lbl, t, label, klass, m)
          hierarchical_permission_children(t, id)
        end
      end

      # TODO remove
      def hierarchical_permission_body(id, parent_id, elem, label, klass, model)
        @anchors[elem["id"]] = model.postprocess_anchor_struct(
          elem, anchor_struct(id, elem,
                              label, klass, { unnumb: elem["unnumbered"], container: false })
        )
        x = "#{subfigure_separator(markup: true)}#{semx(elem, id)}"
        @anchors[elem["id"]][:label] = "#{semx(elem.parent, parent_id)}#{x}"
        @anchors[elem["id"]][:xref] = @anchors[elem.parent["id"]][:xref] + x
        model.permission_parts(elem, id, label, klass).each do |n|
          # we don't have an n["id"], so we allow n[:id] in anchor_struct
          @anchors[n[:id]] = anchor_struct(n[:number], n, n[:label],
                                           n[:klass], { unnumb: false, container: false })
        end
      end
    end
  end
end
