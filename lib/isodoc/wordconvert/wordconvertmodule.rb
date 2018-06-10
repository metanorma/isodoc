module IsoDoc
  class WordConvert < Common
    def make_body1(body, _docxml)
      body.div **{ class: "WordSection1" } do |div1|
        div1.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body2(body, docxml)
  body.div **{ class: "WordSection2" } do |div2|
    info docxml, div2
    foreword docxml, div2
    introduction docxml, div2
    div2.p { |p| p << "&nbsp;" } # placeholder
  end
  section_break(body)
end

def make_body3(body, docxml)
  body.div **{ class: "WordSection3" } do |div3|
    middle docxml, div3
    footnotes div3
    comments div3
  end
end

def insert_tab(out, n)
  out.span **attr_code(style: "mso-tab-count:#{n}") do |span|
    [1..n].each { span << "&#xA0; " }
  end
end

def para_attrs(node)
  classtype = nil
  classtype = "Note" if @note
  classtype = "MsoCommentText" if in_comment
  classtype = "Sourcecode" if @annotation
  attrs = { class: classtype, id: node["id"] }
  unless node["align"].nil?
    attrs[:align] = node["align"] unless node["align"] == "justify"
    attrs[:style] = "text-align:#{node['align']}"
  end
  attrs
end

def remove_bottom_border(td)
  td["style"] =
    td["style"].gsub(/border-bottom:[^;]+;/, "border-bottom:0pt;").
    gsub(/mso-border-bottom-alt:[^;]+;/, "mso-border-bottom-alt:0pt;")
end

SW1 = "solid windowtext".freeze

def new_fullcolspan_row(t, tfoot)
  # how many columns in the table?
  cols = 0
  t.at(".//tr").xpath("./td | ./th").each do |td|
    cols += (td["colspan"] ? td["colspan"].to_i : 1)
  end
  style = %{border-top:0pt;mso-border-top-alt:0pt;
      border-bottom:#{SW1} 1.5pt;mso-border-bottom-alt:#{SW1} 1.5pt;}
  tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
  tfoot.xpath(".//td").last
end

def make_tr_attr(td, row, totalrows)
  style = td.name == "th" ? "font-weight:bold;" : ""
  rowmax = td["rowspan"] ? row + td["rowspan"].to_i - 1 : row
  style += <<~STYLE
        border-top:#{row.zero? ? "#{SW1} 1.5pt;" : 'none;'}
        mso-border-top-alt:#{row.zero? ? "#{SW1} 1.5pt;" : 'none;'}
        border-bottom:#{SW1} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
        mso-border-bottom-alt:#{SW1} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
  STYLE
  { rowspan: td["rowspan"], colspan: td["colspan"],
    align: td["align"], style: style.gsub(/\n/, "") }
end

def section_break(body)
  body.br **{ clear: "all", class: "section" }
end

def page_break(out)
  out.br **{ clear: "all",
             style: "mso-special-character:line-break;page-break-before:always" }
end

WORD_DT_ATTRS = {class: @note ? "Note" : nil, align: "left",
                 style: "margin-left:0pt;text-align:left;"}.freeze

def dt_parse(dt, term)
  term.p **attr_code(WORD_DT_ATTRS) do |p|
    if dt.elements.empty?
      p << dt.text
    else
      dt.children.each { |n| parse(n, p) }
    end
  end
end

def dl_parse(node, out)
  out.table **{ class: "dl" } do |v|
    node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
      v.tr do |tr|
        tr.td **{ valign: "top", align: "left" } do |term|
          dt_parse(dt, term)
        end
        tr.td **{ valign: "top" } do |listitem|
          dd.children.each { |n| parse(n, listitem) }
        end
      end
    end
    dl_parse_notes(node, v)
  end
end

def dl_parse_notes(node, v)
  return if node.elements.reject { |n| dt_dd? n }.empty?
  v.tr do |tr|
    tr.td **{ rowspan: 2 } do |td|
      node.elements.reject { |n| dt_dd? n }.each { |n| parse(n, td) }
    end
  end
end

def figure_get_or_make_dl(t)
  dl = t.at(".//table[@class = 'dl']")
  if dl.nil?
    t.add_child("<p><b>#{@key_lbl}</b></p><table class='dl'></table>")
    dl = t.at(".//table[@class = 'dl']")
  end
  dl
end

def figure_aside_process(f, aside, key)
  # get rid of footnote link, it is in diagram
  f&.at("./a[@class='TableFootnoteRef']")&.remove
  fnref = f.at(".//a[@class='TableFootnoteRef']")
  tr = key.add_child("<tr></tr>").first
  dt = tr.add_child("<td valign='top' align='left'></td>").first
  dd = tr.add_child("<td valign='top'></td>").first
  fnref.parent = dt
  aside.xpath(".//p").each do |a|
    a.delete("class")
    a.parent = dd
  end
end
  end
end
