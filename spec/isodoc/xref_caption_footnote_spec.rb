require "spec_helper"

RSpec.describe IsoDoc do
  # A caption footnote is numbered in the caption's own fmt-name copy by
  # document_footnotes. The xrefstyle=full anchor capture (asset_title) is
  # taken before that pass, so embedding the capture into cross-reference
  # text used to splice in a footnote reference that no fmt-fn-label pass
  # ever reached, crashing the HTML/DOC renderers on table footnotes
  # (metanorma/metanorma-pdfa#123).
  it "drops caption footnote references from xrefstyle=full cross-reference text" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibliography>
          <references id="_normative_references" obligation="informative" normative="true">
            <title>Normative References</title>
            <bibitem id="ISO712" type="standard">
              <title format="text/plain">Cereals and cereal products</title>
              <title type="main" format="text/plain">Cereals and cereal products</title>
              <docidentifier type="ISO">ISO 712</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
        <sections>
          <clause id="A"><title>Scope</title>
            <table id="table-1">
              <name>Core fields<fn reference="1"><p>Some fields are optional according to <eref type="inline" bibitemid="ISO712" citeas="ISO&#xA0;712"/>.</p></fn></name>
              <tbody>
                <tr>
                  <td><p>Cell</p></td>
                </tr>
              </tbody>
            </table>
            <table id="table-2">
              <name>Second table</name>
              <tbody>
                <tr>
                  <td>
                    <note>
                      <p>See <xref target="table-1" style="full"/>.</p>
                    </note>
                  </td>
                </tr>
              </tbody>
            </table>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    presxml = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    pres_doc = Nokogiri::XML(presxml)

    # no footnote reference is spliced into cross-reference text
    expect(pres_doc.xpath("//xmlns:fmt-xref//xmlns:fn")).to be_empty

    # the caption footnote is still numbered in the table's own caption
    expect(pres_doc
      .at_xpath("//xmlns:table[@id = 'table-1']/xmlns:fmt-name" \
                "//xmlns:fmt-fn-label")).not_to be_nil

    expect do
      IsoDoc::HtmlConvert.new({}).convert("test", presxml, true)
    end.not_to raise_error
  end

  # Belt and braces for any other source of label-less table footnotes:
  # the renderers degrade to an empty footnote reference instead of
  # raising NoMethodError (metanorma/metanorma-pdfa#123).
  it "degrades gracefully on table footnotes without fmt-fn-label" do
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <title>
            <title-intro-en>Intro</title-intro-en>
          </title>
        </bibdata>
        <sections>
          <clause id="A" displayorder="1">
            <table id="table-1">
              <name>Caption</name>
              <tbody>
                <tr>
                  <td><p>Cell</p></td>
                </tr>
              </tbody>
              <note>
                <p>
                  <fn reference="1" target="_1"><p>Body</p></fn>
                </p>
              </note>
            </table>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    expect do
      IsoDoc::HtmlConvert.new({}).convert("test", presxml, true)
    end.not_to raise_error
  end
end
