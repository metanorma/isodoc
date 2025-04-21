# frozen_string_literal: true

require_relative "css_border_parser_vars"

module IsoDoc
  # CssBorderParser provides functionality to parse CSS border shorthand
  # properties # and break them down into atomic CSS attributes.
  class CssBorderParser
    # BorderParser class handles the parsing of CSS border properties
    class BorderParser
      def initialize; end # No initialization needed

      # Parse CSS and extract border properties
      #
      # @param css_string [String] CSS content to parse
      # @return [Hash] Parsed border properties organized by selector
      def parse(css_string)
        results = {}
        rule_sets = extract_rule_sets(css_string)
        rule_sets.each do |selector, declarations|
          results[selector] = {}
          process_border_properties(declarations, results[selector])
          store_non_border_properties(declarations, results[selector])
        end

        results
      end

      # Parse a CSS declaration string
      #
      # @param css_declaration [String] CSS declaration string
      # (can contain multiple declarations)
      # @return [Hash] Parsed border properties
      def parse_declaration(css_declaration)
        result = {}
        declarations = css_declaration.split(";").each_with_object({}) do |d, m|
          d = d.strip
          d.empty? and next
          property, value = d.split(":", 2).map(&:strip)
          m[property] = value
        end
        process_border_properties(declarations, result)
        store_non_border_properties(declarations, result)
        result
      end

      # Generate a CSS string from parsed properties
      #
      # @param parsed_properties [Hash] Parsed CSS properties
      # @param format [Symbol] Output format (:inline, :rule_set)
      # @param selector [String] CSS selector (only used with :rule_set format)
      # @return [String] CSS string representation
      def to_css_string(parsed_properties, format: :inline, selector: nil)
        css_parts = []
        parsed_properties.each do |property_group, components|
          property_group == "other_properties" and next
          if property_group == "border"
            components.each do |property_type, value|
              css_parts << "border-#{property_type}: #{value};"
            end
          elsif property_group.start_with?("border-")
            # direction-specific border properties
            direction = property_group.sub("border-", "")
            components.each do |property_type, value|
              css_parts << "border-#{direction}-#{property_type}: #{value};"
            end
          end
        end
        # non-border properties
        parsed_properties["other_properties"]&.each do |property, value|
          css_parts << "#{property}: #{value};"
        end
        format_properties(format, css_parts, selector)
      end

      private

      def format_properties(format, css_parts, selector)
        case format
        when :inline
          css_parts.join(" ")
        when :rule_set
          selector = selector || "selector"
          "#{selector} {\n  #{css_parts.join("\n  ")}\n}"
        else
          css_parts.join(" ")
        end
      end

      # Extract rule sets from CSS string
      def extract_rule_sets(css_string)
        rule_sets = {}
        css_string = css_string.gsub(/\/\*.*?\*\//m, "") # Remove comments
        css_string.scan(/([^{]+)\{([^}]+)\}/m) do |selector, declarations|
          selector = selector.strip
          declarations_hash = {} # Extract declarations
          declarations.scan(/([^:;]+):([^;]+);?/) do |property, value|
            declarations_hash[property.strip] = value.strip
          end
          rule_sets[selector] = declarations_hash
        end
        rule_sets
      end

      # Process border properties from declarations
      def process_border_properties(declarations, result_hash)
        # Process general border property
        process_border_property(declarations, result_hash, "border")
        # Process direction-specific border properties
        ["top", "right", "bottom", "left"].each do |direction|
          process_border_property(declarations, result_hash,
                                  "border-#{direction}")
        end
        # Process individual property groups
        process_individual_properties(declarations, result_hash)
      end

      # Store non-border properties
      def store_non_border_properties(declarations, result_hash)
        # Initialize other_properties hash if it doesn't exist
        result_hash["other_properties"] ||= {}

        # Identify and store non-border properties
        declarations.each do |property, value|
          # Skip border-related properties
          next if property == "border"
          next if property.start_with?("border-")

          # Store non-border property
          result_hash["other_properties"][property] = value
        end
      end

      # Process a specific border property
      def process_border_property(declarations, result_hash, prefix)
        # Check if the property exists
        if declarations.key?(prefix)
          # Parse the border shorthand value
          components = parse_border_value(declarations[prefix])
          result_hash[prefix] = components
        end
      end

      # Parse border shorthand value into components
      def parse_border_value(value)
        components = {
          "width" => DEFAULT_VALUES["width"],
          "style" => DEFAULT_VALUES["style"],
          "color" => DEFAULT_VALUES["color"],
        }
        value.split(/\s+/).each do |part|
          if width?(part) then components["width"] = part
          elsif style?(part) then components["style"] = part
          elsif color?(part)
            components["color"] = convert_color_to_rgb(part)
          end
        end
        components
      end

      # Convert a color name to its RGB hex value
      def convert_color_to_rgb(color)
        color_lower = color.downcase
        # Return the hex value if the color is a named color
        COLOR_MAP.key?(color_lower) and return COLOR_MAP[color_lower]
        # Return the original value if it's not a named color
        # or is already in a valid color format
        color
      end

      # Process individual property groups
      def process_individual_properties(declarations, result)
        # Check for individual property groups
        individual_props = {}
        ["width", "style", "color"].each do |type|
          name = "border-#{type}"
          declarations.key?(name) or next
          # If we don't have a border property yet, create it
          result["border"] ||= {}
          result["border"][type] = if type == "color"
                                     convert_color_to_rgb(declarations[name])
                                   else
                                     declarations[name]
                                   end
          individual_props[type] = true
        end
        process_individual_properties_cleanup(individual_props, declarations,
                                              result)
      end

      # If we're only dealing with individual properties (not a shorthand),
      # only include the properties that were explicitly specified
      def process_individual_properties_cleanup(props, declarations, result)
        if props.size.positive? && !declarations.key?("border")
          # Remove default values for properties that weren't specified
          ["width", "style", "color"].each do |type|
            props[type] or result["border"].delete(type)
          end
        end
      end

      # Check if a value is a border width
      def width?(value)
        return true if BORDER_WIDTHS.include?(value)
        return true if /^(\d+(\.\d+)?)(px|em|rem|%|pt|pc|in|cm|mm|ex|ch|vw|vh|vmin|vmax)$/.match?(value)
        return true if /^\d+$/.match?(value)

        false
      end

      # Check if a value is a border style
      def style?(value)
        BORDER_STYLES.include?(value)
      end

      # Check if a value is a color
      def color?(value)
        return true if COLOR_KEYWORDS.include?(value.downcase)
        return true if /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.match?(value)
        return true if /^rgb\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)$/.match?(value)
        return true if /^rgba\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*[\d.]+\s*\)$/.match?(value)
        return true if /^hsl\(\s*\d+\s*,\s*[\d.]+%\s*,\s*[\d.]+%\s*\)$/.match?(value)
        return true if /^hsla\(\s*\d+\s*,\s*[\d.]+%\s*,\s*[\d.]+%\s*,\s*[\d.]+\s*\)$/.match?(value)

        false
      end
    end
  end
end
