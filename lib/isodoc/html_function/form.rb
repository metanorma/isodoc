module IsoDoc
  module HtmlFunction
    module Form
      def form_parse(node, out)
        out.form **attr_code(id: node["id"], name: node["name"],
                             class: node["class"],
                             action: node["action"]) do |div|
          node.children.each do |n|
            parse(n, div)
          end
        end
      end

      def input_parse(node, out)
        out.input nil, **attr_code(
          id: node["id"], name: node["name"], type: node["type"],
          value: node["value"], disabled: node["disabled"],
          readonly: node["readonly"], checked: node["checked"],
          maxlength: node["maxlength"], minlength: node["minlength"]
        )
      end

      def select_parse(node, out)
        selected = node.at(ns("./option[@value = '#{node['value']}']"))
        selected and selected["selected"] = true
        out.select **attr_code(
          id: node["id"], name: node["name"], size: node["size"],
          disabled: node["disabled"], multiple: node["multiple"]
        ) do |div|
          node.children.each do |n|
            parse(n, div)
          end
        end
      end

      def label_parse(node, out)
        out.label **attr_code(for: node["for"]) do |div|
          node.children.each do |n|
            parse(n, div)
          end
        end
      end

      def option_parse(node, out)
        out.option **attr_code(
          disabled: node["disabled"], selected: node["selected"],
          value: node["value"]
        ) do |o|
          node.children.each do |n|
            parse(n, o)
          end
        end
      end

      def textarea_parse(node, out)
        out.textarea **attr_code(
          id: node["id"], name: node["name"], rows: node["rows"],
          cols: node["cols"]
        ) do |div|
          node["value"] and div << node["value"]
        end
      end
    end
  end
end
