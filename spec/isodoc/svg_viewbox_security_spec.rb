require "spec_helper"
require "benchmark"

RSpec.describe IsoDoc do
  describe "svg_supply_viewbox security" do
    it "handles pathological input without catastrophic backtracking" do
      # Create a mock SVG element with pathological input
      # that would cause exponential backtracking with the old regex /[^0-9]+$/
      mock_svg = {
        "height" => "100" + "/" * 1000,  # Many repeating non-digit characters
        "width" => "200" + "/" * 1000
      }
      
      converter = IsoDoc::HtmlConvert.new({})
      
      # This should complete quickly (under 1 second)
      # With the old regex, this could take minutes or hang
      elapsed = Benchmark.realtime do
        converter.svg_supply_viewbox(mock_svg)
      end
      
      # Verify it completes quickly (should be < 0.1 seconds)
      expect(elapsed).to be < 1.0
      
      # Verify correct behavior: extracts leading digits
      expect(mock_svg["viewbox"]).to eq("0 0 200 100")
    end

    it "correctly extracts digits from various formats" do
      converter = IsoDoc::HtmlConvert.new({})
      
      test_cases = [
        # [height, width, expected_viewbox]
        ["100", "200", "0 0 200 100"],
        ["100px", "200px", "0 0 200 100"],
        ["100pt", "200pt", "0 0 200 100"],
        ["100em", "200rem", "0 0 200 100"],
        ["100///", "200///", "0 0 200 100"],
        ["100 ", "200 ", "0 0 200 100"],
      ]
      
      test_cases.each do |height, width, expected|
        svg = { "height" => height, "width" => width }
        converter.svg_supply_viewbox(svg)
        expect(svg["viewbox"]).to eq(expected), 
          "Failed for height=#{height}, width=#{width}"
      end
    end

    it "returns early when no digits are present" do
      converter = IsoDoc::HtmlConvert.new({})
      
      svg = { "height" => "auto", "width" => "100" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to be_nil
      
      svg = { "height" => "100", "width" => "auto" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to be_nil
      
      svg = { "height" => "px", "width" => "em" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to be_nil
    end

    it "returns early when viewbox already exists" do
      converter = IsoDoc::HtmlConvert.new({})
      
      svg = { "viewbox" => "0 0 50 50", "height" => "100", "width" => "200" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to eq("0 0 50 50")  # Unchanged
    end

    it "returns early when height or width missing" do
      converter = IsoDoc::HtmlConvert.new({})
      
      svg = { "height" => "100" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to be_nil
      
      svg = { "width" => "200" }
      converter.svg_supply_viewbox(svg)
      expect(svg["viewbox"]).to be_nil
    end
  end
end
