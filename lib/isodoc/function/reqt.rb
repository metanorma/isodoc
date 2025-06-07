module IsoDoc
  module Function
    module Blocks
      def recommendation_name(name, out)
        return if name.nil?

        out.p class: "RecommendationTitle" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def reqt_attrs(node, klass)
        attr_code(class: klass, id: node["id"], style: keep_style(node))
      end

      def recommendation_parse(node, out)
        out.div **reqt_attrs(node, "recommend") do |t|
          recommendation_parse1(node, t)
        end
      end

      def recommendation_parse1(node, out)
        p = node.at(ns("./fmt-provision")) or return
        recommendation_name(node.at(ns("./fmt-name")), out)
        p.children.each do |n|
          parse(n, out)
        end
      end

      def requirement_parse(node, out)
        out.div **reqt_attrs(node, "require") do |t|
          recommendation_parse1(node, t)
        end
      end

      def permission_parse(node, out)
        out.div **reqt_attrs(node, "permission") do |t|
          recommendation_parse1(node, t)
        end
      end

      def div_parse(node, out)
        out.div **reqt_attrs(node, node["type"]) do |div|
          children_parse(node, div)
        end
      end
    end
  end
end
