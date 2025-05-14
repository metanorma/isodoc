require "spec_helper"

RSpec.describe IsoDoc do
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
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
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
    html = <<~OUTPUT
      <p id="A">
          <div class="ul_wrap">
             <ul>
                <li>
                   (
                   <a href="#clause1">Clause 2</a>
                   )
                </li>
                <li>
                   <i>term</i>
                   (
                   <a href="#clause1">Clause 2</a>
                   )
                </li>
                <li>
                   <i>w[o]rd</i>
                   (
                   <a href="#clause1">Clause #1</a>
                   )
                </li>
                <li>
                   <i>term</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712</a>
                   )
                </li>
                <li>
                   <i>word</i>
                   (
                   <a href="#ISO712">The Aforementioned Citation</a>
                   )
                </li>
                <li>
                   <i>word</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712, Clause 3.1, Figure a</a>
                   )
                </li>
                <li>
                   <i>word</i>
                   (
                   <a href="#ISO712">ISO\\u00a0712, Clause 3.1 and Figure b</a>
                   )
                </li>
                <li>
                   <i>word</i>
                   (
                   <a href="#ISO712">
     
     
               The Aforementioned Citation
               </a>
                   )
                </li>
                <li>
                   <i>word</i>
                   [Termbase IEV, term ID 135-13-13]
                </li>
                <li>
                   <i>word</i>
                   (The IEV database)
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes concept attributes" do
    input = <<~INPUT
             <iso-standard xmlns="http://riboseinc.com/isoxml">
             <preface><foreword>
             <p id="A">
             <ul>
             <li><concept ital="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept bold="true" ital="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept bold="true" ital="true" ref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="false" bold="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="false" ref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true" linkmention="true" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept bold="true" ital="false" ref="true" linkmention="true" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept bold="true" ital="true" ref="true" linkmention="true" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true" linkmention="true" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true" linkmention="false" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true" linkmention="false" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept>,</li>
             <li><concept ital="true" ref="true" linkmention="true" linkref="true"><strong>error!</strong></concept></li>
             <li><concept ital="false" bold="false" ref="false" linkmention="true">
      <refterm>CV_DiscreteCoverage</refterm>
      <renderterm>CV_DiscreteCoverage</renderterm>
      <xref target="term-cv_discretecoverage"/>
      </concept></li>
              </ul></p>
               </foreword></preface>
             <sections>
             <clause id="clause1"><title>Clause 1</title></clause>
             </sections>
            </iso-standard>
    INPUT

    presxml = <<~OUTPUT
       <p id="A">
          <ul>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" id="_">
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
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept bold="true" ital="false" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <strong>term</strong>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ref="true" id="_">
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
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" id="_">
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
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept bold="true" ital="true" ref="true" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <strong>
                         <em>term</em>
                      </strong>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="false" bold="true" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <strong>term</strong>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ref="false" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>term</em>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="false" ref="false" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">term</semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" linkmention="true" linkref="true" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         <fmt-xref target="clause1">
                            <em>term</em>
                         </fmt-xref>
                      </semx>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept bold="true" ital="false" ref="true" linkmention="true" linkref="true" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         <fmt-xref target="clause1">
                            <strong>term</strong>
                         </fmt-xref>
                      </semx>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept bold="true" ital="true" ref="true" linkmention="true" linkref="true" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         <fmt-xref target="clause1">
                            <strong>
                               <em>term</em>
                            </strong>
                         </fmt-xref>
                      </semx>
                      <semx element="xref" source="_">
                         (
                         <fmt-xref target="clause1">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" linkmention="true" linkref="false" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         <fmt-xref target="clause1">
                            <em>term</em>
                         </fmt-xref>
                      </semx>
                      <semx element="xref" source="_">
                         (
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="clause1">1</semx>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" linkmention="false" linkref="true" id="_">
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
                            <semx element="autonum" source="clause1">1</semx>
                         </fmt-xref>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" linkmention="false" linkref="false" id="_">
                   <refterm>term</refterm>
                   <renderterm>term</renderterm>
                   <xref target="clause1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <em>term</em>
                      <semx element="xref" source="_">
                         (
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="clause1">1</semx>
                         )
                      </semx>
                   </semx>
                </fmt-concept>
                ,
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="true" ref="true" linkmention="true" linkref="true" id="_">
                   <strong>error!</strong>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <strong>error!</strong>
                   </semx>
                </fmt-concept>
             </li>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept ital="false" bold="false" ref="false" linkmention="true" id="_">
                   <refterm>CV_DiscreteCoverage</refterm>
                   <renderterm>CV_DiscreteCoverage</renderterm>
                   <xref target="term-cv_discretecoverage" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">
                      <semx element="xref" source="_">
                         <fmt-xref target="term-cv_discretecoverage">CV_DiscreteCoverage</fmt-xref>
                      </semx>
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
          <li><i>term</i> (<a href="#clause1">Clause 1</a>),</li>
          <li><b>term</b> (<a href="#clause1">Clause 1</a>),</li>
          <li><i>term</i> (<a href="#clause1">Clause 1</a>),</li>
          <li><i>term</i> (<a href="#clause1">Clause 1</a>),</li>
          <li><b><i>term</i></b> (<a href="#clause1">Clause 1</a>),</li>
          <li><b>term</b> (<a href="#clause1">Clause 1</a>),</li>
          <li><i>term</i>,</li>
          <li>term,</li>
          <li><a href="#clause1"><i>term</i></a> (<a href="#clause1">Clause 1</a>),</li>
          <li><a href="#clause1"><b>term</b></a> (<a href="#clause1">Clause 1</a>),</li>
          <li><a href="#clause1"><b><i>term</i></b></a> (<a href="#clause1">Clause 1</a>),</li>
          <li><a href="#clause1"><i>term</i></a> (Clause 1),</li>
          <li><i>term</i> (<a href="#clause1">Clause 1</a>),</li>
          <li><i>term</i> (Clause 1),</li>
          <li>
            <b>error!</b>
          </li>
          <li>
            <a href="#term-cv_discretecoverage">CV_DiscreteCoverage</a>
          </li>
        </ul>
        </div>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes concept markup for symbols" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p id="A">
      <ul>
      <li><concept><refterm>term</refterm><renderterm>ISO</renderterm><xref target='d1'/></concept></li>
        </ul>
        </p>
        </foreword>
        </preface>
        <sections>
        <definitions id="d">
        <dl>
        <dt id="d1">ISO</dt> <dd>xyz</xyz>
        <dt id="d2">IEC</dt> <dd>abc</xyz>
        </dl>
        </definitions>
        </sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <ul>
             <li>
                <fmt-name>
                   <semx element="autonum" source="">—</semx>
                </fmt-name>
                <concept id="_">
                   <refterm>term</refterm>
                   <renderterm>ISO</renderterm>
                   <xref target="d1" id="_"/>
                </concept>
                <fmt-concept>
                   <semx element="concept" source="_">ISO</semx>
                </fmt-concept>
             </li>
          </ul>
       </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A">
      <div class="ul_wrap">
        <ul>
          <li>ISO</li>
        </ul>
        </div>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

    it "do not process concept markup in Semantic XML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <definition><verbal-definition>
      <ul>
      <concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </verbal-definition></definition>
      </term>
      </terms>
      </sections></iso-standard>
    INPUT
    output = <<~OUTPUT
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
         <title id="_">Terms and Definitions</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Terms and Definitions</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="terms_and_definitions">1</semx>
         </fmt-xref-label>
         <term id="paddy1">
            <fmt-name>
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy1">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy1">1</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>paddy</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>paddy</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <definition id="_">
               <verbal-definition>
                  <ul>
                     <concept>
                        <refterm>term1</refterm>
                        <renderterm>term</renderterm>
                        <xref target="clause1"/>
                     </concept>
                  </ul>
                  <li>
                    <concept>
                        <refterm>term1</refterm>
                        <renderterm>term</renderterm>
                        <xref target="clause1"/>
                     </concept>
                  </li>
               </verbal-definition>
            </definition>
            <fmt-definition>
               <semx element="definition" source="_">
                  <ul>
                     <concept id="_">
                        <refterm>term1</refterm>
                        <renderterm>term</renderterm>
                        <xref target="clause1" id="_"/>
                     </concept>
                     <fmt-concept>
                        <semx element="concept" source="_">
                           <em>term</em>
                           <semx element="xref" source="_">
                              (
                              <fmt-xref target="clause1">[clause1]</fmt-xref>
                              )
                           </semx>
                        </semx>
                     </fmt-concept>
                  </ul>
                  <li>
                     <concept id="_">
                        <refterm>term1</refterm>
                        <renderterm>term</renderterm>
                        <xref target="clause1" id="_"/>
                     </concept>
                     <fmt-concept>
                        <semx element="concept" source="_">
                           <em>term</em>
                           <semx element="xref" source="_">
                              (
                              <fmt-xref target="clause1">[clause1]</fmt-xref>
                              )
                           </semx>
                        </semx>
                     </fmt-concept>
                  </li>
               </semx>
            </fmt-definition>
         </term>
      </terms>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
