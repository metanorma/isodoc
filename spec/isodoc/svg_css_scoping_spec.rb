require "spec_helper"

RSpec.describe IsoDoc::HtmlFunction::Html do
  it "scopes CSS class names in SVG elements" do
    input = <<~INPUT
      <html>
        <body>
          <div>
            <svg id="a" data-name="Ebene_2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 340 200">
              <defs>
                <style>
                   @import url("https://fonts.googleapis.com/css2?family=Source+Sans+3");
                  .b {
                    font-family: 'Source Sans 3', sans-serif;
                    font-size: 26px;
                  }

                  .c {
                    fill: none;
                    stroke: #000;
                    stroke-miterlimit: 10;
                  }
                </style>
              </defs>
              <g>
                <rect class="c" x="3" y="2.5" width="138" height="65"/>
                <rect class="c" x="3" y="67.5" width="138" height="65"/>
                <rect class="c" x="3" y="132.5" width="138" height="65"/>
              </g>
              <rect class="c" x="204" y="69.5" width="133" height="65"/>
              <text class="b" transform="translate(28.22 43.14)"><tspan x="0" y="0">Objects</tspan></text>
              <text class="b" transform="translate(50.09 98.14)"><tspan x="0" y="0">File</tspan><tspan x="-30.39" y="22">structure</tspan></text>
              <text class="b" transform="translate(226.54 100.14)"><tspan x="0" y="0">Content</tspan><tspan x="5.8" y="22">stream</tspan></text>
              <text class="b" transform="translate(12.7 162.14)"><tspan x="0" y="0">Document</tspan><tspan x="6.99" y="22">structure</tspan></text>
            </svg>
          </div>
        </body>
      </html>
    INPUT

    c = IsoDoc::HtmlConvert.new({})
    c.convert("test", input, false)
    result = File.read("test.html", encoding: "utf-8")
    
    # Check that CSS classes have been scoped
    expect(result).to include(".b_svg_class_1")
    expect(result).to include(".c_svg_class_1")
    expect(result).to include('class="b_svg_class_1"')
    expect(result).to include('class="c_svg_class_1"')
    
    # Check that original class names are no longer present in SVG context
    expect(result).not_to include('class="b"')
    expect(result).not_to include('class="c"')
    expect(result).not_to include(".b {")
    expect(result).not_to include(".c {")
  end

  it "handles multiple classes in class attributes" do
    input = <<~INPUT
      <html>
        <body>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <style>
              .class1 { fill: red; }
              .class2 { stroke: blue; }
            </style>
            <rect class="class1 class2" x="10" y="10" width="50" height="50"/>
          </svg>
        </body>
      </html>
    INPUT

    c = IsoDoc::HtmlConvert.new({})
    c.convert("test", input, false)
    result = File.read("test.html", encoding: "utf-8")
    
    # Check that both classes have been scoped
    expect(result).to include(".class1_svg_class_1")
    expect(result).to include(".class2_svg_class_1")
    expect(result).to include('class="class1_svg_class_1 class2_svg_class_1"')
  end

  it "handles complex CSS selectors" do
    input = <<~INPUT
      <html>
        <body>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <style>
              .c, g.b, .c > .d { fill: red; }
              .a:hover { stroke: blue; }
            </style>
            <g class="b">
              <rect class="c" x="10" y="10" width="50" height="50"/>
              <rect class="d" x="60" y="60" width="30" height="30"/>
            </g>
            <rect class="a" x="0" y="0" width="10" height="10"/>
          </svg>
        </body>
      </html>
    INPUT

    c = IsoDoc::HtmlConvert.new({})
    c.convert("test", input, false)
    result = File.read("test.html", encoding: "utf-8")
    
    # Check that complex selectors are properly scoped
    expect(result).to include(".c_svg_class_1, g.b_svg_class_1, .c_svg_class_1 > .d_svg_class_1")
    expect(result).to include(".a_svg_class_1:hover")
    expect(result).to include('class="b_svg_class_1"')
    expect(result).to include('class="c_svg_class_1"')
    expect(result).to include('class="d_svg_class_1"')
    expect(result).to include('class="a_svg_class_1"')
  end

  it "handles multiple SVG elements with different counters" do
    input = <<~INPUT
      <html>
        <body>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <style>
              .test { fill: red; }
            </style>
            <rect class="test" x="10" y="10" width="50" height="50"/>
          </svg>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <style>
              .test { fill: blue; }
            </style>
            <rect class="test" x="10" y="10" width="50" height="50"/>
          </svg>
        </body>
      </html>
    INPUT

    c = IsoDoc::HtmlConvert.new({})
    c.convert("test", input, false)
    result = File.read("test.html", encoding: "utf-8")
    
    # Check that each SVG gets its own counter
    expect(result).to include(".test_svg_class_1")
    expect(result).to include(".test_svg_class_2")
    expect(result).to include('class="test_svg_class_1"')
    expect(result).to include('class="test_svg_class_2"')
  end

  it "ignores SVG elements without style tags" do
    input = <<~INPUT
      <html>
        <body>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <rect class="test" x="10" y="10" width="50" height="50"/>
          </svg>
        </body>
      </html>
    INPUT

    c = IsoDoc::HtmlConvert.new({})
    c.convert("test", input, false)
    result = File.read("test.html", encoding: "utf-8")
    
    # Check that class names are not modified when no style tag is present
    expect(result).to include('class="test"')
    expect(result).not_to include('class="test_svg_class_1"')
  end

  after(:each) do
    FileUtils.rm_f("test.html")
  end
end
