require "spec_helper"
require "fileutils"
require "tmpdir"
require "digest"

# metanorma-output (the consumer-supplied PDF backend gem) is not a
# dependency of isodoc and is not loaded in this test bundle. Stand in a
# minimal real backend that captures the intermediate HTML handed over for
# rendering, so the Ruby-side pipeline can be pinned byte-for-byte without
# touching the PDF rendering pipeline itself.
unless defined?(Metanorma::Output::Pdf)
  module Metanorma
    module Output
      class Pdf
        CAPTURED = []

        def convert(in_path, _out_path)
          CAPTURED << File.read(in_path, encoding: "UTF-8")
        end
      end
    end
  end
end

RSpec.describe "converter asset store sharing" do
  # All converters of a compile ingest into the same content-addressed
  # asset store when the compile driver supplies the work root; identical
  # images are stored once across converters and documents.
  let(:image_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  let(:presxml) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <title language="en" type="main">Synthetic document</title>
          <docidentifier type="ISO">99999</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>60</stage><substage>60</substage></status>
        </bibdata>
        <sections>
          <clause id="figures" obligation="normative" displayorder="1">
            <fmt-title depth="1" id="_figures_title">Figures</fmt-title>
            <figure id="fig-1">
              <fmt-name id="_fig_name">Figure 1</fmt-name>
              <image src="#{image_path}" mimetype="image/png" id="_img1"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  it "stores an image once across the html and pdf legs of a compile" do
    Dir.mktmpdir("isodoc-store") do |workdir|
      opts = { workdir: workdir,
               htmlstylesheet: File.expand_path(
                 File.join(File.dirname(__FILE__), "..", "assets",
                           "html.scss"),
               ) }
      Dir.mktmpdir("isodoc-out") do |outdir|
        Dir.chdir(outdir) do
          IsoDoc::HtmlConvert.new(opts).convert("test", presxml, false)
          IsoDoc::PdfConvert.new(opts).convert("test", presxml, false)
        end
      end
      store = Dir.children(File.join(workdir, "assets")).sort
      hash = "#{Digest::SHA256.file(image_path).hexdigest}.png"
      expect(store).to eq([hash])
    end
  end

  it "stores an image once across identical documents in one compile" do
    store = published = nil
    Dir.mktmpdir("isodoc-store") do |workdir|
      opts = { workdir: workdir,
               htmlstylesheet: File.expand_path(
                 File.join(File.dirname(__FILE__), "..", "assets",
                           "html.scss"),
               ) }
      Dir.mktmpdir("isodoc-out") do |outdir|
        Dir.chdir(outdir) do
          IsoDoc::HtmlConvert.new(opts).convert("doc1", presxml, false)
          IsoDoc::HtmlConvert.new(opts).convert("doc2", presxml, false)
        end
        store = Dir.children(File.join(workdir, "assets")).sort
        hash = "#{Digest::SHA256.file(image_path).hexdigest}.png"
        # each document materializes its own published, content-addressed set
        published = [
          Dir.children(File.join(outdir, "doc1_htmlimages")),
          Dir.children(File.join(outdir, "doc2_htmlimages")),
        ]
      end
    end
    expect(store).to eq(["#{Digest::SHA256.file(image_path).hexdigest}.png"])
    expect(published)
      .to eq([["#{Digest::SHA256.file(image_path).hexdigest}.png"]] * 2)
  end

  it "emits no random work names into paths or output" do
    names = html = nil
    Dir.mktmpdir("isodoc-store") do |workdir|
      opts = { workdir: workdir,
               htmlstylesheet: File.expand_path(
                 File.join(File.dirname(__FILE__), "..", "assets",
                           "html.scss"),
               ) }
      Dir.mktmpdir("isodoc-out") do |outdir|
        Dir.chdir(outdir) do
          IsoDoc::HtmlConvert.new(opts).convert("test", presxml, false)
        end
        names = Dir.children(File.join(outdir, "test_htmlimages"))
        html = File.read(File.join(outdir, "test.html"))
      end
    end
    expect(html).not_to match(%r{/_[0-9a-f]{16}_})
    expect(names.first).to match(/\A[0-9a-f]{64}\.png\z/)
  end
end

RSpec.describe "headless HTML compilation determinism" do
  let(:image_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  let(:presxml) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
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
            <fmt-title depth="1" id="_toc_title">Table of contents</fmt-title>
          </clause>
        </preface>
        <sections>
          <clause id="scope" obligation="normative" displayorder="2">
            <fmt-title depth="1" id="_scope_title">Scope</fmt-title>
            <p id="p-scope">This document is a synthetic test.</p>
          </clause>
          <clause id="figures" obligation="normative" displayorder="3">
            <fmt-title depth="1" id="_figures_title">Figures</fmt-title>
            <figure id="fig-1">
              <fmt-name id="_fig_name">Figure 1</fmt-name>
              <image src="#{image_path}" mimetype="image/png" id="_img1"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  def compile_headless
    renders = []
    2.times do
      Dir.mktmpdir("isodoc-headless") do |dir|
        html = Dir.chdir(dir) do
          IsoDoc::HeadlessHtmlConvert.new(
            { htmlstylesheet: File.expand_path(
              File.join(File.dirname(__FILE__), "..", "assets", "html.scss"),
            ),
              htmlintropage: File.expand_path(
                File.join(File.dirname(__FILE__), "..", "assets",
                          "htmlintro.html"),
              ) },
          ).convert("test", presxml, false)
          File.read("test.headless.html", encoding: "UTF-8")
        end
        renders << html
      end
    end
    renders
  end

  it "produces byte-identical headless HTML across compilations" do
    first, second = compile_headless
    expect(second).to eq(first)
  end

  it "moves images to a content-addressed path in the headless output" do
    first, = compile_headless
    expected = "test_headlessimages/" \
               "#{Digest::SHA256.file(image_path).hexdigest}.png"
    expect(first.scan(%r{src="test_headlessimages/[^"]+"}).uniq)
      .to eq(["src=\"#{expected}\""])
  end
end

RSpec.describe "Word compilation determinism" do
  let(:image_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  let(:presxml) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <title language="en" type="main">Synthetic document</title>
          <docidentifier type="ISO">99999</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>60</stage><substage>60</substage></status>
        </bibdata>
        <sections>
          <clause id="scope" obligation="normative" displayorder="1">
            <fmt-title depth="1" id="_scope_title">Scope</fmt-title>
            <p id="p-scope">This document is a synthetic test.</p>
          </clause>
          <clause id="figures" obligation="normative" displayorder="2">
            <fmt-title depth="1" id="_figures_title">Figures</fmt-title>
            <figure id="fig-1">
              <fmt-name id="_fig_name">Figure 1</fmt-name>
              <image src="#{image_path}" mimetype="image/png" id="_img1"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  # The .doc output is an MHT multipart document. Its HTML part is fully
  # controlled by isodoc; the remaining per-run differences live outside
  # this gem's control and are normalised here:
  # - `_TocNNNNNNNNN` Word ToC bookmarks, minted by
  #   IsoDoc::WordFunction::Footnotes#bookmarkid from Random.rand
  #   (lib/isodoc/word_function/footnotes.rb). Deterministic bookmark
  #   minting is a reported follow-up, deliberately not in this change.
  # - image part names `cid:<uuid>.png`, minted by the html2doc gem
  #   (lib/html2doc/mime.rb) from UUIDTools entropy.
  def normalize_word_html(part)
    part.gsub(/_Toc\d+/, "_TocN")
      .gsub(%r{cid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.png},
            "cid:IMAGE.png")
  end

  def word_html_part(doc)
    doc.split(/^------=_NextPart_[^\r\n]+/)[1]
  end

  def compile_word
    docs = []
    2.times do
      Dir.mktmpdir("isodoc-word") do |dir|
        doc = Dir.chdir(dir) do
          IsoDoc::WordConvert.new(
            { wordstylesheet: File.expand_path(
              File.join(File.dirname(__FILE__), "..", "assets", "word.css"),
            ),
              header: File.expand_path(
                File.join(File.dirname(__FILE__), "..", "assets",
                          "header.html"),
              ) },
          ).convert("test", presxml, false)
          File.read("test.doc", encoding: "UTF-8")
        end
        docs << doc
      end
    end
    docs
  end

  it "produces identical Word HTML parts across compilations" do
    first, second = compile_word
    expect(normalize_word_html(word_html_part(second)))
      .to eq(normalize_word_html(word_html_part(first)))
  end

  it "leaks no random image directory name into the Word output" do
    first, = compile_word
    expect(first).not_to match(/_[0-9a-f]{16}_images/)
    expect(first).to include("src=\"cid:")
  end
end

RSpec.describe "PDF intermediate determinism" do
  let(:image_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  let(:presxml) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <title language="en" type="main">Synthetic document</title>
          <docidentifier type="ISO">99999</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>60</stage><substage>60</substage></status>
        </bibdata>
        <sections>
          <clause id="figures" obligation="normative" displayorder="1">
            <fmt-title depth="1" id="_figures_title">Figures</fmt-title>
            <figure id="fig-1">
              <fmt-name id="_fig_name">Figure 1</fmt-name>
              <image src="#{image_path}" mimetype="image/png" id="_img1"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    XML
  end

  def compile_pdf
    Metanorma::Output::Pdf::CAPTURED.clear
    2.times do
      Dir.mktmpdir("isodoc-pdf") do |dir|
        Dir.chdir(dir) do
          IsoDoc::PdfConvert.new(
            { htmlstylesheet: File.expand_path(
              File.join(File.dirname(__FILE__), "..", "assets", "html.scss"),
            ) },
          ).convert("test", presxml, false)
        end
      end
    end
    Metanorma::Output::Pdf::CAPTURED.dup
  end

  it "produces byte-identical intermediate HTML across compilations" do
    first, second = compile_pdf
    expect(second).to eq(first)
  end

  it "references images store-relative in the intermediate HTML" do
    first, = compile_pdf
    # the intermediate lives inside the compile's work root, beside the
    # shared asset store, so its references are store-relative
    expected = "assets/#{Digest::SHA256.file(image_path).hexdigest}.png"
    expect(first.scan(%r{src="assets/[^"]+"}).uniq)
      .to eq(["src=\"#{expected}\""])
  end
end
