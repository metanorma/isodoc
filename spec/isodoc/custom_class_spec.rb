require "spec_helper"

# metanorma/metanorma-standoc#1197: an author's [class="..."] is rendered
# additively into the block's built-in HTML class (HTML output only).
RSpec.describe IsoDoc do
  def html_for(body)
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="fwd">
      #{body}
      </foreword></preface>
      </iso-standard>
    INPUT
    pres = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    IsoDoc::HtmlConvert.new({}).convert("test", pres, true)
  end

  # the custom token must appear within a class attribute somewhere in the
  # rendered HTML (additive on, or alongside, the block's built-in class)
  def expect_class(html, token)
    expect(html).to match(/class="[^"]*\b#{Regexp.escape(token)}\b[^"]*"/)
  end

  it "renders a custom class additively across blocks" do
    {
      'sourcecode lang="ruby"' => ["cc-src", "<body>puts x</body>"],
      "figure" => ["cc-fig", "<name>F</name>"],
      "example" => ["cc-ex", "<name>E</name><p id='p1'>x</p>"],
      "quote" => ["cc-quo", "<p id='p2'>x</p>"],
      "p" => ["cc-par", "x"],
      "ul" => ["cc-ul", "<li><p id='l1'>x</p></li>"],
      "ol" => ["cc-ol", "<li><p id='l2'>x</p></li>"],
      "note" => ["cc-note", "<p id='p3'>x</p>"],
    }.each do |tag, (token, inner)|
      name = tag.split.first
      html = html_for(%(<#{tag} id="x_#{token}" class="#{token}">#{inner}</#{name}>))
      expect_class(html, token)
    end
  end

  it "leaves a class-less block with only its built-in class" do
    html = html_for('<sourcecode lang="ruby" id="s0"><body>x</body></sourcecode>')
    expect(html).to include('class="sourcecode"')
    expect(html).not_to match(/class="[^"]*\bcc-/)
  end

  # pseudocode dispatches on "pseudocode" being among the classes, and passes
  # the other classes through (metanorma/metanorma-standoc#1197)
  it "renders custom classes on a pseudocode alongside the dispatch class" do
    html = html_for(
      '<figure id="ps1" class="pseudocode cc-ps"><name>P</name>' \
      '<p id="pp">a step</p></figure>',
    )
    expect(html).to match(/class="[^"]*\bpseudocode\b[^"]*"/)
    expect(html).to match(/class="[^"]*\bcc-ps\b[^"]*"/)
  end

  # admonition @class is unused by type-driven labelling, so custom classes are
  # rendered additively after the built-in Admonition classes
  it "renders custom classes on an admonition additively" do
    html = html_for(
      '<admonition id="a1" type="warning" class="cc-adm"><p id="ap">x</p></admonition>',
    )
    expect(html).to match(/class="[^"]*\bAdmonition\b[^"]*\bcc-adm\b[^"]*"/)
  end
end
