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
        out.span class: "zzMoveToFollowing inline-header" do |s|
          s.b do |b|
            title&.children&.each { |c2| parse(c2, b) }
            clausedelimspace(node, out) if /\S/.match?(title&.text)
          end
        end
      end

      def sections_names
        %w[clause annex terms references definitions executivesummary
           acknowledgements introduction abstract foreword appendix]
      end

      def freestanding_title(node, out)
        # node.parent.at(ns("./fmt-title[@source = '#{node['id']}']")) and
        # return # this title is already being rendered as fmt-title
        # For testing convenience, let's just go by parent
        sections_names.include?(node.parent.name) and return
        parents = node.ancestors(sections_names.join(", "))
        clause_parse_title(parents.empty? ? node : parents.first,
                           out, node, out)
      end

      # used for subclauses
      def clause_parse_title(node, div, title, out, header_class = {})
        title.nil? and return
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
        depth = title["depth"] if title && title["depth"]
        depth ||= node.ancestors(sections_names.join(", ")).size + 1
        depth
      end

      def clause_parse_subtitle(title, heading)
        if var = title&.at("./following-sibling::xmlns:variant-title" \
                           "[@type = 'sub']")&.remove
          heading.br nil
          heading.br nil
          var.children.each { |c2| parse(c2, heading) }
        end
      end

      # top level clause names
      def clause_name(_node, title, div, header_class)
        header_class = {} if header_class.nil?
        div.h1 **attr_code(header_class) do |h1|
          if title.is_a?(String) then h1 << title
          elsif title
            children_parse(title, h1)
            clause_parse_subtitle(title, h1)
          end
        end
        div.parent.at(".//h1")
      end

      def annex_name(_annex, name, div)
        name.nil? and return
        div.h1 class: "Annex" do |t|
          name.children.each { |c2| parse(c2, t) }
          clause_parse_subtitle(name, t)
        end
      end

      def variant_title(node, out)
        out.p **attr_code(style: "display:none;",
                          class: "variant-title-#{node['type']}") do |p|
          children_parse(node, p)
        end
      end
    end
  end
end
