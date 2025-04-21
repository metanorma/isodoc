# frozen_string_literal: true

module IsoDoc
  # CssBorderParser provides functionality to parse CSS border shorthand properties
  # and break them down into atomic CSS attributes.
  class CssBorderParser
    # BorderParser class handles the parsing of CSS border properties
    class BorderParser
      # Default values according to CSS specifications
      DEFAULT_VALUES = {
        "width" => "medium",
        "style" => "none",
        "color" => "currentColor",
      }.freeze

      # CSS border width values
      BORDER_WIDTHS = ["thin", "medium", "thick"].freeze

      # CSS border style values
      BORDER_STYLES = [
        "none", "hidden", "dotted", "dashed", "solid", "double",
        "groove", "ridge", "inset", "outset"
      ].freeze

      # CSS color keywords
      COLOR_KEYWORDS = [
        "black", "silver", "gray", "white", "maroon", "red", "purple",
        "fuchsia", "green", "lime", "olive", "yellow", "navy", "blue",
        "teal", "aqua", "orange", "aliceblue", "antiquewhite", "aquamarine",
        "azure", "beige", "bisque", "blanchedalmond", "blueviolet", "brown",
        "burlywood", "cadetblue", "chartreuse", "chocolate", "coral",
        "cornflowerblue", "cornsilk", "crimson", "cyan", "darkblue",
        "darkcyan", "darkgoldenrod", "darkgray", "darkgreen", "darkgrey",
        "darkkhaki", "darkmagenta", "darkolivegreen", "darkorange",
        "darkorchid", "darkred", "darksalmon", "darkseagreen", "darkslateblue",
        "darkslategray", "darkslategrey", "darkturquoise", "darkviolet",
        "deeppink", "deepskyblue", "dimgray", "dimgrey", "dodgerblue",
        "firebrick", "floralwhite", "forestgreen", "gainsboro", "ghostwhite",
        "gold", "goldenrod", "greenyellow", "grey", "honeydew", "hotpink",
        "indianred", "indigo", "ivory", "khaki", "lavender", "lavenderblush",
        "lawngreen", "lemonchiffon", "lightblue", "lightcoral", "lightcyan",
        "lightgoldenrodyellow", "lightgray", "lightgreen", "lightgrey",
        "lightpink", "lightsalmon", "lightseagreen", "lightskyblue",
        "lightslategray", "lightslategrey", "lightsteelblue", "lightyellow",
        "limegreen", "linen", "magenta", "mediumaquamarine", "mediumblue",
        "mediumorchid", "mediumpurple", "mediumseagreen", "mediumslateblue",
        "mediumspringgreen", "mediumturquoise", "mediumvioletred",
        "midnightblue", "mintcream", "mistyrose", "moccasin", "navajowhite",
        "oldlace", "olivedrab", "orangered", "orchid", "palegoldenrod",
        "palegreen", "paleturquoise", "palevioletred", "papayawhip",
        "peachpuff", "peru", "pink", "plum", "powderblue", "rosybrown",
        "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen",
        "seashell", "sienna", "skyblue", "slateblue", "slategray",
        "slategrey", "snow", "springgreen", "steelblue", "tan", "thistle",
        "tomato", "turquoise", "violet", "wheat", "whitesmoke",
        "yellowgreen", "transparent", "currentColor"
      ].freeze
      
      # Mapping of CSS color names to RGB hex values
      COLOR_MAP = {
        "black" => "#000000",
        "silver" => "#C0C0C0",
        "gray" => "#808080",
        "white" => "#FFFFFF",
        "maroon" => "#800000",
        "red" => "#FF0000",
        "purple" => "#800080",
        "fuchsia" => "#FF00FF",
        "green" => "#008000",
        "lime" => "#00FF00",
        "olive" => "#808000",
        "yellow" => "#FFFF00",
        "navy" => "#000080",
        "blue" => "#0000FF",
        "teal" => "#008080",
        "aqua" => "#00FFFF",
        "orange" => "#FFA500",
        "aliceblue" => "#F0F8FF",
        "antiquewhite" => "#FAEBD7",
        "aquamarine" => "#7FFFD4",
        "azure" => "#F0FFFF",
        "beige" => "#F5F5DC",
        "bisque" => "#FFE4C4",
        "blanchedalmond" => "#FFEBCD",
        "blueviolet" => "#8A2BE2",
        "brown" => "#A52A2A",
        "burlywood" => "#DEB887",
        "cadetblue" => "#5F9EA0",
        "chartreuse" => "#7FFF00",
        "chocolate" => "#D2691E",
        "coral" => "#FF7F50",
        "cornflowerblue" => "#6495ED",
        "cornsilk" => "#FFF8DC",
        "crimson" => "#DC143C",
        "cyan" => "#00FFFF",
        "darkblue" => "#00008B",
        "darkcyan" => "#008B8B",
        "darkgoldenrod" => "#B8860B",
        "darkgray" => "#A9A9A9",
        "darkgreen" => "#006400",
        "darkgrey" => "#A9A9A9",
        "darkkhaki" => "#BDB76B",
        "darkmagenta" => "#8B008B",
        "darkolivegreen" => "#556B2F",
        "darkorange" => "#FF8C00",
        "darkorchid" => "#9932CC",
        "darkred" => "#8B0000",
        "darksalmon" => "#E9967A",
        "darkseagreen" => "#8FBC8F",
        "darkslateblue" => "#483D8B",
        "darkslategray" => "#2F4F4F",
        "darkslategrey" => "#2F4F4F",
        "darkturquoise" => "#00CED1",
        "darkviolet" => "#9400D3",
        "deeppink" => "#FF1493",
        "deepskyblue" => "#00BFFF",
        "dimgray" => "#696969",
        "dimgrey" => "#696969",
        "dodgerblue" => "#1E90FF",
        "firebrick" => "#B22222",
        "floralwhite" => "#FFFAF0",
        "forestgreen" => "#228B22",
        "gainsboro" => "#DCDCDC",
        "ghostwhite" => "#F8F8FF",
        "gold" => "#FFD700",
        "goldenrod" => "#DAA520",
        "greenyellow" => "#ADFF2F",
        "grey" => "#808080",
        "honeydew" => "#F0FFF0",
        "hotpink" => "#FF69B4",
        "indianred" => "#CD5C5C",
        "indigo" => "#4B0082",
        "ivory" => "#FFFFF0",
        "khaki" => "#F0E68C",
        "lavender" => "#E6E6FA",
        "lavenderblush" => "#FFF0F5",
        "lawngreen" => "#7CFC00",
        "lemonchiffon" => "#FFFACD",
        "lightblue" => "#ADD8E6",
        "lightcoral" => "#F08080",
        "lightcyan" => "#E0FFFF",
        "lightgoldenrodyellow" => "#FAFAD2",
        "lightgray" => "#D3D3D3",
        "lightgreen" => "#90EE90",
        "lightgrey" => "#D3D3D3",
        "lightpink" => "#FFB6C1",
        "lightsalmon" => "#FFA07A",
        "lightseagreen" => "#20B2AA",
        "lightskyblue" => "#87CEFA",
        "lightslategray" => "#778899",
        "lightslategrey" => "#778899",
        "lightsteelblue" => "#B0C4DE",
        "lightyellow" => "#FFFFE0",
        "limegreen" => "#32CD32",
        "linen" => "#FAF0E6",
        "magenta" => "#FF00FF",
        "mediumaquamarine" => "#66CDAA",
        "mediumblue" => "#0000CD",
        "mediumorchid" => "#BA55D3",
        "mediumpurple" => "#9370DB",
        "mediumseagreen" => "#3CB371",
        "mediumslateblue" => "#7B68EE",
        "mediumspringgreen" => "#00FA9A",
        "mediumturquoise" => "#48D1CC",
        "mediumvioletred" => "#C71585",
        "midnightblue" => "#191970",
        "mintcream" => "#F5FFFA",
        "mistyrose" => "#FFE4E1",
        "moccasin" => "#FFE4B5",
        "navajowhite" => "#FFDEAD",
        "oldlace" => "#FDF5E6",
        "olivedrab" => "#6B8E23",
        "orangered" => "#FF4500",
        "orchid" => "#DA70D6",
        "palegoldenrod" => "#EEE8AA",
        "palegreen" => "#98FB98",
        "paleturquoise" => "#AFEEEE",
        "palevioletred" => "#DB7093",
        "papayawhip" => "#FFEFD5",
        "peachpuff" => "#FFDAB9",
        "peru" => "#CD853F",
        "pink" => "#FFC0CB",
        "plum" => "#DDA0DD",
        "powderblue" => "#B0E0E6",
        "rosybrown" => "#BC8F8F",
        "royalblue" => "#4169E1",
        "saddlebrown" => "#8B4513",
        "salmon" => "#FA8072",
        "sandybrown" => "#F4A460",
        "seagreen" => "#2E8B57",
        "seashell" => "#FFF5EE",
        "sienna" => "#A0522D",
        "skyblue" => "#87CEEB",
        "slateblue" => "#6A5ACD",
        "slategray" => "#708090",
        "slategrey" => "#708090",
        "snow" => "#FFFAFA",
        "springgreen" => "#00FF7F",
        "steelblue" => "#4682B4",
        "tan" => "#D2B48C",
        "thistle" => "#D8BFD8",
        "tomato" => "#FF6347",
        "turquoise" => "#40E0D0",
        "violet" => "#EE82EE",
        "wheat" => "#F5DEB3",
        "whitesmoke" => "#F5F5F5",
        "yellowgreen" => "#9ACD32",
        # Special values that should not be converted
        "transparent" => "transparent",
        "currentColor" => "currentColor"
      }.freeze

      def initialize
        # No initialization needed
      end

      # Parse CSS and extract border properties
      #
      # @param css_string [String] CSS content to parse
      # @return [Hash] Parsed border properties organized by selector
      def parse(css_string)
        results = {}

        # Extract rule sets from CSS
        rule_sets = extract_rule_sets(css_string)

        # Process each rule set
        rule_sets.each do |selector, declarations|
          results[selector] = {}

          # Process border properties and preserve non-border properties
          process_border_properties(declarations, results[selector])
          
          # Store non-border properties
          store_non_border_properties(declarations, results[selector])
        end

        results
      end

      # Parse a CSS declaration string
      #
      # @param css_declaration [String] CSS declaration string (can contain multiple declarations)
      # @return [Hash] Parsed border properties
      def parse_declaration(css_declaration)
        result = {}
        declarations = {}

        # Split multiple declarations if present
        css_declaration.split(';').each do |declaration|
          declaration = declaration.strip
          next if declaration.empty?
          
          # Split property and value
          property, value = declaration.split(":", 2).map(&:strip)
          declarations[property] = value
        end

        # Process border properties
        process_border_properties(declarations, result)
        
        # Store non-border properties
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
        
        # Process border properties
        parsed_properties.each do |property_group, components|
          next if property_group == "other_properties"
          
          if property_group == "border"
            # Handle general border properties
            components.each do |property_type, value|
              css_parts << "border-#{property_type}: #{value};"
            end
          elsif property_group.start_with?("border-")
            # Handle direction-specific border properties
            direction = property_group.sub("border-", "")
            components.each do |property_type, value|
              css_parts << "border-#{direction}-#{property_type}: #{value};"
            end
          end
        end
        
        # Add non-border properties
        if parsed_properties["other_properties"]
          parsed_properties["other_properties"].each do |property, value|
            css_parts << "#{property}: #{value};"
          end
        end
        
        # Format the output
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

      private

      # Extract rule sets from CSS string
      def extract_rule_sets(css_string)
        rule_sets = {}

        # Remove comments
        css_string = css_string.gsub(/\/\*.*?\*\//m, "")

        # Extract rule sets
        css_string.scan(/([^{]+)\{([^}]+)\}/m) do |selector, declarations|
          selector = selector.strip
          declarations_hash = {}

          # Extract declarations
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

        # Split value into parts
        parts = value.split(/\s+/)

        parts.each do |part|
          if is_width?(part)
            components["width"] = part
          elsif is_style?(part)
            components["style"] = part
          elsif is_color?(part)
            # Convert color name to RGB hex if it's a named color
            components["color"] = convert_color_to_rgb(part)
          end
        end

        components
      end
      
      # Convert a color name to its RGB hex value
      def convert_color_to_rgb(color)
        color_lower = color.downcase
        
        # Return the hex value if the color is a named color
        return COLOR_MAP[color_lower] if COLOR_MAP.key?(color_lower)
        
        # Return the original value if it's not a named color or is already in a valid color format
        color
      end

      # Process individual property groups
      def process_individual_properties(declarations, result_hash)
        # Check for individual property groups
        individual_props = {}

        ["width", "style", "color"].each do |property_type|
          property_name = "border-#{property_type}"

          if declarations.key?(property_name)
            # If we don't have a border property yet, create it
            result_hash["border"] ||= {}
            
            # For color properties, convert color names to RGB hex values
            if property_type == "color"
              result_hash["border"][property_type] = convert_color_to_rgb(declarations[property_name])
            else
              result_hash["border"][property_type] = declarations[property_name]
            end
            
            individual_props[property_type] = true
          end
        end

        # If we're only dealing with individual properties (not a shorthand),
        # only include the properties that were explicitly specified
        if individual_props.size > 0 && !declarations.key?("border")
          # Remove default values for properties that weren't specified
          ["width", "style", "color"].each do |property_type|
            unless individual_props[property_type]
              result_hash["border"].delete(property_type)
            end
          end
        end
      end

      # Check if a value is a border width
      def is_width?(value)
        return true if BORDER_WIDTHS.include?(value)
        return true if /^(\d+(\.\d+)?)(px|em|rem|%|pt|pc|in|cm|mm|ex|ch|vw|vh|vmin|vmax)$/.match?(value)
        return true if /^\d+$/.match?(value)

        false
      end

      # Check if a value is a border style
      def is_style?(value)
        BORDER_STYLES.include?(value)
      end

      # Check if a value is a color
      def is_color?(value)
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
