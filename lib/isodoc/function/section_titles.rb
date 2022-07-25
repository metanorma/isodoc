module IsoDoc
  module Function
    module Section
      def clausedelim
        "."
      end

      def clausedelimspace(_node, out)
        insert_tab(out, 1)
      end

      def inline_header_title(out, node, title)
        out.span **{ class: "zzMoveToFollowing" } do |s|
          s.b do |b|
            title&.children&.each { |c2| parse(c2, b) }
            clausedelimspace(node, out) if /\S/.match?(title&.text)
          end
        end
      end

      # used for subclauses
      def clause_parse_title(node, div, title, out, header_class = {})
        return if title.nil?

        if node["inline-header"] == "true"
          inline_header_title(out, node, title)
        else
          clause_parse_title1(node, div, title, out, header_class)
        end
      end

      def clause_parse_title1(node, div, title, _out, header_class = {})
        depth = clause_title_depth(node, title)
        div.send "h#{depth}", **attr_code(header_class) do |h|
          title&.children&.each { |c2| parse(c2, h) }
          clause_parse_subtitle(title, h)
        end
      end

      def clause_title_depth(node, title)
        depth = node.ancestors("clause, annex, terms, references, "\
                               "definitions, acknowledgements, introduction, "\
                               "foreword").size + 1
        depth = title["depth"] if title && title["depth"]
        depth
      end

      def clause_parse_subtitle(title, heading)
        if var = title&.at("./following-sibling::xmlns:variant-title"\
                           "[@type = 'sub']")&.remove
          heading.br nil
          heading.br nil
          var.children.each { |c2| parse(c2, heading) }
        end
      end

      # top level clause names
      def clause_name(_num, title, div, header_class)
        preceding_floating_titles(title, div)
        header_class = {} if header_class.nil?
        div.h1 **attr_code(header_class) do |h1|
          if title.is_a?(String) then h1 << title
          else
            title&.children&.each { |c2| parse(c2, h1) }
            clause_parse_subtitle(title, h1)
          end
        end
        div.parent.at(".//h1")
      end

      def annex_name(_annex, name, div)
        preceding_floating_titles(name, div)
        return if name.nil?

        div.h1 **{ class: "Annex" } do |t|
          name.children.each { |c2| parse(c2, t) }
          clause_parse_subtitle(name, t)
        end
      end

      def variant_title(node, out)
        out.p **attr_code(style: "display:none;",
                          class: "variant-title-#{node['type']}") do |p|
          node.children.each { |c| parse(c, p) }
        end
      end

      def preceding_floating_titles(name, div)
        return if name.nil? || name.is_a?(String)

        out = name.parent.xpath("./preceding-sibling::*")
          .reverse.each_with_object([]) do |p, m|
          break m unless p.name == "p"

          m << p
        end or return
        out.each { |c| parse(c, div) }
      end
    end
  end
end
