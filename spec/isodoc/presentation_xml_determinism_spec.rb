require "spec_helper"
require "digest"
require "fileutils"

RSpec.describe "Presentation XML id determinism" do
  let(:input) do
    <<~XML
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword id="A" displayorder="1"><fmt-title>Foreword</fmt-title>
      <p>Body text.</p>
      </foreword>
      <bibliography>
      <references normative="false" displayorder="9">
      <bibitem id="bib1" type="standard">
      <title>Some Standard</title>
      <docidentifier>ISO 1:2024</docidentifier>
      <note type="Unpublished-Status">
      <p>Document under preparation.</p></note>
      </bibitem>
      </references>
      </bibliography>
      </preface>
      <sections>
      <clause id="B" displayorder="2"><fmt-title>Clause B</fmt-title>
      <note id="n1"><p>Note one.</p></note>
      <note id="n2"><p>Note two.</p></note>
      <term id="term-alpha"><preferred><name>alpha</name></preferred>
      <definition>
      <dd>A first species of alpha.</dd>
      <dd>A second species of alpha.</dd>
      </definition>
      </term>
      </clause>
      <annex id="C" displayorder="3"><fmt-title>Annex C</fmt-title>
      <figure id="fig1"><name>Figure name</name></figure>
      </annex>
      </sections>
      <index>
      <primary>alpha</primary><secondary>first</secondary>
      </index>
      </iso-standard>
    XML
  end

  def compile
    FileUtils.rm_f("tmp_det.presentation.xml")
    IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")
      .convert("tmp_det", input, false)
    File.read("tmp_det.presentation.xml")
  end

  def uuid_shaped_ids(xml)
    xml.xpath("//*[@id]").select do |x|
      Metanorma::Utils::guid_anchor?(x["id"])
    end
  end

  it "produces byte-identical Presentation XML across runs" do
    expect(compile).to eq(compile)
  end

  # ids minted during conversion are content-derived at mint time; the
  # contenthash cleanup converges them unchanged, so every uuid-shaped id
  # in the output addresses its element
  it "emits only content-derived uuid-shaped ids" do
    xml = Nokogiri::XML(compile)
    ids = uuid_shaped_ids(xml)
    expect(ids).not_to be_empty
    ids.each do |x|
      expect(x["id"]).to eq(Metanorma::Utils.contenthash(x))
    end
  end

  it "mints identical ids from fresh converters on identical input" do
    expect(compile.scan(/id="_[0-9A-F-]{36}"/).sort)
      .to eq(compile.scan(/id="_[0-9A-F-]{36}"/).sort)
  end

  it "mints distinct ids for identically named index and TOC elements" do
    xml = Nokogiri::XML(compile)
    ids = uuid_shaped_ids(xml).map { |x| x["id"] }

    expect(ids.uniq.length).to eq(ids.length)
  end

  it "derives bibitem date-note fn ids from the note content" do
    xml = Nokogiri::XML(compile)
    fn = xml.at_xpath("//*[local-name() = 'fn']")

    expect(fn).not_to be_nil
    # the fn id is the content address of the final element; the
    # reference is renumbered to a footnote ordinal, with no entropy
    expect(fn["id"]).to eq(Metanorma::Utils.contenthash(fn))
    expect(fn["reference"]).to match(/\A\d+\z/)
  end
end
