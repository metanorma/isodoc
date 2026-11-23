require "spec_helper"

RSpec.describe "HTML heading identifier determinism" do
  let(:input) do
    <<~HTML
      <html><body><div id="toc"></div><main>
        <div id="scope"><h1>Scope</h1><p id="body-text">Same source.</p></div>
        <div id="terms"><h1>Terms</h1>
          <div id="definitions"><h1>Definitions</h1>
            <p class="TermNum" id="term-alpha">alpha</p>
            <p class="TermNum" id="term-beta">beta</p>
          </div>
        </div>
      </main></body></html>
    HTML
  end

  def converter
    IsoDoc::HtmlConvert.new({}).tap do |instance|
      instance.instance_variable_set(:@htmlToClevels, 2)
    end
  end

  def render_headings(source)
    document = Nokogiri::HTML(source)
    instance = converter
    instance.term_header(document)
    instance.heading_anchors(document)
    instance.html_toc(document)
    document
  end

  it "produces byte-identical heading markup and TOC for identical input" do
    first = render_headings(input)
    second = render_headings(input)

    expect(first.to_html).to eq(second.to_html)
    expect(first.css("h1,h2").map { |h| h["id"] }).to all(be_a(String))
  end

  it "retains original term anchors while making term headings stable" do
    first = render_headings(input)
    second = render_headings(input)

    %w(term-alpha term-beta).each do |id|
      heading = first.at("div[id='#{id}'] > h2.TermNum")
      expect(heading).not_to be_nil
      expect(heading["id"]).not_to eq(id)
      expect(heading["id"]).to eq(second.at("div[id='#{id}'] > h2.TermNum")["id"])
      expect(first.css("a.anchor[href='##{id}']").length).to eq(1)
    end
  end

  it "keeps existing heading identifiers and semantic TOC targets" do
    document = render_headings(input.sub("<h1>Scope", '<h1 id="author-heading">Scope'))

    expect(document.at("#author-heading").name).to eq("h1")
    expect(document.at("#toc a[href='#scope']")).not_to be_nil
    expect(document.at("#body-text").text).to eq("Same source.")
  end

  it "gives repeated anonymous headings distinct, stable TOC targets" do
    source = '<html><body><div id="toc"></div><main><h1>Repeat</h1><h1>Repeat</h1></main></body></html>'
    first = render_headings(source)
    second = render_headings(source)
    ids = first.css("main h1").map { |h| h["id"] }

    expect(ids.uniq.length).to eq(2)
    expect(ids).to eq(second.css("main h1").map { |h| h["id"] })
    expect(first.css("#toc a").map { |a| a["href"] }).to eq(ids.map { |id| "##{id}" })
  end

  it "avoids generated IDs that collide with existing anchors" do
    document = Nokogiri::HTML('<html><body><main><h1>Scope</h1></main></body></html>')
    heading = document.at("h1")
    base = Metanorma::Utils.contenthash(heading)
    document.at("body") << %(<span id="#{base}"></span><span id="#{base}-1"></span>)

    converter.html_toc_entries_prep(document, ["//main//h1"])

    expect(heading["id"]).to eq("#{base}-2")
    expect(document.xpath("//*[@id]").map { |n| n["id"] }.uniq.length).to eq(3)
  end

  it "keeps generated term IDs distinct from existing anchors" do
    document = Nokogiri::HTML(input)
    term = document.at("#term-alpha")
    term.name = "h2"
    base = Metanorma::Utils.contenthash(term)
    term.name = "p"
    document.at("body") << %(<span id="#{base}"></span>)

    converter.term_header(document)

    expect(document.at("div#term-alpha > h2")["id"]).to eq("#{base}-1")
    ids = document.xpath("//*[@id]").map { |node| node["id"] }
    expect(ids.uniq.length).to eq(ids.length)
  end
end
