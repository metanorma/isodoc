module Nokogiri
  module XML
    class Node
      def add_first_child(content)
        if children.empty?
          add_child(content)
        else
          children.first.previous = content
        end
        self
      end
    end
  end
end
