require "spec_helper"

RSpec.describe IsoDoc do
  it "processes unlabelled notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <note id="A" keep-with-next="true" keep-lines-together="true">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="B" keep-with-next="true" keep-lines-together="true" notag="true" unnumbered="true">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <note id="A" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="A">1</semx>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
                <note id="B" keep-with-next="true" keep-lines-together="true" notag="true" unnumbered="true">
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
        <br/>
        <div id="fwd">
        <h1 class="ForewordTitle">Foreword</h1>
                       <div id='A' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>
                   <span class='note_label'>NOTE 1\\u00a0 </span>
                   These results are based on a study carried out on three
                   different types of kernel.
                 </p>
               </div>
               <div id='B' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>
                   These results are based on a study carried out on three
                   different types of kernel.
                 </p>
               </div>
             </div>
        </div>
        </body>
        </html>
    OUTPUT
    doc = <<~OUTPUT
    #{WORD_HDR}
                  <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div id="fwd">
              <h1 class="ForewordTitle">Foreword</h1>
                             <div id='A' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p class='Note'>
                   <span class='note_label'>NOTE 1
                   <span style='mso-tab-count:1'>\\u00a0 </span></span>
                    These results are based on a study carried out on three different
                   types of kernel.
                 </p>
               </div>
               <div id='B' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p class='Note'>
                    These results are based on a study carried out on three different
                   types of kernel.
                 </p>
               </div>
            </div>
            <p>\\u00a0</p>
          </div>
          <p class="section-break"><br clear="all" class="section"/></p>
          <div class="WordSection3">
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(doc)
  end

  it "processes sequences of notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <note id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <note id="note1" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="note1">1</semx>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note1">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note1">1</semx>
                   </fmt-xref-label>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
                <note id="note2" autonum="2">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="note2">2</semx>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note2">2</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note2">2</semx>
                   </fmt-xref-label>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                   <div id="fwd">
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div id="note1" class="Note">
                       <p><span class="note_label">NOTE  1\\u00a0 </span>These results are based on a study carried out on three different types of kernel.</p>
                     </div>
                     <div id="note2" class="Note">
                       <p><span class="note_label">NOTE  2\\u00a0 </span>These results are based on a study carried out on three different types of kernel.</p>
                     </div>
                   </div>
                 </div>
               </body>
           </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes multi-para notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1">
              <fmt-title id="_" depth="1">Table of contents</fmt-title>
          </clause>
        <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <note>
          <fmt-name id="_">NOTE<span class="fmt-label-delim"><tab/></span></fmt-name>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="fwd">
                  <h1 class="ForewordTitle">Foreword</h1>
                  <div class="Note">
                    <p><span class="note_label">NOTE\\u00a0 </span>These results are based on a study carried out on three different types of kernel.</p>
                    <p id="_">These results are based on a study carried out on three different types of kernel.</p>
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

  it "processes non-para notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><clause type="toc" id="_" displayorder="1">
              <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause><foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <note id="A"><fmt-name id="_">NOTE<span class="fmt-label-delim"><tab/></span></fmt-name>
          <dl>
          <dt>A</dt>
          <dd><p>B</p></dd>
          </dl>
          <ul>
          <li>C</li></ul>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="fwd">
                  <h1 class="ForewordTitle">Foreword</h1>
                  <div id="A" class="Note"><p><span class="note_label">NOTE\\u00a0 </span></p>
                   <div class="figdl">
            <dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
            </div>
            <div class="ul_wrap">
            <ul>
            <li>C</li></ul>
            </div>
        </div>
                </div>
              </div>
            </body>
        </html>

    OUTPUT
    doc = <<~OUTPUT
      #{WORD_HDR}
            <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="A" class="Note">
                      <p class="Note">
                         <span class="note_label">
                            NOTE
                            <span style="mso-tab-count:1">\\u00a0 </span>
                         </span>
                      </p>
                      <div align="left">
                         <table class="dl">
                            <tr>
                               <td valign="top" align="left">
                                  <p align="left" style="margin-left:0pt;text-align:left;">A</p>
                               </td>
                               <td valign="top">
                                  <p class="Note">B</p>
                               </td>
                            </tr>
                         </table>
                      </div>
                      <div class="ul_wrap">
                         <ul>
                            <li>C</li>
                         </ul>
                      </div>
                   </div>
                </div>
                <p>\\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
          </body>
       </html>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to Canon.format_xml(doc)
  end

  it "processes paragraphs containing notes" do
    input = <<~INPUT
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>    <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
        <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
            <p id="A">ABC <note id="B"><fmt-name id="_">NOTE 1<span class="fmt-label-delim"><tab/></span></fmt-name>
          <p id="C">XYZ</p></note>
        <note id="B1"><fmt-name id="_">NOTE 2<span class="fmt-label-delim"><tab/></span></fmt-name>
        <p id="C1">XYZ1</p></note></p>
        </foreword></preface>
            </iso-standard>
    INPUT
    html = <<~OUTPUT
      <html lang="en">
      <head/>
      <body lang="en">
        <div class="title-section">
          <p> </p>
        </div>
        <br/>
        <div class="prefatory-section">
          <p> </p>
        </div>
        <br/>
        <div class="main-section"><br />
          <div id="fwd">
            <h1 class="ForewordTitle">Foreword</h1>
            <p id="A">ABC
            </p>
            <div id="B" class="Note">
              <p><span class="note_label">NOTE 1  </span>XYZ</p>
            </div>
            <div id="B1" class="Note">
              <p><span class="note_label">NOTE 2  </span>XYZ1</p>
            </div>
          </div><br />
          <div id="_" class="TOC">
            <h1 class="IntroTitle">Table of contents</h1>
          </div>
        </div>
      </body>
      </html>
    OUTPUT

    doc = <<~OUTPUT
      #{WORD_HDR}
             <p class="page-break">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="fwd">
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">ABC
         </p>
               <div id="B" class="Note">
                 <p class="Note"><span class="note_label">NOTE 1<span style="mso-tab-count:1">\\u00a0 </span></span>XYZ</p>
               </div>
               <div id="B1" class="Note">
                 <p class="Note"><span class="note_label">NOTE 2<span style="mso-tab-count:1">\\u00a0 </span></span>XYZ1</p>
               </div>
             </div>
             <p>\\u00a0</p>
           </div>
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
           </div>
         </body>
       </html>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(doc)
  end

  it "converts notes and admonitions intended for coverpage" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <note id="FB" coverpage="true" unnumbered="true"><p>XYZ</p></note>
          <admonition id="FC" coverpage="true" unnumbered="true" type="warning"><p>XYZ</p></admonition>
      </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <note id="FB" coverpage="true" unnumbered="true">
                   <p>XYZ</p>
                </note>
                <admonition id="FC" coverpage="true" unnumbered="true" type="warning">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">WARNING</span>
                      </span>
                   </fmt-name>
                   <p>XYZ</p>
                </admonition>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div id="fwd">
              <h1 class='ForewordTitle'>Foreword</h1>
                <div id='FB' class='Note' coverpage='true'>
                 <p>
                   XYZ
                 </p>
               </div>
               <div id='FC' class='Admonition' coverpage='true'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
      #{WORD_HDR}
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
      <div id="fwd">
              <h1 class='ForewordTitle'>Foreword</h1>
                <div id='FB' class='Note' coverpage='true'>
                 <p class='Note'>
                   XYZ
                 </p>
               </div>
               <div id='FC' class='Admonition' coverpage='true'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
            </div>
            <p>\\u00a0</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(doc)
  end

  it "numbers notes in tables and figures separately from notes outside them" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <figure id="F"><note id="FB"><p>XYZ</p></note></figure>
          <table id="T"><note id="TB"><p>XYZ</p></note></table>
          <p id="A">ABC <note id="B"><p id="C">XYZ</p></note>
      </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <figure id="F" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="F">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="F">1</semx>
                   </fmt-xref-label>
                   <note id="FB" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="F">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="F">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <p>XYZ</p>
                   </note>
                </figure>
                <table id="T" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="T">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="T">1</semx>
                   </fmt-xref-label>
                   <note id="TB" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="T">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Table</span>
                            <semx element="autonum" source="T">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <p>XYZ</p>
                   </note>
                </table>
                <p id="A">
                   ABC
                   <note id="B" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="fwd">
                         <span class="fmt-xref-container">
                            <semx element="foreword" source="fwd">Foreword</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                      </fmt-xref-label>
                      <p id="C">XYZ</p>
                   </note>
                </p>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes single-paragraph admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution" keep-with-next="true" keep-lines-together="true">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6b" type="caution" keep-with-next="true" keep-lines-together="true" notag="true">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
          <preface>
           <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
          <admonition id="_" type="caution" keep-with-next="true" keep-lines-together="true">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">CAUTION</span>
               </span>
            </fmt-name>
        <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          <admonition id="_" type="caution" keep-with-next="true" keep-lines-together="true" notag="true">
        <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
      <br/>
        <div id="fwd">
        <h1 class="ForewordTitle">Foreword</h1>
        <div class="Admonition" id='_' style='page-break-after: avoid;page-break-inside: avoid;'><p class="AdmonitionTitle" style="text-align:center;">CAUTION</p>
        <p id='_'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        </div>
        <div id='_' class='Admonition' style='page-break-after: avoid;page-break-inside: avoid;'>
        <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        </div>
        </div>
        </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes multiple-paragraph and no-paragraph admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution" keep-with-next="true" keep-lines-together="true">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Paragraph 1.</p>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Paragraph 2.</p>
      </admonition>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6b" type="caution" keep-with-next="true" keep-lines-together="true" notag="true">
        <note><p id="_e94663cc-2473-4ccc-9a72-983a74d989f4">Paragraph 3.</p></note>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <admonition id="_" type="caution" keep-with-next="true" keep-lines-together="true">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">CAUTION</span>
                      </span>
                   </fmt-name>
                   <p id="_">Paragraph 1.</p>
                   <p id="_">Paragraph 2.</p>
                </admonition>
                <admonition id="_" type="caution" keep-with-next="true" keep-lines-together="true" notag="true">
                   <note>
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <p id="_">Paragraph 3.</p>
                   </note>
                </admonition>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="_" class="Admonition" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p class="AdmonitionTitle" style="text-align:center;">CAUTION</p>
                      <p id="_">Paragraph 1.</p>
                      <p id="_">Paragraph 2.</p>
                   </div>
                   <div id="_" class="Admonition" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div class="Note">
                         <p>
                            <span class="note_label">NOTE\\u00a0 </span>
                            Paragraph 3.
                         </p>
                      </div>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes empty admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
           <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
            <admonition id="_" type="caution">
              <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">CAUTION</span>
               </span>
            </fmt-name>
            </admonition>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes admonitions with titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
          <name>Title</name>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6b" type="caution" notag="true">
          <name>Title</name>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <admonition id="_" type="caution">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                         <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
                </admonition>
                <admonition id="_" type="caution" notag="true">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                         <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
                </admonition>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div id="fwd">
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div class="Admonition" id="_">
                             <p class='AdmonitionTitle' style='text-align:center;'>Title</p>
         <p id='_'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </div>
       <div id='_' class='Admonition'>
         <p class='AdmonitionTitle' style='text-align:center;'>Title</p>
            <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
          </div>
                  </div>
                </div>
              </body>
          </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes box admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="box">
          <name>Title</name>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6b" type="box" notag="true">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title id="_" depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="fwd" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <admonition id="_" type="box" autonum="1">
                    <name id="_">Title</name>
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Box</span>
                          <semx element="autonum" source="_">1</semx>
                       </span>
                       <span class="fmt-caption-delim">\\u00a0— </span>
                       <semx element="name" source="_">Title</semx>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Box</span>
                       <semx element="autonum" source="_">1</semx>
                    </fmt-xref-label>
                    <fmt-xref-label container="fwd">
                       <span class="fmt-xref-container">
                          <semx element="foreword" source="fwd">Foreword</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Box</span>
                       <semx element="autonum" source="_">1</semx>
                    </fmt-xref-label>
                    <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
                 </admonition>
                 <admonition id="_" type="box" notag="true" autonum="2">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Box</span>
                          <semx element="autonum" source="_">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Box</span>
                       <semx element="autonum" source="_">2</semx>
                    </fmt-xref-label>
                    <fmt-xref-label container="fwd">
                       <span class="fmt-xref-container">
                          <semx element="foreword" source="fwd">Foreword</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Box</span>
                       <semx element="autonum" source="_">2</semx>
                    </fmt-xref-label>
                    <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
                 </admonition>
              </foreword>
           </preface>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div id="fwd">
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="Admonition">
                 <p class="AdmonitionTitle" style="text-align:center;">Box  1\\u00a0— Title</p>
                 <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
               <div id="_" class="Admonition">
                 <p class="AdmonitionTitle" style="text-align:center;">Box  2</p>
                 <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
