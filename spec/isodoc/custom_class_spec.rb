require "spec_helper"

# metanorma/metanorma-standoc#1197: an author's [class="..."] is rendered
# additively into the block's built-in HTML class (HTML output only).
RSpec.describe IsoDoc do
  def html_for(input)
    pres = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    IsoDoc::HtmlConvert.new({}).convert("test", pres, true)
  end

  it "renders a custom class additively on sourcecode" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="fwd">
      <sourcecode lang="ruby" id="s1" class="special"><body>puts x</body></sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    expect(html_for(input)).to include('class="sourcecode special"')
  end

  it "renders a custom class additively on figure" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="fwd">
      <figure id="f1" class="sortable"><name>Fig</name></figure>
      </foreword></preface>
      </iso-standard>
    INPUT
    expect(html_for(input)).to include('class="figure sortable"')
  end

  it "leaves the built-in class untouched when no custom class is given" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="fwd">
      <sourcecode lang="ruby" id="s1"><body>puts x</body></sourcecode>
      <figure id="f1"><name>Fig</name></figure>
      </foreword></preface>
      </iso-standard>
    INPUT
    html = html_for(input)
    expect(html).to include('class="sourcecode"')
    expect(html).to include('class="figure"')
  end
end
