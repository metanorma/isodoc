module IsoDoc
  module XrefGen
    module Blocks
      def list_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
            s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
          c = list_counter(0, {})
          notes.noblank.each do |n|
            @anchors[n["id"]] =
              anchor_struct(increment_label(notes, n, c), n,
                            @labels["list"], "list",
                            { unnumb: false, container: true })
            list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
          end
          list_anchor_names(s.xpath(ns(child_sections)))
        end
      end

      def list_item_delim
        ")"
      end

      def list_item_anchor_names(list, list_anchor, depth, prev_label,
refer_list)
        c = list_counter(list["start"] ? list["start"].to_i - 1 : 0, {})
        list.xpath(ns("./li")).each do |li|
          bare_label, label =
            list_item_value(li, c, depth,
                            { list_anchor:, prev_label:,
                              refer_list: depth == 1 ? refer_list : nil })
          @anchors[li["id"]] =
            { label: bare_label, bare_xref: "#{label})", type: "listitem",
              xref: %[#{label}#{delim_wrap(list_item_delim)}], refer_list:,
              container: list_anchor[:container] }
          (li.xpath(ns(".//ol")) - li.xpath(ns(".//ol//ol"))).each do |ol|
            list_item_anchor_names(ol, list_anchor, depth + 1, label,
                                   refer_list)
          end
        end
      end

      def list_item_value(entry, counter, depth, opts)
        label = counter.increment(entry).listlabel(entry.parent, depth)
        s = semx(entry, label)
        [label,
         list_item_anchor_label(s, opts[:list_anchor], opts[:prev_label],
                                opts[:refer_list])]
      end

      def list_item_anchor_label(label, list_anchor, prev_label, refer_list)
        prev_label.empty? or
          label = @klass.connectives_spans(@i18n.list_nested_xref
            .sub("%1", %[#{prev_label}#{delim_wrap(list_item_delim)}])
            .sub("%2", label))
        refer_list and
          label = @klass.connectives_spans(@i18n.list_nested_xref
            .sub("%1", list_anchor[:xref])
            .sub("%2", label))
        label
      end

      def deflist_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//dl")) - s.xpath(ns(".//clause//dl")) -
            s.xpath(ns(".//appendix//dl")) - s.xpath(ns(".//dl//dl"))
          deflist_anchor_names1(notes, Counter.new)
          deflist_anchor_names(s.xpath(ns(child_sections)))
        end
      end

      def deflist_anchor_names1(notes, counter)
        notes.noblank.each do |n|
          @anchors[n["id"]] =
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["deflist"], "deflist",
                          { unnumb: false, container: true })
          deflist_term_anchor_names(n, @anchors[n["id"]])
        end
      end

      def deflist_term_anchor_names(list, list_anchor)
        list.xpath(ns("./dt")).each do |li|
          label = deflist_term_anchor_lbl(li, list_anchor)
          li["id"] and @anchors[li["id"]] =
                         { xref: label, type: "deflistitem",
                           container: list_anchor[:container] }
          li.xpath(ns("./dl")).each do |dl|
            deflist_term_anchor_names(dl, list_anchor)
          end
        end
      end

      def deflist_term_anchor_lbl(listitem, list_anchor)
        s = semx(listitem, dt2xreflabel(listitem))
        %(#{list_anchor[:xref]}#{delim_wrap(":")} #{s}</semx>)
      end

      def dt2xreflabel(dterm)
        label = dterm.dup
        label.xpath(ns(".//p")).each { |x| x.replace(x.children) }
        label.xpath(ns(".//index")).each(&:remove)
        Common::to_xml(label.children)
      end
    end
  end
end
