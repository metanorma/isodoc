require "spec_helper"

RSpec.describe IsoDoc do
  it "warns of missing crossreference" do
    i = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      </preface>
      </iso-standard>
    INPUT
    expect do
      IsoDoc::PresentationXMLConvert
        .new(presxml_options)
        .convert("test", i, true)
    end
      .to output(/No label has been processed for ID N1/).to_stderr
  end

  it "does not warn of missing crossreference if text is supplied" do
    i = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1">abc</xref>
      </preface>
      </iso-standard>
    INPUT
    expect { IsoDoc::HtmlConvert.new({}).convert("test", i, true) }
      .not_to output(/No label has been processed for ID N1/).to_stderr
  end

  it "cross-references external documents" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="a#b"/>
      </p>
      </foreword>
      </preface>
      </iso-standard
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <title depth="1">Table of contents</title>
          </clause>
          <foreword displayorder='2'>
            <p>
              <xref target='a#b'>a#b</xref>
            </p>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
              #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
      <a href="a.html#b">a#b</a>
      </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
          <div class="WordSection2">
            <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
           <div class="TOC" id="_">
              <p class="zzContents">Table of contents</p>
            </div>
            <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
      <a href="a.doc#b">a#b</a>
      </p>
            </div><p> </p></div>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))
      .at("//div[@class = 'WordSection2']").to_xml))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "droplocs xrefs" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <clause id="A">
          <formula id="B">
          </formula>
          </clause>
          <clause id="C">
          <p>This is <xref target="A"/> and <xref target="B"/>.
          This is <xref target="A" droploc="true"/> and <xref target="B" droploc="true"/>.</p>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <title depth="1">Table of contents</title>
        </clause>
        </preface>
        <sections>
          <clause id='A' displayorder="2">
            <title>1.</title>
            <formula id='B'>
              <name>1</name>
            </formula>
          </clause>
          <clause id='C' displayorder="3">
            <title>2.</title>
            <p>
              This is
              <xref target='A'>kla&#x16D;zo 1</xref>
               and
              <xref target='B'>kla&#x16D;zo 1, Formula (1)</xref>
              . This is
              <xref target='A' droploc='true'>1</xref>
               and
              <xref target='B' droploc='true'>(1)</xref>
              .
            </p>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "puts custom labels on xrefs" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <clause id="A">
          <formula id="B">
          </formula>
          </clause>
          <clause id="C">
          <p>This is <xref target="A" label="Klauze"/> and <xref target="B" label="Formulen"/>.</p>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <title depth="1">Table of contents</title>
        </clause>
        </preface>
        <sections>
          <clause id='A' displayorder="2">
            <title>1.</title>
            <formula id='B'>
              <name>1</name>
            </formula>
          </clause>
          <clause id='C' displayorder="3">
            <title>2.</title>
            <p>
              This is
              <xref target='A' label='Klauze'>Klauze 1</xref>
               and
              <xref target='B' label='Formulen'>kla&#x16D;zo 1, Formulen (1)</xref>
              .
            </p>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "renders xrefs with style" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <clause id="A"><title>My section</title>
          <formula id="B">
          </formula>
          </clause>
          <clause id="C">
          <p>This is <xref target="A"/> and <xref target="B"/> and <xref target="C"/>.</p>
          <p>This is <xref style="id" target="A"/> and <xref style="id" target="B"/> and <xref style="id" target="C"/>.</p>
          <p>This is <xref style="basic" target="A"/> and <xref style="basic" target="B"/> and <xref style="basic" target="C"/>.</p>
          <p>This is <xref style="short" target="A"/> and <xref style="short" target="B"/> and <xref style="short" target="C"/>.</p>
          <p>This is <xref style="full" target="A"/> and <xref style="full" target="B"/> and <xref style="full" target="C"/>.</p>
          </clause>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <title depth="1">Table of contents</title>
        </clause>
        </preface>
        <sections>
          <clause id='A' displayorder='2'>
            <title depth='1'>
              1.
              <tab/>
              My section
            </title>
            <formula id='B'>
              <name>1</name>
            </formula>
          </clause>
          <clause id='C' displayorder='3'>
            <title>2.</title>
            <p>This is
        <xref style='id' target='A'>A</xref>
         and
        <xref style='id' target='B'>B</xref>
         and
        <xref style='id' target='C'>C</xref>
        .
      </p>
            <p>
              This is
              <xref target='A'>Clause 1</xref>
               and
              <xref target='B'>Clause 1, Formula (1)</xref>
               and
              <xref target='C'>Clause 2</xref>
              .
            </p>
            <p>
              This is
              <xref style='basic' target='A'>My section</xref>
               and
              <xref style='basic' target='B'>My section, Formula (1)</xref>
               and
              <xref style='basic' target='C'>Clause 2</xref>
              .
            </p>
            <p>
              This is
              <xref style='short' target='A'>Clause 1</xref>
               and
              <xref style='short' target='B'>Clause 1, Formula (1)</xref>
               and
              <xref style='short' target='C'>Clause 2</xref>
              .
            </p>
            <p>
              This is
              <xref style='full' target='A'>Clause 1, My section</xref>
               and
              <xref style='full' target='B'>Clause 1, My section, Formula (1)</xref>
               and
              <xref style='full' target='C'>Clause 2</xref>
              .
            </p>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "cases xrefs" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause id="CC"><title>Introduction</title></clause>
          </preface>
          <sections>
          <clause id="A">
          <table id="B">
          </table>
          <figure id="B1"/>
          <example id="B2"/>
          </clause>
          <clause id="C">
          <p>This is <xref target="A"/> and <xref target="B"/>.
          This is <xref target="A" case="capital"/> and <xref target="B" case="lowercase"/>.
          This is <xref target="A" case="lowercase"/> and <xref target="B" case="capital"/>.
          Downcasing an xref affects only the first letter: <xref target="B2" case="lowercase"/>.
          Capitalising an xref affects only the first letter: <xref target="B1" case="capital"/>.
          <xref target="A"/> is clause <em>initial.</em><br/>
          <xref target="A"/> is too.  </p>
          <p><xref target="A"/> is also.</p>
          <p>Annex has formatting, and crossreferences ignore it when determining casing. <xref target="AA"/>.</p>
          <p>Labels are not subject to casing: <xref target="CC" case="lowercase"/></p>
      </clause>
      <annex id="AA">
      <clause id="AA1"/>
      </annex>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
        <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
          <clause id='CC' displayorder='2'>
            <title depth='1'>Introduction</title>
          </clause>
          </preface>
          <sections>
            <clause id='A' displayorder='3'>
              <title>1.</title>
              <table id='B'>
                <name>Tabelo 1</name>
              </table>
              <figure id='B1'>
                <name>Figur-etikedo duvorta 1</name>
              </figure>
              <example id='B2'>
                <name>Ekzempl-etikedo Duvorta</name>
              </example>
            </clause>
            <clause id='C' displayorder='4'>
              <title>2.</title>
              <p>
                This is
                <xref target='A'>kla&#x16D;zo 1</xref>
                 and
                <xref target='B'>tabelo 1</xref>
                . This is
                <xref target='A' case='capital'>Kla&#x16D;zo 1</xref>
                 and
                <xref target='B' case='lowercase'>tabelo 1</xref>
                . This is
                <xref target='A' case='lowercase'>kla&#x16D;zo 1</xref>
                 and
                <xref target='B' case='capital'>Tabelo 1</xref>
                . Downcasing an xref affects only the first letter:
                <xref target='B2' case='lowercase'>kla&#x16D;zo 1, Example</xref>
                . Capitalising an xref affects only the first letter:
                <xref target='B1' case='capital'>Figur-etikedo duvorta 1</xref>
                .
               <xref target='A'>Kla&#x16D;zo 1</xref>
                 is clause
                <em>initial.</em>
                <br/>
                <xref target='A'>Kla&#x16D;zo 1</xref>
                 is too.
              </p>
              <p>
                <xref target='A'>Kla&#x16D;zo 1</xref>
                 is also.
              </p>
              <p>
                Annex has formatting, and crossreferences ignore it when determining
                casing.
                <xref target='AA'>
                  <strong>Aldono</strong>
                   A
                </xref>
                .
              </p>
              <p>
                Labels are not subject to casing:
                <xref target='CC' case='lowercase'>Introduction</xref>
              </p>
            </clause>
              <annex id='AA' displayorder='5'>
                <title>
                  <strong>
                    <strong>Aldono</strong>
                     A
                  </strong>
                  <br/>
                  (informa)
                </title>
                <clause id='AA1'>
                  <title>A.1.</title>
                </clause>
              </annex>
          </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "ignores casing of xrefs in unicameral scripts" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <clause id="A">
          <table id="B">
          </table>
          </clause>
          <clause id="C">
          <p>This is <xref target="A"/> and <xref target="B"/>.
          This is <xref target="A" case="capital"/> and <xref target="B" case="lowercase"/>.
          This is <xref target="A" case="lowercase"/> and <xref target="B" case="capital"/>.
          <xref target="A"/> is clause <em>initial.</em><br/>
          <xref target="A"/> is too.  </p>
          <p><xref target="A"/> is also.</p>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
             <preface><clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause></preface>
        <sections>
         <clause id='A' displayorder="2">
          <title>1.</title>
            <table id='B'>
              <name>Tabelo 1</name>
            </table>
          </clause>
          <clause id='C' displayorder="3">
          <title>2.</title>
            <p>
              This is
              <xref target='A'>kla&#x16D;zo 1</xref>
               and
              <xref target='B'>tabelo 1</xref>
              . This is
              <xref target='A' case='capital'>kla&#x16D;zo 1</xref>
               and
              <xref target='B' case='lowercase'>tabelo 1</xref>
              . This is
              <xref target='A' case='lowercase'>kla&#x16D;zo 1</xref>
               and
              <xref target='B' case='capital'>tabelo 1</xref>
              .
              <xref target='A'>kla&#x16D;zo 1</xref>
               is clause
              <em>initial.</em>
              <br/>
              <xref target='A'>kla&#x16D;zo 1</xref>
               is too.
            </p>
            <p>
              <xref target='A'>kla&#x16D;zo 1</xref>
               is also.
            </p>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml", script: "Hans" }
      .merge(presxml_options))
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "ignores locations in xrefs" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface><foreword displayorder="1">
                  <p id='_'>
              <xref target="item_6-4-a"><location target="item_6-4-a" connective="from"/><location target="item_6-4-i" connective="to"/>6.4 List 1.a) to 2.b)</xref>
              </p>
              </foreword></preface>
              </itu-standard>
    INPUT
    html = <<~OUTPUT
      <div><h1 class='ForewordTitle'>Foreword</h1>
          <p id='_'>
            <a href='#item_6-4-a'>6.4 List 1.a) to 2.b)</a>
          </p>
        </div>
    OUTPUT
    doc = <<~OUTPUT
      <div><h1 class='ForewordTitle'>Foreword</h1>
          <p id='_'>
            <a href='#item_6-4-a'>6.4 List 1.a) to 2.b)</a>
          </p>
        </div>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
    .convert("test", input, true))
    .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end
