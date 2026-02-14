module IsoDoc
  module XrefGen
    module Blocks
      NUMBERED_BLOCKS = %w(termnote termexample note example requirement
                           recommendation permission figure table formula
                           admonition sourcecode).freeze

      def amend_preprocess(xmldoc)
        xmldoc.xpath(ns("//amend[newcontent]")).each do |a|
          amend_preprocess1(a)
        end
      end

      def amend_preprocess1(amend)
        autonum = amend_autonums(amend)
        NUMBERED_BLOCKS.each do |b|
          amend_blocks(amend, autonum, b)
        end
        amdend.xpath(ns("./newcontent/clause")).each do |c|
          amend_preprocess1(c)
        end
      end

      def amend_autonums(amend)
        autonum = {}
        amend.xpath(ns("./autonumber")).each do |n|
          autonum[n["type"]] = n.text
        end
        autonum
      end

      def amend_blocks(amend, autonum, blocktype)
        (amend.xpath(ns("./newcontent//#{blocktype}")) -
         amend.xpath(ns("./newcontent/clause//#{blocktype}")))
          .each_with_index do |e, i|
            autonum[blocktype] && i.zero? and e["number"] = autonum[blocktype]
            !autonum[blocktype] and e["unnumbered"] = "true"
        end
      end

      def termnote_label(node, label)
        if label.blank?
          @labels["termnote"].gsub(/%\s?/, "")
        else
          @labels["termnote"].gsub("%", semx(node, label.to_s))
        end
      end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//*[termnote]")).each do |t|
          c = Counter.new
          t.xpath(ns("./termnote")).noblank.each do |n|
            c.increment(n)
            @anchors[n["id"]] =
              { label: termnote_label(n, c.print), type: "termnote",
                value: c.print, elem: @labels["termnote"],
                container: t["id"],
                xref: anchor_struct_xref(c.print, n, @labels["note_xref"]) }
          end
        end
      end

      # processed from Presentation XML notes_inside_bibitem(),
      # after notes moved: need docid from references processing
      def bibitem_note_names(bib)
        notes = bib.xpath(ns("./formattedref/note"))
        counter = Counter.new
        notes.noblank.each do |n|
          lbl = increment_label(notes, n, counter)
          @anchors[n["id"]] =
            { label: lbl, value: lbl, container: bib["id"],
              xref: anchor_struct_xref(lbl, n, @labels["note_xref"]),
              elem: @labels["note_xref"], type: "note" }
        end
      end

      # note within an asset: table, figure, provision
      def nested_notes(asset, container: true)
        notes = asset.xpath(ns(".//note"))
        counter = Counter.new
        notes.noblank.each do |n|
          lbl = increment_label(notes, n, counter)
          @anchors[n["id"]] =
            { label: lbl, value: lbl, container: container ? asset["id"] : nil,
              xref: anchor_struct_xref(lbl, n, @labels["note_xref"]),
              elem: @labels["note_xref"], type: "note" }.compact
        end
      end

      def termexample_anchor_names(docxml)
        docxml.xpath(ns("//*[termexample]")).each do |t|
          examples = t.xpath(ns("./termexample"))
          examples.noblank.each_with_object(Counter.new) do |n, c|
            c.increment(n)
            idx = increment_label(examples, n, c, increment: false)
            @anchors[n["id"]] =
              { label: idx, type: "termexample", value: idx,
                elem: @labels["example_xref"], container: t["id"],
                xref: anchor_struct_xref(idx, n, @labels["example_xref"]) }
          end
        end
      end

      def note_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(child_asset_path("note")) -
            s.xpath(ns(".//figure//note | .//table//note | //permission//note | " \
              "//recommendation//note | //requirement//note"))
          note_anchor_names1(notes, Counter.new)
          note_anchor_names(s.xpath(ns(child_sections)))
        end
      end

      def note_anchor_names1(notes, counter)
        notes.noblank.each do |n|
          @anchors[n["id"]] =
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["note_xref"], "note",
                          { container: true, unnumb: false })
        end
      end

      def admonition_anchor_names(sections)
        sections.each do |s|
          s.at(ns(".//admonition[@type = 'box']")) or next
          notes = s.xpath(child_asset_path("admonition[@type = 'box']"))
          admonition_anchor_names1(notes, Counter.new)
          admonition_anchor_names(s.xpath(ns(child_sections)))
        end
      end

      def admonition_anchor_names1(notes, counter)
        notes.noblank.each do |n|
          @anchors[n["id"]] ||=
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["box"], "admonition",
                          { container: true, unnumb: n["unnumbered"] })
        end
      end

      # note within an asset: provision
      def nested_examples(asset, container: true)
        notes = asset.xpath(ns(".//example"))
        notes.noblank.each_with_object(Counter.new) do |n, counter|
          @anchors[n["id"]] ||=
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["example_xref"], "example",
                          { unnumb: n["unnumbered"] })
          @anchors[n["id"]][:container] = container ? asset["id"] : nil
        end
      end

      def example_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(child_asset_path("example")) -
            s.xpath(ns("//permission//note | " \
              "//recommendation//note | //requirement//note"))
          example_anchor_names1(notes, Counter.new)
          example_anchor_names(s.xpath(ns(child_sections)))
        end
      end

      def example_anchor_names1(notes, counter)
        notes.noblank.each do |n|
          @anchors[n["id"]] ||=
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["example_xref"], "example",
                          { unnumb: n["unnumbered"], container: true })
        end
      end

      def id_ancestor(node)
        parent = nil
        node.ancestors.each do |a|
          (a["id"] && (parent = a) && @anchors.dig(a["id"], :xref)) or next
          break
        end
        parent ? [parent, parent["id"]] : [nil, nil]
      end

      def bookmark_container(parent)
        if parent
          clause = parent.xpath(CLAUSE_ANCESTOR)&.last
          if clause["id"] == id then nil
          else
            @anchors.dig(clause["id"], :xref)
          end
        end
      end

      def bookmark_anchor_names(xml)
        xml.xpath(ns(".//bookmark")).noblank.each do |n|
          _parent, id = id_ancestor(n)
          @anchors[n["id"]] = { type: "bookmark", label: nil, value: nil,
                                xref: @anchors.dig(id, :xref) || "???",
                                container: @anchors.dig(id, :container) }
        end
      end
    end
  end
end
