# frozen_string_literal: true

require "spec_helper"

RSpec.describe IsoDoc::Metadata do
  def info(input)
    c = IsoDoc::Convert.new({})
    c.convert_init(input, "test", false)
    c.info(Nokogiri::XML(input), nil)
  end

  it "populates meta[:bibdata] preserving embedded MathML in a title" do
    input = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="title-main">Internal Standard Reference Data for qNMR: 4,4-Dimethyl-4-silapentane-1-sulfonic acid-<stem block="false" type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="false"><msub><mi>d</mi><mn>6</mn></msub></mstyle></math><asciimath>d_6</asciimath></stem> [ISRD-07]</title>
          <docidentifier primary="true" type="BIPM">BIPM-2019/04</docidentifier>
          <language>en</language>
          <script>Latn</script>
          <status><stage>published</stage></status>
        </bibdata>
      </metanorma>
    XML
    m = info(input)
    expect(m[:bibdata]).not_to be_nil
    # schema_version tracks Relaton model versions and would force this
    # fixture to be re-blessed on every Relaton release, so strip it.
    actual = m[:bibdata].dup
    actual.delete(:schema_version)
    expected = YAML.safe_load(
      File.read("spec/assets/bibdata_mathml_title.yml"),
      permitted_classes: [Date, Symbol], symbolize_names: true,
    )
    expect(actual).to eq expected
  end

  it "excludes boilerplate docidentifiers from meta[:bibdata]" do
    input = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <docidentifier primary="true" type="OGC">24-041</docidentifier>
          <docidentifier type="DOI">10.62973/24-041</docidentifier>
          <docidentifier boilerplate="true">{{ seriesabbr }} {{ docnumeric }}</docidentifier>
          <docnumber>24041</docnumber>
          <status><stage>published</stage></status>
        </bibdata>
      </metanorma>
    XML
    m = info(input)
    expect(m[:bibdata][:docidentifier])
      .to eq [{ content: "24-041", type: "OGC", primary: true },
              { content: "10.62973/24-041", type: "DOI" }]
  end

  it "returns nil meta[:bibdata] without raising on unparseable bibdata" do
    input = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <date type="published"><on>not-a-date</on></date>
          <status><stage>published</stage></status>
        </bibdata>
      </metanorma>
    XML
    m = nil
    expect { m = info(input) }.not_to raise_error
    expect(m).to have_key(:bibdata)
  end

  it "leaves meta[:bibdata] nil when there is no bibdata" do
    m = info("<metanorma xmlns='https://www.metanorma.org/ns/standoc'>" \
             "<sections/></metanorma>")
    expect(m[:bibdata]).to be_nil
  end

  it "re-parses when the bibdata changes on the same Metadata instance" do
    input1 = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard"><docnumber>1111</docnumber>
        <status><stage>draft</stage></status></bibdata>
      </metanorma>
    XML
    input2 = input1.sub("1111", "2222")
    c = IsoDoc::Convert.new({})
    c.convert_init(input1, "test", false)
    expect(c.info(Nokogiri::XML(input1), nil)[:bibdata][:docnumber])
      .to eq "1111"
    expect(c.info(Nokogiri::XML(input2), nil)[:bibdata][:docnumber])
      .to eq "2222"
  end

  it "renders bibdata fields in the HTML cover page through Liquid" do
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { htmlstylesheet: "spec/assets/html.scss",
        htmlcoverpage: "spec/assets/htmlcover_bibdata.html" },
    ).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
        <docidentifier primary="true" type="OGC">24-041</docidentifier>
        <docidentifier type="DOI">10.62973/24-041</docidentifier>
        <docnumber>24041</docnumber>
        <status><stage>published</stage></status>
        <ext><doctype>standard</doctype></ext>
      </bibdata>
      <sections/>
      </iso-standard>
    INPUT
    html = File.read("test.html")
    expect(html)
      .to include "BIBDATA:10.62973/24-041|published|24041|standard"
    FileUtils.rm_f "test.html"
  end
end
