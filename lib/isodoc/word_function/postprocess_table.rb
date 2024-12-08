module IsoDoc
  module WordFunction
    module Postprocess
      def table_note_cleanup(docxml)
        super
        # preempt html2doc putting MsoNormal there
        docxml.xpath("//p[not(self::*[@class])][ancestor::*[@class = 'Note']]")
          .each { |p| p["class"] = "Note" }
      end

      def word_colgroup(docxml)
        cells2d = {}
        docxml.xpath("//table[colgroup]").each do |t|
          w = colgroup_widths(t)
          t.xpath(".//tr").each_with_index { |_tr, r| cells2d[r] = {} }
          t.xpath(".//tr").each_with_index do |tr, r|
            tr.xpath("./td | ./th").each_with_index do |td, _i|
              x = 0
              rs = td.attr("rowspan")&.to_i || 1
              cs = td.attr("colspan")&.to_i || 1
              while cells2d[r][x]
                x += 1
              end
              (r..(r + rs - 1)).each do |y2|
                cells2d[y2].nil? and next
                (x..(x + cs - 1)).each { |x2| cells2d[y2][x2] = 1 }
              end
              width = (x..(x + cs - 1)).each_with_object({ width: 0 }) do |z, m|
                m[:width] += w[z]
              end
              td["width"] = "#{width[:width]}%"
              x += cs
            end
          end
        end
      end

      # assume percentages
      def colgroup_widths(table)
        table.xpath("./colgroup/col").each_with_object([]) do |c, m|
          m << c["width"].sub(/%$/, "").to_f
        end
      end

      def word_nested_tables(docxml)
        docxml.xpath("//table").each do |t|
          t.xpath(".//table").reverse_each do |tt|
            t.next = tt.remove
          end
        end
      end

      def style_update(node, css)
        node or return
        node["style"] =
          node["style"] ? node["style"].sub(/;?$/, ";#{css}") : css
      end

      def word_table_align(docxml)
        docxml.xpath("//td[@align]/p | //th[@align]/p").each do |p|
          p["align"] and next
          style_update(p, "text-align: #{p.parent['align']}")
        end
      end

      def word_table_separator(docxml)
        docxml.xpath("//p[@class = 'TableTitle']").each do |t|
          t.children.empty? or next
          t["style"] = t["style"].sub(/;?$/, ";font-size:0pt;")
          t.children = "&#xa0;"
        end
      end

      def word_table_pagebreak(docxml)
        docxml.xpath("//td[@style] | //th[@style]").each do |t|
          s = /(page-break-after:[^;]+)/.match(t["style"])
          (s && s[1]) or next
          t.xpath(".//div | .//p | .//pre").each do |p|
            style_update(p, s[1])
          end
        end
      end
    end
  end
end
