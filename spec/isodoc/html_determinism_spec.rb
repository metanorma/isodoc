require "spec_helper"
require "fileutils"
require "tmpdir"
require "digest"

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

RSpec.describe "HTML compilation determinism" do
  # End-to-end regression for metanorma/isodoc#861: compiling the same
  # document twice must produce byte-identical HTML. The document
  # exercises the three places where identifiers or image paths are
  # minted during HTML postprocessing:
  # - TOC-linked clause headings without ids (html_toc_entries_prep),
  # - term headings (term_header),
  # - moved images (move_image1) and the image directory name
  #   (tmpimagedir_suffix).
  let(:image_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  let(:semantic_xml) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <title language="en" type="main">Synthetic document</title>
          <docidentifier type="ISO">99999</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>60</stage><substage>60</substage></status>
        </bibdata>
        <sections>
          <clause id="scope" obligation="normative" inline-header="false" displayorder="1">
            <title>Scope</title>
            <p id="p-scope">This document is a synthetic test.</p>
          </clause>
          <terms id="terms" obligation="normative" displayorder="2">
            <title>Terms and definitions</title>
            <p id="p-terms">For the purposes of this document, the following terms apply.</p>
            <term id="term-alpha">
              <preferred><expression><name>alpha</name></expression></preferred>
            </term>
            <term id="term-beta">
              <preferred><expression><name>beta</name></expression></preferred>
            </term>
          </terms>
          <clause id="figures" obligation="normative" displayorder="3">
            <title>Figures</title>
            <figure id="fig-1">
              <fmt-name>Figure 1</fmt-name>
              <image src="#{image_path}" mimetype="image/png" id="_img1"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  def compile_twice(semantic = semantic_xml)
    presxml = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", semantic, true)

    renders = []
    2.times do
      Dir.mktmpdir("isodoc-determinism") do |dir|
        html = Dir.chdir(dir) do
          IsoDoc::HtmlConvert.new(
            { htmlintropage: File.expand_path(
              File.join(File.dirname(__FILE__), "..", "assets",
                        "htmlintro.html"),
            ),
              htmlstylesheet: File.expand_path(
                File.join(File.dirname(__FILE__), "..", "assets", "html.scss"),
              ) },
          ).convert("test", presxml, false)
          File.read("test.html", encoding: "UTF-8")
        end
        renders << html
      end
    end
    renders
  end

  it "produces byte-identical HTML across compilations" do
    first, second = compile_twice
    expect(second).to eq(first)
  end

  it "moves images to a content-derived path" do
    first, = compile_twice
    srcs = first.scan(%r{src="test_htmlimages/[^"]+"}).uniq
    expected = "test_htmlimages/#{Digest::MD5.file(image_path).hexdigest}.png"
    expect(srcs).to eq(["src=\"#{expected}\""])
  end

  it "generates stable TOC targets for id-less headings" do
    first, second = compile_twice
    doc = Nokogiri::HTML(first)
    heading_ids = doc.xpath("//main//h1[not(@class = 'IntroTitle')]")
      .map { |h| h["id"] }
    second_ids = Nokogiri::HTML(second)
      .xpath("//main//h1[not(@class = 'IntroTitle')]").map { |h| h["id"] }

    expect(heading_ids).to all(be_truthy)
    expect(heading_ids).to eq(second_ids)
    # clause targets referenced from the ToC resolve to ids in the document
    %w(scope terms).each do |id|
      hrefs = doc.xpath("//div[@id = 'toc']//a/@href").map(&:text)
      expect(hrefs).to include("##{id}")
      expect(doc.xpath("//*[@id = '#{id}']")).not_to be_empty
    end
  end

  it "leaves no dangling links to the removed ToC clause div" do
    # html_toc_init moves the ToC clause heading into the ToC destination
    # and removes the clause div it used to live in: the permalinks minted
    # on that heading pointed at the removed div's id, so they now point
    # at the destination instead.
    first, = compile_twice(<<~XML)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <title language="en" type="main">Synthetic document</title>
          <docidentifier type="ISO">99999</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>60</stage><substage>60</substage></status>
        </bibdata>
        <preface>
          <clause type="toc" id="toc-clause" displayorder="1">
            <title>Table of contents</title>
          </clause>
          <foreword id="fwd" displayorder="2">
            <title>Foreword</title>
            <p>Hello.</p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" obligation="normative" displayorder="3">
            <title>Scope</title>
            <p id="p-scope">This document is a synthetic test.</p>
          </clause>
        </sections>
      </iso-standard>
    XML

    doc = Nokogiri::HTML(first)
    ids = doc.xpath("//*[@id]").map { |n| n["id"] }
    hrefs = doc.xpath("//*[@href]")
      .map { |n| n["href"] }.grep(/\A#/).map { |h| h.sub(/\A#/, "") }

    expect(hrefs).not_to include("toc-clause")
    expect(hrefs - ids).to be_empty
  end
end
