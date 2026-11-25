require "spec_helper"
require "fileutils"
require "tmpdir"
require "digest"

RSpec.describe "work root lifecycle" do
  # The compile driver supplies the work root and owns its lifecycle; a
  # converter-derived root is deterministic (content hash of the source,
  # never entropy) and is removed with the conversion.
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
        </sections>
      </iso-standard>
    XML
  end

  def derived_root(xml = presxml)
    File.join(Dir.tmpdir, "isodoc-work",
              "doc-#{Digest::SHA256.hexdigest(xml)}")
  end

  def compile_in(workdir: nil, debug: false)
    opts = {}
    opts[:workdir] = workdir if workdir
    Dir.mktmpdir("isodoc-work") do |outdir|
      Dir.chdir(outdir) do
        yield IsoDoc::HtmlConvert.new(opts)
          .convert("test", presxml, debug), outdir
      end
    end
  end

  it "uses a driver-supplied work root and leaves it in place" do
    Dir.mktmpdir("isodoc-root") do |root|
      compile_in(workdir: root) do |_ret, outdir|
        expect(Dir.exist?(File.join(root, "assets"))).to be(true)
        expect(Dir.exist?(File.join(root, "html_convert", "files")))
          .to be(true)
        expect(File.exist?(File.join(outdir, "test.html"))).to be(true)
        # the root survives the conversion: the driver tears it down
        expect(Dir.exist?(root)).to be(true)
      end
    end
  end

  it "removes a converter-derived root with the conversion" do
    compile_in do |_ret, outdir|
      expect(File.exist?(File.join(outdir, "test.html"))).to be(true)
      expect(Dir.exist?(derived_root)).to be(false)
    end
  end

  it "renders without creating work root content in debug mode" do
    compile_in(debug: true) do |result|
      expect(result).to include("Scope")
      expect(Dir.exist?(File.join(derived_root, "assets"))).to be(false)
      expect(Dir.exist?(File.join(derived_root, "html_convert"))).to be(false)
    end
  end

  it "derives the same root for identical sources, distinct roots otherwise" do
    expect(derived_root).to eq(derived_root(presxml.dup))
    expect(derived_root)
      .not_to eq(derived_root(presxml.sub("Scope", "Purpose")))
  end
end
