require "spec_helper"

RSpec.describe IsoDoc do
  it "formats identifier" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISO712" citeas="x"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO"><semx>ISO</semx> 712<sup>1</sup></docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <foreword displayorder='2' id="_">
        <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="_">
      <eref bibitemid="ISO712" id="_"/>
      <semx element="eref" source="_">
         <fmt-xref target="ISO712">
            ISO 712
            <sup>1</sup>
         </fmt-xref>
      </semx>
      <eref bibitemid="ISO712" citeas="x" id="_"/>
      <semx element="eref" source="_">
         <fmt-xref target="ISO712">
            ISO 712
            <sup>1</sup>
         </fmt-xref>
      </semx>
        </p>
      </foreword>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)

    presxml = <<~PRESXML
      <foreword displayorder='2' id="_">
        <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="_">
      <eref bibitemid="ISO712" id="_"/>
      <semx element="eref" source="_">
         <fmt-link target="https://www.bipm.org/en/committees/ci/cipm/43-1950">
            ISO 712
            <sup>1</sup>
         </fmt-link>
      </semx>
      <eref bibitemid="ISO712" citeas="x" id="_"/>
      <semx element="eref" source="_">
         <fmt-link target="https://www.bipm.org/en/committees/ci/cipm/43-1950">
            ISO 712
            <sup>1</sup>
         </fmt-link>
      </semx>
        </p>
      </foreword>
    PRESXML
    input = input.sub("</bibitem>", <<~XML)
      <uri type="citation" language="en" script="Latn">https://www.bipm.org/en/committees/ci/cipm/43-1950</uri></bibitem>
    XML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "selects the primary identifier" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="IEC" primary="true">IEC 217</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <foreword displayorder='2' id="_">
        <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="_">
        <eref bibitemid="ISO712" id="_"/>
      <semx element="eref" source="_">
         <fmt-xref target="ISO712">IEC 217</fmt-xref>
      </semx>
        </p>
      </foreword>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "selects multiple primary identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true">
                  <title id="_">Normative References</title>
        <fmt-title depth="1">
           <span class="fmt-caption-label">
              <semx element="autonum" source="A">1</semx>
              <span class="fmt-autonum-delim">.</span>
              </span>
              <span class="fmt-caption-delim">
                 <tab/>
              </span>
              <semx element="title" source="_">Normative References</semx>
        </fmt-title>
        <fmt-xref-label>
           <span class="fmt-element-name">Clause</span>
           <semx element="autonum" source="A">1</semx>
        </fmt-xref-label>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO" primary="true">ISO 712</docidentifier>
        <docidentifier type="IEC" primary="true">IEC 217</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <foreword displayorder='2' id="_">
        <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="_">
        <eref bibitemid="ISO712" id="_"/>
      <semx element="eref" source="_">
         <fmt-xref target="ISO712">ISO 712 / IEC 217</fmt-xref>
      </semx>
        </p>
      </foreword>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "enforces consistent metanorma-ordinal numbering" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography>
                <references id="_normative_references" obligation="informative" normative="true"><title>Normative references</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="IEC">IEC 217</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[3]</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABC</docidentifier>
      </bibitem>
      </references>
      <references id="_bibliography" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref4" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="IEC">IEC 217</docidentifier>
      </bibitem>
      <bibitem id="ref5" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[3]</docidentifier>
      </bibitem>
      <bibitem id="ref6" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABC</docidentifier>
      </bibitem>
      </references>
      </bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata>
              <language current="true">en</language>
           </bibdata>
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <references id="_" obligation="informative" normative="true" displayorder="2">
                 <title id="_">Normative references</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Normative references</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">1</semx>
                 </fmt-xref-label>
                 <bibitem id="ref1" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier type="IEC">IEC 217</docidentifier>
                    <docidentifier scope="biblio-tag">IEC 217</docidentifier>
                    <biblio-tag>IEC 217, </biblio-tag>
                 </bibitem>
                 <bibitem id="ref2" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                    <biblio-tag>[1] </biblio-tag>
                 </bibitem>
                 <bibitem id="ref3" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier>ABC</docidentifier>
                    <docidentifier scope="biblio-tag">ABC</docidentifier>
                    <biblio-tag>ABC, </biblio-tag>
                 </bibitem>
              </references>
           </sections>
           <bibliography>
              <references id="_" obligation="informative" normative="false" displayorder="3">
                 <title id="_">Bibliography</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Bibliography</semx>
                 </fmt-title>
                 <bibitem id="ref4" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                    <docidentifier type="IEC">IEC 217</docidentifier>
                    <docidentifier scope="biblio-tag">IEC 217</docidentifier>
                    <biblio-tag>
                       [2]
                       <tab/>
                       IEC 217,
                    </biblio-tag>
                 </bibitem>
                 <bibitem id="ref5" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier type="metanorma-ordinal">[3]</docidentifier>
                    <biblio-tag>
                       [3]
                       <tab/>
                    </biblio-tag>
                 </bibitem>
                 <bibitem id="ref6" type="standard">
                    <formattedref>
                       <em>Cereals or cereal products</em>
                       .
                    </formattedref>
                    <title format="text/plain">Cereals or cereal products</title>
                    <docidentifier type="metanorma-ordinal">[4]</docidentifier>
                    <docidentifier>ABC</docidentifier>
                    <docidentifier scope="biblio-tag">ABC</docidentifier>
                    <biblio-tag>
                       [4]
                       <tab/>
                       ABC,
                    </biblio-tag>
                 </bibitem>
              </references>
           </bibliography>
        </iso-standard>
    PRESXML
    xml = Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
    xml.at("//xmlns:localized-strings")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "enforces consistent references numbering with hidden items: metanorma identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[1]</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard" hidden="true">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[2]</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[3]</docidentifier>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
        <bibliography>
           <references id="_" obligation="informative" normative="false" displayorder="2">
              <title id="_">Bibliography</title>
              <fmt-title depth="1">
                 <semx element="title" source="_">Bibliography</semx>
              </fmt-title>
              <bibitem id="ref1" type="standard">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
                 <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                 <biblio-tag>
                    [1]
                    <tab/>
                 </biblio-tag>
              </bibitem>
              <bibitem id="ref2" type="standard" hidden="true">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
              </bibitem>
              <bibitem id="ref3" type="standard">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
                 <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                 <biblio-tag>
                    [2]
                    <tab/>
                 </biblio-tag>
              </bibitem>
           </references>
        </bibliography>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:bibliography").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "enforces consistent references numbering with hidden items: metanorma-ordinal identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABC</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard" hidden="true">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABD</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABE</docidentifier>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
        <bibliography>
           <references id="_" obligation="informative" normative="false" displayorder="2">
              <title id="_">Bibliography</title>
              <fmt-title depth="1">
                 <semx element="title" source="_">Bibliography</semx>
              </fmt-title>
              <bibitem id="ref1" type="standard">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
                 <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                 <docidentifier>ABC</docidentifier>
                 <docidentifier scope="biblio-tag">ABC</docidentifier>
                 <biblio-tag>
                    [1]
                    <tab/>
                    ABC,
                 </biblio-tag>
              </bibitem>
              <bibitem id="ref2" type="standard" hidden="true">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
                 <docidentifier>ABD</docidentifier>
                 <docidentifier scope="biblio-tag">ABD</docidentifier>
              </bibitem>
              <bibitem id="ref3" type="standard">
                 <formattedref>
                    <em>Cereals or cereal products</em>
                    .
                 </formattedref>
                 <title format="text/plain">Cereals or cereal products</title>
                 <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                 <docidentifier>ABE</docidentifier>
                 <docidentifier scope="biblio-tag">ABE</docidentifier>
                 <biblio-tag>
                    [2]
                    <tab/>
                    ABE,
                 </biblio-tag>
              </bibitem>
           </references>
        </bibliography>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:bibliography").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "suppresses document identifier if requested to" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard" suppress_identifier="true">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref1" suppress_identifier="true">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="ICC">ICC/167</docidentifier>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
        <references id="_" obligation="informative" normative="true" displayorder="2">
           <title id="_">Normative References</title>
           <fmt-title depth="1">
              <span class="fmt-caption-label">
                 <semx element="autonum" source="_">1</semx>
                 <span class="fmt-autonum-delim">.</span>
              </span>
              <span class="fmt-caption-delim">
                 <tab/>
              </span>
              <semx element="title" source="_">Normative References</semx>
           </fmt-title>
           <fmt-xref-label>
              <span class="fmt-element-name">Clause</span>
              <semx element="autonum" source="_">1</semx>
           </fmt-xref-label>
           <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
           <bibitem id="ISO712" type="standard" suppress_identifier="true">
              <formattedref>
                 International Organization for Standardization.
                 <em>Cereals and cereal products</em>
                 .
              </formattedref>
              <title format="text/plain">Cereals or cereal products</title>
              <title type="main" format="text/plain">Cereals and cereal products</title>
              <docidentifier type="ISO">ISO 712</docidentifier>
              <contributor>
                 <role type="publisher"/>
                 <organization>
                    <name>International Organization for Standardization</name>
                 </organization>
              </contributor>
           </bibitem>
           <bibitem id="ref1" suppress_identifier="true">
              <formattedref format="application/x-isodoc+xml">
                 <smallcap>Standard No I.C.C 167</smallcap>
                 .
                 <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                 (see
                 <link target="http://www.icc.or.at" id="_"/>
                 <semx element="link" source="_">
                    <fmt-link target="http://www.icc.or.at"/>
                 </semx>
                 )
              </formattedref>
              <docidentifier type="ICC">ICC/167</docidentifier>
           </bibitem>
        </references>
    PRESXML
    html = <<~OUTPUT
      #{HTML_HDR}
             <div>
               <h1>1.&#xa0; Normative References</h1>
               <p>
                 The following documents are referred to in the text in such a way that
                 some or all of their content constitutes requirements of this
                 document. For dated references, only the edition cited applies. For
                 undated references, the latest edition of the referenced document
                 (including any amendments) applies.
               </p>
               <p id='ISO712' class='NormRef'>
                 International Organization for Standardization.
                 <i>Cereals and cereal products</i>
                 .
               </p>
               <p id='ref1' class='NormRef'>
                 <span style='font-variant:small-caps;'>Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href='http://www.icc.or.at'>http://www.icc.or.at</a>
                 )
               </p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:references").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "renders footnote in metanorma docidentifier" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <language>en</language>
                </bibdata>
                <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="ISO712" type="standard">
              <title type="title-intro" format="text/plain" language="en" script="Latn">International vocabulary of metrology</title>
              <title type="title-main" format="text/plain" language="en" script="Latn">Basic and general concepts and associated terms (VIM)</title>
              <title type="main" format="text/plain" language="en" script="Latn">International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</title>
              <uri type="src">https://www.iso.org/standard/45324.html</uri>  <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:45324:en</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/04/53/45324.detail.rss</uri>  <uri type="pub">https://isotc.iso.org/livelink/livelink/Open/8389141</uri>
                    <docidentifier type="ISO" primary="true">ISO/IEC Guide 99:2007</docidentifier>
                    <docidentifier type="metanorma">[ISO/IEC Guide 99:2007<fn reference="1"><p id="_f6ba916e-f2ee-05fe-7ee3-b5d891a37db3">Also known as JCGM 200</p></fn>]</docidentifier>
                    <docidentifier type="URN">urn:iso:std:iso-iec:guide:99:ed-1</docidentifier>
                  <docnumber>99</docnumber>  <date type="published">    <on>2007-12</on>  </date>  <contributor>    <role type="publisher"/>    <organization>
                <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <contributor>    <role type="publisher"/>    <organization>
      <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>      <uri>www.iec.ch</uri>    </organization>  </contributor>  <edition>1</edition>  <language>en</language>  <script>Latn</script>
            </bibitem>
            </references>
            </bibliography>
            </iso-standard>
    INPUT
    presxml = <<~PRESXML
       <references id="_" obligation="informative" normative="true" displayorder="2">
           <title id="_">Normative References</title>
           <fmt-title depth="1">
              <span class="fmt-caption-label">
                 <semx element="autonum" source="_">1</semx>
                 <span class="fmt-autonum-delim">.</span>
              </span>
              <span class="fmt-caption-delim">
                 <tab/>
              </span>
              <semx element="title" source="_">Normative References</semx>
           </fmt-title>
           <fmt-xref-label>
              <span class="fmt-element-name">Clause</span>
              <semx element="autonum" source="_">1</semx>
           </fmt-xref-label>
           <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
           <bibitem id="ISO712" type="standard">
              <formattedref>
                 International Organization for Standardization and International Electrotechnical Commission.
                 <em>International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</em>
                 . First edition. 2007.
                 <link target="https://www.iso.org/standard/45324.html" id="_">https://www.iso.org/standard/45324.html</link>
                 <semx element="link" source="_">
                    <fmt-link target="https://www.iso.org/standard/45324.html">https://www.iso.org/standard/45324.html</fmt-link>
                 </semx>
                 .
              </formattedref>
              <title type="title-intro" format="text/plain" language="en" script="Latn">International vocabulary of metrology</title>
              <title type="title-main" format="text/plain" language="en" script="Latn">Basic and general concepts and associated terms (VIM)</title>
              <title type="main" format="text/plain" language="en" script="Latn">International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</title>
              <uri type="src">https://www.iso.org/standard/45324.html</uri>
              <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:45324:en</uri>
              <uri type="rss">https://www.iso.org/contents/data/standard/04/53/45324.detail.rss</uri>
              <uri type="pub">https://isotc.iso.org/livelink/livelink/Open/8389141</uri>
              <docidentifier type="ISO" primary="true">ISO/IEC Guide 99:2007</docidentifier>
              <docidentifier type="metanorma">[ISO/IEC Guide 99:2007]</docidentifier>
              <docidentifier type="URN">URN urn:iso:std:iso-iec:guide:99:ed-1</docidentifier>
              <docidentifier scope="biblio-tag">ISO/IEC Guide 99:2007</docidentifier>
              <docnumber>99</docnumber>
              <date type="published">
                 <on>2007-12</on>
              </date>
              <contributor>
                 <role type="publisher"/>
                 <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                    <uri>www.iso.org</uri>
                 </organization>
              </contributor>
              <contributor>
                 <role type="publisher"/>
                 <organization>
                    <name>International Electrotechnical Commission</name>
                    <abbreviation>IEC</abbreviation>
                    <uri>www.iec.ch</uri>
                 </organization>
              </contributor>
              <edition>1</edition>
              <language>en</language>
              <script>Latn</script>
              <biblio-tag>
                 ISO/IEC Guide 99:2007, ISO/IEC Guide 99:2007
                 <fn reference="1" original-reference="1" id="_" target="_">
                   <p original-id="_">Also known as JCGM 200</p>
                </fn>
                 ,
              </biblio-tag>
           </bibitem>
        </references>
    PRESXML
    html = <<~OUTPUT
      #{HTML_HDR}
             <div>
               <h1>1.  Normative References</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                                  <p id="ISO712" class="NormRef">
                      ISO/IEC Guide 99:2007, ISO/IEC Guide 99:2007
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1</sup>
                      </a>
                      , International Organization for Standardization and International Electrotechnical Commission.
                      <i>International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</i>
                      . First edition. 2007.
                      <a href="https://www.iso.org/standard/45324.html">https://www.iso.org/standard/45324.html</a>
                      .
                   </p>
                </div>
               <aside id="fn:1" class="footnote">
                   <p id="_">
                      <sup>1</sup>
                        Also known as JCGM 200
                   </p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:references").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "emend citeas" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
            <p id="_214f7090-c6d4-8fdc-5e6a-837ebb515871">
            <eref bibitemid="B" citeas="what"/>
            </p>
       </foreword></preface>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="A" displayorder="2">
                  <title id="_">Foreword</title>
            <fmt-title depth="1">
                  <semx element="title" source="_">Foreword</semx>
            </fmt-title>
        <p id="_">
              <eref bibitemid="B" citeas="what" id="_"/>
      <semx element="eref" source="_">
         <fmt-eref bibitemid="B" citeas="what">what</fmt-eref>
      </semx>
        </p>
      </foreword>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "sets NO ID to nil" do
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata><language>en</language></bibdata>
       <sections/>
       <bibliography>
        <references id="C" obligation="informative" normative="true">
         <title>Normative References 2</title>
       <bibitem id="ref2">
        <formattedref format="application/x-isodoc+xml">Reference 2</formattedref>
      </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
        </preface>
        <sections>
          <references id="C" obligation="informative" normative="true" displayorder="2">
          <title id="_">Normative References 2</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="C">1</semx>
               <span class="fmt-autonum-delim">.</span>
               </span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Normative References 2</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="C">1</semx>
         </fmt-xref-label>
            <bibitem id="ref2">
              <formattedref format="application/x-isodoc+xml">Reference 2</formattedref>
              <biblio-tag>(NO ID), </biblio-tag>
            </bibitem>
          </references>
        </sections>
        <bibliography>
       </bibliography>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)

    mock_i18n
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <language current="true">eo</language>
        </bibdata>
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1"/>
          </clause>
        </preface>
        <sections>
          <references id="C" obligation="informative" normative="true" displayorder="2">
                   <title id="_">Normative References 2</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="C">1</semx>
               <span class="fmt-autonum-delim">.</span>
               </span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Normative References 2</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">klaŭzo</span>
            <semx element="autonum" source="C">1</semx>
         </fmt-xref-label>
            <bibitem id="ref2">
              <formattedref format="application/x-isodoc+xml">Reference 2</formattedref>
              <biblio-tag/>
            </bibitem>
          </references>
        </sections>
        <bibliography>
       </bibliography>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input.sub(">en<", ">eo<"), true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  private

  def mock_i18n
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with("eo", "Latn", nil, anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with("eo", "Latn", "spec/assets/i18n.yaml", anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
  end
end
