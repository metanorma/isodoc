require "spec_helper"

RSpec.describe IsoDoc do
  # An unresolved cross-doc eref survives HTML conversion as an empty
  # <eref> plus a <semx element="eref" source="<eref id>"> companion
  # carrying the display text.
  let(:presxml) do
    <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <foreword displayorder="1" id="_">
            <title id="_">Foreword</title>
            <fmt-title id="_" depth="1">Foreword</fmt-title>
            <p id="_">
              <eref id="eref1" bibitemid="express_representation_schema_ISO_10303-41_2025" citeas="ISO 10303-41"/>
              <semx element="eref" source="eref1">
                <fmt-eref bibitemid="express_representation_schema_ISO_10303-41_2025" citeas="ISO 10303-41">ISO 10303-41, Representation schema</fmt-eref>
              </semx>
            </p>
          </foreword>
        </preface>
        <sections/>
      </iso-standard>
    INPUT
  end

  it "wraps unresolved erefs in bibitemid spans when opted in" do
    converter = IsoDoc::HtmlConvert.new(unresolved_eref_markers: true)
    html = strip_guid(converter.convert("test", presxml, true))
    expect(html).to include('<span class="unresolved-eref" ' \
      'data-bibitemid="express_representation_schema_ISO_10303-41_2025" ' \
      'data-citeas="ISO 10303-41">')
    expect(html).to include("ISO 10303-41, Representation schema\n        </span>")
  end

  it "leaves erefs unchanged by default" do
    html = strip_guid(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))
    expect(html).not_to include("unresolved-eref")
    expect(html).not_to include("data-bibitemid")
    expect(html).to include("ISO 10303-41, Representation schema")
  end
end
