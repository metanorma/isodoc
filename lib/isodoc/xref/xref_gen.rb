require_relative "xref_gen_seq"

module IsoDoc
  module XrefGen
    module Blocks
      NUMBERED_BLOCKS = %w(termnote termexample note example requirement
                           recommendation permission figure table formula
                           admonition sourcecode).freeze

      def blank?(text)
        text.nil? || text.empty?
      end

      def amend_preprocess(xmldoc)
        xmldoc.xpath(ns("//amend[newcontent]")).each do |a|
          autonum = amend_autonums(a)
          NUMBERED_BLOCKS.each do |b|
            a.xpath(ns("./newcontent//#{b}")).each_with_index do |e, i|
              autonum[b] && i.zero? and e["number"] = autonum[b]
              !autonum[b] and e["unnumbered"] = "true"
            end
          end
        end
      end

      def amend_autonums(amend)
        autonum = {}
        amend.xpath(ns("./autonumber")).each do |n|
          autonum[n["type"]] = n.text
        end
        autonum
      end

      def termnote_label(note)
        @labels["termnote"].gsub(/%/, note.to_s)
      end

      def increment_label(elems, node, counter, increment = true)
        return "" if elems.size == 1 && !node["number"]

        counter.increment(node) if increment
        " #{counter.print}"
      end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[termnote]")).each do |t|
          c = Counter.new
          t.xpath(ns("./termnote")).reject { |n| blank?(n["id"]) }.each do |n|
            c.increment(n)
            @anchors[n["id"]] =
              { label: termnote_label(c.print), type: "termnote", value: c.print,
                xref: l10n("#{anchor(t['id'], :xref)}, "\
                           "#{@labels['note_xref']} #{c.print}") }
          end
        end
      end

      def termexample_anchor_names(docxml)
        docxml.xpath(ns("//term[termexample]")).each do |t|
          examples = t.xpath(ns("./termexample"))
          c = Counter.new
          examples.reject { |n| blank?(n["id"]) }.each do |n|
            c.increment(n)
            idx = increment_label(examples, n, c, false)
            @anchors[n["id"]] =
              anchor_struct(idx, n, @labels["example_xref"], "termexample",
                            n["unnumbered"])
          end
        end
      end

      SECTIONS_XPATH =
        "//foreword | //introduction | //acknowledgements | "\
        "//preface/terms | preface/definitions | preface/references | "\
        "//preface/clause | //sections/terms | //annex | "\
        "//sections/clause | //sections/definitions | "\
        "//bibliography/references | //bibliography/clause".freeze

      def sections_xpath
        SECTIONS_XPATH
      end

      CHILD_NOTES_XPATH =
        "./*[not(self::xmlns:clause) and not(self::xmlns:appendix) and "\
        "not(self::xmlns:terms) and not(self::xmlns:definitions)]//xmlns:note | "\
        "./xmlns:note".freeze

      def note_anchor_names(sections)
        sections.each do |s|
          c = Counter.new
          (notes = s.xpath(CHILD_NOTES_XPATH)).each do |n|
            next if @anchors[n["id"]] || n["id"].nil? || n["id"].empty?

            @anchors[n["id"]] =
              anchor_struct(increment_label(notes, n, c), n,
                            @labels["note_xref"], "note", false)
          end
          note_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      CHILD_EXAMPLES_XPATH =
        "./*[not(self::xmlns:clause) and not(self::xmlns:appendix) and "\
        "not(self::xmlns:terms) and not(self::xmlns:definitions)]//"\
        "xmlns:example | ./xmlns:example".freeze

      CHILD_SECTIONS = "./clause | ./appendix | ./terms | ./definitions | "\
                       "./references".freeze

      def example_anchor_names(sections)
        sections.each do |s|
          c = Counter.new
          (notes = s.xpath(CHILD_EXAMPLES_XPATH)).each do |n|
            next if @anchors[n["id"]] || n["id"].nil? || n["id"].empty?

            @anchors[n["id"]] =
              anchor_struct(increment_label(notes, n, c), n,
                            @labels["example_xref"], "example", n["unnumbered"])
          end
          example_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      def list_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
            s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
          c = Counter.new
          notes.reject { |n| blank?(n["id"]) }.each do |n|
            @anchors[n["id"]] = anchor_struct(increment_label(notes, n, c), n,
                                              @labels["list"], "list", false)
            list_item_anchor_names(n, @anchors[n["id"]], 1, "", notes.size != 1)
          end
          list_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      def list_item_anchor_names(list, list_anchor, depth, prev_label, refer_list)
        c = Counter.new(list["start"] ? list["start"].to_i - 1 : 0)
        list.xpath(ns("./li")).each do |li|
          label = c.increment(li).listlabel(list, depth)
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

      def deflist_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//dl")) - s.xpath(ns(".//clause//dl")) -
            s.xpath(ns(".//appendix//dl")) - s.xpath(ns(".//dl//dl"))
          c = Counter.new
          notes.reject { |n| blank?(n["id"]) }.each do |n|
            @anchors[n["id"]] =
              anchor_struct(increment_label(notes, n, c), n,
                            @labels["deflist"], "deflist", false)
            deflist_term_anchor_names(n, @anchors[n["id"]])
          end
          deflist_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      def deflist_term_anchor_names(list, list_anchor)
        list.xpath(ns("./dt")).each do |li|
          label = l10n("#{list_anchor[:xref]}: #{dt2xreflabel(li)}")
          li["id"] and @anchors[li["id"]] =
                         { xref: label, type: "deflistitem",
                           container: list_anchor[:container] }
          li.xpath(ns("./dl")).each do |dl|
            deflist_term_anchor_names(dl, list_anchor)
          end
        end
      end

      def dt2xreflabel(dterm)
        label = dterm.dup
        label.xpath(ns(".//p")).each { |x| x.replace(x.children) }
        label.xpath(ns(".//index")).each(&:remove)
        label.children.to_xml
      end

      def bookmark_anchor_names(xml)
        xml.xpath(ns(".//bookmark")).reject { |n| blank?(n["id"]) }.each do |n|
          parent = nil
          n.ancestors.each do |a|
            next unless a["id"] && parent = @anchors.dig(a["id"], :xref)

            break
          end
          @anchors[n["id"]] = { type: "bookmark", label: nil, value: nil,
                                xref: parent || "???" }
        end
      end
    end
  end
end
