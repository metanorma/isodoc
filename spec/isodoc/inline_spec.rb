require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
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
    expect(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_html5_equivalent_to html
    expect(IsoDoc::WordConvert.new({})
      .convert("test", input, true)
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_xml_equivalent_to doc
  end

  it "processes identifier" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <bibdata/>
      <sections><clause id="_scope" type="scope" inline-header="false" obligation="normative">
      <title>Scope</title>
      <p id="A"><identifier>http://www.example.com A-B</identifier></p>
      </clause>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <identifier id="_">http://www.example.com A-B</identifier>
          <fmt-identifier>
             <tt>
                <semx element="identifier" source="_">http://www.example.com A-B</semx>
             </tt>
          </fmt-identifier>
       </p>
    OUTPUT
    html = <<~OUTPUT
       <p id="A">
          <span style="white-space: nowrap;">
             <tt>http://www.example.com A-B</tt>
          </span>
       </p>
    OUTPUT
    doc = <<~OUTPUT
           <p class="MsoNormal">
          <a name="A" id="A"/>
          <span>
             <tt>http://www.⁠example.⁠com\\u00a0A‑B</tt>
          </span>
       </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml))
      .to be_html5_equivalent_to html
    FileUtils.rm_f("test.doc")
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")
    wordxml = Nokogiri::XML(word)
    expect(strip_guid(wordxml.at("//p").to_xml))
      .to be_xml_equivalent_to doc
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
    expect(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml))
      .to be_html5_equivalent_to html
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <xref target="clause1" id="_"/>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>w[o]rd</renderterm>
                   <xref target="clause1" id="_">Clause #1</xref>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>term</em>
                      <semx element="eref" source="_">
                         (
                         <fmt-xref type="inline" target="ISO712">ISO\\u00a0712</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">The Aforementioned Citation</eref>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
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
                         <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Clause 3.1, Figure a</fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
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
                            ISO\\u00a0712, Clause 3.1
                            <span class="fmt-conn">and</span>
                            Figure b
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
             </li>
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>word</renderterm>
                   <eref bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
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
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
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
    output = <<~OUTPUT
         <p id="A">
          <div class="ul_wrap">
             <ul>
                <li id="_">
                   (
                   <a href="#clause1">Clause 2</a>
                   )
                </li>
                <li id="_">
                   <i>term</i>
                   (
                   <a href="#clause1">Clause 2</a>
                   )
                </li>
                <li id="_">
                   <i>w[o]rd</i>
                   (
                   <a href="#clause1">Clause #1</a>
                   )
                </li>
                <li id="_">
                   <i>term</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712</a>
                   )
                </li>
                <li id="_">
                   <i>word</i>
                   (
                   <a href="#ISO712">The Aforementioned Citation</a>
                   )
                </li>
                <li id="_">
                   <i>word</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712, Clause 3.1, Figure a</a>
                   )
                </li>
                <li id="_">
                   <i>word</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712, Clause 3.1 and Figure b</a>
                   )
                </li>
                <li id="_">
                   <i>word</i>
                   (
                   <a href="#ISO712">
     
     
               The Aforementioned Citation
               </a>
                   )
                </li>
                <li id="_">
                   <i>word</i>
                   [Termbase IEV, term ID 135-13-13]
                </li>
                <li id="_">
                   <i>word</i>
                   (The IEV database)
                </li>
                <li id="_">
                   <b>error!</b>
                </li>
             </ul>
          </div>
       </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
      .at("//p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to output
  end

  it "processes embedded inline formatting" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
        <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
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
            <foreword id="_" displayorder="1">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">Foreword</fmt-title>
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
                  <xref target="_http_1_1" id="_">
                     Requirement
                     <tt>/req/core/http</tt>
                  </xref>
                  <semx element="xref" source="_">
                     <fmt-xref target="_http_1_1">
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
        </sections>
      </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      <html lang="en">
      <head/>
      <body lang="en">
        <div class="title-section">
        <p>\\u00a0</p>
        </div>
        <br/>
        <div class="prefatory-section">
        <p>\\u00a0</p>
        </div>
        <br/>
        <div class="main-section">
        <br/>
        <div id="_">
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
        <i><b>&lt;</b></i> <tt><a href="B">B</a></tt> <a href="#_http_1_1">Requirement <tt>/req/core/http</tt></a> Requirement <tt>/req/core/http</tt>
        </p>
        </div>
        <div class="TOC" id="_">
        <h1 class="IntroTitle">Table of contents</h1>
        </div>
        <br/>
        </div>
        </div>
      </body>
      </html>
    OUTPUT

   pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to output
  end

  it "processes inline images" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
      <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
          <p>
        <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
        </p>
        </foreword></preface>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{HTML_HDR}
            <br/>
            <div id="_">
              <h1 class='ForewordTitle'>Foreword</h1>
              <p>
                <img src='rice_images/rice_image1.png' height='20' width='30' title='titletxt' alt='alttext'/>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_html5_equivalent_to output
  end

  it "processes unrecognised markup" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
      <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
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
                 <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
         <para><b role="strong">&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</b></para>
         </p>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_html5_equivalent_to output
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
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <clause id="A" displayorder="2">
                <title id="_">ABC</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">ABC</semx>
                </fmt-title>
             </clause>
             <clause id="A1" displayorder="3">
                <title id="_">ABC/DEF</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">ABC/DEF</semx>
                </fmt-title>
             </clause>
             <clause id="A2" displayorder="4">
                <title id="_">ABC</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">ABC</semx>
                </fmt-title>
             </clause>
             <clause id="B" displayorder="5">
                <title id="_">GHI/JKL</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">GHI/JKL</semx>
                </fmt-title>
             </clause>
             <clause id="C" displayorder="6">
                <title id="_">DEF</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">DEF</semx>
                </fmt-title>
             </clause>
             <clause id="C1" displayorder="7">
                <title id="_">ABC/DEF</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">ABC/DEF</semx>
                </fmt-title>
             </clause>
             <clause id="C2" displayorder="8">
                <title id="_">DEF</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">DEF</semx>
                </fmt-title>
             </clause>
             <p displayorder="9">A B D E</p>
          </preface>
       </iso-standard>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to output
  end

  it "processes add, del" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface>
      <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>
       <foreword id="A" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
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
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_html5_equivalent_to output
  end

  it "processes ruby markup" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <preface>
      <foreword id="F">
      <p id="A">
      <ruby><ruby-pronunciation value="とうきょう"/>東京</ruby>
      <ruby><ruby-pronunciation value="とうきょう" lang="ja" script="Hira"/>東京</ruby>
      <ruby><ruby-pronunciation value="Tōkyō" script="Latn"/>東京</ruby>
      <ruby><ruby-annotation value="ライバル"/>親友</ruby>
      <ruby><ruby-pronunciation value="とう"/>東</ruby> <ruby><ruby-pronunciation value="きょう"/>京</ruby>
      <ruby><ruby-pronunciation value="Tō" script="Latn"/>東</ruby><ruby><ruby-pronunciation value="kyō" script="Latn"/>京</ruby>


      <ruby><ruby-pronunciation value="とう"/><ruby><ruby-pronunciation value="tou"/>東</ruby></ruby> <ruby><ruby-pronunciation value="なん"/><ruby><ruby-pronunciation value="nan"/>南</ruby></ruby> の方角
      <ruby><ruby-pronunciation value="たつみ"/><ruby><ruby-pronunciation value="とう"/>東</ruby><ruby><ruby-pronunciation value="なん"/>南</ruby></ruby>
      <ruby><ruby-pronunciation value="プロテゴ"/><ruby><ruby-pronunciation value="まも"/>護</ruby>れ</ruby>!
      <ruby><ruby-pronunciation value="プロテゴ"/>れ<ruby><ruby-pronunciation value="まも"/>護</ruby></ruby>!</p>
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
    expect(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml))
      .to be_html5_equivalent_to html
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true),
    )
  .at("//p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to doc
  end
end
