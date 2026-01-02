require "spec_helper"

RSpec.describe IsoDoc do
  it "processes floating titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
        <floating-title depth="1" id="F1">A0</p>
        <introduction id="B" obligation="informative">
        <title>Introduction</title>
        <floating-title depth="1" id="F2">A</p>
        <clause id="B1" obligation="informative">
         <title>Introduction Subsection</title>
        <floating-title depth="2" id="F3">B</p>
        <clause id="B2" obligation="informative">
         <title>Introduction Sub-subsection</title>
        <floating-title depth="1" id="F4">C</p>
       </clause>
       </clause>
       </introduction>
       </preface>
       <sections>
        <clause id="C" obligation="informative">
        <title>Introduction</title>
        <floating-title depth="1">A</p>
        <clause id="C1" obligation="informative">
         <title>Introduction Subsection</title>
        <floating-title depth="2">B</p>
        <clause id="C2" obligation="informative">
         <title>Introduction Sub-subsection</title>
        <floating-title depth="1">C</p>
       </clause>
       </clause>
       </clause>
        <floating-title depth="1">D</p>
       <clause id="C4"><title>Clause 2</title></clause>
       </sections>
       </iso-standard>
    INPUT

    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <floating-title depth="1" original-id="F1">A0</floating-title>
            <p depth="1" id="F1" type="floating-title" displayorder="2">
               <semx element="floating-title" source="F1">A0</semx>
            </p>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <floating-title depth="1" original-id="F2">A</floating-title>
               <p depth="1" id="F2" type="floating-title">
                  <semx element="floating-title" source="F2">A</semx>
               </p>
               <clause id="B1" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <floating-title depth="2" original-id="F3">B</floating-title>
                  <p depth="2" id="F3" type="floating-title">
                     <semx element="floating-title" source="F3">B</semx>
                  </p>
                  <clause id="B2" obligation="informative">
                     <title id="_">Introduction Sub-subsection</title>
                     <fmt-title id="_" depth="3">
                        <semx element="title" source="_">Introduction Sub-subsection</semx>
                     </fmt-title>
                     <floating-title depth="1" original-id="F4">C</floating-title>
                     <p depth="1" id="F4" type="floating-title">
                        <semx element="floating-title" source="F4">C</semx>
                     </p>
                  </clause>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="C" obligation="informative" displayorder="4">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="C">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="C">1</semx>
               </fmt-xref-label>
               <floating-title depth="1" original-id="_">A</floating-title>
               <p depth="1" id="_" type="floating-title">
                  <semx element="floating-title" source="_">A</semx>
               </p>
               <clause id="C1" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="C">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="C">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="C1">1</semx>
                  </fmt-xref-label>
                  <floating-title depth="2" original-id="_">B</floating-title>
                  <p depth="2" id="_" type="floating-title">
                     <semx element="floating-title" source="_">B</semx>
                  </p>
                  <clause id="C2" obligation="informative">
                     <title id="_">Introduction Sub-subsection</title>
                     <fmt-title id="_" depth="3">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="C">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="C1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="C2">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Introduction Sub-subsection</semx>
                     </fmt-title>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="C">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C2">1</semx>
                     </fmt-xref-label>
                     <floating-title depth="1" original-id="_">C</floating-title>
                     <p depth="1" id="_" type="floating-title">
                        <semx element="floating-title" source="_">C</semx>
                     </p>
                  </clause>
               </clause>
            </clause>
            <floating-title depth="1" original-id="_">D</floating-title>
            <p depth="1" id="_" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_">D</semx>
            </p>
            <clause id="C4" displayorder="6">
               <title id="_">Clause 2</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="C4">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 2</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="C4">2</semx>
               </fmt-xref-label>
            </clause>
         </sections>
      </iso-standard>
    PRESXML

    html = <<~OUTPUT
      #{HTML_HDR}
                <p class="h1" id="F1">A0</p>
                <br/>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <p class="h1" id="F2">A</p>
                   <div id="B1">
                      <h2>Introduction Subsection</h2>
                      <p class="h2" id="F3">B</p>
                      <div id="B2">
                         <h3>Introduction Sub-subsection</h3>
                         <p class="h1" id="F4">C</p>
                      </div>
                   </div>
                </div>
                <div id="C">
                   <h1>1.\\u00a0 Introduction</h1>
                   <p class="h1" id="_">A</p>
                   <div id="C1">
                      <h2>1.1.\\u00a0 Introduction Subsection</h2>
                      <p class="h2" id="_">B</p>
                      <div id="C2">
                         <h3>1.1.1.\\u00a0 Introduction Sub-subsection</h3>
                         <p class="h1" id="_">C</p>
                      </div>
                   </div>
                </div>
                <p class="h1" id="_">D</p>
                <div id="C4">
                   <h1>2.\\u00a0 Clause 2</h1>
                </div>
             </div>
          </body>
       </html>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
            <p class="MsoNormal">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <p class="h1">
               <a name="F1" id="F1"/>
               A0
            </p>
            <div class="Section3">
               <a name="B" id="B"/>
               <h1 class="IntroTitle">Introduction</h1>
               <p class="h1">
                  <a name="F2" id="F2"/>
                  A
               </p>
               <div>
                  <a name="B1" id="B1"/>
                  <h2>Introduction Subsection</h2>
                  <p class="h2">
                     <a name="F3" id="F3"/>
                     B
                  </p>
                  <div>
                     <a name="B2" id="B2"/>
                     <h3>Introduction Sub-subsection</h3>
                     <p class="h1">
                        <a name="F4" id="F4"/>
                        C
                     </p>
                  </div>
               </div>
            </div>
            <p class="MsoNormal">\\u00a0</p>
         </div>
         <p class="MsoNormal">
            <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
            <div>
               <a name="C" id="C"/>
               <h1>
                  1.
                  <span style="mso-tab-count:1">\\u00a0 </span>
                  Introduction
               </h1>
               <p class="h1">
                  <a name="_" id="_"/>
                  A
               </p>
               <div>
                  <a name="C1" id="C1"/>
                  <h2>
                     1.1.
                     <span style="mso-tab-count:1">\\u00a0 </span>
                     Introduction Subsection
                  </h2>
                  <p class="h2">
                     <a name="_" id="_"/>
                     B
                  </p>
                  <div>
                     <a name="C2" id="C2"/>
                     <h3>
                        1.1.1.
                        <span style="mso-tab-count:1">\\u00a0 </span>
                        Introduction Sub-subsection
                     </h3>
                     <p class="h1">
                        <a name="_" id="_"/>
                        C
                     </p>
                  </div>
               </div>
            </div>
            <p class="h1">
               <a name="_" id="_"/>
               D
            </p>
            <div>
               <a name="C4" id="C4"/>
               <h1>
                  2.
                  <span style="mso-tab-count:1">\\u00a0 </span>
                  Clause 2
               </h1>
            </div>
         </div>
         <div style="mso-element:footnote-list"/>
      </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(strip_guid(Canon.format_xml(File.read("test.doc")
    .sub(/^.*<body/m, "<body")
    .sub(%r{</body>.*$}m, ""))))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "processes disconnected titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <clause id="A1" displayorder="1">
           <clause id="A2">
           <clause id="A3">
           <cross-align>
           <align-cell>
           <title>Title</title>
           <p>Para</p>
           </align-cell>
           <align-cell>
           <title>Iitre</title>
           <p>Alinée</p>
           </align-cell>
           </cross-align>
           </clause>
           </clause>
           </clause>
           </sections>
      </iso-standard>
    INPUT
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
             <div id="A1">
               <h1/>
               <div id="A2">
                 <div id="A3">
                   <table>
                     <tbody>
                       <td>
                         <h3>Title</h3>
                         <p>Para</p>
                       </td>
                       <td>
                         <h3>Iitre</h3>
                         <p>Alinée</p>
                       </td>
                     </tbody>
                   </table>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
       .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
