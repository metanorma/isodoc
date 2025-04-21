# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::CssBorderParser::BorderParser do
  let(:parser) { IsoDoc::CssBorderParser::BorderParser.new }

  describe "#parse" do
    context "with non-border properties" do
      it "preserves non-border properties" do
        css = "div { color: blue; font-size: 12px; border: 2px solid red; margin: 5px; }"
        result = parser.parse(css)
        
        # Check that border properties are parsed correctly
        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "#FF0000",
                 })
        
        # Check that non-border properties are preserved
        expect(result["div"]["other_properties"])
          .to eq({
                   "color" => "blue",
                   "font-size" => "12px",
                   "margin" => "5px",
                 })
      end
    end

    context "with complete border shorthand" do
      it "parses border with all components specified" do
        css = "div { border: 2px solid red; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "#FF0000",
                 })
      end
    end

    context "with partial border shorthand" do
      it "parses border with missing color" do
        css = "div { border: 2px solid; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "currentColor",
                 })
      end

      it "parses border with missing width" do
        css = "div { border: solid red; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "medium",
                   "style" => "solid",
                   "color" => "#FF0000",
                 })
      end

      it "parses border with missing style" do
        css = "div { border: 2px red; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "none",
                   "color" => "#FF0000",
                 })
      end

      it "parses border with only width" do
        css = "div { border: 2px; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "none",
                   "color" => "currentColor",
                 })
      end

      it "parses border with only style" do
        css = "div { border: solid; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "medium",
                   "style" => "solid",
                   "color" => "currentColor",
                 })
      end

      it "parses border with only color" do
        css = "div { border: red; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "medium",
                   "style" => "none",
                   "color" => "#FF0000",
                 })
      end

      it "preserves special color values" do
        css = "div { border: 2px solid transparent; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "transparent",
                 })

        css = "div { border: 2px solid currentColor; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "currentColor",
                 })
      end

      it "preserves hex color values" do
        css = "div { border: 2px solid #123456; }"
        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "#123456",
                 })
      end
    end

    context "with direction-specific borders" do
      it "parses all direction-specific borders" do
        css = <<-CSS
          div {
            border-top: 1px solid black;
            border-right: 2px dashed green;
            border-bottom: 3px dotted blue;
            border-left: 4px double red;
          }
        CSS

        result = parser.parse(css)

        expect(result["div"]["border-top"])
          .to eq({
                   "width" => "1px",
                   "style" => "solid",
                   "color" => "#000000",
                 })

        expect(result["div"]["border-right"])
          .to eq({
                   "width" => "2px",
                   "style" => "dashed",
                   "color" => "#008000",
                 })

        expect(result["div"]["border-bottom"])
          .to eq({
                   "width" => "3px",
                   "style" => "dotted",
                   "color" => "#0000FF",
                 })

        expect(result["div"]["border-left"])
          .to eq({
                   "width" => "4px",
                   "style" => "double",
                   "color" => "#FF0000",
                 })
      end

      it "parses partial direction-specific borders" do
        css = <<-CSS
          div {
            border-top: 1px;
            border-right: solid;
            border-bottom: blue;
          }
        CSS

        result = parser.parse(css)

        expect(result["div"]["border-top"])
          .to eq({
                   "width" => "1px",
                   "style" => "none",
                   "color" => "currentColor",
                 })

        expect(result["div"]["border-right"])
          .to eq({
                   "width" => "medium",
                   "style" => "solid",
                   "color" => "currentColor",
                 })

        expect(result["div"]["border-bottom"])
          .to eq({
                   "width" => "medium",
                   "style" => "none",
                   "color" => "#0000FF",
                 })
      end
    end

    context "with individual property groups" do
      it "parses individual border properties" do
        css = <<-CSS
          div {
            border-width: 2px;
            border-style: solid;
            border-color: red;
          }
        CSS

        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "solid",
                   "color" => "#FF0000",
                 })
      end
    end

    context "with multiple selectors" do
      it "parses borders for multiple selectors" do
        css = <<-CSS
          div { border: 1px solid black; }
          p { border: 2px dashed red; }
          span { border-top: 3px dotted blue; }
        CSS

        result = parser.parse(css)

        expect(result["div"]["border"])
          .to eq({
                   "width" => "1px",
                   "style" => "solid",
                   "color" => "#000000",
                 })

        expect(result["p"]["border"])
          .to eq({
                   "width" => "2px",
                   "style" => "dashed",
                   "color" => "#FF0000",
                 })

        expect(result["span"]["border-top"])
          .to eq({
                   "width" => "3px",
                   "style" => "dotted",
                   "color" => "#0000FF",
                 })
      end
    end
  end

  describe "#parse_declaration" do
    it "parses a complete border declaration" do
      result = parser.parse_declaration("border: 2px solid red")

      expect(result["border"])
        .to eq({
                 "width" => "2px",
                 "style" => "solid",
                 "color" => "#FF0000",
               })
    end

    it "parses a partial border declaration" do
      result = parser.parse_declaration("border: 2px solid")

      expect(result["border"])
        .to eq({
                 "width" => "2px",
                 "style" => "solid",
                 "color" => "currentColor",
               })
    end

    it "parses a direction-specific border declaration" do
      result = parser.parse_declaration("border-left: 3px dotted blue")

      expect(result["border-left"])
        .to eq({
                 "width" => "3px",
                 "style" => "dotted",
                 "color" => "#0000FF",
               })
    end

    it "parses a border-color declaration" do
      result = parser.parse_declaration("border-color: green")

      expect(result["border"])
        .to eq({
                 "color" => "#008000",
               })
    end

    it "parses an individual border property declaration" do
      result = parser.parse_declaration("border-width: 2px")

      expect(result["border"])
        .to eq({
                 "width" => "2px",
               })
    end
  end

  describe "#to_css_string" do
    context "with inline format" do
      it "generates CSS string with border properties" do
        parsed_properties = {
          "border" => {
            "width" => "2px",
            "style" => "solid",
            "color" => "#FF0000"
          }
        }
        
        css_string = parser.to_css_string(parsed_properties)
        
        expect(css_string).to include("border-width: 2px;")
        expect(css_string).to include("border-style: solid;")
        expect(css_string).to include("border-color: #FF0000;")
      end
      
      it "generates CSS string with direction-specific border properties" do
        parsed_properties = {
          "border-top" => {
            "width" => "1px",
            "style" => "solid",
            "color" => "#000000"
          },
          "border-bottom" => {
            "width" => "3px",
            "style" => "dotted",
            "color" => "#0000FF"
          }
        }
        
        css_string = parser.to_css_string(parsed_properties)
        
        expect(css_string).to include("border-top-width: 1px;")
        expect(css_string).to include("border-top-style: solid;")
        expect(css_string).to include("border-top-color: #000000;")
        expect(css_string).to include("border-bottom-width: 3px;")
        expect(css_string).to include("border-bottom-style: dotted;")
        expect(css_string).to include("border-bottom-color: #0000FF;")
      end
      
      it "includes non-border properties in the CSS string" do
        parsed_properties = {
          "border" => {
            "width" => "2px",
            "style" => "solid",
            "color" => "#FF0000"
          },
          "other_properties" => {
            "color" => "blue",
            "font-size" => "12px",
            "margin" => "5px"
          }
        }
        
        css_string = parser.to_css_string(parsed_properties)
        
        expect(css_string).to include("border-width: 2px;")
        expect(css_string).to include("border-style: solid;")
        expect(css_string).to include("border-color: #FF0000;")
        expect(css_string).to include("color: blue;")
        expect(css_string).to include("font-size: 12px;")
        expect(css_string).to include("margin: 5px;")
      end
    end
    
    context "with rule_set format" do
      it "generates a CSS rule set" do
        parsed_properties = {
          "border" => {
            "width" => "2px",
            "style" => "solid",
            "color" => "#FF0000"
          },
          "other_properties" => {
            "color" => "blue",
            "font-size" => "12px"
          }
        }
        
        css_string = parser.to_css_string(parsed_properties, format: :rule_set, selector: "div")
        
        expect(css_string).to start_with("div {")
        expect(css_string).to include("border-width: 2px;")
        expect(css_string).to include("border-style: solid;")
        expect(css_string).to include("border-color: #FF0000;")
        expect(css_string).to include("color: blue;")
        expect(css_string).to include("font-size: 12px;")
        expect(css_string).to end_with("}")
      end
    end
  end
end
