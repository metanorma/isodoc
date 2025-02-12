require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1"><fmt-title>Foreword</fmt-title>
      <p>
      <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
      <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword> <br/> <hr/>
      <bookmark id="H"/> <pagebreak/> <pagebreak orientation="landscape"/> <underline>J</underline>
      <underline style="wavy">J1</underline>
      <span class="A"><em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt> F</span>
      <span style="font-family:&quot;Arial&quot;"><em>A</em> F</span>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      <div><h1 class="ForewordTitle">Foreword</h1>
               <p>
       <i>A</i> <b>B</b> <sup>C</sup> <sub>D</sub> <tt>E</tt>
       <s>F</s> <span style="font-variant:small-caps;">G</span> <span class="keyword">I</span> <br/> <hr/>
       <a id="H"/> <br/> <br/> <span style="text-decoration: underline">J</span>
       <span style="text-decoration: underline wavy">J1</span>
       <span class="A"><i>A</i> <b>B</b> <sup>C</sup> <sub>D</sub> <tt>E</tt> F</span>
       <span style="font-family:&quot;Arial&quot;"><i>A</i> F</span>
       </p>
             </div>
    OUTPUT

    doc = <<~OUTPUT
      <div><h1 class="ForewordTitle">Foreword</h1>
           <p>
             <i>A</i>
             <b>B</b>
             <sup>C</sup>
             <sub>D</sub>
             <tt>E</tt>
             <s>F</s>
             <span style="font-variant:small-caps;">G</span>
             <span class="keyword">I</span>
             <br/>
             <hr/>
             <a id="H"/>
             <p class="page-break">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <p>
               <br clear="all" class="section" orientation="landscape"/>
             </p>
             <u>J</u>
             <u style="text-decoration: wavy">J1</u>
             <span class="A"><i>A</i><b>B</b><sup>C</sup><sub>D</sub><tt>E</tt> F</span>
             <span style="font-family:&quot;Arial&quot;"><i>A</i> F</span>
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

  it "processes identifier" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <bibdata/>
      <sections><clause id="_scope" type="scope" inline-header="false" obligation="normative">
      <title>Scope</title>
      <p id="A"><identifier>http://www.example.com</identifier></p>
      </clause>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <p id='A'>
         <identifier id="_">http://www.example.com</identifier>
        <fmt-identifier>
            <tt>
              <semx element="identifier" source="_">http://www.example.com</semx>
            </tt>
        </fmt-identifier>
      </p>
    OUTPUT
    html = <<~OUTPUT
       <p id="A">
          <tt>http://www.example.com</tt>
       </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes dates" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p id="A"><date format="%m/%d/%Y" value="2021-01-03"/></p>
      </foreword></preface>
      <sections/>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
          <date format="%m/%d/%Y" value="2021-01-03" id="_"/>
          <fmt-date>
             <semx element="date" source="_">01/03/2021</semx>
          </fmt-date>
      </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A">01/03/2021</p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes concept markup" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <ul>
          <li>
          <concept><refterm>term</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            <li><concept>
              <strong>error!</strong>
              </concept>
              </li>
            </ul>
          </p>
          </foreword></preface>
          <sections>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <ul>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <xref target="clause1" original-id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">2</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" original-id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>term</em>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">2</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>w[o]rd</renderterm>
                   <xref target="clause1" original-id="_">Clause #1</xref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>w[o]rd</em>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">Clause #1</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>term</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">ISO 712</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">The Aforementioned Citation</eref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">The Aforementioned Citation</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                      <locality type="clause">
                         <referenceFrom>3.1</referenceFrom>
                      </locality>
                      <locality type="figure">
                         <referenceFrom>a</referenceFrom>
                      </locality>
                   </eref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">ISO 712, Clause 3.1, Figure a</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                      <localityStack connective="and">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </localityStack>
                      <localityStack connective="and">
                         <locality type="figure">
                            <referenceFrom>b</referenceFrom>
                         </locality>
                      </localityStack>
                   </eref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">
                            ISO 712, Clause 3.1
                            <span class="fmt-conn">and</span>
                            Figure b
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                      <localityStack connective="and">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </localityStack>
                      <localityStack connective="and">
                         <locality type="figure">
                            <referenceFrom>b</referenceFrom>
                         </locality>
                      </localityStack>
                      The Aforementioned Citation
                   </eref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">
               
               
               The Aforementioned Citation
               </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <termref base="IEV" target="135-13-13"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      [
                      <termref base="IEV" target="135-13-13"/>
                      ]
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <termref base="IEV" target="135-13-13">The IEV database</termref>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>word</em>
                      (
                      <termref base="IEV" target="135-13-13">The IEV database</termref>
                      )
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <concept id="_">
                   <strong>error!</strong>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <strong>error!</strong>
                   </semx>
                </fmt-concept>
             </li>
          </ul>
       </p>
    OUTPUT
    html = <<~OUTPUT
        <p id="A">
        <div class="ul_wrap">
          <ul>
            <li>

        (<a href="#clause1">Clause 2</a>)
      </li>
            <li><i>term</i>
        (<a href="#clause1">Clause 2</a>)
      </li>
            <li><i>w[o]rd</i>
        [<a href="#clause1">Clause #1</a>]
      </li>
            <li><i>term</i>
        (<a href="#ISO712">ISO 712</a>)
      </li>
            <li><i>word</i>
        [<a href="#ISO712">The Aforementioned Citation</a>]
      </li>
            <li><i>word</i>
        (<a href="#ISO712">ISO 712, Clause 3.1, Figure a</a>)
      </li>
            <li><i>word</i>
        (<a href="#ISO712">ISO 712, Clause 3.1 and Figure b</a>)
      </li>
            <li><i>word</i>
        [<a href="#ISO712">


        The Aforementioned Citation
        </a>]
      </li>
            <li><i>word</i>
        (Termbase IEV, term ID 135-13-13)
      </li>
            <li><i>word</i>
        [The IEV database]
      </li>
            <li>
              <b>error!</b>
            </li>
          </ul>
          </div>
        </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes embedded inline formatting" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
        <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
        <p>
        <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="_http_1_1">Requirement <tt>/req/core/http</tt></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712">Requirement <tt>/req/core/http</tt></eref>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1">
                <title id="_">Foreword</title>
                <fmt-title depth="1">Foreword</fmt-title>
                <p>
                   <em>
                      <strong>&lt;</strong>
                   </em>
                   <tt>
                      <link target="B" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="B"/>
                      </semx>
                   </tt>
                   <xref target="_" id="_">
                      Requirement
                      <tt>/req/core/http</tt>
                   </xref>
                   <semx element="xref" source="_">
                      <fmt-xref target="_">
                         Requirement
                         <tt>/req/core/http</tt>
                      </fmt-xref>
                   </semx>
                   <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">
                      Requirement
                      <tt>/req/core/http</tt>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-eref type="inline" bibitemid="ISO712" citeas="ISO 712">
                         Requirement
                         <tt>/req/core/http</tt>
                      </fmt-eref>
                   </semx>
                </p>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
         </sections>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                 <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
         <i><b>&lt;</b></i> <tt><a href="B">B</a></tt> <a href="#_http_1_1">Requirement <tt>/req/core/http</tt></a>  Requirement <tt>/req/core/http</tt>
         </p>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes inline images" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
      <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
          <p>
        <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
        </p>
        </foreword></preface>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{HTML_HDR}
            <br/>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <p>
                <img src='rice_images/rice_image1.png' height='20' width='30' title='titletxt' alt='alttext'/>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes links" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
      <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
        <p>
        <link target="http://example.com"/>
        <link target="http://example.com"><br/></link>
        <link target="http://example.com">example</link>
        <link target="http://example.com" alt="tip">example</link>
        <link target="mailto:fred@example.com"/>
        <link target="mailto:fred@example.com">mailto:fred@example.com</link>
        <link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512"/>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1">
                <title id="_">Foreword</title>
                <fmt-title depth="1">Foreword</fmt-title>
                <p>
                   <link target="http://example.com" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="http://example.com"/>
                   </semx>
                   <link target="http://example.com" id="_">
                      <br/>
                   </link>
                   <semx element="link" source="_">
                      <fmt-link target="http://example.com">
                         <br/>
                      </fmt-link>
                   </semx>
                   <link target="http://example.com" id="_">example</link>
                   <semx element="link" source="_">
                      <fmt-link target="http://example.com">example</fmt-link>
                   </semx>
                   <link target="http://example.com" alt="tip" id="_">example</link>
                   <semx element="link" source="_">
                      <fmt-link target="http://example.com" alt="tip">example</fmt-link>
                   </semx>
                   <link target="mailto:fred@example.com" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="mailto:fred@example.com"/>
                   </semx>
                   <link target="mailto:fred@example.com" id="_">mailto:fred@example.com</link>
                   <semx element="link" source="_">
                      <fmt-link target="mailto:fred@example.com">mailto:fred@example.com</fmt-link>
                   </semx>
                   <link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512"/>
                   </semx>
                </p>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
         </sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                 <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
         <a href="http://example.com">http://example.com</a>
         <a href="http://example.com"><br/></a>
         <a href="http://example.com">example</a>
         <a href="http://example.com" title="tip">example</a>
         <a href="mailto:fred@example.com">fred@example.com</a>
         <a href="mailto:fred@example.com">mailto:fred@example.com</a>
         <a href="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512">https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512</a>
         </p>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes updatetype links" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="2"><fmt-title>Foreword</fmt-title>
      <p>
      <fmt-link update-type="true" target="http://example.com"/>
      <fmt-link update-type="true" target="list.adoc">example</fmt-link>
      <fmt-link update-type="true" target="list" alt="tip">example</fmt-link>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
      <a href="http://example.com">http://example.com</a>
      <a href='list.adoc'>example</a>
      <a href='list.html' title='tip'>example</a>
      </p>
              </div>
    OUTPUT
    doc = <<~OUTPUT
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
      <a href="http://example.com">http://example.com</a>
      <a href='list.adoc'>example</a>
      <a href='list.doc' title='tip'>example</a>
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

  it "processes unrecognised markup" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
      <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
        <p>
        <barry fred="http://example.com">example</barry>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                 <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
         <para><b role="strong">&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</b></para>
         </p>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes AsciiMath and MathML" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m="http://www.w3.org/1998/Math/MathML">
        <preface>    <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
       <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
        <p id="A">
        <stem type="AsciiMath">&lt;A&gt;</stem>
        <stem type="AsciiMath"><m:math><m:mrow>X</m:mrow></m:math><asciimath>&lt;A&gt;</asciimath></stem>
        <stem type="MathML"><m:math><m:mrow>X</m:mrow></m:math></stem>
        <stem type="LaTeX">Latex?</stem>
        <stem type="LaTeX"><asciimath>&lt;A&gt;</asciimath><latexmath>Latex?</latexmath></stem>
        <stem type="None">Latex?</stem>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <stem type="AsciiMath" id="_">&lt;A&gt;</stem>
          <fmt-stem type="AsciiMath">
             <semx element="stem" source="_">&lt;A&gt;</semx>
          </fmt-stem>
          <stem type="AsciiMath" id="_">
             <m:math>
                <m:mrow>X</m:mrow>
             </m:math>
             <asciimath>&lt;A&gt;</asciimath>
          </stem>
          <fmt-stem type="AsciiMath">
             <semx element="stem" source="_">
                <m:math>
                   <m:mrow>X</m:mrow>
                </m:math>
                <asciimath>&lt;A&gt;</asciimath>
             </semx>
          </fmt-stem>
          <stem type="MathML" id="_">
             <m:math>
                <m:mrow>X</m:mrow>
             </m:math>
          </stem>
          <fmt-stem type="MathML">
             <semx element="stem" source="_">
                <m:math>
                   <m:mrow>X</m:mrow>
                </m:math>
                <asciimath>X</asciimath>
             </semx>
          </fmt-stem>
          <stem type="LaTeX" id="_">Latex?</stem>
          <fmt-stem type="LaTeX">
             <semx element="stem" source="_">Latex?</semx>
          </fmt-stem>
          <stem type="LaTeX" id="_">
             <asciimath>&lt;A&gt;</asciimath>
             <latexmath>Latex?</latexmath>
          </stem>
          <fmt-stem type="LaTeX">
             <semx element="stem" source="_">
                <asciimath>&lt;A&gt;</asciimath>
                <latexmath>Latex?</latexmath>
             </semx>
          </fmt-stem>
          <stem type="None" id="_">Latex?</stem>
          <fmt-stem type="None">
             <semx element="stem" source="_">Latex?</semx>
          </fmt-stem>
       </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A">
         <span class="stem">(#(&lt;A&gt;)#)</span>
         <span class="stem">(#(&lt;A&gt;)#)</span>
         <span class="stem"><m:math xmlns:m="http://www.w3.org/1998/Math/MathML">
           <m:mrow>X</m:mrow>
         </m:math></span>
         <span class="stem">Latex?</span>
         <span class="stem">Latex?</span>
         <span class="stem">Latex?</span>
         </p>
    OUTPUT
       pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "overrides AsciiMath delimiters" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
            <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
        <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
        <p id="A">
        <stem type="AsciiMath">A</stem>
        (#((Hello))#)
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <stem type="AsciiMath" id="_">A</stem>
          <fmt-stem type="AsciiMath">
             <semx element="stem" source="_">A</semx>
          </fmt-stem>
          (#((Hello))#)
       </p>
    OUTPUT
    html = <<~OUTPUT
         <p id="A">
         <span class="stem">(#(((A)#)))</span>
         (#((Hello))#)
         </p>
    OUTPUT
       pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "duplicates MathML with AsciiMath" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m='http://www.w3.org/1998/Math/MathML'>
      <preface><foreword>
      <p>
      <stem type="MathML"><m:math>
        <m:msup> <m:mrow> <m:mo>(</m:mo> <m:mrow> <m:mi>x</m:mi> <m:mo>+</m:mo> <m:mi>y</m:mi> </m:mrow> <m:mo>)</m:mo> </m:mrow> <m:mn>2</m:mn> </m:msup>
      </m:math></stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' xmlns:m='http://www.w3.org/1998/Math/MathML' type='presentation'>
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
              <stem type='MathML' id="_">
                 <m:math>
                   <m:msup>
                     <m:mrow>
                       <m:mo>(</m:mo>
                       <m:mrow>
                         <m:mi>x</m:mi>
                         <m:mo>+</m:mo>
                         <m:mi>y</m:mi>
                       </m:mrow>
                       <m:mo>)</m:mo>
                     </m:mrow>
                     <m:mn>2</m:mn>
                   </m:msup>
                   </m:math>
              </stem>
              <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 <m:math>
                    <m:msup>
                       <m:mrow>
                          <m:mo>(</m:mo>
                          <m:mrow>
                             <m:mi>x</m:mi>
                             <m:mo>+</m:mo>
                             <m:mi>y</m:mi>
                          </m:mrow>
                          <m:mo>)</m:mo>
                       </m:mrow>
                       <m:mn>2</m:mn>
                    </m:msup>
                 </m:math>
                 <asciimath>(x + y)^(2)</asciimath>
              </semx>
           </fmt-stem>
            </p>
          </foreword>
        </preface>
        <sections> </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub("<!--", "<comment>")
      .gsub("-->", "</comment>"))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "overrides duplication of MathML with AsciiMath" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml"  xmlns:m='http://www.w3.org/1998/Math/MathML'>
      <preface><foreword>
      <p>
      <stem type="MathML"><m:math>
        <m:msup> <m:mrow> <m:mo>(</m:mo> <m:mrow> <m:mi>x</m:mi> <m:mo>+</m:mo> <m:mi>y</m:mi> </m:mrow> <m:mo>)</m:mo> </m:mrow> <m:mn>2</m:mn> </m:msup>
      </m:math></stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' xmlns:m='http://www.w3.org/1998/Math/MathML' type='presentation'>
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
              <stem type='MathML' id="_">
                 <m:math>
                   <m:msup>
                     <m:mrow>
                       <m:mo>(</m:mo>
                       <m:mrow>
                         <m:mi>x</m:mi>
                         <m:mo>+</m:mo>
                         <m:mi>y</m:mi>
                       </m:mrow>
                       <m:mo>)</m:mo>
                     </m:mrow>
                     <m:mn>2</m:mn>
                   </m:msup>
                 </m:math>
              </stem>
                     <fmt-stem type="MathML">
                      <semx element="stem" source="_">
                         <m:math>
                            <m:msup>
                               <m:mrow>
                                  <m:mo>(</m:mo>
                                  <m:mrow>
                                     <m:mi>x</m:mi>
                                     <m:mo>+</m:mo>
                                     <m:mi>y</m:mi>
                                  </m:mrow>
                                  <m:mo>)</m:mo>
                               </m:mrow>
                               <m:mn>2</m:mn>
                            </m:msup>
                         </m:math>
                      </semx>
                   </fmt-stem>
            </p>
          </foreword>
        </preface>
        <sections> </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ suppressasciimathdup: true }
      .merge(presxml_options))
      .convert("test", input, true)
      .gsub("<!--", "<comment>")
      .gsub("-->", "</comment>"))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes eref types" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <eref type="footnote" bibitemid="ISO713" citeas="ISO 713">A</stem>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</stem>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em></formattedref>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
            <bibitem id="ISO713" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em></formattedref>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <uri type="citation">http://wwww.example.com</uri>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
             <semx element="eref" source="_">
                <sup>
                   <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
                </sup>
             </semx>
             <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
             <semx element="eref" source="_">
                <fmt-xref type="inline" target="ISO712">A</fmt-xref>
             </semx>
             <eref type="footnote" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
             <semx element="eref" source="_">
                <sup>
                   <fmt-link target="http://wwww.example.com">A</fmt-link>
                </sup>
             </semx>
             <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
             <semx element="eref" source="_">
                <fmt-link target="http://wwww.example.com">A</fmt-link>
             </semx>
          </p>
       </foreword>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
                              <p>
                 <sup>
                   <a href="#ISO712">A</a>
                 </sup>
                 <a href="#ISO712">A</a>
                 <sup>
                   <a href="http://wwww.example.com">A</a>
                 </sup>
                 <a href="http://wwww.example.com">A</a>
               </p>
             </div>
             <div>
               <h1>1.  Normative References</h1>
               <p id="ISO712" class="NormRef">ISO 712,
                 <i>Cereals and cereal products</i>
               </p>
               <p id="ISO713" class="NormRef">ISO 713,
                 <i>Cereals and cereal products</i>
               </p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)))).to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes eref content" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality><display-text>A</display-text></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:URI"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><display-text>A</display-text></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" droploc="true" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" case="lowercase" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_"/>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
             <localityStack connective="and">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">
                ISO 712, Table 1
                <span class="fmt-conn">and</span>
                Clause 1
             </fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
                <referenceTo>1</referenceTo>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Table 1–1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Clause 1, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Clause 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1.5</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Clause 1.5</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
             A
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">A</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="whole"/>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Whole of text</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="locality:prelude">
                <referenceFrom>7</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Prelude 7</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="locality:URI">
                <referenceFrom>7</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, URI 7</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">A</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO 712, Clause 1</fmt-xref>
          </semx>
          <eref type="inline" droploc="true" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" droploc="true" target="ISO712">ISO 712, 1</fmt-xref>
          </semx>
          <eref type="inline" case="lowercase" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" case="lowercase" target="ISO712">ISO 712, clause 1</fmt-xref>
          </semx>
       </p>
    OUTPUT

    html = <<~OUTPUT
            <p id="A">
      <a href="#ISO712">ISO&#xa0;712</a>
      <a href="#ISO712">ISO&#xa0;712</a>
      <a href="#ISO712">ISO&#xa0;712, Table 1</a>
      <a href='#ISO712'>ISO&#xa0;712, Table 1</a>
      <a href="#ISO712">ISO 712, Table 1 and Clause 1</a>
      <a href="#ISO712">ISO&#xa0;712, Table 1&#8211;1</a>
      <a href="#ISO712">ISO&#xa0;712, Clause 1, Table 1</a>
      <a href="#ISO712">ISO&#xa0;712, Clause 1</a>
      <a href="#ISO712">ISO&#xa0;712, Clause 1.5</a>
      <a href="#ISO712">A</a>
      <a href="#ISO712">ISO&#xa0;712, Whole of text</a>
      <a href="#ISO712">ISO&#xa0;712, Prelude 7</a>
      <a href="#ISO712">ISO&#xa0;712, URI 7</a>
      <a href="#ISO712">A</a>
      <a href='#ISO712'>ISO&#xa0;712</a>
      <a href='#ISO712'>ISO&#xa0;712, Clause 1</a>
      <a href='#ISO712'>ISO&#xa0;712, 1</a>
      <a href='#ISO712'>ISO&#xa0;712, clause 1</a>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes eref content pointing to reference with citation URL" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          </bibdata>
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO714"/>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">https://www.google.com</uri>
        <uri type="citation" language="en">https://www.google.com/en</uri>
        <uri type="citation" language="fr">https://www.google.com/fr</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO713" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">spec/assets/iso713</uri>
        <uri type="citation">spec/assets/iso714</uri>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO714" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">spec/assets/iso714.svg</uri>
        <docidentifier>ISO 714</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword displayorder="2">
          <title id="_">Avant-propos</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Avant-propos</semx>
          </fmt-title>
          <p>
             <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="https://www.google.com/fr">ISO 712</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="https://www.google.com/fr">ISO 712</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <localityStack connective="and">
                   <locality type="table">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <localityStack connective="and">
                   <locality type="table">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
                <localityStack connective="and">
                   <locality type="clause">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">
                   ISO 713, Tableau 1
                   <span class="fmt-conn">et</span>
                   Article 1
                </fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                   <referenceTo>1</referenceTo>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Tableau 1–1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Article 1, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Article 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1.5</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Article 1.5</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
                A
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">A</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="whole"/>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Ensemble du texte</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="locality:prelude">
                   <referenceFrom>7</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO 713, Prelude 7</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">A</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="anchor">
                   <referenceFrom>xyz</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html#xyz">ISO 713</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="anchor">
                   <referenceFrom>xyz</referenceFrom>
                </locality>
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html#xyz">ISO 713, Article 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO714" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso714.svg">ISO 714</fmt-link>
             </semx>
          </p>
       </foreword>
    OUTPUT

    html = <<~OUTPUT
      <div>
         <h1 class="ForewordTitle">Avant-propos</h1>
         <p>
            <a href="https://www.google.com/fr">ISO 712</a>
            <a href="https://www.google.com/fr">ISO 712</a>
            <a href="spec/assets/iso713.html">ISO 713, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO 713, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO 713, Tableau 1 et Article 1</a>
            <a href="spec/assets/iso713.html">ISO 713, Tableau 1–1</a>
            <a href="spec/assets/iso713.html">ISO 713, Article 1, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO 713, Article 1</a>
            <a href="spec/assets/iso713.html">ISO 713, Article 1.5</a>
            <a href="spec/assets/iso713.html">A</a>
            <a href="spec/assets/iso713.html">ISO 713, Ensemble du texte</a>
            <a href="spec/assets/iso713.html">ISO 713, Prelude 7</a>
            <a href="spec/assets/iso713.html">A</a>
            <a href="spec/assets/iso713.html#xyz">ISO 713</a>
            <a href="spec/assets/iso713.html#xyz">ISO 713, Article 1</a>
            <a href="spec/assets/iso714.svg">ISO 714</a>
         </p>
      </div>
    OUTPUT

    word = <<~OUTPUT
      <div>
         <h1 class="ForewordTitle">Avant-propos</h1>
         <p>
           <a href="https://www.google.com/fr">ISO 712</a>
           <a href="https://www.google.com/fr">ISO 712</a>
           <a href="spec/assets/iso713.html">ISO 713, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO 713, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO 713, Tableau 1 et Article 1</a>
           <a href="spec/assets/iso713.html">ISO 713, Tableau 1–1</a>
           <a href="spec/assets/iso713.html">ISO 713, Article 1, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO 713, Article 1</a>
           <a href="spec/assets/iso713.html">ISO 713, Article 1.5</a>
           <a href="spec/assets/iso713.html">A</a>
           <a href="spec/assets/iso713.html">ISO 713, Ensemble du texte</a>
           <a href="spec/assets/iso713.html">ISO 713, Prelude 7</a>
           <a href="spec/assets/iso713.html">A</a>
           <a href="spec/assets/iso713.html#xyz">ISO 713</a>
           <a href="spec/assets/iso713.html#xyz">ISO 713, Article 1</a>
           <a href="spec/assets/iso714.svg">ISO 714</a>
         </p>
       </div>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    xml = IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)
    expect(Xml::C14n.format(Nokogiri::XML(xml)
      .at("//div[h1/@class='ForewordTitle']").to_xml))
      .to be_equivalent_to Xml::C14n.format(html)
    xml = IsoDoc::WordConvert.new({})
      .convert("test", output, true)
    expect(Xml::C14n.format(Nokogiri::XML(xml)
      .at("//div[h1/@class='ForewordTitle']").to_xml))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes eref content pointing to reference with attachment URL" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          </bibdata>
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="attachment">https://example.google.com</uri>
        <uri type="citation">https://www.google.com</uri>
        <uri type="citation" language="en">https://www.google.com/en</uri>
        <uri type="citation" language="fr">https://www.google.com/fr</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword displayorder="2">
          <title id="_">Avant-propos</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Avant-propos</semx>
          </fmt-title>
          <p>
             <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link attachment="true" target="https://example.google.com">ISO 712</fmt-link>
             </semx>
          </p>
       </foreword>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes eref content pointing to hidden bibliographic entries" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true" hidden="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard" hidden="true">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">http://www.example.com</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO713" type="standard" hidden="true">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type='src'>https://www.iso.org/standard/3944.html</uri>
        <uri type='rss'>https://www.iso.org/contents/data/standard/00/39/3944.detail.rss</uri>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
    INPUT
    presxml = <<~PRESXML
       <p id="A">
           <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
           <semx element="eref" source="_">
              <fmt-link target="http://www.example.com">ISO 712</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO712" id="_"/>
           <semx element="eref" source="_">
              <fmt-link target="http://www.example.com">ISO 712</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="table">
                 <referenceFrom>1</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Table 1</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <localityStack connective="and">
                 <locality type="table">
                    <referenceFrom>1</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Table 1</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <localityStack connective="and">
                 <locality type="table">
                    <referenceFrom>1</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">
                 ISO 713, Table 1
                 <span class="fmt-conn">and</span>
                 Clause 1
              </fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="table">
                 <referenceFrom>1</referenceFrom>
                 <referenceTo>1</referenceTo>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Table 1–1</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="clause">
                 <referenceFrom>1</referenceFrom>
              </locality>
              <locality type="table">
                 <referenceFrom>1</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Clause 1, Table 1</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="clause">
                 <referenceFrom>1</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Clause 1</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="clause">
                 <referenceFrom>1.5</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Clause 1.5</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="table">
                 <referenceFrom>1</referenceFrom>
              </locality>
              A
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">A</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="whole"/>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Whole of text</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="locality:prelude">
                 <referenceFrom>7</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">ISO 713, Prelude 7</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html">A</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="anchor">
                 <referenceFrom>xyz</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html#xyz">ISO 713</fmt-link>
           </semx>
           <eref type="inline" bibitemid="ISO713" id="_">
              <locality type="anchor">
                 <referenceFrom>xyz</referenceFrom>
              </locality>
              <locality type="clause">
                 <referenceFrom>1</referenceFrom>
              </locality>
           </eref>
           <semx element="eref" source="_">
              <fmt-link target="https://www.iso.org/standard/3944.html#xyz">ISO 713, Clause 1</fmt-link>
           </semx>
        </p>
    PRESXML
    html = <<~OUTPUT
      <p id="A">
         <a href="http://www.example.com">ISO 712</a>
         <a href="http://www.example.com">ISO 712</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1 and Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1–1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1.5</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Whole of text</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Prelude 7</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO 713</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO 713, Clause 1</a>
      </p>
    OUTPUT
    word = <<~OUTPUT
      <p id="A">
         <a href="http://www.example.com">ISO 712</a>
         <a href="http://www.example.com">ISO 712</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1 and Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Table 1–1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Clause 1.5</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Whole of text</a>
         <a href="https://www.iso.org/standard/3944.html">ISO 713, Prelude 7</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO 713</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO 713, Clause 1</a>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true),
    )
  .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes eref content with Unicode characters" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <eref type="inline" bibitemid="ISO712" citeas="BSI BS EN ISO 19011:2018&#8201;&#8212;&#8201;TC"/></p>
      </foreword></preface>
              <bibliography>
          <references id='_normative_references' obligation='informative' normative='true'>
          <title>Normative References</title>
            <bibitem id='ISO712' type='standard'>
              <title format='text/plain'>Cereals and cereal products</title>
              <docidentifier>BSI BS EN ISO 19011:2018&#8201;&#8212;&#8201;TC</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
           </references></bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <eref type="inline" bibitemid="ISO712" citeas="BSI BS EN ISO 19011:2018 — TC" id="_"/>
              <semx element="eref" source="_">
                 <fmt-xref type="inline" target="ISO712">BSI BS EN ISO 19011:2018 — TC</fmt-xref>
              </semx>
           </p>
        </foreword>
      </foreword>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    expect(Xml::C14n.format(strip_guid(xml.at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

    it "processes erefstack" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
       <clause id="A1" inline-header="false" obligation="normative">
       <title>Section</title>
       <p id="A2">
       <erefstack><eref connective="from" bibitemid="A" citeas="A" type="inline" /><eref connective="to" bibitemid="B" citeas="B" type="inline" /></erefstack>
       </p>
       </clause>
       </sections>
       <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
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
      <bibitem id="ISO16634" type="standard">
        <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
        <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
        <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
        <date type="published"><on>--</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
        <extent type="part">
        <referenceFrom>all</referenceFrom>
        </extent>
      </bibitem>
      </bibliography>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A2">
          <erefstack id="_">
             <eref connective="from" bibitemid="A" citeas="A" type="inline" id="_"/>
             <eref connective="to" bibitemid="B" citeas="B" type="inline" id="_"/>
          </erefstack>
          <semx element="erefstack" source="_">
             <semx element="eref" source="_">
                <fmt-eref connective="from" bibitemid="A" citeas="A" type="inline">A</fmt-eref>
             </semx>
             <span class="fmt-conn">to</span>
             <semx element="eref" source="_">
                <fmt-eref connective="to" bibitemid="B" citeas="B" type="inline">B</fmt-eref>
             </semx>
          </semx>
       </p>
    OUTPUT
html = <<~OUTPUT
<p id="A2">
 A to B
 </p>
OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true))
    xml = xml.at("//xmlns:p[@id = 'A2']")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
        pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A2']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A2']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end


  it "processes variant" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <contributor>
      <role type="author"/>
      <organization>
      <name><variant language="en">A</variant><variant language="fr">B</variant></name>
      </organization>
      </contributor>
      </bibdata>
      <preface>
          <clause id="A"><title><variant lang="en" script="Latn">ABC</variant><variant lang="fr" script="Latn">DEF</variant></title></clause>
          <clause id="A1"><title><variant lang="en" script="Grek">ABC</variant><variant lang="fr" script="Grek">DEF</variant></title></clause>
          <clause id="A2"><title><variant lang="en">ABC</variant><variant lang="fr">DEF</variant></title></clause>
          <clause id="B"><title><variant lang="de" script="Latn">GHI</variant><variant lang="es" script="Latn">JKL</variant></title></clause>
          <clause id="C"><title><variant lang="fr" script="Latn">ABC</variant><variant lang="en" script="Latn">DEF</variant></title></clause>
          <clause id="C1"><title><variant lang="fr" script="Grek">ABC</variant><variant lang="en" script="Grek">DEF</variant></title></clause>
          <clause id="C2"><title><variant lang="fr">ABC</variant><variant lang="en">DEF</variant></title></clause>
          <p>A <variant><variant lang="en">B</variant><variant lang="fr">C</variant></variant> D <variant><variant lang="en" script="Latn">E</variant><variant lang="fr" script="Latn">F</variant></variant></p>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">en</language>
             <script current="true">Latn</script>
             <contributor>
                <role type="author"/>
                <organization>
                   <name>
                      <variant language="en">A</variant>
                      <variant language="fr">B</variant>
                   </name>
                </organization>
             </contributor>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <clause id="A" displayorder="2">
                <title id="_">ABC</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">ABC</semx>
                </fmt-title>
             </clause>
             <clause id="A1" displayorder="3">
                <title id="_">ABC/DEF</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">ABC/DEF</semx>
                </fmt-title>
             </clause>
             <clause id="A2" displayorder="4">
                <title id="_">ABC</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">ABC</semx>
                </fmt-title>
             </clause>
             <clause id="B" displayorder="5">
                <title id="_">GHI/JKL</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">GHI/JKL</semx>
                </fmt-title>
             </clause>
             <clause id="C" displayorder="6">
                <title id="_">DEF</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">DEF</semx>
                </fmt-title>
             </clause>
             <clause id="C1" displayorder="7">
                <title id="_">ABC/DEF</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">ABC/DEF</semx>
                </fmt-title>
             </clause>
             <clause id="C2" displayorder="8">
                <title id="_">DEF</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">DEF</semx>
                </fmt-title>
             </clause>
             <p displayorder="9">A B D E</p>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes add, del" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface>
      <clause type="toc" id="_" displayorder="1"> <fmt-title depth="1">Table of contents</fmt-title> </clause>
       <foreword id="A" displayorder="2"><fmt-title>Foreword</fmt-title>
      <add>ABC <fmt-xref target="A"/></add> <del><strong>B</strong></del>
      </foreword></preface>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
             <br/>
                 <div id="A">
                    <h1 class="ForewordTitle">Foreword</h1>
                    <span class="addition">
                       ABC
                       <a href="#A"/>
                    </span>
                    <span class="deletion">
                       <b>B</b>
                    </span>
                 </div>
              </div>
           </body>
        </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes formatting in eref/@citeas" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
               <preface>
           <foreword id='_' obligation='informative'>
             <title>Foreword</title>
             <p id='A'>
               <eref type='inline' bibitemid='iso124' citeas='[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]'/>
             </p>
           </foreword>
         </preface>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
        <p id="A">
           <eref type="inline" bibitemid="iso124" citeas="[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]" id="_"/>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="iso124" citeas="[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]">
                 [
                 <strong>A</strong>
                 .
                 <fn reference="1">
                    <p>hello</p>
                 </fn>
                 ]
              </fmt-eref>
           </semx>
        </p>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "combines locality stacks with connectives" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
                  <p id='_'>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                  <locality type="table">
                    <referenceFrom>2</referenceFrom>
                  </locality>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>7</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='annex'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='or'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>8</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>10</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id='_' normative='false' obligation='informative'>
            <title>Bibliography</title>
            <bibitem id='ref1'>
              <formattedref format='application/x-isodoc+xml'>
                <em>Standard</em>
              </formattedref>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
        <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
           <p id="_">
              <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="clause">
                          <referenceFrom>5</referenceFrom>
                       </locality>
                    </localityStack>
                    XYZ, Clauses 3
                    <span class="fmt-conn">to</span>
                    5
                 </fmt-eref>
              </semx>
              <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                    <locality type="table">
                       <referenceFrom>2</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="clause">
                          <referenceFrom>5</referenceFrom>
                       </locality>
                       <locality type="table">
                          <referenceFrom>2</referenceFrom>
                       </locality>
                    </localityStack>
                    XYZ, Clause 3
                    <span class="fmt-conn">to</span>
                    Clause 5, Table 2
                 </fmt-eref>
              </semx>
              text
           </p>
           <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>5</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
                 XYZ, Clauses 3
                 <span class="fmt-conn">and</span>
                 5
              </fmt-eref>
           </semx>
           <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>5</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>7</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>7</referenceFrom>
                    </locality>
                 </localityStack>
                 XYZ, Clauses 3
                 <span class="fmt-enum-comma">,</span>
                 5
                 <span class="fmt-enum-comma">,</span>
                 <span class="fmt-conn">and</span>
                 7
              </fmt-eref>
           </semx>
           <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="annex">
                    <referenceFrom>5</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="and">
                    <locality type="annex">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
                 XYZ, Clause 3
                 <span class="fmt-conn">and</span>
                 Annex 5
              </fmt-eref>
           </semx>
           <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="or">
                 <locality type="clause">
                    <referenceFrom>5</referenceFrom>
                 </locality>
              </localityStack>
              text
           </eref>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="or">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
                 text
              </fmt-eref>
           </semx>
           <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
              <localityStack connective="from">
                 <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="to">
                 <locality type="clause">
                    <referenceFrom>5</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="and">
                 <locality type="clause">
                    <referenceFrom>8</referenceFrom>
                 </locality>
              </localityStack>
              <localityStack connective="to">
                 <locality type="clause">
                    <referenceFrom>10</referenceFrom>
                 </locality>
              </localityStack>
           </eref>
           <semx element="eref" source="_">
              <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="and">
                    <locality type="clause">
                       <referenceFrom>8</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>10</referenceFrom>
                    </locality>
                 </localityStack>
                 XYZ, Clauses 3
                 <span class="fmt-conn">to</span>
                 5
                 <span class="fmt-conn">and</span>
                 8
                 <span class="fmt-conn">to</span>
                 10
              </fmt-eref>
           </semx>
        </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes ruby markup" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <preface>
      <foreword id="F">
      <p id="A">
      <ruby><pronunciation value="とうきょう"/>東京</ruby>
      <ruby><pronunciation value="とうきょう" lang="ja" script="Hira"/>東京</ruby>
      <ruby><pronunciation value="Tōkyō" script="Latn"/>東京</ruby>
      <ruby><annotation value="ライバル"/>親友</ruby>
      <ruby><pronunciation value="とう"/>東</ruby> <ruby><pronunciation value="きょう"/>京</ruby>
      <ruby><pronunciation value="Tō" script="Latn"/>東</ruby><ruby><pronunciation value="kyō" script="Latn"/>京</ruby>


      <ruby><pronunciation value="とう"/><ruby><pronunciation value="tou"/>東</ruby></ruby> <ruby><pronunciation value="なん"/><ruby><pronunciation value="nan"/>南</ruby></ruby> の方角
      <ruby><pronunciation value="たつみ"/><ruby><pronunciation value="とう"/>東</ruby><ruby><pronunciation value="なん"/>南</ruby></ruby>
      <ruby><pronunciation value="プロテゴ"/><ruby><pronunciation value="まも"/>護</ruby>れ</ruby>!
      <ruby><pronunciation value="プロテゴ"/>れ<ruby><pronunciation value="まも"/>護</ruby></ruby>!</p>
      </p>
      </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
           <p id="A">
           <ruby><rb>東京</rb><rt>とうきょう</rt></ruby><ruby><rb>東京</rb><rt>とうきょう</rt></ruby><ruby><rb>東京</rb><rt>Tōkyō</rt></ruby><ruby><rb>親友</rb><rt>ライバル</rt></ruby><ruby><rb>東</rb><rt>とう</rt></ruby><ruby><rb>京</rb><rt>きょう</rt></ruby><ruby><rb>東</rb><rt>Tō</rt></ruby><ruby><rb>京</rb><rt>kyō</rt></ruby><ruby><rb><ruby><rb>東</rb><rt>tou</rt></ruby></rb><rt>とう</rt></ruby><ruby><rb><ruby><rb>南</rb><rt>nan</rt></ruby></rb><rt>なん</rt></ruby> の方角
      <ruby><rb><ruby><rb>東</rb><rt>とう</rt></ruby><ruby><rb>南</rb><rt>なん</rt></ruby></rb><rt>たつみ</rt></ruby>
      <ruby><rb><ruby><rb>護</rb><rt>まも</rt></ruby>れ</rb><rt>プロテゴ</rt></ruby>!
      <ruby><rb>れ<ruby><rb>護</rb><rt>まも</rt></ruby></rb><rt>プロテゴ</rt></ruby>!</p>
            </p>
    OUTPUT
    html = <<~OUTPUT
             <p id="A"><ruby><rb>東京</rb><rt>とうきょう</rt></ruby><ruby><rb>東京</rb><rt>とうきょう</rt></ruby><ruby><rb>東京</rb><rt>Tōkyō</rt></ruby><ruby><rb>親友</rb><rt>ライバル</rt></ruby><ruby><rb>東</rb><rt>とう</rt></ruby><ruby><rb>京</rb><rt>きょう</rt></ruby><ruby><rb>東</rb><rt>Tō</rt></ruby><ruby><rb>京</rb><rt>kyō</rt></ruby><ruby><rb><ruby><rb>東</rb><rt>tou</rt></ruby></rb><rt>とう</rt></ruby><ruby><rb><ruby><rb>南</rb><rt>nan</rt></ruby></rb><rt>なん</rt></ruby> の方角
      <ruby><rb><ruby><rb>東</rb><rt>とう</rt></ruby><ruby><rb>南</rb><rt>なん</rt></ruby></rb><rt>たつみ</rt></ruby>
      <ruby><rb><ruby><rb>護</rb><rt>まも</rt></ruby>れ</rb><rt>プロテゴ</rt></ruby>!
      <ruby><rb>れ<ruby><rb>護</rb><rt>まも</rt></ruby></rb><rt>プロテゴ</rt></ruby>!</p>
    OUTPUT
    doc = <<~OUTPUT
      <p id="A"><ruby><rb>東京</rb><rt style="font-size: 6pt;">とうきょう</rt></ruby><ruby><rb>東京</rb><rt style="font-size: 6pt;">とうきょう</rt></ruby><ruby><rb>東京</rb><rt style="font-size: 6pt;">Tōkyō</rt></ruby><ruby><rb>親友</rb><rt style="font-size: 6pt;">ライバル</rt></ruby><ruby><rb>東</rb><rt style="font-size: 6pt;">とう</rt></ruby><ruby><rb>京</rb><rt style="font-size: 6pt;">きょう</rt></ruby><ruby><rb>東</rb><rt style="font-size: 6pt;">Tō</rt></ruby><ruby><rb>京</rb><rt style="font-size: 6pt;">kyō</rt></ruby><ruby><rb>東</rb><rt style="font-size: 6pt;">とう</rt></ruby>(tou)<ruby><rb>南</rb><rt style="font-size: 6pt;">なん</rt></ruby>(nan) の方角
      <ruby><rb>東</rb><rt style="font-size: 6pt;">たつみ</rt></ruby>(とう)
      <ruby><rb>護</rb><rt style="font-size: 6pt;">プロテゴ</rt></ruby>(まも)!
      <ruby><rb>護</rb><rt style="font-size: 6pt;">プロテゴ</rt></ruby>(まも)!</p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true),
    )
  .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end
