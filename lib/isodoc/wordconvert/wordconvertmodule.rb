
require "html2doc"
require "liquid"

module IsoDoc
  #class WordConvert < Convert
  module WordConvertModule
    def self.included base 
      base.class_eval do
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

        def new_fullcolspan_row(t, tfoot)
          # how many columns in the table?
          cols = 0
          t.at(".//tr").xpath("./td | ./th").each do |td|
            cols += (td["colspan"] ? td["colspan"].to_i : 1)
          end
          style = %{border-top:0pt;mso-border-top-alt:0pt;
      border-bottom:#{SW} 1.5pt;mso-border-bottom-alt:#{SW} 1.5pt;}
          tfoot.add_child("<tr><td colspan='#{cols}' style='#{style}'/></tr>")
          tfoot.xpath(".//td").last
        end

        def make_tr_attr(td, row, totalrows)
          style = td.name == "th" ? "font-weight:bold;" : ""
          rowmax = td["rowspan"] ? row + td["rowspan"].to_i - 1 : row
          style += <<~STYLE
        border-top:#{row.zero? ? "#{SW} 1.5pt;" : 'none;'}
        mso-border-top-alt:#{row.zero? ? "#{SW} 1.5pt;" : 'none;'}
        border-bottom:#{SW} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
        mso-border-bottom-alt:#{SW} #{rowmax == totalrows ? '1.5' : '1.0'}pt;
          STYLE
          { rowspan: td["rowspan"], colspan: td["colspan"],
            align: td["align"], style: style.gsub(/\n/, "") }
        end

        def section_break(body)
          body.br **{ clear: "all", class: "section" }
        end

        def page_break(out)
          out.br **{
            clear: "all",
            style: "mso-special-character:line-break;page-break-before:always",
          }
        end

        def dt_parse(dt, term)
          if dt.elements.empty?
            term.p **attr_code(class: note? ? "Note" : nil,
                               style: "text-align: left;") do |p|
              p << dt.text
            end
          else
            dt.children.each { |n| parse(n, term) }
          end
        end

        def dl_parse(node, out)
          out.table **{ class: "dl" } do |v|
            node.elements.each_slice(2) do |dt, dd|
              v.tr do |tr|
                tr.td **{ valign: "top", align: "left" } do |term|
                  dt_parse(dt, term)
                end
                tr.td **{ valign: "top" } do |listitem|
                  dd.children.each { |n| parse(n, listitem) }
                end
              end
            end
          end
        end



        def postprocess(result, filename, dir)
          generate_header(filename, dir)
          result = from_xhtml(cleanup(to_xhtml(result)))
          toWord(result, filename, dir)
        end

        def toWord(result, filename, dir)
          result = from_xhtml(word_cleanup(to_xhtml(result)))
          result = populate_template(result, :word)
          Html2Doc.process(result, filename: filename, stylesheet: @wordstylesheet,
                           header_file: "header.html", dir: dir,
                           asciimathdelims: [@openmathdelim, @closemathdelim],
                           liststyles: { ul: @ulstyle, ol: @olstyle })
        end

        def word_cleanup(docxml)
          word_preface(docxml)
          word_annex_cleanup(docxml)
          docxml
        end

        # force Annex h2 to be p.h2Annex, so it is not picked up by ToC
        def word_annex_cleanup(docxml)
          docxml.xpath("//h2[ancestor::*[@class = 'Section3']]").each do |h2|
            h2.name = "p"
            h2["class"] = "h2Annex"
          end
        end

        def word_preface(docxml)
          word_cover(docxml) if @wordcoverpage
          word_intro(docxml) if @wordintropage
        end

        def word_cover(docxml)
          cover = to_xhtml_fragment(File.read(@wordcoverpage, encoding: "UTF-8"))
          docxml.at('//div[@class="WordSection1"]').children.first.previous =
            cover.to_xml(encoding: "US-ASCII")
        end

        def word_intro(docxml)
          intro = to_xhtml_fragment(File.read(@wordintropage, encoding: "UTF-8").
                                    sub(/WORDTOC/, make_WordToC(docxml)))
          docxml.at('//div[@class="WordSection2"]').children.first.previous =
            intro.to_xml(encoding: "US-ASCII")
        end

        def generate_header(filename, _dir)
          return unless @header
          template = Liquid::Template.parse(File.read(@header, encoding: "UTF-8"))
          meta = get_metadata
          meta[:filename] = filename
          params = meta.map { |k, v| [k.to_s, v] }.to_h
          File.open("header.html", "w") do |f|
            f.write(template.render(params))
          end
        end

        def word_toc_entry(toclevel, heading)
          bookmark = Random.rand(1000000000)
          <<~TOC
        <p class="MsoToc#{toclevel}"><span class="MsoHyperlink"><span
        lang="EN-GB" style='mso-no-proof:yes'>
        <a href="#_Toc#{bookmark}">#{heading}<span lang="EN-GB"
        class="MsoTocTextSpan">
        <span style='mso-tab-count:1 dotted'>. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan">
        <span style='mso-element:field-begin'></span></span>
        <span lang="EN-GB"
        class="MsoTocTextSpan"> PAGEREF _Toc#{bookmark} \\h </span>
          <span lang="EN-GB" class="MsoTocTextSpan"><span
          style='mso-element:field-separator'></span></span><span
          lang="EN-GB" class="MsoTocTextSpan">1</span>
          <span lang="EN-GB"
          class="MsoTocTextSpan"></span><span
          lang="EN-GB" class="MsoTocTextSpan"><span
          style='mso-element:field-end'></span></span></a></span></span></p>

          TOC
        end

        WORD_TOC_PREFACE = <<~TOC.freeze
      <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\o &quot;1-2&quot; \\h \\z \\u <span
        style='mso-element:field-separator'></span></span>
        TOC

        WORD_TOC_SUFFIX = <<~TOC.freeze
      <p class="MsoToc1"><span lang="EN-GB"><span
        style='mso-element:field-end'></span></span><span
        lang="EN-GB"><o:p>&nbsp;</o:p></span></p>
        TOC

        def make_WordToC(docxml)
          toc = ""
          docxml.xpath("//h1 | //h2[not(ancestor::*[@class = 'Section3'])]").
            each do |h|
            toc += word_toc_entry(h.name == "h1" ? 1 : 2, header_strip(h))
          end
          toc.sub(/(<p class="MsoToc1">)/,
                  %{\\1#{WORD_TOC_PREFACE}}) + WORD_TOC_SUFFIX
        end
      end
    end
  end
end
