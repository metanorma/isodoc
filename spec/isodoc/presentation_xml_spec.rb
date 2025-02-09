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

  it "calculates depth of clauses regardless of whether they have anchors" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause><title>A</title>
          <clause><title>B</title>
          <clause><title>C</title>
          </clause></clause></clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause displayorder="2">
                <title id="_">A</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">A</semx>
                </fmt-title>
                <clause>
                   <title id="_">B</title>
                   <fmt-title depth="2">
                         <semx element="title" source="_">B</semx>
                   </fmt-title>
                   <clause>
                      <title id="_">C</title>
                      <fmt-title depth="3">
                            <semx element="title" source="_">C</semx>
                      </fmt-title>
                   </clause>
                </clause>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="_" inline-header="false" obligation="normative" autonum="A" displayorder="2">
                 <title id="_">Clause</title>
                 <fmt-title depth="1">
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
                    <fmt-title depth="1">
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
                       <stem type="MathML">
                          <math xmlns="http://www.w3.org/1998/Math/MathML">
                             <mi>x</mi>
                          </math>
                          <asciimath>x</asciimath>
                       </stem>
                    </variant-title>
                    <p id="_">Text</p>
                 </clause>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative" autonum="A" displayorder="3">
              <title id="_">
                 <strong>Clause</strong>
              </title>
              <fmt-title>
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
                 <stem type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mi>x</mi>
                    </math>
                    <asciimath>x</asciimath>
                 </stem>
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
                   (normative).&#160; Clause
                </h1>
                <p id='_'>Text</p>
                <div id='_'>
                  <h1>
                    <b>Annex A</b>
                    <br/>
                     (normative).&#160; Subclause
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
              <p> </p>
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
                  <span style='mso-tab-count:1'>&#160; </span>
                   Clause
                </h1>
                <p id='_'>Text</p>
                <div id='_'>
                  <h1>
                    <b>Annex A</b>
                    <br/>
                     (normative).
                    <span style='mso-tab-count:1'>&#160; </span>
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
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
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
          <fmt-name>
             <span class="fmt-caption-label">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="B">1</semx>
             </span>
          </fmt-name>
          <fmt-xref-label>
             <span class="fmt-element-name">Figure</span>
             <semx element="autonum" source="B">1</semx>
          </fmt-xref-label>
               <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"><emf src="spec/assets/odf.emf"/></image>
               <image src="" mimetype="image/svg+xml" alt="2">
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
      <g transform="translate(-0.0000, -0.0000)">
      <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
      <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
      <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
      </g>
      </g>
      </svg>
      <emf src="data:image/emf;base64"/></image>
      <image src="" mimetype="image/svg+xml" alt="3"  height="" width=""><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle fill="#009" r="45" cx="50" cy="50"/><path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/></svg><emf src="data:image/emf;base64"/></image>
               <image src="" mimetype="image/svg+xml" alt="4">
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
      <g transform="translate(-0.0000, -0.0000)">
      <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
      <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
      <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
      </g>
      </g>
      </svg>
      <emf src="data:application/x-msmetafile;base64"/></image>
             </figure>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
        <fmt-name>
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
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
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
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
                 <circle fill="#009" r="45" cx="50" cy="50"/>
                 <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
               </svg>
             </image>
             <image src="" mimetype="image/svg+xml" alt="4">
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html" }))
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to (output)
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
         <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .gsub(%r{src="[^"]+?\.emf"}, 'src="_.emf"')
      .gsub(%r{src="[^"]+?\.svg"}, 'src="_.svg"'))))
      .to be_equivalent_to (output)
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
         <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
      <ol id='B1' type='alphabet'>
        <li id="_" label="a">
          A1
          <ol id='B2' type='arabic'>
            <li id="_" label="1">
              A2
              <ol id='B3' type='roman'>
                <li id="_" label="i">
                  A3
                  <ol id='B4' type='alphabet_upper'>
                    <li id="_" label="A">
                      A4
                      <ol id='B5' type='roman_upper'>
                        <li id="_" label="I">
                          A5
                          <ol id='B6' type='alphabet'>
                            <li id="_" label="a">
                              A6
                              <ol id='B7' type='arabic'>
                                <li id="_" label="1">
                                  A7
                                  <ol id='B8' type='roman'>
                                    <li id="_" label="i">
                                      A8
                                      <ol id='B9' type='alphabet_upper'>
                                        <li id="_" label="A">
                                          A9
                                          <ol id='B0' type='roman_upper'>
                                            <li id="_" label="I">A0</li>
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
         <fmt-title depth="1">
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
      <ol id='B1' type='alphabet'>
        <li id="_" label="a">
          A1
          <ul id='B2'>
            <li>
              A2
              <ol id='B3' type='roman'>
                <li id="_" label="i">A3 </li>
              </ol>
            </li>
          </ul>
        </li>
      </ol>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
      <foreword displayorder="2">
         <title id="_">Section</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Section</semx>
         </fmt-title>
         <p id="A">
         <semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">to</span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               <location target="ref1" connective="from"/>
               <location target="ref2" connective="to"/>
               text
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">and</span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-enum-comma">, </span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-enum-comma">,</span>
            <span class="fmt-conn">and</span>
            <fmt-xref target="ref3">
               <semx element="autonum" source="ref3">3</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               <location target="ref1" connective="and"/>
               <location target="ref2" connective="and"/>
               text
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">or</span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-enum-comma">, </span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-enum-comma">,</span>
            <span class="fmt-conn">or</span>
            <fmt-xref target="ref3">
               <semx element="autonum" source="ref3">3</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <fmt-xref target="ref1">
               Clauses
               <semx element="autonum" source="ref1">1</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">to</span>
            <fmt-xref target="ref2">
               <semx element="autonum" source="ref2">2</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">and</span>
            <fmt-xref target="ref3">
               <semx element="autonum" source="ref3">3</semx>
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">to</span>
            <fmt-xref target="ref4">
               <semx element="autonum" source="ref4">4</semx>
            </fmt-xref></semx><semx element="xref" source="_">
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
            </fmt-xref></semx><semx element="xref" source="_">
            <span class="fmt-conn">to</span>
            <fmt-xref target="item_6-4-i">
               <semx element="autonum" source="_">b</semx>
               <span class="fmt-autonum-delim">)</span>
               <semx element="autonum" source="item_6-4-i">1</semx>
               )
            </fmt-xref></semx>
         </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
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
      <semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">～</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <location target="ref1" connective="from"/>
             <location target="ref2" connective="to"/>
             text
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">及び</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-enum-comma">,</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-enum-comma">、</span>
          <fmt-xref target="ref3">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref3">3</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <location target="ref1" connective="and"/>
             <location target="ref2" connective="and"/>
             text
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">または</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-enum-comma">,</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-enum-comma">、</span>
          <span class="fmt-conn">または</span>
          <fmt-xref target="ref3">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref3">3</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <fmt-xref target="ref1">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref1">1</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">～</span>
          <fmt-xref target="ref2">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref2">2</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">及び</span>
          <fmt-xref target="ref3">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref3">3</semx>
          </fmt-xref></semx><semx element="xref" source="_">
          <span class="fmt-conn">～</span>
          <fmt-xref target="ref4">
             <span class="fmt-element-name">箇条</span>
             <semx element="autonum" source="ref4">4</semx>
          </fmt-xref></semx><semx element="xref" source="_">
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
          </fmt-xref></semx><semx element="xref" source="_">
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
          </fmt-xref></semx>
       </p>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:p[@id = 'A']")
      .to_xml)))
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
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true))
    xml = xml.at("//xmlns:p[@id = 'A2']")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
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
           <fmt-title depth="1">
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
              <fmt-name>
                 <span class="fmt-caption-label">
                    <span class="fmt-element-name">Figure</span>
                    <semx element="autonum" source="B1">1</semx>
                 </span>
                 <span class="fmt-caption-delim"> — </span>
                 <semx element="name" source="_">First</semx>
              </fmt-name>
              <fmt-xref-label>
                 <span class="fmt-element-name">Figure</span>
                 <semx element="autonum" source="B1">1</semx>
              </fmt-xref-label>
           </figure>
           <example id="C1" autonum="1">
              <fmt-name>
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
                 <fmt-name>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="B2">2</semx>
                    </span>
                    <span class="fmt-caption-delim"> — </span>
                    <semx element="name" source="_">Second</semx>
                 </fmt-name>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Figure</span>
                    <semx element="autonum" source="B2">2</semx>
                 </fmt-xref-label>
              </figure>
           </example>
           <example id="C2" autonum="2">
              <fmt-name>
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
                 <fmt-name>
                    <semx element="name" source="_">Unnamed</semx>
                 </fmt-name>
              </figure>
           </example>
           <figure id="B3" autonum="3">
              <name id="_">Third</name>
              <fmt-name>
                 <span class="fmt-caption-label">
                    <span class="fmt-element-name">Figure</span>
                    <semx element="autonum" source="B3">3</semx>
                 </span>
                 <span class="fmt-caption-delim"> — </span>
                 <semx element="name" source="_">Third</semx>
              </fmt-name>
              <fmt-xref-label>
                 <span class="fmt-element-name">Figure</span>
                 <semx element="autonum" source="B3">3</semx>
              </fmt-xref-label>
           </figure>
        </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="_" type="scope" inline-header="false" obligation="normative" displayorder="2">
                 <title id="_">Scope</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Scope</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">1</semx>
                 </fmt-xref-label>
                 <p id="_">A</p>
                 <p id="_">
            <eref type="inline" bibitemid="_607373b1-0cc4-fcdb-c482-fd86ae572bd1" citeas="ISO 639-2" id="_"/>
            <semx element="eref" source="_">
               <fmt-eref type="inline" bibitemid="_607373b1-0cc4-fcdb-c482-fd86ae572bd1" citeas="ISO 639-2">ISO 639-2</fmt-eref>
            </semx>
                 </p>
              </clause>
              <terms id="_" obligation="normative" displayorder="4">
                 <title id="_">Terms and definitions</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms and definitions</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">2</semx>
                 </fmt-xref-label>
                 <p id="_">No terms and definitions are listed in this document.</p>
              </terms>
              <references hidden="true" normative="true" displayorder="3">
                 <title id="_">Normative references</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Normative references</semx>
                 </fmt-title>
              </references>
           </sections>
           <bibliography>
        </bibliography>
        </standard-document>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <floating-title original-id="_">FL 6</floating-title>
             <p id="_" type="floating-title" displayorder="2">
                <semx element="floating-title" source="_">FL 6</semx>
             </p>
             <abstract displayorder="3"/>
             <floating-title original-id="_">FL 3</floating-title>
             <p id="_" type="floating-title" displayorder="4">
                <semx element="floating-title" source="_">FL 3</semx>
             </p>
             <floating-title original-id="_">FL 4</floating-title>
             <p id="_" type="floating-title" displayorder="5">
                <semx element="floating-title" source="_">FL 4</semx>
             </p>
             <foreword displayorder="6">
                <title id="_">Foreword 1</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword 1</semx>
                </fmt-title>
             </foreword>
             <floating-title original-id="_">FL 5</floating-title>
             <p id="_" type="floating-title" displayorder="7">
                <semx element="floating-title" source="_">FL 5</semx>
             </p>
             <foreword displayorder="8">
                <title id="_">Foreword 2</title>
                <fmt-title depth="1">
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
             <introduction displayorder="11"/>
             <floating-title original-id="_">FL 0</floating-title>
             <p id="_" type="floating-title" displayorder="12">
                <semx element="floating-title" source="_">FL 0</semx>
             </p>
             <acknowledgements displayorder="13"/>
          </preface>
       </standard-document>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
      </preface>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
       <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
          <bibdata/>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <floating-title original-id="_">FL 1</floating-title>
             <p id="_" type="floating-title" displayorder="2">
                <semx element="floating-title" source="_">FL 1</semx>
             </p>
             <floating-title original-id="_">FL 2</floating-title>
             <p id="_" type="floating-title" displayorder="3">
                <semx element="floating-title" source="_">FL 2</semx>
             </p>
             <abstract displayorder="4"/>
             <floating-title original-id="_">FL 3</floating-title>
             <p id="_" type="floating-title" displayorder="5">
                <semx element="floating-title" source="_">FL 3</semx>
             </p>
             <floating-title original-id="_">FL 4</floating-title>
             <p id="_" type="floating-title" displayorder="6">
                <semx element="floating-title" source="_">FL 4</semx>
             </p>
             <foreword displayorder="7">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
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
             <introduction displayorder="10"/>
             <floating-title original-id="_">FL 7</floating-title>
             <p id="_" type="floating-title" displayorder="11">
                <semx element="floating-title" source="_">FL 7</semx>
             </p>
             <acknowledgements displayorder="12"/>
          </preface>
       </standard-document>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
                  <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
         <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
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
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="_">
                    <span custom-charset="weather" style=";font-family:&quot;OGC Weather Symbols&quot;">ﶀ</span>
                 </p>
              </foreword>
           </preface>
        </standard-document>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
         <fmt-title depth="1">Table of contents</fmt-title>
      </clause>

           <foreword id="A" displayorder="2">
           <title id="_">Foreword</title><fmt-title depth="1"><semx element="title" source="_">Foreword</semx></fmt-title>
             <p id="_">
             AB<span style="x:y">C</span>D<span style="x:y;text-transform:none">ABC</span>
             <span style="text-transform:none">A<em>B</em>C</span>
             <span style="text-transform:none">a<em>b</em>c</span>
             <span style="text-transform:none">A<em>b</em>c Abc</span>
             <span style="text-transform:none">A<em>b</em>c   Abc</span>
             </p>
        </foreword></preface></standard-document>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
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
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="B">
                    <table id="C" autonum="1">
                       <fmt-name>
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
                                <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to (presxml)
  end
end
