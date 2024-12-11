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

      def hierreqtsep
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
        end
      end

      def hier_separator(markup: false)
        h = hiersep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return
        subfignum.to_s
      end

      def subfigure_separator(markup: false)
        h = hierfigsep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subreqt_separator(markup: false)
        h = hierreqtsep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subfigure_delim
        ""
      end

      def figure_anchor(elem, sublabel, label, klass, container: false)
        if sublabel
          /<semx/.match?(label) or label = semx(elem.parent, label)
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
          @anchors[elem["id"]][:label] = "#{label}#{x}" # "#{semx(elem.parent, label)}#{x}"
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

      def nodeSet(clauses)
        case clauses
        when Nokogiri::XML::Node
          [clauses]
        when Nokogiri::XML::NodeSet
          clauses
        end
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
          # hierarchical_figure_body(num, j, c, t, "figure")
          #figure_anchor(t, sublabel, "#{num}#{hier_separator}#{c.print}", "figure")
          #require "debug"; binding.b
          figure_anchor(t, sublabel, hiersemx(clause, num, c, t), "figure")
        end
        hierarchical_figure_class_names(clause, num)
        end
      end

      def hierarchical_figure_class_names(clauses, num)
        c = {}
        j = 0
        nodeSet(clauses).each do |clause|
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .noblank.each do |t|
          # labelled_ancestor(t, %w(figure)) and next
          c[t["class"]] ||= Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = subfigure_label(j)
          # hierarchical_figure_body(num, j, c[t["class"]], t, t["class"])
          #figure_anchor(t, sublabel, "#{num}#{hier_separator}#{c[t['class']].print}", t["class"])
          figure_anchor(t, sublabel, hiersemx(clause, num, c[t["class"]], t), t["class"])
        end
        end
      end

      def hierarchical_table_names(clauses, num)
        c = Counter.new
        nodeSet(clauses).each do |clause|
        clause.xpath(ns(".//table")).noblank.each do |t|
          # labelled_ancestor(t) and next
          @anchors[t["id"]] =
            #anchor_struct("#{num}#{hier_separator}#{c.increment(t).print}",
            anchor_struct(hiersemx(clause, num, c.increment(t), t),
                          t, @labels["table"], "table", { unnumb: t["unnumbered"], container: false })
        end
        end
      end

      def hierarchical_asset_names(clause, num)
        hierarchical_table_names(clause, num)
        hierarchical_figure_names(clause, num)
        hierarchical_formula_names(clause, num)
        hierarchical_permission_names(clause, num)
      end

      def hierarchical_formula_names(clauses, num)
        c = Counter.new
        nodeSet(clauses).each do |clause|
        clause.xpath(ns(".//formula")).noblank.each do |t|
          @anchors[t["id"]] = anchor_struct(
            #"#{num}#{hier_separator}#{c.increment(t).print}", t,
                     hiersemx(clause, num, c.increment(t), t), t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", { unnumb: t["unnumbered"], container: false }
          )
        end
        end
      end

      def hierarchical_permission_names(clauses, num)
        c = ReqCounter.new
        nodeSet(clauses).each do |clause|
        clause.xpath(ns(FIRST_LVL_REQ)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_label(t, m)
          #id = "#{num}#{hier_separator}#{c.increment(label, t).print}"
          id = hiersemx(clause, num, c.increment(label, t), t)
          sequential_permission_body(id, nil, t, label, klass, m, container: false)
          sequential_permission_children(t, id, klass, container: false)
        end
       end
      end

      # TODO remove
      def hierarchical_permission_children(block, lbl)
        c = ReqCounter.new
        block.xpath(ns(REQ_CHILDREN)).noblank.each do |t|
          m = @reqt_models.model(t["model"])
          klass, label = reqt2class_nested_label(t, m)
          id = "#{lbl}#{subreqt_separator}#{c.increment(label, t).print}"
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
        x = "#{subreqt_separator(markup: true)}#{semx(elem, id)}"
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
