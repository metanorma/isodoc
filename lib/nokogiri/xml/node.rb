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

      # Only works for immutable XMLs
      def fast_ancestor_names()
        ancestors = compute_ancestors
        ancestors.map(&:name)
      end

      def compute_ancestors
        return @cached_ancestors if @cached_ancestors

        return NodeSet.new(document) unless respond_to?(:parent)
        return NodeSet.new(document) unless parent

        ancestors = [document] + parent.compute_ancestors
        @cached_ancestors = NodeSet.new(document, ancestors)
      end
    end
  end
end
