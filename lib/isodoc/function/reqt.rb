module IsoDoc
  module Function
    module Blocks
      def recommendation_labels(node)
        [node.at(ns("./label")), node.at(ns("./title")), node.at(ns("./name"))]
      end

      def recommendation_name(node, out, _type)
        label, title, lbl = recommendation_labels(node)
        out.p **{ class: "RecommendationTitle" } do |b|
          lbl&.children&.each { |n| parse(n, b) }
          b << l10n(":")
          if label || title
            b.br
            label&.children&.each { |n| parse(n, b) }
            b << "#{clausedelim} " if label && title
            title&.children&.each { |n| parse(n, b) }
          end
        end
      end

      def recommendation_attributes1(node)
        out = []
        oblig = node["obligation"] and
          out << l10n("#{@i18n.obligation}: #{oblig}")
        subj = node&.at(ns("./subject"))&.text and
          out << l10n("#{@i18n.subject}: #{subj}")
        node.xpath(ns("./inherit")).each do |i|
          out << recommendation_attr_parse(i, @i18n.inherits)
        end
        node.xpath(ns("./classification")).each do |c|
          line = recommendation_attr_keyvalue(c, "tag", "value") and out << line
        end
        out
      end

      def recommendation_attr_parse(node, label)
        noko do |xml|
          xml << "#{label}: "
          node.children.each { |n| parse(n, xml) }
        end.join
      end

      def recommendation_attr_keyvalue(node, key, value)
        tag = node.at(ns("./#{key}")) or return nil
        value = node.at(ns("./#{value}")) or return nil
        "#{tag.text.capitalize}: #{value.text}"
      end

      def recommendation_attributes(node, out)
        ret = recommendation_attributes1(node)
        return if ret.empty?

        out.p do |p|
          p.i do |i|
            i << ret.join("<br/>")
          end
        end
      end

      def reqt_metadata_node(node)
        %w(label title subject classification tag value
           inherit name).include? node.name
      end

      def reqt_attrs(node, klass)
        attr_code(class: klass, id: node["id"], style: keep_style(node))
      end

      def recommendation_parse(node, out)
        out.div **reqt_attrs(node, "recommend") do |t|
          recommendation_name(node, t, @i18n.recommendation)
          recommendation_attributes(node, out)
          node.children.each do |n|
            parse(n, t) unless reqt_metadata_node(n)
          end
        end
      end

      def requirement_parse(node, out)
        out.div **reqt_attrs(node, "require") do |t|
          recommendation_name(node, t, @i18n.requirement)
          recommendation_attributes(node, out)
          node.children.each do |n|
            parse(n, t) unless reqt_metadata_node(n)
          end
        end
      end

      def permission_parse(node, out)
        out.div **reqt_attrs(node, "permission") do |t|
          recommendation_name(node, t, @i18n.permission)
          recommendation_attributes(node, out)
          node.children.each do |n|
            parse(n, t) unless reqt_metadata_node(n)
          end
        end
      end

      def reqt_component_attrs(node)
        klass = node.name
        klass == "component" and klass = node["class"]
        attr_code(class: "requirement-#{klass}",
                  style: keep_style(node))
      end

      def requirement_component_parse(node, out)
        return if node["exclude"] == "true"

        out.div **reqt_component_attrs(node) do |div|
          node.children.each do |n|
            parse(n, div)
          end
        end
      end

      def requirement_skip_parse(node, out); end
    end
  end
end
