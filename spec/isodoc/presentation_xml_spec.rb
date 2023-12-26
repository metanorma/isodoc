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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
          <preface><clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause></preface>
         <sections>
           <clause displayorder='2'>
             <title depth='1'>A</title>
             <clause>
               <title depth='2'>B</title>
               <clause>
                 <title depth='3'>C</title>
               </clause>
             </clause>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true))
  .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
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
            <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
            <bibdata/>
         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
            <sections>
              <clause id='_' inline-header='false' obligation='normative' displayorder='2'>
                <title depth='1'>
                  <strong>Annex A</strong>
                  <br/>
                  (normative).
                  <tab/>
                  Clause
                </title>
                <p id='_'>Text</p>
                <clause id='_' inline-header='false' obligation='normative'>
                  <title depth='1'>
                    <strong>Annex A</strong>
                    <br/>
                    (normative).
                    <tab/>
                    Subclause
                  </title>
              <variant-title variant_title='true' type='sub' id='_'>&#x201C;A&#x201D; &#x2018;B&#x2019;</variant-title>
              <variant-title variant_title='true' type='toc' id='_'>
         Clause
        <em>A</em>
        <stem type='MathML'>
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
            <mi>x</mi>
          </math>
          <asciimath>x</asciimath>
        </stem>
      </variant-title>
                  <p id='_'>Text</p>
                </clause>
              </clause>
            </sections>
            <annex id='_' inline-header='false' obligation='normative' displayorder='3'>
              <title>
                <strong>Annex A</strong>
                <br/>
                (normative)
                <br/>
                <br/>
                <strong>Clause</strong>
              </title>
                  <variant-title variant_title='true' type='toc' id='_'>
             Clause
            <em>A</em>
            <stem type='MathML'>
              <math xmlns='http://www.w3.org/1998/Math/MathML'>
                <mi>x</mi>
              </math>
              <asciimath>x</asciimath>
            </stem>
          </variant-title>
              <p id='_'>Text</p>
            </annex>
            </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
              <div id='_'>
                <h1>
                  <b>Annex A</b>
                  <br/>
                   (normative). &#160; Clause
                </h1>
                <p id='_'>Text</p>
                <div id='_'>
                  <h1>
                    <b>Annex A</b>
                    <br/>
                     (normative). &#160; Subclause
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
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
      <?xml version="1.0"?>
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata/>
         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <sections>
           <clause id="A" inline-header="false" obligation="normative" displayorder="2">
             <title depth="1">1.<tab/>Clause</title>
             <figure id="B"><name>Figure 1</name>
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
           </clause>
         </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to (xmlpp(output))

    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata/>
         <preface>
           <clause type="toc" id="_" displayorder="1">
             <title depth="1">Table of contents</title>
           </clause>
         </preface>
         <sections>
           <clause id="A" inline-header="false" obligation="normative" displayorder="2">
             <title depth="1">1.<tab/>Clause</title>
             <figure id="B">
               <name>Figure 1</name>
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
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html" }))
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
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
      <?xml version="1.0" encoding="UTF-8"?>
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata/>
         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
      <sections>
       <clause id="A" inline-header="false" obligation="normative" displayorder="2">
       <title depth="1">1.<tab/>Clause</title>
       <figure id="B"><name>Figure 1</name>
       <image mimetype="image/svg+xml" alt="3" src="_.svg"></image>
                   </figure>
                 </clause>
               </sections>
            </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true)
  .sub(%r{<localized-strings>.*</localized-strings>}m, "")
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
      <?xml version="1.0" encoding="UTF-8"?>
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata/>
        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <sections>
          <clause id="A" inline-header="false" obligation="normative" displayorder="2">
            <title depth="1">1.<tab/>Clause</title>
            <figure id="B"><name>Figure 1</name>
              <image mimetype="image/svg+xml" alt="3" src="_.svg"></image>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata/>
         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <sections>
          <clause id='A' inline-header='false' obligation='normative' displayorder='2'>
            <title depth='1'>
              1.
              <tab/>
              Clause
            </title>
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
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "considers ul when adding types to ordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata/>

         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <sections>
          <clause id='A' inline-header='false' obligation='normative' displayorder='2'>
            <title depth='1'>
              1.
              <tab/>
              Clause
            </title>
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
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
         <title>Section</title>
         <p id="A"><xref target="ref1">Clauses 1</xref> to <xref target="ref2">2</xref>
         <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/>text</xref>
         <xref target="ref1">Clauses 1</xref> and <xref target="ref2">2</xref>
         <xref target="ref1">Clauses 1</xref>, <xref target="ref2">2</xref>, and <xref target="ref3">3</xref>
         <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/>text</xref>
         <xref target="ref1">Clauses 1</xref> or <xref target="ref2">2</xref>
         <xref target="ref1">Clauses 1</xref>, <xref target="ref2">2</xref>, or <xref target="ref3">3</xref>
         <xref target="ref1">Clauses 1</xref> to <xref target="ref2">2</xref> and <xref target="ref3">3</xref> to <xref target="ref4">4</xref>
         Clause 5, <xref target="item_6-4-a">a) 1)</xref> to <xref target="item_6-4-i">b) 1)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:foreword")
      .to_xml))
      .to be_equivalent_to xmlpp(presxml)
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
      <foreword displayorder="2">
         <title>Section</title>
         <p id="A"><xref target="ref1">箇条 1</xref>～<xref target="ref2">箇条 2</xref><xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/>text</xref><xref target="ref1">箇条 1</xref> and <xref target="ref2">箇条 2</xref>
        <xref target="ref1">箇条 1</xref>, <xref target="ref2">箇条 2</xref>, and <xref target="ref3">箇条 3</xref>
        <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/>text</xref>
        <xref target="ref1">箇条 1</xref> or <xref target="ref2">箇条 2</xref>
        <xref target="ref1">箇条 1</xref>, <xref target="ref2">箇条 2</xref>, or <xref target="ref3">箇条 3</xref>
        <xref target="ref1">箇条 1</xref>～<xref target="ref2">箇条 2</xref> and <xref target="ref3">箇条 3</xref>～<xref target="ref4">箇条 4</xref>
        <xref target="item_6-4-a">箇条 5のa)の1)</xref>～<xref target="item_6-4-i">箇条 5のb)の1)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:foreword")
      .to_xml))
      .to be_equivalent_to xmlpp(presxml)
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <bibdata/>
        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
         <sections>
           <clause id='A1' inline-header='false' obligation='normative' displayorder='3'>
             <title depth='1'>
               2.
               <tab/>
               Section
             </title>
             <p id='A2'>
               <eref connective='from' bibitemid='A' citeas='A' type='inline'>A</eref>
                to
               <eref connective='to' bibitemid='B' citeas='B' type='inline'>B</eref>
             </p>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    xml.at("//xmlns:bibliography")&.remove
    xml.at("//xmlns:references")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(presxml)
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <bibdata/>

        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
         <sections>
           <clause id='A' inline-header='false' obligation='normative' displayorder='2'>
             <title depth='1'>
               1.
               <tab/>
               Section
             </title>
             <figure id='B1'>
               <name>Figure 1&#xA0;&#x2014; First</name>
             </figure>
             <example id='C1'>
               <name>EXAMPLE 1</name>
               <figure id='B2'>
                 <name>Figure 2&#xA0;&#x2014; Second</name>
               </figure>
             </example>
             <example id='C2'>
                <name>EXAMPLE 2</name>
                <figure id='B4' unnumbered='true'>
                  <name>Unnamed</name>
                </figure>
              </example>
             <figure id='B3'>
               <name>Figure 3&#xA0;&#x2014; Third</name>
             </figure>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
       <sections>
          <clause id='_' type='scope' inline-header='false' obligation='normative' displayorder='2'>
            <title depth='1'>
              1.
              <tab/>
              Scope
            </title>
            <p id='_'>A</p>
            <p id='_'>
              <eref type='inline' bibitemid='_607373b1-0cc4-fcdb-c482-fd86ae572bd1' citeas='ISO 639-2'>ISO&#xa0;639-2</eref>
            </p>
          </clause>
          <terms id='_' obligation='normative' displayorder='4'>
            <title depth='1'>
              2.
              <tab/>
              Terms and definitions
            </title>
            <p id='_'>No terms and definitions are listed in this document.</p>
          </terms>
          <references hidden='true' normative='true' displayorder='3'>
            <title depth='1'>Normative references</title>
          </references>
        </sections>
        <bibliography>
        </bibliography>
      </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes identifier" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <bibdata/>
      <sections><clause id="_scope" type="scope" inline-header="false" obligation="normative">
      <title>Scope</title>
      <p id="_8d98c053-85d7-e8cc-75bb-183a14209d61"><identifier>http://www.example.com</identifier></p>
      </clause>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns='https://www.metanorma.org/ns/standoc' type='presentation'>
         <bibdata/>
           <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
         <sections>
           <clause id='_' type='scope' inline-header='false' obligation='normative' displayorder='2'>
             <title depth='1'>
               1.
               <tab/>
               Scope
             </title>
             <p id='_'>
               <tt>http://www.example.com</tt>
             </p>
           </clause>
         </sections>
       </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
      <foreword/>
      <floating-title>FL 5</p>
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
            <title depth="1">Table of contents</title>
          </clause>
          <abstract displayorder="2"/>
          <foreword displayorder="3"/>
          <introduction displayorder="4"/>
          <p type="floating-title" displayorder="5">FL 1</p>
          <p type="floating-title" displayorder="6">FL 2</p>
          <p type="floating-title" displayorder="7">FL 3</p>
          <p type="floating-title" displayorder="8">FL 4</p>
          <p type="floating-title" displayorder="9">FL 5</p>
          <p type="floating-title" displayorder="10">FL 6</p>
          <p type="floating-title" displayorder="11">FL 0</p>
          <acknowledgements displayorder="12"/>
        </preface>
      </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
             <title depth="1">Table of contents</title>
           </clause>
           <p type="floating-title" displayorder="2">FL 1</p>
           <p type="floating-title" displayorder="3">FL 2</p>
           <abstract displayorder="4"/>
           <p type="floating-title" displayorder="5">FL 3</p>
           <p type="floating-title" displayorder="6">FL 4</p>
           <foreword displayorder="7"/>
           <p type="floating-title" displayorder="8">FL 5</p>
           <p type="floating-title" displayorder="9">FL 6</p>
           <introduction displayorder="10"/>
           <p type="floating-title" displayorder="11">FL 7</p>
           <acknowledgements displayorder="12"/>
         </preface>
       </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
       <preface><clause type="toc" id="_" displayorder="1"><title depth="1">Table of contents</title></clause>
          <foreword id="A" displayorder="2">
          <table id="tableD-1"><name>Table 1</name>
               <tbody>
                 <tr>
                   <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                   <td align="left">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                   <td align="center">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
       <preface><clause type="toc" id="_" displayorder="1"><title depth="1">Table of contents</title></clause>
          <foreword id="A" displayorder="2">
               <table id="tableD-1"><name>Table 1</name>
                  <tbody>
                  <tr>
                    <td align="left">http://&#x200B;www.example.&#x200B;com/&#x200B;AAAAAAAAAAAAAAAAA&#xAD;AAAAAAAAAAAAAAAAAAAA&#xAD;AAAAAAAA/&#x200B;BBBBBBBBBBB&#xAD;BBBBBBBBBBBBBBBBB</td>
                    <td align="left">http://&#x200B;www.example.&#x200B;com/&#x200B;AAAAAAAAAAAAAAAAA&#xAD;AAAAAAAAAAAAAAAAAAAA&#xAD;AAAAAAAABBBBBBBBBBBB&#xAD;BBBBBBBBBBBBBBBB</td>
                    <td align="center">www.&#x200B;example.com/&#x200B;AAAAAAAAAAAAAAAAAAAAAAAA&#xAD;AAAAAAAAAAAAAAAAAAAA&#xAD;ABBBBBBBBBBBBBBBBBBB&#xAD;BBBBBBBBB</td>
                    <td align="center">aaaaaaaa_&#x200B;aa</td>
                    <td align="center">aaaaaaaa.&#x200B;aa</td>
                    <td align="center">aaaaaaaa.0a</td>
                    <td align="center">aaaaaaaa&#x200B;&#x3c;a&#x3e;a</td>
                    <td align="center">aaaaaaaa&#x200B;&#x3c;&#x3c;a&#x3e;&#x3e;a</td>
                    <td align="center">aaaaaaaa/&#x200B;aa</td>
                    <td align="center">aaaaaaaa//&#x200B;aa</td>
                    <td align="center">aaaaaaaa+&#x200B;aa</td>
                    <td align="center">aaaaaaaa+&#x200B;0a</td>
                    <td align="center">aaaaaaaa&#x200B;{aa</td>
                    <td align="center">aaaaaaaa;&#x200B;{aa</td>
                    <td align="center">aaaaaaaa&#x200B;(aa</td>
                    <td align="center">aaaaaaaa(0a</td>
                    <td align="center">aaaaaaa0(aa</td>
                    <td align="center">aaaaaaa&#xAD;Aaaaa</td>
                    <td align="center">aaaaaaaAAaaa</td>
                  </tr>
                  </tbody>
                  </table>
       </foreword></preface></standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(breakupurlsintables: "true"))
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to (presxml)
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
      <presentation-metadata><custom-charset-font>weather:"OGC Weather Symbols",conscript:"Code 2000"</custom-charset-font></presentation-metadata>
        <preface><clause type="toc" id="_" displayorder="1"><title depth="1">Table of contents</title></clause>

          <foreword id="A" displayorder="2">
            <p id="_"><span custom-charset="weather" style=";font-family:&quot;OGC Weather Symbols&quot;">&#xFD80;</span></p>
       </foreword></preface></standard-document>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to (presxml)
  end

  it "supplies formats in passthrough" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
            <p>
            <passthrough formats="html">A</passthrough>
            <passthrough formats="word,html">A</passthrough>
            <passthrough formats="word,html,other">A</passthrough>
            <passthrough>A</passthrough>
            <passthrough formats="all">A</passthrough>
            </p>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
         <metanorma-extension>
                    <render>
             <preprocess-xslt format="html">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'passthrough']">
                   <xsl:if test="contains(@formats,',html,')">
                     <!-- delimited -->
                     <xsl:copy>
                       <xsl:apply-templates select="@* | node()"/>
                     </xsl:copy>
                   </xsl:if>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
             <preprocess-xslt format="html">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'math-with-linebreak']">

       </xsl:template>
                 <xsl:template match="*[local-name() = 'math-no-linebreak']">
                     <xsl:apply-templates select="node()"/>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
             <preprocess-xslt format="doc">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'passthrough']">
                   <xsl:if test="contains(@formats,',doc,')">
                     <!-- delimited -->
                     <xsl:copy>
                       <xsl:apply-templates select="@* | node()"/>
                     </xsl:copy>
                   </xsl:if>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
             <preprocess-xslt format="doc">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'math-with-linebreak']">

       </xsl:template>
                 <xsl:template match="*[local-name() = 'math-no-linebreak']">
                     <xsl:apply-templates select="node()"/>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
             <preprocess-xslt format="pdf">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'passthrough']">
                   <xsl:if test="contains(@formats,',pdf,')">
                     <!-- delimited -->
                     <xsl:copy>
                       <xsl:apply-templates select="@* | node()"/>
                     </xsl:copy>
                   </xsl:if>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
             <preprocess-xslt format="pdf">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:template match="@* | node()">
                   <xsl:copy>
                     <xsl:apply-templates select="@* | node()"/>
                   </xsl:copy>
                 </xsl:template>
                 <xsl:template match="*[local-name() = 'math-with-linebreak']">

       </xsl:template>
                 <xsl:template match="*[local-name() = 'math-no-linebreak']">
                     <xsl:apply-templates select="node()"/>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
           </render>
         </metanorma-extension>
         <preface>
           <clause type="toc" id="_" displayorder="1">
             <title depth="1">Table of contents</title>
           </clause>
           <foreword id="A" displayorder="2">
             <p>
               <passthrough formats=",html,">A</passthrough>
               <passthrough formats=",word,html,">A</passthrough>
               <passthrough formats=",word,html,other,">A</passthrough>
               <passthrough formats=",html,doc,pdf,">A</passthrough>
               <passthrough formats=",html,doc,pdf,">A</passthrough>
             </p>
           </foreword>
         </preface>
       </standard-document>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc", pdf: "pdf" }))
      .convert("test", input, true))
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end
end
