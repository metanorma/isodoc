require "spec_helper"

RSpec.describe IsoDoc do
  it "warns of missing crossreference" do
    i = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword><title>Foreword</title>
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
      <foreword><title>Foreword</title>
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
      <title>Foreword</title>
      <p>
      <xref target="a#b"/>
      </p>
      </foreword>
      </preface>
      </iso-standard
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                <xref target="a#b" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="a#b">a#b</fmt-xref>
            </semx>
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
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
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
       <clause id="C" displayorder="3">
          <fmt-title depth="1">
             <span class="fmt-caption-label">
                <semx element="autonum" source="C">2</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">klaŭzo</span>
             <semx element="autonum" source="C">2</semx>
          </fmt-xref-label>
          <p>
             This is
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">—</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="B">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             . This is
             <xref target="A" droploc="true" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" droploc="true">
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" droploc="true" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" droploc="true">
                   <span class="fmt-autonum-delim">(</span>
                   1
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             .
          </p>
       </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
    .new({ i18nyaml: "spec/assets/i18n.yaml" }
    .merge(presxml_options))
    .convert("test", input, true))
    .at("//xmlns:clause[@id = 'C']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <clause id="C" displayorder="3">
          <fmt-title depth="1">
             <span class="fmt-caption-label">
                <semx element="autonum" source="C">2</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">klaŭzo</span>
             <semx element="autonum" source="C">2</semx>
          </fmt-xref-label>
          <p>
             This is
             <xref target="A" label="Klauze" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" label="Klauze">
                   <span class="fmt-element-name">Klauze</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" label="Formulen" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" label="Formulen">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">—</span>
                   <span class="fmt-element-name">Formulen</span>
                   <span class="fmt-autonum-delim">(</span>
                   1
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             .
          </p>
       </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'C']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <clause id="C" displayorder="3">
          <fmt-title depth="1">
             <span class="fmt-caption-label">
                <semx element="autonum" source="C">2</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">Clause</span>
             <semx element="autonum" source="C">2</semx>
          </fmt-xref-label>
          <p>
             This is
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="B">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             and
             <xref target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="C">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref>
             </semx>
             .
          </p>
          <p>
             This is
             <xref style="id" target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="id" target="A">A</fmt-xref>
             </semx>
             and
             <xref style="id" target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="id" target="B">B</fmt-xref>
             </semx>
             and
             <xref style="id" target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="id" target="C">C</fmt-xref>
             </semx>
             .
          </p>
          <p>
             This is
             <xref style="basic" target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="basic" target="A">
                   <semx element="title" source="A">My section</semx>
                </fmt-xref>
             </semx>
             and
             <xref style="basic" target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="basic" target="B">
                   <span class="fmt-xref-container">
                      <semx element="title" source="A">My section</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="B">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             and
             <xref style="basic" target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="basic" target="C">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref>
             </semx>
             .
          </p>
          <p>
             This is
             <xref style="short" target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="short" target="A">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref style="short" target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="short" target="B">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="B">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             and
             <xref style="short" target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="short" target="C">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref>
             </semx>
             .
          </p>
          <p>
             This is
             <xref style="full" target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="full" target="A">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                   <span class="fmt-comma">,</span>
                   <semx element="title" source="A">My section</semx>
                </fmt-xref>
             </semx>
             and
             <xref style="full" target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="full" target="B">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-comma">,</span>
                      <semx element="title" source="A">My section</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="B">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             and
             <xref style="full" target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref style="full" target="C">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref>
             </semx>
             .
          </p>
       </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'C']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <clause id="C" displayorder="4">
          <fmt-title depth="1">
             <span class="fmt-caption-label">
                <semx element="autonum" source="C">2</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">klaŭzo</span>
             <semx element="autonum" source="C">2</semx>
          </fmt-xref-label>
          <p>
             This is
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B">
                   <span class="fmt-element-name">tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             . This is
             <xref target="A" case="capital" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" case="capital">
                   <span class="fmt-element-name">Klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" case="lowercase">
                   <span class="fmt-element-name">tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             . This is
             <xref target="A" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" case="lowercase">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" case="capital" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" case="capital">
                   <span class="fmt-element-name">Tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             . Downcasing an xref affects only the first letter:
             <xref target="B2" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B2" case="lowercase">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">—</span>
                   <span class="fmt-element-name">Example</span>
                </fmt-xref>
             </semx>
             . Capitalising an xref affects only the first letter:
             <xref target="B1" case="capital" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B1" case="capital">
                   <span class="fmt-element-name">Figur-etikedo duvorta</span>
                   <semx element="autonum" source="B1">1</semx>
                </fmt-xref>
             </semx>
             .
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">Klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is clause
             <em>initial.</em>
             <br/>
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">Klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is too.
          </p>
          <p>
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">Klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is also.
          </p>
          <p>
             Annex has formatting, and crossreferences ignore it when determining casing.
             <xref target="AA" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AA">
                   <span class="fmt-element-name">
                      <strong>Aldono</strong>
                   </span>
                   <semx element="autonum" source="AA">A</semx>
                </fmt-xref>
             </semx>
             .
          </p>
          <p>
             Labels are not subject to casing:
             <xref target="CC" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="CC" case="lowercase">
                   <semx element="clause" source="CC">Introduction</semx>
                </fmt-xref>
             </semx>
          </p>
       </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'C']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <clause id="C" displayorder="3">
          <fmt-title depth="1">
             <span class="fmt-caption-label">
                <semx element="autonum" source="C">2</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">klaŭzo</span>
             <semx element="autonum" source="C">2</semx>
          </fmt-xref-label>
          <p>
             This is
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B">
                   <span class="fmt-element-name">tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             . This is
             <xref target="A" case="capital" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" case="capital">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" case="lowercase">
                   <span class="fmt-element-name">tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             . This is
             <xref target="A" case="lowercase" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A" case="lowercase">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             and
             <xref target="B" case="capital" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="B" case="capital">
                   <span class="fmt-element-name">tabelo</span>
                   <semx element="autonum" source="B">1</semx>
                </fmt-xref>
             </semx>
             .
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is clause
             <em>initial.</em>
             <br/>
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is too.
          </p>
          <p>
             <xref target="A" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="A">
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref>
             </semx>
             is also.
          </p>
       </clause>
    OUTPUT
    # We pretend this is Chinese—so no capitalisation is applied
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml", script: "Hans" }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'C']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "ignores locations in xrefs" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface><foreword displayorder="1"><fmt-title>Foreword</fmt-title>
                  <p id='_'>
              <xref target="item_6-4-a"><location target="item_6-4-a" connective="from"/><location target="item_6-4-i" connective="to"/><display-text>6.4 List 1.a) to 2.b)</display-text></xref>
              </p>
              </foreword></preface>
              </itu-standard>
    INPUT
    presxml = <<~OUTPUT
       <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">Foreword</fmt-title>
                <p id="_">
                   <xref target="item_6-4-a" id="_">
                      <location target="item_6-4-a" connective="from"/>
                      <location target="item_6-4-i" connective="to"/>
                      6.4 List 1.a) to 2.b)
                   </xref>
                   <semx element="xref" source="_">
                      <fmt-xref target="item_6-4-a">
                         <location target="item_6-4-a" connective="from"/>
                         <location target="item_6-4-i" connective="to"/>
                         6.4 List 1.a) to 2.b)
                      </fmt-xref>
                   </semx>
                </p>
             </foreword>
          </preface>
       </itu-standard>
    OUTPUT
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
    .convert("test", pres_output, true))
    .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end
