module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    # Entry point: find all top-level (ol|ul)[@display='table'] and convert each
    def list_to_table(docxml)
      docxml.xpath(ns("//ol[@display='table'] | //ul[@display='table']"))
        .each do |elem|
        list_table_convert(elem)
      end
    end

    # Convert a single display="table" list: build table, insert under fmt-ol
    def list_table_convert(elem)
      n = list_table_depth(elem)
      table = list_table_build(elem, n)
      elem << "<fmt-#{elem.name}></fmt-#{elem.name}>"
      elem.elements.last << table
    end

    # Maximum depth of nested ol/ul: elem itself = depth 1
    def list_table_depth(elem)
      depths = [1]
      elem.xpath(ns(".//ol | .//ul")).each do |sub|
        d = sub.ancestors.take_while { |a| a != elem }
          .count { |a| %w[ol ul].include?(a.name) } + 2
        depths << d
      end
      depths.max
    end

    # Build the full table as a Nokogiri node
    def list_table_build(elem, cellcount)
      xml = "<table>"
      xml += list_table_name(elem)
      xml += list_table_colgroup(elem, cellcount)
      xml += list_table_header(elem, cellcount)
      xml += list_table_body(elem, cellcount)
      xml += "</table>"
      Nokogiri::XML(xml).root
    end

    # global table title if there are no nested titled in the list:
    # move list/fmt-name to ol/fmt-ol/table/fmt-name: ol/fmt-ol is all we render
    def list_table_name(elem)
      list_only_one_title(elem) or return ""
      ret = elem.at(ns("./fmt-name")) or return ""
      to_xml(ret.remove)
    end

    def list_table_colgroup(elem, cellcount)
      n = elem["display-directives"] or return ""
      attrs = csv_attribute_extract(n)
      attrs[:colgroup] or return ""
      vals = attrs[:colgroup].split(",").map(&:to_f)
      vals = list_table_normalise_colgroup(vals, cellcount)
      ret = vals.map { |n| "<col width='#{n}%'/>" }.join
      "<colgroup>#{ret}</colgroup>"
    end

    def list_table_normalise_colgroup(vals, cellcount)
      vals.size > cellcount and vals = vals[0...cellcount]
      if vals.size < cellcount
        (vals.size...cellcount).each do |_i|
          vals << 10.0
        end
      end
      sum = vals.sum
      vals.map { |i| 100 * i / sum }
    end

    # Build <thead><tr> with n <th> cells, one per depth level
    def list_table_header(elem, cellcount)
      list_only_one_title(elem) and return ""
      ths = (1..cellcount).map { |i| list_table_th(elem, i) }.join
      "<thead><tr>#{ths}</tr></thead>"
    end

    def list_only_one_title(elem)
      (!elem.at(ns(".//ol//name")) && !elem.at(ns(".//ul//name"))) or return nil
      elem.at(ns("./name"))
    end

    def list_table_th(elem, depth)
      name = list_table_col_name(elem, depth)
      name or return "<th/>"
      add_id(name)
      src = name["original-id"] || name["id"]
      children = to_xml(name.children)
      <<~XML
        <th><fmt-name><semx element='name' source='#{src}'>#{children}</semx></fmt-name></th>
      XML
    end

    # Find the <name> element of the first ol/ul at the given depth within elem
    def list_table_col_name(elem, depth)
      list_at_depth(elem, depth)&.at(ns("./name"))
    end

    # Return the first ol/ul at the given depth (depth 1 = elem itself)
    def list_at_depth(elem, target_depth)
      target_depth == 1 and return elem
      elem.xpath(ns(".//ol | .//ul")).find do |sub|
        d = sub.ancestors.take_while { |a| a != elem }
          .count { |a| %w[ol ul].include?(a.name) } + 2
        d == target_depth
      end
    end

    # Build <tbody> with one <tr> per leaf (terminal sublist) path
    def list_table_body(elem, cellcount)
      paths = list_table_leaf_paths(elem, 1)
      emitted = {} # li object_id => true when already emitted under a rowspan
      rows = paths.map do |path|
        list_table_row(path, cellcount, emitted)
      end.join
      "<tbody>#{rows}</tbody>"
    end

    def list_table_row(path, cellcount, emitted)
      cells = path.map do |step|
        if step[:terminal]
          if step[:li]
            # Degenerate: single li with no child sublist —
            # render just that li with colspan
            list_table_degen_terminal_td(step[:list], step[:li], step[:li_idx],
                                              step[:depth], cellcount)
          else
            list_table_terminal_td(step[:list], step[:depth], cellcount)
          end
        else
          li = step[:li]
          emitted[li.object_id] and next
          rowspan = list_table_count_terminals(li)
          emitted[li.object_id] = true
          list_table_nonterminal_td(step[:list], li, step[:li_idx], rowspan,
                                    step[:depth])
        end
      end.compact.join
      "<tr>#{cells}</tr>"
    end

    # Recursively collect all leaf paths from xl downward.
    # Each path is an array of step hashes; the last step has terminal: true.
    # Non-terminal step: { list:, li:, depth:, li_idx: }
    # Terminal step:     { list:, depth:, terminal: true }
    def list_table_leaf_paths(xl, depth)
      paths = []
      xl.xpath(ns("./li")).each_with_index do |li, idx|
        li_idx = idx + 1
        sub_xls = li.children.select { |c| %w[ol ul].include?(c.name) }
        if sub_xls.empty?
          # Degenerate: li with no child sublist — treat as its own terminal row
          paths << [{ list: xl, li:, depth:, li_idx:, terminal: true }]
        else
          sub_xls.each do |sub_xl|
            step = { list: xl, li: li, depth: depth, li_idx: li_idx }
            if (sub_xl.xpath(ns(".//ol")) + sub_xl.xpath(ns(".//ul"))).empty?
              paths << [step,
                        { list: sub_xl, depth: depth + 1, terminal: true }]
            else
              list_table_leaf_paths(sub_xl, depth + 1).each do |sub_path|
                paths << ([step] + sub_path)
              end
            end
          end
        end
      end
      paths
    end

    # Count terminal sublists reachable from a li element (used for rowspan)
    def list_table_count_terminals(listitem)
      sub_xls = listitem.children.select { |c| %w[ol ul].include?(c.name) }
      sub_xls.empty? and return 1
      count = 0
      sub_xls.each do |sub_xl|
        count += list_table_count_terminals_recurse(sub_xl)
      end
      [count, 1].max
    end

    def list_table_count_terminals_recurse(sub_xl)
      ret = 0
      (sub_xl.xpath(ns(".//ol")) + sub_xl.xpath(ns(".//ul"))).empty? and
        return 1
      sub_xl.xpath(ns("./li")).each do |sub_li|
        ret += list_table_count_terminals(sub_li)
      end
      ret
    end

    # Build a nonterminal <td>: wraps a single li (minus nested sublists)
    # in an ol/ul with appropriate start, type, and rowspan
    def list_table_nonterminal_td(list, listitem, li_idx, rowspan, depth)
      rowspan_attr = rowspan > 1 ? " rowspan='#{rowspan}'" : ""
      li_content = list_table_li_content(listitem)
      if list.name == "ol"
        start = list_table_calc_start(list, li_idx)
        type = @counter.ol_type(list, depth).to_s
        "<td#{rowspan_attr}><ol start='#{start}' type='#{type}'>" \
          "<li>#{li_content}</li></ol></td>"
      else
        "<td#{rowspan_attr}><ul><li>#{li_content}</li></ul></td>"
      end
    end

    # Serialize a li's content, excluding any direct ol/ul children
    def list_table_li_content(listitem)
      listitem.children.reject { |c| %w[ol ul].include?(c.name) }
        .map { |c| to_xml(c) }.join
    end

    # Build a terminal <td> for a degenerate li (no child sublist),
    # wrapping just that single li with the correct colspan
    def list_table_degen_terminal_td(list, listitem, li_idx, depth, cellcount)
      colspan = cellcount - depth + 1
      colspan_attr = colspan > 1 ? " colspan='#{colspan}'" : ""
      li_content = list_table_li_content(listitem)
      if list.name == "ol"
        start = list_table_calc_start(list, li_idx)
        type = @counter.ol_type(list, depth).to_s
        "<td#{colspan_attr}><ol start='#{start}' type='#{type}'>" \
          "<li>#{li_content}</li></ol></td>"
      else
        "<td#{colspan_attr}><ul><li>#{li_content}</li></ul></td>"
      end
    end

    # Build a terminal <td>: contains the whole sublist,
    # with colspan if depth < cellcount
    def list_table_terminal_td(xl, depth, cellcount)
      colspan = cellcount - depth + 1
      colspan_attr = colspan > 1 ? " colspan='#{colspan}'" : ""
      xl_dup = xl.dup
      # Remove <name> from the copy (names go in thead, not in the cell body)
      xl_dup.children.each { |c| c.name == "name" and c.remove }
      if xl.name == "ol"
        type = @counter.ol_type(xl, depth).to_s
        xl_dup["type"] = type
      end
      "<td#{colspan_attr}>#{to_xml(xl_dup)}</td>"
    end

    # Calculate the start number for a wrapped ol cell
    # (original ol start) + (0-based position of this li) = start
    # for this li's number
    def list_table_calc_start(list, li_idx)
      (list["start"] || 1).to_i + li_idx - 1
    end
  end
end
