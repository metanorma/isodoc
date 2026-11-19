# frozen_string_literal: true

require "spec_helper"

RSpec.describe IsoDoc::BibdataParser do
  let(:iso_bibdata_xml) do
    <<~XML
      <bibdata type="standard">
        <title language="en" type="title-main" format="text/plain">Cordial horizontal commissioning</title>
        <docidentifier primary="true" type="ISO">ISO 17302-1:2016</docidentifier>
        <docnumber>17302</docnumber>
        <edition>1</edition>
        <status><stage>60</stage><substage>60</substage></status>
      </bibdata>
    XML
  end

  it "parses bibdata XML through relaton's library surface" do
    parsed = described_class.from_xml(iso_bibdata_xml)
    expect(parsed).not_to be_nil
    expect(parsed.docidentifier.first.content).to eq "ISO 17302-1:2016"
    expect(parsed.title.first.content)
      .to eq "Cordial horizontal commissioning"
    expect(parsed.edition.content).to eq "1"
  end

  it "picks the flavor processor named by the docidentifier type, " \
     "not the generic fallback" do
    parsed = described_class.from_xml(iso_bibdata_xml)
    # The no-flavor fallback of the mirrored Cli dispatch is
    # Relaton::Bib::Item; a flavor pick yields the flavor's item class.
    expect(parsed.class).not_to eq Relaton::Bib::Item
    expect(Relaton::Db::Registry.instance.by_type("ISO")).not_to be_nil
  end

  it "strips namespaces, which lutaml-model cannot parse" do
    ns_xml = iso_bibdata_xml.sub(
      "<bibdata ",
      '<bibdata xmlns="https://www.metanorma.org/ns/standoc" ',
    )
    parsed = described_class.from_xml(ns_xml)

    expect(parsed).not_to be_nil
    expect(parsed.docidentifier.first.content).to eq "ISO 17302-1:2016"
  end

  it "returns nil on nil input" do
    expect(described_class.from_xml(nil)).to be_nil
  end

  it "returns nil on unparseable XML, as the mirrored Cli method does" do
    expect(described_class.from_xml("<bibdata><docidentifier")).to be_nil
  end

  # relaton#581: Relaton::Cli.parse_xml was tightened to a String
  # contract and its Moxml path calls .read on non-string input, so the
  # Nokogiri document bibdata_from_xml used to hand it died
  # NoMethodError on every compile; metadata's bibdata_hash_parse
  # rescued that into a silently nil meta[:bibdata] and every Liquid
  # template lost the bibdata object. This is that degradation's
  # regression test.
  it "parses through BibdataConfig without silent degradation" do
    config = IsoDoc::BibdataConfig.from_xml(
      "<metanorma>#{iso_bibdata_xml}</metanorma>",
    )
    expect(config.bibdata).not_to be_nil
    expect(config.bibdata.docidentifier.first.content)
      .to eq "ISO 17302-1:2016"
    expect(config.bibdata.docidentifier.first.type).to eq "ISO"
  end
end
