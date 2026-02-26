require "spec_helper"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.presentation.xml"
    IsoDoc::PresentationXMLConvert.new({ filename: "test" }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
  end

  it "resolve address components" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <contributor>
                 <role type='author'/>
                 <person>
                   <name>
                     <completename>Fred Flintstone</completename>
                   </name>
                   <affiliation>
                     <organization>
                       <name>Slate Rock and Gravel Company</name>
                       <address>
                         <street>1 Infinity Loop</street>
                         <city>Cupertino</city>
                         <state>CA</state>
                         <country>USA</country>
                         <postcode>95014</postcode>
                       </address>
                     </organization>
                   </affiliation>
                 </person>
               </contributor>
      </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <contributor>
            <role type='author'/>
            <person>
              <name>
                <completename>Fred Flintstone</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Slate Rock and Gravel Company</name>
                  <address>
                    <formattedAddress>
                      1 Infinity Loop
                      <br/>
                      Cupertino
                      <br/>
                      CA
                      <br/>
                      USA 95014
                    </formattedAddress>
                  </address>
                </organization>
              </affiliation>
            </person>
          </contributor>
        </bibdata>
      </iso-standard>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to output
  end

  it "strips variant-title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
               <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <p id='B'>Text</p>
             <clause id='C' inline-header='false' obligation='normative'>
               <title>Subclause</title>
               <variant-title variant_title='true' type='sub' id='D'>&#8220;A&#8221; &#8216;B&#8217;</variant-title>
               <variant-title variant_title='true' type='toc' id='E'>
                 Clause
                 <em>A</em>
                 <stem type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mi>x</mi>
                   </math>
                 </stem>
               </variant-title>
               <p id='F'>Text</p>
             </clause>
           </clause>
         </sections>
         <annex id='G' inline-header='false' obligation='normative'>
           <title>Clause</title>
           <variant-title variant_title='true' type='toc' id='H'>
             Clause
             <em>A</em>
             <stem type='MathML'>
               <math xmlns='http://www.w3.org/1998/Math/MathML'>
                 <mi>x</mi>
               </math>
             </stem>
           </variant-title>
           <p id='_'>Text</p>
         </annex>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata/>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="A" inline-header="false" obligation="normative" displayorder="2">
                <title id="_">Clause</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref-label>
                <p id="B">Text</p>
                <clause id="C" inline-header="false" obligation="normative">
                   <title id="_">Subclause</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="A">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="C">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Subclause</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </fmt-xref-label>
                   <variant-title variant_title="true" type="sub" id="D">“A” ‘B’</variant-title>
                   <variant-title variant_title="true" type="toc" id="E">
                      Clause
                      <em>A</em>
                      <stem type="MathML" id="_">
                         <math xmlns="http://www.w3.org/1998/Math/MathML">
                            <mi>x</mi>
                         </math>
                      </stem>
                      <fmt-stem type="MathML">
                         <semx element="stem" source="_">
                            <math xmlns="http://www.w3.org/1998/Math/MathML">
                               <mi>x</mi>
                            </math>
                            <asciimath>x</asciimath>
                         </semx>
                      </fmt-stem>
                   </variant-title>
                   <p id="F">Text</p>
                </clause>
             </clause>
          </sections>
          <annex id="G" inline-header="false" obligation="normative" autonum="A" displayorder="3">
             <title id="_">
                <strong>Clause</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="G">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Clause</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="G">A</semx>
             </fmt-xref-label>
             <variant-title variant_title="true" type="toc" id="H">
                Clause
                <em>A</em>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mi>x</mi>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
                      <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mi>x</mi>
                      </math>
                      <asciimath>x</asciimath>
                   </semx>
                </fmt-stem>
             </variant-title>
             <p id="_">Text</p>
          </annex>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                <div id="A">
                   <h1>1.\\u00a0 Clause</h1>
                   <p id="B">Text</p>
                   <div id="C">
                      <h2>
                         1.1.\\u00a0 Subclause
                         <br/>
                         <br/>
                         “A” ‘B’
                      </h2>
                      <p style="display:none;" class="variant-title-toc">
                         Clause
                         <i>A</i>
                         <span class="stem">
                            <math xmlns="http://www.w3.org/1998/Math/MathML">
                               <mi>x</mi>
                            </math>
                         </span>
                      </p>
                      <p id="F">Text</p>
                   </div>
                </div>
                <br/>
                <div id="G" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (normative)
                      <br/>
                      <br/>
                      <b>Clause</b>
                   </h1>
                   <p style="display:none;" class="variant-title-toc">
                      Clause
                      <i>A</i>
                      <span class="stem">
                         <math xmlns="http://www.w3.org/1998/Math/MathML">
                            <mi>x</mi>
                         </math>
                      </span>
                   </p>
                   <p id="_">Text</p>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    doc = <<~OUTPUT
       #{WORD_HDR}
               <p>\\u00a0</p>
      </div>
      <p class="section-break">
         <br clear="all" class="section"/>
      </p>
      <div class="WordSection3">
                <div id="A">
                   <h1>
                      1.
                      <span style="mso-tab-count:1">\\u00a0 </span>
                      Clause
                   </h1>
                   <p id="B">Text</p>
                   <div id="C">
                      <h2>
                         1.1.
                         <span style="mso-tab-count:1">\\u00a0 </span>
                         Subclause
                         <br/>
                         <br/>
                         “A” ‘B’
                      </h2>
                      <p style="display:none;" class="variant-title-toc">
                         Clause
                         <i>A</i>
                         <span class="stem">
                            <math xmlns="http://www.w3.org/1998/Math/MathML">
                               <mi>x</mi>
                            </math>
                         </span>
                      </p>
                      <p id="F">Text</p>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="G" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (normative)
                      <br/>
                      <br/>
                      <b>Clause</b>
                   </h1>
                   <p style="display:none;" class="variant-title-toc">
                      Clause
                      <i>A</i>
                      <span class="stem">
                         <math xmlns="http://www.w3.org/1998/Math/MathML">
                            <mi>x</mi>
                         </math>
                      </span>
                   </p>
                   <p id="_">Text</p>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
    expect(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html4_equivalent_to doc
  end

  it "configures unordered list bullets dynamically" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>en</language></bibdata>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <ul id="B1">
             <li>A1
             <ul id="B2">
             <li>A2
             <ul id="B3">
             <li>A3
             <ul id="B4">
             <li>A4
             <ul id="B5">
             <li>A5
             <ul id="B6">
             <li>A6
             <ul id="B7">
             <li>A7
             <ul id="B8">
             <li>A8
             <ul id="B9">
             <li>A9
             <ul id="B0">
             <li>A0</li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul></li>
             </ul>
           </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <ul id="B1">
         <li id="_">
            <fmt-name id="_">
               <semx element="autonum" source="_">—</semx>
            </fmt-name>
            A1
            <ul id="B2">
               <li id="_">
                  <fmt-name id="_">
                     <semx element="autonum" source="_">—</semx>
                  </fmt-name>
                  A2
                  <ul id="B3">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        A3
                        <ul id="B4">
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">—</semx>
                              </fmt-name>
                              A4
                              <ul id="B5">
                                 <li id="_">
                                    <fmt-name id="_">
                                       <semx element="autonum" source="_">—</semx>
                                    </fmt-name>
                                    A5
                                    <ul id="B6">
                                       <li id="_">
                                          <fmt-name id="_">
                                             <semx element="autonum" source="_">—</semx>
                                          </fmt-name>
                                          A6
                                          <ul id="B7">
                                             <li id="_">
                                                <fmt-name id="_">
                                                   <semx element="autonum" source="_">—</semx>
                                                </fmt-name>
                                                A7
                                                <ul id="B8">
                                                   <li id="_">
                                                      <fmt-name id="_">
                                                         <semx element="autonum" source="_">—</semx>
                                                      </fmt-name>
                                                      A8
                                                      <ul id="B9">
                                                         <li id="_">
                                                            <fmt-name id="_">
                                                               <semx element="autonum" source="_">—</semx>
                                                            </fmt-name>
                                                            A9
                                                            <ul id="B0">
                                                               <li id="_">
                                                                  <fmt-name id="_">
                                                                     <semx element="autonum" source="_">—</semx>
                                                                  </fmt-name>
                                                                  A0
                                                               </li>
                                                            </ul>
                                                         </li>
                                                      </ul>
                                                   </li>
                                                </ul>
                                             </li>
                                          </ul>
                                       </li>
                                    </ul>
                                 </li>
                              </ul>
                           </li>
                        </ul>
                     </li>
                  </ul>
               </li>
            </ul>
         </li>
      </ul>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:ul[@id = 'B1']").to_xml))
      .to be_xml_equivalent_to presxml
    m = <<~METADATA
      <metanorma-extension><presentation-metadata><ul-label-list>•</ul-label-list></presentation-metadata><presentation-metadata><ul-label-list>-</ul-label-list></presentation-metadata><presentation-metadata><ul-label-list>o</ul-label-list></presentation-metadata></metanorma-extension>
    METADATA
    presxml = <<~OUTPUT
      <ul id="B1">
         <li id="_">
            <fmt-name id="_">
               <semx element="autonum" source="_">•</semx>
            </fmt-name>
            A1
            <ul id="B2">
               <li id="_">
                  <fmt-name id="_">
                     <semx element="autonum" source="_">-</semx>
                  </fmt-name>
                  A2
                  <ul id="B3">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">o</semx>
                        </fmt-name>
                        A3
                        <ul id="B4">
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">•</semx>
                              </fmt-name>
                              A4
                              <ul id="B5">
                                 <li id="_">
                                    <fmt-name id="_">
                                       <semx element="autonum" source="_">-</semx>
                                    </fmt-name>
                                    A5
                                    <ul id="B6">
                                       <li id="_">
                                          <fmt-name id="_">
                                             <semx element="autonum" source="_">o</semx>
                                          </fmt-name>
                                          A6
                                          <ul id="B7">
                                             <li id="_">
                                                <fmt-name id="_">
                                                   <semx element="autonum" source="_">•</semx>
                                                </fmt-name>
                                                A7
                                                <ul id="B8">
                                                   <li id="_">
                                                      <fmt-name id="_">
                                                         <semx element="autonum" source="_">-</semx>
                                                      </fmt-name>
                                                      A8
                                                      <ul id="B9">
                                                         <li id="_">
                                                            <fmt-name id="_">
                                                               <semx element="autonum" source="_">o</semx>
                                                            </fmt-name>
                                                            A9
                                                            <ul id="B0">
                                                               <li id="_">
                                                                  <fmt-name id="_">
                                                                     <semx element="autonum" source="_">•</semx>
                                                                  </fmt-name>
                                                                  A0
                                                               </li>
                                                            </ul>
                                                         </li>
                                                      </ul>
                                                   </li>
                                                </ul>
                                             </li>
                                          </ul>
                                       </li>
                                    </ul>
                                 </li>
                              </ul>
                           </li>
                        </ul>
                     </li>
                  </ul>
               </li>
            </ul>
         </li>
      </ul>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("</bibdata>", "</bibdata>#{m}"), true))
      .at("//xmlns:ul[@id = 'B1']").to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "adds types to ordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <ol id="B1">
             <li>A1
             <ol id="B2">
             <li>A2
             <ol id="B3">
             <li>A3
             <ol id="B4">
             <li>A4
             <ol id="B5">
             <li>A5
             <ol id="B6">
             <li>A6
             <ol id="B7">
             <li>A7
             <ol id="B8">
             <li>A8
             <ol id="B9">
             <li>A9
             <ol id="B0">
             <li>A0</li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol></li>
             </ol>
           </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <ol id="B1" type="alphabet">
         <li id="_">
            <fmt-name id="_">
               <semx element="autonum" source="_">a</semx>
               <span class="fmt-label-delim">)</span>
            </fmt-name>
            A1
            <ol id="B2" type="arabic">
               <li id="_">
                  <fmt-name id="_">
                     <semx element="autonum" source="_">1</semx>
                     <span class="fmt-label-delim">)</span>
                  </fmt-name>
                  A2
                  <ol id="B3" type="roman">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">i</semx>
                           <span class="fmt-label-delim">)</span>
                        </fmt-name>
                        A3
                        <ol id="B4" type="alphabet_upper">
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">A</semx>
                                 <span class="fmt-label-delim">.</span>
                              </fmt-name>
                              A4
                              <ol id="B5" type="roman_upper">
                                 <li id="_">
                                    <fmt-name id="_">
                                       <semx element="autonum" source="_">I</semx>
                                       <span class="fmt-label-delim">.</span>
                                    </fmt-name>
                                    A5
                                    <ol id="B6" type="alphabet">
                                       <li id="_">
                                          <fmt-name id="_">
                                             <semx element="autonum" source="_">a</semx>
                                             <span class="fmt-label-delim">)</span>
                                          </fmt-name>
                                          A6
                                          <ol id="B7" type="arabic">
                                             <li id="_">
                                                <fmt-name id="_">
                                                   <semx element="autonum" source="_">1</semx>
                                                   <span class="fmt-label-delim">)</span>
                                                </fmt-name>
                                                A7
                                                <ol id="B8" type="roman">
                                                   <li id="_">
                                                      <fmt-name id="_">
                                                         <semx element="autonum" source="_">i</semx>
                                                         <span class="fmt-label-delim">)</span>
                                                      </fmt-name>
                                                      A8
                                                      <ol id="B9" type="alphabet_upper">
                                                         <li id="_">
                                                            <fmt-name id="_">
                                                               <semx element="autonum" source="_">A</semx>
                                                               <span class="fmt-label-delim">.</span>
                                                            </fmt-name>
                                                            A9
                                                            <ol id="B0" type="roman_upper">
                                                               <li id="_">
                                                                  <fmt-name id="_">
                                                                     <semx element="autonum" source="_">I</semx>
                                                                     <span class="fmt-label-delim">.</span>
                                                                  </fmt-name>
                                                                  A0
                                                               </li>
                                                            </ol>
                                                         </li>
                                                      </ol>
                                                   </li>
                                                </ol>
                                             </li>
                                          </ol>
                                       </li>
                                    </ol>
                                 </li>
                              </ol>
                           </li>
                        </ol>
                     </li>
                  </ol>
               </li>
            </ol>
         </li>
      </ol>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:ol[@id = 'B1']").to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "considers ul when adding types to ordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
                 <title id="_">Clause</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Clause</semx>
            </span>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
             <ol id="B1">
             <li>A1
             <ul id="B2">
             <li>A2
             <ol id="B3">
             <li>A3
             </ol></li>
             </ul></li>
             </ol>
           </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <ol id="B1" type="alphabet">
         <li id="_">
            <fmt-name id="_">
               <semx element="autonum" source="_">a</semx>
               <span class="fmt-label-delim">)</span>
            </fmt-name>
            A1
            <ul id="B2">
               <li id="_">
                  <fmt-name id="_">
                     <semx element="autonum" source="_">—</semx>
                  </fmt-name>
                  A2
                  <ol id="B3" type="roman">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">i</semx>
                           <span class="fmt-label-delim">)</span>
                        </fmt-name>
                        A3
                     </li>
                  </ol>
               </li>
            </ul>
         </li>
      </ol>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:ol[@id = 'B1']").to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "processes multiple-target xrefs in English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>en</language></bibdata>
        <preface>
        <foreword>
       <title>Section</title>
       <p id="A"><xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/><location target="ref3" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/><location target="ref3" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/><location target="ref3" connective="and"/><location target="ref4" connective="to"/></xref>
       <xref target="item_6-4-a"><location target="item_6-4-a" connective="from"/><location target="item_6-4-i" connective="to"/></xref>
       <xref target="item_6-4-a"><location target="item_6-4-a" connective="from" custom-connective="ekde"/><location target="item_6-4-i" connective="to" custom-connective="ĝis"/></xref>
        </p>
       </foreword>
       </preface>
        <sections>
       <clause id="ref1"/>
       <clause id="ref2"/>
       <clause id="ref3"/>
       <clause id="ref4"/>
       <clause id="id1">
       <ol id="_5eebf861-525f-0ece-7502-b1c94611db4e"><li><p id="_01fc71c0-8f76-228a-5a0d-7b9d0003d219">The following CRScsd strings represent the CRS types supported by this document:</p>
       <ol id="_7450988f-2dc2-3937-1aa0-a73d21b28ecc"><li id="item_6-4-a"><p id="_9ff8eeb0-5384-41af-e0f6-7143331f59f2">CRS1d: one-dimensional spatial or temporal CRS.</p>
        </li>
        </ol>
        </li>
        <li><p id="_2375be59-1c5e-d3ef-0882-fc5e2b852ea9">Additionally, in each component of a GPL representation string, the following characters shall also act as delimiters:</p>
        <ol id="_81d60fdc-e0ef-e94e-4f59-d41181945c98"><li id="item_6-4-i"><p id="_db51305f-60ad-1714-a497-bc9aa305e02b"><em>a solidus</em> [ / ] shall act as the terminator character and any GPL string shall always be terminated.</p>
        </li>
        </ol>
        </li>
        </ol>
       </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="_" displayorder="2">
          <title id="_">Section</title>
          <fmt-title depth="1" id="_">
             <semx element="title" source="_">Section</semx>
          </fmt-title>
          <p id="A">
             <xref target="ref1" id="_">
                <location target="ref1" connective="from"/>
                <location target="ref2" connective="to"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-conn">to</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="from"/>
                <location target="ref2" connective="to"/>
                text
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   <location target="ref1" connective="from"/>
                   <location target="ref2" connective="to"/>
                   text
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="and"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-conn">and</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="and"/>
                <location target="ref3" connective="and"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-enum-comma">,</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
                <span class="fmt-enum-comma">,</span>
                <span class="fmt-conn">and</span>
                <fmt-xref target="ref3">
                   <semx element="autonum" source="ref3">3</semx>
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="and"/>
                text
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   <location target="ref1" connective="and"/>
                   <location target="ref2" connective="and"/>
                   text
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="or"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-conn">or</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="or"/>
                <location target="ref3" connective="or"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-enum-comma">,</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
                <span class="fmt-enum-comma">,</span>
                <span class="fmt-conn">or</span>
                <fmt-xref target="ref3">
                   <semx element="autonum" source="ref3">3</semx>
                </fmt-xref>
             </semx>
             <xref target="ref1" id="_">
                <location target="ref1" connective="from"/>
                <location target="ref2" connective="to"/>
                <location target="ref3" connective="and"/>
                <location target="ref4" connective="to"/>
             </xref>
             <semx element="xref" source="_">
                <fmt-xref target="ref1">
                   Clauses
                   <semx element="autonum" source="ref1">1</semx>
                </fmt-xref>
                <span class="fmt-conn">to</span>
                <fmt-xref target="ref2">
                   <semx element="autonum" source="ref2">2</semx>
                </fmt-xref>
                <span class="fmt-conn">and</span>
                <fmt-xref target="ref3">
                   <semx element="autonum" source="ref3">3</semx>
                </fmt-xref>
                <span class="fmt-conn">to</span>
                <fmt-xref target="ref4">
                   <semx element="autonum" source="ref4">4</semx>
                </fmt-xref>
             </semx>
             <xref target="item_6-4-a" id="_">
                <location target="item_6-4-a" connective="from"/>
                <location target="item_6-4-i" connective="to"/>
             </xref>
             <semx element="xref" source="_">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="id1">5</semx>
                </span>
                <span class="fmt-comma">,</span>
                <fmt-xref target="item_6-4-a">
                   <semx element="autonum" source="_">a</semx>
                   <span class="fmt-autonum-delim">)</span>
                   <semx element="autonum" source="item_6-4-a">1</semx>
                   )
                </fmt-xref>
                <span class="fmt-conn">to</span>
                <fmt-xref target="item_6-4-i">
                   <semx element="autonum" source="_">b</semx>
                   <span class="fmt-autonum-delim">)</span>
                   <semx element="autonum" source="item_6-4-i">1</semx>
                   )
                </fmt-xref>
             </semx>
             <xref target="item_6-4-a" id="_">
                <location target="item_6-4-a" connective="from" custom-connective="ekde"/>
                <location target="item_6-4-i" connective="to" custom-connective="ĝis"/>
             </xref>
             <semx element="xref" source="_">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="id1">5</semx>
                </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-conn">ekde</span>
                <fmt-xref target="item_6-4-a">
                   <semx element="autonum" source="_">a</semx>
                   <span class="fmt-autonum-delim">)</span>
                   <semx element="autonum" source="item_6-4-a">1</semx>
                   )
                </fmt-xref>
                <span class="fmt-conn">ĝis</span>
                <fmt-xref target="item_6-4-i">
                   <semx element="autonum" source="_">b</semx>
                   <span class="fmt-autonum-delim">)</span>
                   <semx element="autonum" source="item_6-4-i">1</semx>
                   )
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true),
      )
      .at("//xmlns:foreword")
      .to_xml)
    ).to be_xml_equivalent_to presxml
  end

  it "processes multiple-target xrefs in Japanese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>ja</language></bibdata>
       <preface>
        <foreword>
       <title>Section</title>
       <p id="A"><xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/><location target="ref3" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/><location target="ref3" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/><location target="ref3" connective="and"/><location target="ref4" connective="to"/></xref>
       <xref target="item_6-4-a"><location target="item_6-4-a" connective="from"/><location target="item_6-4-i" connective="to"/></xref>
        </p>
       </foreword>
       </preface>
       <sections>
       <clause id="ref1"/>
       <clause id="ref2"/>
       <clause id="ref3"/>
       <clause id="ref4"/>
       <clause id="id1">
       <ol id="_5eebf861-525f-0ece-7502-b1c94611db4e"><li><p id="_01fc71c0-8f76-228a-5a0d-7b9d0003d219">The following CRScsd strings represent the CRS types supported by this document:</p>
       <ol id="_7450988f-2dc2-3937-1aa0-a73d21b28ecc"><li id="item_6-4-a"><p id="_9ff8eeb0-5384-41af-e0f6-7143331f59f2">CRS1d: one-dimensional spatial or temporal CRS.</p>
        </li>
        </ol>
        </li>
        <li><p id="_2375be59-1c5e-d3ef-0882-fc5e2b852ea9">Additionally, in each component of a GPL representation string, the following characters shall also act as delimiters:</p>
        <ol id="_81d60fdc-e0ef-e94e-4f59-d41181945c98"><li id="item_6-4-i"><p id="_db51305f-60ad-1714-a497-bc9aa305e02b"><em>a solidus</em> [ / ] shall act as the terminator character and any GPL string shall always be terminated.</p>
        </li>
        </ol>
        </li>
        </ol>
       </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <p id="A">
          <xref target="ref1" id="_">
             <location target="ref1" connective="from"/>
             <location target="ref2" connective="to"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="from"/>
             <location target="ref2" connective="to"/>
             text
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <location target="ref1" connective="from"/>
                <location target="ref2" connective="to"/>
                text
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="and"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             \\u2005
             <span class="fmt-conn">及び</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="and"/>
             <location target="ref3" connective="and"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref3">3</semx>
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="and"/>
             text
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <location target="ref1" connective="and"/>
                <location target="ref2" connective="and"/>
                text
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="or"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             \\u2005
             <span class="fmt-conn">または</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="or"/>
             <location target="ref3" connective="or"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <span class="fmt-conn">または</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref3">3</semx>
             </fmt-xref>
          </semx>
          <xref target="ref1" id="_">
             <location target="ref1" connective="from"/>
             <location target="ref2" connective="to"/>
             <location target="ref3" connective="and"/>
             <location target="ref4" connective="to"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="ref1">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             \\u2005
             <span class="fmt-conn">及び</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref3">3</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref4">
                <span class="fmt-element-name">箇条</span>
                \\u2005
                <semx element="autonum" source="ref4">4</semx>
             </fmt-xref>
          </semx>
          <xref target="item_6-4-a" id="_">
             <location target="item_6-4-a" connective="from"/>
             <location target="item_6-4-i" connective="to"/>
          </xref>
          <semx element="xref" source="_">
             <fmt-xref target="item_6-4-a">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">箇条</span>
                   \\u2005
                   <semx element="autonum" source="id1">5</semx>
                </span>
                <span class="fmt-conn">の</span>
                <semx element="autonum" source="_">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">の</span>
                <semx element="autonum" source="item_6-4-a">1</semx>
                <span class="fmt-autonum-delim">)</span>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="item_6-4-i">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">箇条</span>
                   \\u2005
                   <semx element="autonum" source="id1">5</semx>
                </span>
                <span class="fmt-conn">の</span>
                <semx element="autonum" source="_">b</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">の</span>
                <semx element="autonum" source="item_6-4-i">1</semx>
                <span class="fmt-autonum-delim">)</span>
             </fmt-xref>
          </semx>
       </p>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true),
      )
      .at("//xmlns:p[@id = 'A']")
      .to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "skips numbering of hidden sections" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <bibdata/>
      <sections><clause id="_scope" type="scope" inline-header="false" obligation="normative">
      <title>Scope</title>
      <p id="_8d98c053-85d7-e8cc-75bb-183a14209d61">A</p>

      <p id="_2141c040-93a4-785a-73f0-ffad4fa1779f"><eref type="inline" bibitemid="_607373b1-0cc4-fcdb-c482-fd86ae572bd1" citeas="ISO 639-2"/></p>
      </clause>

      <terms id="_terms_and_definitions" obligation="normative">
      <title>Terms and definitions</title><p id="_36938d4b-05e5-bd0f-a082-0415db50e8f7">No terms and definitions are listed in this document.</p>

      </terms>
      </sections><bibliography><references hidden="true" normative="true">
      <title>Normative references</title>
      </references>
      </bibliography></standard-document>
    INPUT
    presxml = <<~OUTPUT
       <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
         <bibdata/>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="_scope" type="scope" inline-header="false" obligation="normative" displayorder="2">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_scope">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_scope">1</semx>
               </fmt-xref-label>
               <p id="_">A</p>
               <p id="_">
                  <eref type="inline" bibitemid="_607373b1-0cc4-fcdb-c482-fd86ae572bd1" citeas="ISO 639-2" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-eref type="inline" bibitemid="_607373b1-0cc4-fcdb-c482-fd86ae572bd1" citeas="ISO 639-2">ISO\\u00a0639-2</fmt-eref>
                  </semx>
               </p>
            </clause>
            <terms id="_terms_and_definitions" obligation="normative" displayorder="4">
               <title id="_">Terms and definitions</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_terms_and_definitions">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms and definitions</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_terms_and_definitions">2</semx>
               </fmt-xref-label>
               <p id="_">No terms and definitions are listed in this document.</p>
            </terms>
            <references hidden="true" normative="true" id="_" displayorder="3">
               <title id="_">Normative references</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_"/>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative references</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_"/>
               </fmt-xref-label>
            </references>
         </sections>
         <bibliography>
      </bibliography>
      </standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to presxml
  end

  it "sorts preface sections" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
            <bibdata/>
      <preface>
      <floating-title>FL 7</p>
      <executivesummary/>
      <floating-title>FL 0</p>
      <acknowledgements/>
      <floating-title>FL 1</p>
      <floating-title>FL 2</p>
      <introduction/>
      <floating-title>FL 3</p>
      <floating-title>FL 4</p>
      <foreword><title>Foreword 1</title></foreword>
      <floating-title>FL 5</p>
      <foreword><title>Foreword 2</title></foreword>
      <floating-title>FL 6</p>
      <abstract/>
      </preface>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
         <bibdata/>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <floating-title original-id="_">FL 6</floating-title>
            <p id="_" type="floating-title" displayorder="2">
               <semx element="floating-title" source="_">FL 6</semx>
            </p>
            <abstract displayorder="3" id="_"/>
            <floating-title original-id="_">FL 3</floating-title>
            <p id="_" type="floating-title" displayorder="4">
               <semx element="floating-title" source="_">FL 3</semx>
            </p>
            <floating-title original-id="_">FL 4</floating-title>
            <p id="_" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_">FL 4</semx>
            </p>
            <foreword displayorder="6" id="_">
               <title id="_">Foreword 1</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword 1</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_">FL 5</floating-title>
            <p id="_" type="floating-title" displayorder="7">
               <semx element="floating-title" source="_">FL 5</semx>
            </p>
            <foreword displayorder="8" id="_">
               <title id="_">Foreword 2</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword 2</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_">FL 1</floating-title>
            <p id="_" type="floating-title" displayorder="9">
               <semx element="floating-title" source="_">FL 1</semx>
            </p>
            <floating-title original-id="_">FL 2</floating-title>
            <p id="_" type="floating-title" displayorder="10">
               <semx element="floating-title" source="_">FL 2</semx>
            </p>
            <introduction displayorder="11" id="_"/>
            <floating-title original-id="_">FL 0</floating-title>
            <p id="_" type="floating-title" displayorder="12">
               <semx element="floating-title" source="_">FL 0</semx>
            </p>
            <acknowledgements displayorder="13" id="_"/>
      <floating-title original-id="_">FL 7</floating-title>
      <p id="_" type="floating-title" displayorder="14">
         <semx element="floating-title" source="_">FL 7</semx>
      </p>
      <executivesummary id="_" displayorder="15"/>
         </preface>
      </standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to presxml
  end

  it "does not break up very long strings in tables by default" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
              <table id="tableD-1">
                  <tbody>
                  <tr>
                    <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                  </tr>
                  </tbody>
                  </table>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <table id="tableD-1" autonum="1">
                  <fmt-name id="_">
           <span class="fmt-caption-label">
              <span class="fmt-element-name">Table</span>
              <semx element="autonum" source="tableD-1">1</semx>
           </span>
        </fmt-name>
        <fmt-xref-label>
           <span class="fmt-element-name">Table</span>
           <semx element="autonum" source="tableD-1">1</semx>
        </fmt-xref-label>
           <tbody>
             <tr>
               <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
               <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
               <td align="center">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
             </tr>
           </tbody>
         </table>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:table").to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "breaks up very long strings in tables on request" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
              <table id="tableD-1">
                  <tbody>
                  <tr>
                    <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center">aaaaaaaa_aa</td>
                    <td align="center">aaaaaaaa.aa</td>
                    <td align="center">aaaaaaaa.0a</td>
                    <td align="center">aaaaaaaa&lt;a&gt;a</td>
                    <td align="center">aaaaaaaa&lt;&lt;a&gt;&gt;a</td>
                    <td align="center">aaaaaaaa/aa</td>
                    <td align="center">aaaaaaaa//aa</td>
                    <td align="center">aaaaaaaa+aa</td>
                    <td align="center">aaaaaaaa+0a</td>
                    <td align="center">aaaaaaaa{aa</td>
                    <td align="center">aaaaaaaa;{aa</td>
                    <td align="center">aaaaaaaa(aa</td>
                    <td align="center">aaaaaaaa(0a</td>
                    <td align="center">aaaaaaa0(aa</td>
                    <td align="center">aaaaaaaAaaaa</td>
                    <td align="center">aaaaaaaAAaaa</td>
                  </tr>
                  </tbody>
                  </table>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <table id="tableD-1" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Table</span>
               <semx element="autonum" source="tableD-1">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Table</span>
            <semx element="autonum" source="tableD-1">1</semx>
         </fmt-xref-label>
         <tbody>
            <tr>
               <td align="left">http://&#x200b;www.example.&#x200b;com/&#x200b;AAAAAAAAAAAAAAAAA­AAAAAAAAAAAAAAAAAAAA­AAAAAAAA/&#x200b;BBBBBBBBBBB­BBBBBBBBBBBBBBBBB</td>
               <td align="left">http://&#x200b;www.example.&#x200b;com/&#x200b;AAAAAAAAAAAAAAAAA­AAAAAAAAAAAAAAAAAAAA­AAAAAAAABBBBBBBBBBBB­BBBBBBBBBBBBBBBB</td>
               <td align="center">www.&#x200b;example.com/&#x200b;AAAAAAAAAAAAAAAAAAAAAAAA­AAAAAAAAAAAAAAAAAAAA­ABBBBBBBBBBBBBBBBBBB­BBBBBBBBB</td>
               <td align="center">aaaaaaaa_&#x200b;aa</td>
               <td align="center">aaaaaaaa.&#x200b;aa</td>
               <td align="center">aaaaaaaa.0a</td>
               <td align="center">aaaaaaaa&#x200b;&lt;a&gt;a</td>
               <td align="center">aaaaaaaa&#x200b;&lt;&lt;a&gt;&gt;a</td>
               <td align="center">aaaaaaaa/&#x200b;aa</td>
               <td align="center">aaaaaaaa//&#x200b;aa</td>
               <td align="center">aaaaaaaa+&#x200b;aa</td>
               <td align="center">aaaaaaaa+&#x200b;0a</td>
               <td align="center">aaaaaaaa&#x200b;{aa</td>
               <td align="center">aaaaaaaa;&#x200b;{aa</td>
               <td align="center">aaaaaaaa&#x200b;(aa</td>
               <td align="center">aaaaaaaa(0a</td>
               <td align="center">aaaaaaa0(aa</td>
               <td align="center">aaaaaaa­Aaaaa</td>
               <td align="center">aaaaaaaAAaaa</td>
            </tr>
         </tbody>
      </table>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(breakupurlsintables: "true"))
      .convert("test", input, true))
      .at("//xmlns:table").to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "realises custom charsets" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <presentation-metadata><custom-charset-font>weather:"OGC Weather Symbols",conscript:"Code 2000"</custom-charset-font></presentation-metadata>
        <preface>
          <foreword id="A">
            <p id="_214f7090-c6d4-8fdc-5e6a-837ebb515871"><span custom-charset="weather">ﶀ</span></p>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
          <presentation-metadata>
             <custom-charset-font>weather:"OGC Weather Symbols",conscript:"Code 2000"</custom-charset-font>
          </presentation-metadata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="_">
                   <span custom-charset="weather" style=";font-family:&quot;OGC Weather Symbols&quot;">ﶀ</span>
                </p>
             </foreword>
          </preface>
       </standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to presxml
  end

  it "realises text-transform" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
            <p id="_214f7090-c6d4-8fdc-5e6a-837ebb515871">
            AB<span style="x:y">C</span>D<span style="x:y; text-transform:uppercase">aBc</span>
            <span style="text-transform:uppercase">a<em>b</em>c</span>
            <span style="text-transform:lowercase">A<em>B</em>C</span>
            <span style="text-transform:capitalize">a<em>b</em>c abc</span>
            <span style="text-transform:capitalize">a<em>b</em>c   abc</span>
            </p>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
         <preface><clause type="toc" id="_" displayorder="1">
         <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>

           <foreword id="A" displayorder="2">
           <title id="_">Foreword</title><fmt-title id="_" depth="1"><semx element="title" source="_">Foreword</semx></fmt-title>
             <p id="_">
             AB<span style="x:y">C</span>D<span style="x:y;text-transform:none">ABC</span>
             <span style="text-transform:none">A<em>B</em>C</span>
             <span style="text-transform:none">a<em>b</em>c</span>
             <span style="text-transform:none">A<em>b</em>c Abc</span>
             <span style="text-transform:none">A<em>b</em>c   Abc</span>
             </p>
        </foreword></preface></standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_xml_equivalent_to presxml
  end

  it "gets rid of empty fmt- elements" do
    mock_empty_fmt_identifier
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
         <identifier>http://www.example.com A-B</identifier>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml))
      .to be_xml_equivalent_to presxml
  end

  private

  def mock_empty_fmt_identifier
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:identifier) do |_instance, docxml|
      docxml.xpath("//xmlns:identifier").each do |n|
        n.next = "<fmt-identifier> </fmt-identifier>"
      end
    end
  end
end
