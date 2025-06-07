module IsoDoc
  module Function
    module Form
      def form_parse(node, out)
        out.div **attr_code(class: node["class"],
                            id: node["id"]) do |div|
          children_parse(node, div)
        end
      end

      def input_parse(node, out)
        case node["type"]
        when "button" then out << "[#{node['value'] || 'BUTTON'}]"
        when "checkbox" then out << "&#x2610; "
        when "date", "file", "password" then text_input(out)
        when "radio" then out << "&#x25CE; "
        when "submit" # nop
        when "text" then text_input(out, node["maxlength"])
        end
      end

      def text_input(out, length = 10)
        length ||= 10
        length = length.to_i
        length.zero? and length = 10
        out << "_" * length
        out << " "
      end

      def select_parse(node, out)
        text_input(out, node["size"] || 10)
      end

      def label_parse(node, out)
        children_parse(node, out)
      end

      def option_parse(node, out); end

      def textarea_parse(_node, out)
        out.table **{ border: 1, width: "50%" } do |t|
          t.tr do |tr|
            tr.td do |td|
            end
          end
        end
      end
    end
  end
end
