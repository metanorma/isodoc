require_relative "../function/utils"
require_relative "xref_util"

module IsoDoc
  module XrefGen
    module Blocks
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
          figure_anchor(t, sublabel, c.print, "figure", container: container)
        end
        sequential_figure_class_names(clause, container:)
      end

      def sequential_figure_class_names(clause, container: false)
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .each_with_object({}) do |t, c|
          c[t["class"]] ||= Counter.new
          # labelled_ancestor(t, %w(figure)) and next
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = subfigure_label(j)
          figure_anchor(t, sublabel, c[t["class"]].print, t["class"],
                        container: container)
        end
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return
        subfignum.to_s
      end

      def figure_anchor(elem, sublabel, label, klass, container: false)
        if sublabel
          label&.include?("<semx") or label = semx(elem.parent, label)
          subfigure_anchor(elem, sublabel, label, klass, container: false)
        else
          @anchors[elem["id"]] = anchor_struct(
            label, elem, @labels[klass] || klass.capitalize, klass,
            { unnumb: elem["unnumbered"], container: }
          )
        end
      end

      def fig_subfig_label(label, sublabel)
        label && sublabel or return
        "#{label}#{subfigure_separator}#{sublabel}"
      end

      def subfigure_anchor(elem, sublabel, label, klass, container: false)
        figlabel = fig_subfig_label(label, sublabel)
        @anchors[elem["id"]] = anchor_struct(
          figlabel, elem, @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"] }
        )
        if elem["unnumbered"] != "true"
          x = "#{subfigure_separator(markup: true)}#{semx(elem, sublabel)}"
          @anchors[elem["id"]][:label] = "#{label}#{x}"
          @anchors[elem["id"]][:xref] = @anchors[elem.parent["id"]][:xref] + x +
            delim_wrap(subfigure_delim)
          x = @anchors[elem.parent["id"]][:container] and
            @anchors[elem["id"]][:container] = x
        end
      end

      def sequential_table_names(clause, container: false)
        c = Counter.new
        clause.xpath(ns(".//table")).noblank.each do |t|
          # labelled_ancestor(t) and next
          @anchors[t["id"]] = anchor_struct(
            c.increment(t).print, t, @labels["table"], "table",
            { unnumb: t["unnumbered"], container: container }
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
          @anchors[t["id"]][:bare_xref] = @anchors[t["id"]][:label]
        end
      end

      def sequential_permission_names(clause, container: true)
        c = ReqCounter.new
        clause.xpath(ns(first_lvl_req)).noblank.each do |t|
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
        elem.xpath(ns(req_children)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          ctr = c.increment(label, t).print
          id = "#{lbl}#{subreqt_separator}#{ctr}"
          sequential_permission_body(ctr, lbl, t, label, klass, m,
                                     container:)
          sequential_permission_children(t, id, klass, container:)
        end
      end

      def sequential_permission_body(id, parent_id, elem, label, klass, model,
container: false)
        lbl = parent_id ? "#{parent_id}#{subreqt_separator}#{id}" : id
        @anchors[elem["id"]] = model.postprocess_anchor_struct(
          elem, anchor_struct(lbl, elem,
                              label, klass, { unnumb: elem["unnumbered"], container: })
        )
        @anchors[elem["id"]][:semx] = semx(elem, lbl)
        if parent_id
          x = "#{subreqt_separator(markup: true)}#{semx(elem, id)}"
          @anchors[elem["id"]][:semx] = @anchors[elem.parent["id"]][:semx] + x
          @anchors[elem["id"]][:label] =
            "<span class='fmt-element-name'>#{label}</span> #{@anchors[elem['id']][:semx]}"
          @anchors[elem["id"]][:xref] =
            "<span class='fmt-element-name'>#{label}</span> #{@anchors[elem['id']][:semx]}"
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

      # these can take a NodeSet as argument; semx will point to members of the NodeSet,
      # but numbering will be consecutive
      def hierarchical_figure_names(clauses, num)
        c = Counter.new
        j = 0
        nodeSet(clauses).each do |clause|
          clause.xpath(ns(self.class::FIGURE_NO_CLASS)).noblank.each do |t|
            # labelled_ancestor(t, %w(figure)) and next
            j = subfigure_increment(j, c, t)
            sublabel = subfigure_label(j)
            figure_anchor(t, sublabel, hiersemx(clause, num, c, t), "figure")
          end
          hierarchical_figure_class_names(clause, num)
        end
      end

      def hierarchical_figure_class_names(clauses, num)
        j = 0
        nodeSet(clauses).each_with_object({}) do |clause, c|
          clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
            .noblank.each do |t|
            # labelled_ancestor(t, %w(figure)) and next
            c[t["class"]] ||= Counter.new
            j = subfigure_increment(j, c[t["class"]], t)
            sublabel = subfigure_label(j)
            figure_anchor(t, sublabel, hiersemx(clause, num, c[t["class"]], t),
                          t["class"])
          end
        end
      end

      def hierarchical_table_names(clauses, num)
        c = Counter.new
        nodeSet(clauses).each do |clause|
          clause.xpath(ns(".//table")).noblank.each do |t|
            # labelled_ancestor(t) and next
            @anchors[t["id"]] =
              anchor_struct(hiersemx(clause, num, c.increment(t), t),
                            t, @labels["table"], "table",
                            { unnumb: t["unnumbered"], container: false })
          end
        end
      end

      def hierarchical_formula_names(clauses, num)
        c = Counter.new
        nodeSet(clauses).each do |clause|
          clause.xpath(ns(".//formula")).noblank.each do |t|
            @anchors[t["id"]] = anchor_struct(
              hiersemx(clause, num, c.increment(t), t), t,
              t["inequality"] ? @labels["inequality"] : @labels["formula"],
              "formula", { unnumb: t["unnumbered"], container: false }
            )
            @anchors[t["id"]][:bare_xref] = @anchors[t["id"]][:label]
          end
        end
      end

      def hierarchical_permission_names(clauses, num)
        c = ReqCounter.new
        nodeSet(clauses).each do |clause|
          clause.xpath(ns(first_lvl_req)).noblank.each do |t|
            m = @reqt_models.model(t["model"])
            klass, label = reqt2class_label(t, m)
            id = hiersemx(clause, num, c.increment(label, t), t)
            sequential_permission_body(id, nil, t, label, klass, m,
                                       container: false)
            sequential_permission_children(t, id, klass, container: false)
          end
        end
      end
    end
  end
end
