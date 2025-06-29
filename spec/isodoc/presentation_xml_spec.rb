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

  it "manipulates identifier attributes in Presentation XML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="A"/>
          <clause id="B" anchor="C"/>
          <clause id="D" anchor="Löwe">
            <xref target="Löwe"/>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="A" semx-id="A" displayorder="2">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref-label>
             </clause>
             <clause id="C" anchor="C" semx-id="B" displayorder="3">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref-label>
             </clause>
             <clause id="Löwe" anchor="Löwe" semx-id="D" displayorder="4">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="Löwe">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="Löwe">3</semx>
                </fmt-xref-label>
                <xref target="Löwe" id="_"/>
                <semx element="xref" source="_">
                   <fmt-xref target="Löwe">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="Löwe">3</semx>
                   </fmt-xref>
                </semx>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r("_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), '"_"'))
      .to be_equivalent_to Xml::C14n.format(output)
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "strips variant-title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
               <sections>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <p id='_'>Text</p>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Subclause</title>
               <variant-title variant_title='true' type='sub' id='_'>&#8220;A&#8221; &#8216;B&#8217;</variant-title>
               <variant-title variant_title='true' type='toc' id='_'>
                 Clause
                 <em>A</em>
                 <stem type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mi>x</mi>
                   </math>
                 </stem>
               </variant-title>
               <p id='_'>Text</p>
             </clause>
           </clause>
         </sections>
         <annex id='_' inline-header='false' obligation='normative'>
           <title>Clause</title>
           <variant-title variant_title='true' type='toc' id='_'>
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="_" inline-header="false" obligation="normative" autonum="A" displayorder="2">
               <title id="_">Clause</title>
               <fmt-title id="_" depth="1">
                  <strong>
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Annex</span>
                        <semx element="autonum" source="_">A</semx>
                     </span>
                  </strong>
                  <br/>
                  <span class="fmt-obligation">(normative)</span>
                  <span class="fmt-autonum-delim">.</span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="_">A</semx>
               </fmt-xref-label>
               <p id="_">Text</p>
               <clause id="_" inline-header="false" obligation="normative" autonum="A">
                  <title id="_">Subclause</title>
                  <fmt-title id="_" depth="1">
                     <strong>
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Annex</span>
                           <semx element="autonum" source="_">A</semx>
                        </span>
                     </strong>
                     <br/>
                     <span class="fmt-obligation">(normative)</span>
                     <span class="fmt-autonum-delim">.</span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Subclause</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="_">A</semx>
                  </fmt-xref-label>
                  <variant-title variant_title="true" type="sub" id="_">“A” ‘B’</variant-title>
                  <variant-title variant_title="true" type="toc" id="_">
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
               </clause>
            </clause>
         </sections>
         <annex id="_" inline-header="false" obligation="normative" autonum="A" displayorder="3">
            <title id="_">
               <strong>Clause</strong>
            </title>
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="_">A</semx>
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
               <semx element="autonum" source="_">A</semx>
            </fmt-xref-label>
            <variant-title variant_title="true" type="toc" id="_">
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
              <div id='_'>
                <h1>
                  <b>Annex A</b>
                  <br/>
                   (normative).\\u00a0 Clause
                </h1>
                <p id='_'>Text</p>
                <div id='_'>
                  <h1>
                    <b>Annex A</b>
                    <br/>
                     (normative).\\u00a0 Subclause
                    <br/>
                    <br/>
                    &#8220;A&#8221; &#8216;B&#8217;
                  </h1>
                  <p style='display:none;' class='variant-title-toc'>
                     Clause
                    <i>A</i>
                    <span class='stem'>
                      <math xmlns='http://www.w3.org/1998/Math/MathML'>
                        <mi>x</mi>
                      </math>
                    </span>
                  </p>
                  <p id='_'>Text</p>
                </div>
              </div>
              <br/>
              <div id='_' class='Section3'>
                <h1 class='Annex'>
                  <b>Annex A</b>
                  <br/>
                   (normative)
                  <br/>
                  <br/>
                  <b>Clause</b>
                </h1>
                <p style='display:none;' class='variant-title-toc'>
                   Clause
                  <i>A</i>
                  <span class='stem'>
                    <math xmlns='http://www.w3.org/1998/Math/MathML'>
                      <mi>x</mi>
                    </math>
                  </span>
                </p>
                <p id='_'>Text</p>
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
               <div id='_'>
                 <h1>
                   <b>Annex A</b>
                   <br/>
                    (normative).
                   <span style='mso-tab-count:1'>\\u00a0 </span>
                    Clause
                 </h1>
                 <p id='_'>Text</p>
                 <div id='_'>
                   <h1>
                     <b>Annex A</b>
                     <br/>
                      (normative).
                     <span style='mso-tab-count:1'>\\u00a0 </span>
                      Subclause
                     <br/>
                     <br/>
                     &#8220;A&#8221; &#8216;B&#8217;
                   </h1>
                   <p style='display:none;' class='variant-title-toc'>
                      Clause
                     <i>A</i>
                     <span class='stem'>
                       <math xmlns='http://www.w3.org/1998/Math/MathML'>
                         <mi>x</mi>
                       </math>
                     </span>
                   </p>
                   <p id='_'>Text</p>
                 </div>
               </div>
               <p class="page-break">
                 <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
               </p>
               <div id='_' class='Section3'>
                 <h1 class='Annex'>
                   <b>Annex A</b>
                   <br/>
                    (normative)
                   <br/>
                   <br/>
                   <b>Clause</b>
                 </h1>
                 <p style='display:none;' class='variant-title-toc'>
                    Clause
                   <i>A</i>
                   <span class='stem'>
                     <math xmlns='http://www.w3.org/1998/Math/MathML'>
                       <mi>x</mi>
                     </math>
                   </span>
                 </p>
                 <p id='_'>Text</p>
               </div>
             </div>
           </body>
         </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "duplicates EMF and SVG files" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <figure id="B">
               <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"/>
               <image src="spec/assets/odf.emf" mimetype="image/x-emf" alt="2"/>
               <image src="data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPjxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz48L3N2Zz4=" mimetype="image/svg+xml" alt="3"/>
               <image src="data:application/x-msmetafile;base64,AQAAAMgAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAJAQAACgAAAACAAAALgAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADAAIAAoADQAMAAzADUAYQA0AGYALAAgADIAMAAyADAALQAwADUALQAwADEAKQAgAAAAbwBkAGYALgBlAG0AZgAAAAAAAAARAAAADAAAAAEAAAAkAAAAJAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAIAAABGAAAALAAAACAAAABTY3JlZW49MTAyMDV4MTMxODFweCwgMjE2eDI3OW1tAEYAAAAwAAAAIwAAAERyYXdpbmc9MTAwLjB4MTAwLjBweCwgMjYuNXgyNi41bW0AABIAAAAMAAAAAQAAABMAAAAMAAAAAgAAABYAAAAMAAAAGAAAABgAAAAMAAAAAAAAABQAAAAMAAAADQAAACcAAAAYAAAAAQAAAAAAAAAAAJkABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACkBAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACkBAAAqAMAAKgDAACkBAAAcQIAAKQEAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAOgEAAKQEAAA/AAAAqAMAAD8AAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAD8AAAA6AQAAOgEAAD8AAABxAgAAPwAAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACoAwAAPwAAAKQEAAA6AQAApAQAAHECAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAAJwAAABgAAAABAAAAAAAAAP///wAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAJ0BAABFAQAANgAAABAAAADPAwAARQEAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABfBAAA7QEAAGQEAADjAgAA2wMAAJEDAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAUgMAAD4EAABhAgAAcwQAAJ0BAAAOBAAANgAAABAAAACdAQAAyQIAADYAAAAQAAAA4gIAAMkCAAA2AAAAEAAAAOICAAAaAgAANgAAABAAAACdAQAAGgIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAOAAAAFAAAAAAAAAAAAAAAJAQAAA==" mimetype="image/x-emf" alt="4"/>
             </figure>
           </clause>
         </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1">
            <emf src="spec/assets/odf.emf"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="2">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
               <g transform="translate(-0.0000, -0.0000)">
                  <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                  </g>
               </g>
            </svg>
            <emf src="data:image/emf;base64"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="3" height="" width="">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
               <circle fill="#009" r="45" cx="50" cy="50"/>
               <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
            </svg>
            <emf src="data:image/emf;base64"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="4">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
               <g transform="translate(-0.0000, -0.0000)">
                  <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                  </g>
               </g>
            </svg>
            <emf src="data:application/x-msmetafile;base64"/>
         </image>
      </figure>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to (Xml::C14n.format(output))

    output = <<~OUTPUT
      <figure id="B" autonum="1">
        <fmt-name id="_">
           <span class="fmt-caption-label">
              <span class="fmt-element-name">Figure</span>
              <semx element="autonum" source="B">1</semx>
           </span>
        </fmt-name>
        <fmt-xref-label>
           <span class="fmt-element-name">Figure</span>
           <semx element="autonum" source="B">1</semx>
        </fmt-xref-label>
             <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"/>
             <image src="" mimetype="image/svg+xml" alt="2">
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
                 <g transform="translate(-0.0000, -0.0000)">
                   <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                   </g>
                 </g>
               </svg>
               <emf src="data:image/emf;base64"/>
             </image>
             <image src="" mimetype="image/svg+xml" alt="3">
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
                 <circle fill="#009" r="45" cx="50" cy="50"/>
                 <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
               </svg>
             </image>
             <image src="" mimetype="image/svg+xml" alt="4">
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
                 <g transform="translate(-0.0000, -0.0000)">
                   <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                   </g>
                 </g>
               </svg>
               <emf src="data:application/x-msmetafile;base64"/>
             </image>
           </figure>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html" }))
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "converts EPS to SVG files" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
      <sections>
       <clause id='A' inline-header='false' obligation='normative'>
       <title>Clause</title>
       <figure id="B">
       <image mimetype="application/postscript" alt="3">%!PS-Adobe-3.0 EPSF-3.0
      %%Document-Fonts: Times-Roman
      %%Title: circle.eps
      %%Creator: PS_Write.F
      %%CreationDate: 02-Aug-99
      %%Pages: 1
      %%BoundingBox:   36   36  576  756
      %%LanguageLevel: 1
      %%EndComments
      %%BeginProlog
      %%EndProlog
      /inch {72 mul} def
      /Palatino-Roman findfont
      1.00 inch scalefont
      setfont
       0.0000 0.0000 0.0000 setrgbcolor
      %% Page:     1    1
      save
        63 153 moveto
       newpath
        63 153 moveto
       549 153 lineto
       stroke
       newpath
       549 153 moveto
       549 639 lineto
       stroke
       newpath
       549 639 moveto
        63 639 lineto
       stroke
       newpath
        63 639 moveto
        63 153 lineto
       stroke
       newpath
       360 261 108   0 360 arc
       closepath stroke
       newpath
       361 357 moveto
       358 358 lineto
       353 356 lineto
       348 353 lineto
       342 347 lineto
       336 340 lineto
       329 331 lineto
       322 321 lineto
       315 309 lineto
       307 296 lineto
       300 283 lineto
       292 268 lineto
       285 253 lineto
       278 237 lineto
       271 222 lineto
       266 206 lineto
       260 191 lineto
       256 177 lineto
       252 164 lineto
       249 152 lineto
       247 141 lineto
       246 131 lineto
       246 123 lineto
       247 117 lineto
       248 113 lineto
       251 111 lineto
       254 110 lineto
       259 112 lineto
       264 115 lineto
       270 121 lineto
       276 128 lineto
       283 137 lineto
       290 147 lineto
       297 159 lineto
       305 172 lineto
       312 185 lineto
       320 200 lineto
       327 215 lineto
       334 231 lineto
       341 246 lineto
       346 262 lineto
       352 277 lineto
       356 291 lineto
       360 304 lineto
       363 316 lineto
       365 327 lineto
       366 337 lineto
       366 345 lineto
       365 351 lineto
       364 355 lineto
       361 357 lineto
       stroke
       newpath
       171 261 moveto
       171 531 lineto
       stroke
       newpath
       198 261 moveto
       198 531 lineto
       stroke
       newpath
       225 261 moveto
       225 531 lineto
       stroke
       newpath
       252 261 moveto
       252 531 lineto
       stroke
       newpath
       279 261 moveto
       279 531 lineto
       stroke
       newpath
       306 261 moveto
       306 531 lineto
       stroke
       newpath
       333 261 moveto
       333 531 lineto
       stroke
       newpath
       360 261 moveto
       360 531 lineto
       stroke
       newpath
       387 261 moveto
       387 531 lineto
       stroke
       newpath
       414 261 moveto
       414 531 lineto
       stroke
       newpath
       441 261 moveto
       441 531 lineto
       stroke
       newpath
       171 261 moveto
       441 261 lineto
       stroke
       newpath
       171 288 moveto
       441 288 lineto
       stroke
       newpath
       171 315 moveto
       441 315 lineto
       stroke
       newpath
       171 342 moveto
       441 342 lineto
       stroke
       newpath
       171 369 moveto
       441 369 lineto
       stroke
       newpath
       171 396 moveto
       441 396 lineto
       stroke
       newpath
       171 423 moveto
       441 423 lineto
       stroke
       newpath
       171 450 moveto
       441 450 lineto
       stroke
       newpath
       171 477 moveto
       441 477 lineto
       stroke
       newpath
       171 504 moveto
       441 504 lineto
       stroke
       newpath
       171 531 moveto
       441 531 lineto
       stroke
       newpath
       306 396   5   0 360 arc
       closepath stroke
       0.0000 1.0000 0.0000 setrgbcolor
       newpath
       387 477  54   0  90 arc
       stroke
       171 261 moveto
       0.0000 0.0000 0.0000 setrgbcolor
      /Palatino-Roman findfont
         0.250 inch scalefont
      setfont
      (This is "circle.plot".) show
       171 342 moveto
      /Palatino-Roman findfont
         0.125 inch scalefont
      setfont
      (This is small print.) show
      restore showpage
      %%Trailer
      </image>
                   </figure>
                 </clause>
               </sections>
            </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image mimetype="image/svg+xml" alt="3" src="_.svg"/>
      </figure>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .gsub(%r{src="[^"]+?\.emf"}, 'src="_.emf"')
      .gsub(%r{src="[^"]+?\.svg"}, 'src="_.svg"'))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "converts file EPS to SVG" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata/>
        <sections>
          <clause id='A' inline-header='false' obligation='normative'>
            <title>Clause</title>
            <figure id="B">
              <image mimetype="application/postscript" alt="3" src="spec/assets/img.eps"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image mimetype="image/svg+xml" alt="3" src="_.svg"/>
      </figure>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .gsub(%r{src="[^"]+?\.svg"}, 'src="_.svg"'))))
      .to be_equivalent_to(output)
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:ol[@id = 'B1']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:ol[@id = 'B1']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
         <fmt-title id="_" depth="1">
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
         </p>
      </foreword>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:foreword")
      .to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">及び</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">,</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">または</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">,</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             <span class="fmt-enum-comma">、</span>
             <span class="fmt-conn">または</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
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
                <semx element="autonum" source="ref1">1</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref2">
                <span class="fmt-element-name">箇条</span>
                <semx element="autonum" source="ref2">2</semx>
             </fmt-xref>
             <span class="fmt-conn">及び</span>
             <fmt-xref target="ref3">
                <span class="fmt-element-name">箇条</span>
                <semx element="autonum" source="ref3">3</semx>
             </fmt-xref>
             <span class="fmt-conn">～</span>
             <fmt-xref target="ref4">
                <span class="fmt-element-name">箇条</span>
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:p[@id = 'A']")
      .to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "captions embedded figures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
       <clause id="A" inline-header="false" obligation="normative">
       <title>Section</title>
       <figure id="B1">
       <name>First</name>
       </figure>
       <example id="C1">
       <figure id="B2">
       <name>Second</name>
       </figure>
       </example>
       <example id="C2">
       <figure id="B4" unnumbered="true">
       <name>Unnamed</name>
       </figure>
       </example>
       <figure id="B3">
       <name>Third</name>
       </figure>
       </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <clause id="A" inline-header="false" obligation="normative" displayorder="2">
         <title id="_">Section</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Section</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
         <figure id="B1" autonum="1">
            <name id="_">First</name>
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B1">1</semx>
               </span>
               <span class="fmt-caption-delim">\\u00a0— </span>
               <semx element="name" source="_">First</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B1">1</semx>
            </fmt-xref-label>
         </figure>
         <example id="C1" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EXAMPLE</span>
                  <semx element="autonum" source="C1">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C1">1</semx>
            </fmt-xref-label>
            <fmt-xref-label container="A">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C1">1</semx>
            </fmt-xref-label>
            <figure id="B2" autonum="2">
               <name id="_">Second</name>
               <fmt-name id="_">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Figure</span>
                     <semx element="autonum" source="B2">2</semx>
                  </span>
                  <span class="fmt-caption-delim">\\u00a0— </span>
                  <semx element="name" source="_">Second</semx>
               </fmt-name>
               <fmt-xref-label>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B2">2</semx>
               </fmt-xref-label>
            </figure>
         </example>
         <example id="C2" autonum="2">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EXAMPLE</span>
                  <semx element="autonum" source="C2">2</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C2">2</semx>
            </fmt-xref-label>
            <fmt-xref-label container="A">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C2">2</semx>
            </fmt-xref-label>
            <figure id="B4" unnumbered="true">
               <name id="_">Unnamed</name>
               <fmt-name id="_">
                  <semx element="name" source="_">Unnamed</semx>
               </fmt-name>
            </figure>
         </example>
         <figure id="B3" autonum="3">
            <name id="_">Third</name>
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B3">3</semx>
               </span>
               <span class="fmt-caption-delim">\\u00a0— </span>
               <semx element="name" source="_">Third</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B3">3</semx>
            </fmt-xref-label>
         </figure>
      </clause>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "leaves alone floating titles if preface sections already sorted" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
            <bibdata/>
      <preface>
      <floating-title>FL 1</p>
      <floating-title>FL 2</p>
      <abstract/>
      <floating-title>FL 3</p>
      <floating-title>FL 4</p>
      <foreword/>
      <floating-title>FL 5</p>
      <floating-title>FL 6</p>
      <introduction/>
      <floating-title>FL 7</p>
      <acknowledgements/>
      <floating-title>FL 8</p>
      <executivesummary/>
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
            <floating-title original-id="_">FL 1</floating-title>
            <p id="_" type="floating-title" displayorder="2">
               <semx element="floating-title" source="_">FL 1</semx>
            </p>
            <floating-title original-id="_">FL 2</floating-title>
            <p id="_" type="floating-title" displayorder="3">
               <semx element="floating-title" source="_">FL 2</semx>
            </p>
            <abstract displayorder="4" id="_"/>
            <floating-title original-id="_">FL 3</floating-title>
            <p id="_" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_">FL 3</semx>
            </p>
            <floating-title original-id="_">FL 4</floating-title>
            <p id="_" type="floating-title" displayorder="6">
               <semx element="floating-title" source="_">FL 4</semx>
            </p>
            <foreword displayorder="7" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_">FL 5</floating-title>
            <p id="_" type="floating-title" displayorder="8">
               <semx element="floating-title" source="_">FL 5</semx>
            </p>
            <floating-title original-id="_">FL 6</floating-title>
            <p id="_" type="floating-title" displayorder="9">
               <semx element="floating-title" source="_">FL 6</semx>
            </p>
            <introduction displayorder="10" id="_"/>
            <floating-title original-id="_">FL 7</floating-title>
            <p id="_" type="floating-title" displayorder="11">
               <semx element="floating-title" source="_">FL 7</semx>
            </p>
            <acknowledgements displayorder="12" id="_"/>
          <floating-title original-id="_">FL 8</floating-title>
          <p id="_" type="floating-title" displayorder="13">
            <semx element="floating-title" source="_">FL 8</semx>
          </p>
          <executivesummary id="_" displayorder="14"/>
            </preface>
      </standard-document>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:table").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(breakupurlsintables: "true"))
      .convert("test", input, true))
      .at("//xmlns:table").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "label figures embedded within other assets" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
            <p id="B">
            <table id="C">
            <tbody><td>
            <figure id="D">X</figure>
            </td>
            </tbody>
            </table>
            </p>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title id="_" depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title id="_" depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="B">
                    <table id="C" autonum="1">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">Table</span>
                             <semx element="autonum" source="C">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="C">1</semx>
                       </fmt-xref-label>
                       <tbody>
                          <td>
                             <figure id="D" autonum="1">
                                <fmt-name id="_">
                                   <span class="fmt-caption-label">
                                      <span class="fmt-element-name">Figure</span>
                                      <semx element="autonum" source="D">1</semx>
                                   </span>
                                </fmt-name>
                                <fmt-xref-label>
                                   <span class="fmt-element-name">Figure</span>
                                   <semx element="autonum" source="D">1</semx>
                                </fmt-xref-label>
                                X
                             </figure>
                          </td>
                       </tbody>
                    </table>
                 </p>
              </foreword>
           </preface>
        </standard-document>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to (presxml)
  end

  it "uses content GUIDs in Presentation XML" do
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
            <clause type="toc" id="_ad031967-2ffb-7abe-7724-fe42e3e69ab6" displayorder="1">
               <fmt-title depth="1" id="_94e961da-c46e-10c4-3633-df05fa9b249b">Table of contents</fmt-title>
            </clause>
            <floating-title original-id="_7a358acc-ba01-efef-79d3-ffddb271a5f2">FL 6</floating-title>
            <p id="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6" type="floating-title" displayorder="2">
               <semx element="floating-title" source="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6">FL 6</semx>
            </p>
            <abstract id="_342ec181-36d5-e26a-f135-7a2ab9504cc7" displayorder="3"/>
            <floating-title original-id="_5eb946b0-308e-6eba-08b6-6b4c87e08eed">FL 3</floating-title>
            <p id="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53" type="floating-title" displayorder="4">
               <semx element="floating-title" source="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53">FL 3</semx>
            </p>
            <floating-title original-id="_9e7ab2e8-e33c-91c3-7744-66800e5b8a87">FL 4</floating-title>
            <p id="_2eb9f685-30aa-f993-e7ce-77a904a5998c" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_2eb9f685-30aa-f993-e7ce-77a904a5998c">FL 4</semx>
            </p>
            <foreword id="_92a0fd29-1e23-10a1-7ccf-79659e1d55c4" displayorder="6">
               <title id="_6ef51b59-4654-aa9d-dd44-776977643101">Foreword 1</title>
               <fmt-title depth="1" id="_78ad0ed3-d83f-8139-0bcd-200a2d61daf5">
                  <semx element="title" source="_6ef51b59-4654-aa9d-dd44-776977643101">Foreword 1</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_e448c5b5-a5e2-25ba-292b-bc6388f9c0bb">FL 5</floating-title>
            <p id="_d01a6376-a126-1b02-481e-e66a095e91fd" type="floating-title" displayorder="7">
               <semx element="floating-title" source="_d01a6376-a126-1b02-481e-e66a095e91fd">FL 5</semx>
            </p>
            <foreword id="_35070999-7e5f-7e8f-cf70-1ca23584af50" displayorder="8">
               <title id="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f">Foreword 2</title>
               <fmt-title depth="1" id="_d7ffd817-6fae-c526-d5cb-5b33e3f75cea">
                  <semx element="title" source="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f">Foreword 2</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_6d170179-ba49-4af9-ed38-7987c1a7cbe0">FL 1</floating-title>
            <p id="_f8a8f840-3950-a27d-a79d-7db536f9980a" type="floating-title" displayorder="9">
               <semx element="floating-title" source="_f8a8f840-3950-a27d-a79d-7db536f9980a">FL 1</semx>
            </p>
            <floating-title original-id="_a139118f-038f-e387-88cc-9dbf651bcbcb">FL 2</floating-title>
            <p id="_9fdb84cf-58b7-1ac8-450f-29cfe0117412" type="floating-title" displayorder="10">
               <semx element="floating-title" source="_9fdb84cf-58b7-1ac8-450f-29cfe0117412">FL 2</semx>
            </p>
            <introduction id="_27e1812e-2d86-ea96-5220-c895b505e1aa" displayorder="11"/>
            <floating-title original-id="_6cfccd90-6101-23b5-f708-728b534920f9">FL 0</floating-title>
            <p id="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4" type="floating-title" displayorder="12">
               <semx element="floating-title" source="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4">FL 0</semx>
            </p>
            <acknowledgements id="_8afab461-7af9-b53a-d387-6ff08ef0e2d1" displayorder="13"/>
            <floating-title original-id="_5622af3a-8c11-41a3-2998-1f268a74ac1c">FL 7</floating-title>
            <p id="_c888c2f8-b742-0209-ffaa-d5783dec2c65" type="floating-title" displayorder="14">
               <semx element="floating-title" source="_c888c2f8-b742-0209-ffaa-d5783dec2c65">FL 7</semx>
            </p>
            <executivesummary id="_3d8ba6d3-5e1a-e024-7985-661f63bdab97" displayorder="15"/>
         </preface>
      </standard-document>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "validates on duplicate identifiers" do
    FileUtils.rm_f "test.presentation.xml"
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).not_to be_empty
    expect(log.abort_messages.first).to eq "Anchor _f06fd0d1-a203-4f3d-a515-0bdba0f8d83e has already been used at line 7"
  end

  it "validates on undefined IDREF" do
    FileUtils.rm_f "test.presentation.xml"
    FileUtils.rm_f "test.html.err"
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
            <title id="A">Hello</title>
            <fmt-title source="A">Hello</fmt-title>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log.write("test.err.html")
    html = File.read("test.err.html")
    expect(html).not_to include "is not defined in the document"

    log = Metanorma::Utils::Log.new
    FileUtils.rm_f "test.presentation.xml"
    FileUtils.rm_f "test.html.err"
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                    <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
            <title id="A">Hello</title>
            <fmt-title source="B">Hello</fmt-title>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log.write("test.err.html")
    html = File.read("test.err.html")
    expect(html).to include "Anchor B pointed to by fmt-title is not defined in the document"
  end

  it "completes incomplete logo presentation metadata" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en">test</title>
        </bibdata>
        <metanorma-extension>
          <presentation-metadata><logo-fred-height>4</logo-fred-height></presentation-metadata>
          <presentation-metadata><logo-author-pdf-height>4</logo-author-pdf-height></presentation-metadata>
          <presentation-metadata><logo-author-height>4</logo-author-height></presentation-metadata>
        </metanorma-extension>
      </iso-standard
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en">test</title>
          </bibdata>
          <metanorma-extension>
             <presentation-metadata>
                <logo-fred-height>4</logo-fred-height>
             </presentation-metadata>
             <presentation-metadata>
                <logo-author-pdf-height>4</logo-author-pdf-height>
             </presentation-metadata>
             <presentation-metadata>
                <logo-author-height>4</logo-author-height>
             </presentation-metadata>
             <presentation-metadata>
                <logo-author-html-height>4</logo-author-html-height>
             </presentation-metadata>
             <presentation-metadata>
                <logo-author-pdf-height>4</logo-author-pdf-height>
             </presentation-metadata>
             <presentation-metadata>
                <logo-author-doc-height>4</logo-author-doc-height>
             </presentation-metadata>
          </metanorma-extension>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::PresentationXMLConvert
       .new(presxml_options.merge({ output_formats: { doc: "DOC", pdf: "PDF",
                                                      html: "HTML" } }))
       .convert("test", input, true)
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
