require "spec_helper"

RSpec.describe IsoDoc do
  it "processes amend blocks" do
    input = <<~INPUT
      <standard-document xmlns='https://www.metanorma.org/ns/standoc'>
           <bibdata type='standard'>
             <title language='en' format='text/plain'>Document title</title>
             <language>en</language>
             <script>Latn</script>
             <status>
               <stage>published</stage>
             </status>
             <copyright>
               <from>2020</from>
             </copyright>
             <ext>
               <doctype>article</doctype>
             </ext>
           </bibdata>
           <sections>
             <clause id='A' inline-header='false' obligation='normative'>
               <title>Change Clause</title>
               <amend id='B' change='modify' path='//table[2]' path_end='//table[2]/following-sibling:example[1]' title='Change'>
                 <autonumber type='table'>2</autonumber>
                 <autonumber type='example'>A.7</autonumber>
                 <description>
                   <p id='C'>
                     <em>
                       This table contains information on polygon cells which are not
                       included in ISO 10303-52. Remove table 2 completely and replace
                       with:
                     </em>
                   </p>
                 </description>
                 <newcontent id='D'>
                   <table id='E'>
                     <name>Edges of triangle and quadrilateral cells</name>
                     <tbody>
                       <tr>
                         <th colspan='2' valign='middle' align='center'>triangle</th>
                         <th colspan='2' valign='middle' align='center'>quadrilateral</th>
                       </tr>
                       <tr>
                         <td valign='middle' align='center'>edge</td>
                         <td valign='middle' align='center'>vertices</td>
                         <td valign='middle' align='center'>edge</td>
                         <td valign='middle' align='center'>vertices</td>
                       </tr>
                       <tr>
                         <td valign='middle' align='center'>1</td>
                         <td valign='middle' align='center'>1, 2</td>
                         <td valign='middle' align='center'>1</td>
                         <td valign='middle' align='center'>1, 2</td>
                       </tr>
                       <tr>
                         <td valign='middle' align='center'>2</td>
                         <td valign='middle' align='center'>2, 3</td>
                         <td valign='middle' align='center'>2</td>
                         <td valign='middle' align='center'>2, 3</td>
                       </tr>
                       <tr>
                         <td valign='middle' align='center'>3</td>
                         <td valign='middle' align='center'>3, 1</td>
                         <td valign='middle' align='center'>3</td>
                         <td valign='middle' align='center'>3, 4</td>
                       </tr>
                       <tr>
                         <td valign='top' align='left'/>
                         <td valign='top' align='left'/>
                         <td valign='middle' align='center'>4</td>
                         <td valign='middle' align='center'>4, 1</td>
                       </tr>
                     </tbody>
                   </table>
                   <figure id="H"><name>Figure</name></figure>
                   <example id='F'>
                     <p id='G'>This is not generalised further.</p>
                   </example>
                 </newcontent>
               </amend>
             </clause>
           </sections>
         </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
              <bibdata type="standard">
                <title language="en" format="text/plain">Document title</title>
                <language current="true">en</language>
                <script current="true">Latn</script>
                <status>
                  <stage>published</stage>
                </status>
                <copyright>
                  <from>2020</from>
                </copyright>
                <ext>
                  <doctype>article</doctype>
                </ext>
              </bibdata>
              <sections>
                <clause id="A" inline-header="false" obligation="normative" displayorder="1">
                  <title depth="1">1.<tab/>Change Clause</title>
                      <p id="C">
                        <em>
                          This table contains information on polygon cells which are not
                          included in ISO 10303-52. Remove table 2 completely and replace
                          with:
                        </em>
                      </p>
                    <quote id="D">
                      <table id="E" number="2">
                        <name>Table 2&#xA0;&#x2014; Edges of triangle and quadrilateral cells</name>
                        <tbody>
                          <tr>
                            <th colspan="2" valign="middle" align="center">triangle</th>
                            <th colspan="2" valign="middle" align="center">quadrilateral</th>
                          </tr>
                          <tr>
                            <td valign="middle" align="center">edge</td>
                            <td valign="middle" align="center">vertices</td>
                            <td valign="middle" align="center">edge</td>
                            <td valign="middle" align="center">vertices</td>
                          </tr>
                          <tr>
                            <td valign="middle" align="center">1</td>
                            <td valign="middle" align="center">1, 2</td>
                            <td valign="middle" align="center">1</td>
                            <td valign="middle" align="center">1, 2</td>
                          </tr>
                          <tr>
                            <td valign="middle" align="center">2</td>
                            <td valign="middle" align="center">2, 3</td>
                            <td valign="middle" align="center">2</td>
                            <td valign="middle" align="center">2, 3</td>
                          </tr>
                          <tr>
                            <td valign="middle" align="center">3</td>
                            <td valign="middle" align="center">3, 1</td>
                            <td valign="middle" align="center">3</td>
                            <td valign="middle" align="center">3, 4</td>
                          </tr>
                          <tr>
                            <td valign="top" align="left"/>
                            <td valign="top" align="left"/>
                            <td valign="middle" align="center">4</td>
                            <td valign="middle" align="center">4, 1</td>
                          </tr>
                        </tbody>
                      </table>
                      <figure id="H" unnumbered="true"><name>Figure</name></figure>
                      <example id="F" number="A.7"><name>EXAMPLE  A.7</name>
                        <p id="G">This is not generalised further.</p>
                      </example>
                    </quote>
                </clause>
              </sections>
            </standard-document>
    OUTPUT
    html = <<~OUTPUT
      <html lang='en'>
           <head/>
           <body lang='en'>
             <div class='title-section'>
               <p>&#160;</p>
             </div>
             <br/>
             <div class='prefatory-section'>
               <p>&#160;</p>
             </div>
             <br/>
             <div class='main-section'>
               <p class='zzSTDTitle1'>Document title</p>
               <div id='A'>
                 <h1>1.&#160; Change Clause</h1>
                 <p id='C'>
                   <i>
                      This table contains information on polygon cells which are not
                     included in ISO 10303-52. Remove table 2 completely and replace
                     with:
                   </i>
                 </p>
                 <div class='Quote' id="D">
                   <p class='TableTitle' style='text-align:center;'>Table 2&#160;&#8212; Edges of triangle and quadrilateral cells</p>
                   <table id='E' class='MsoISOTable' style='border-width:1px;border-spacing:0;'>
                     <tbody>
                       <tr>
                         <th colspan='2' style='font-weight:bold;text-align:center;vertical-align:middle;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;' scope='row'>triangle</th>
                         <th colspan='2' style='font-weight:bold;text-align:center;vertical-align:middle;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;' scope='row'>quadrilateral</th>
                       </tr>
                       <tr>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>edge</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>vertices</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>edge</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>vertices</td>
                       </tr>
                       <tr>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>1</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>1, 2</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>1</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>1, 2</td>
                       </tr>
                       <tr>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>2</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>2, 3</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>2</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>2, 3</td>
                       </tr>
                       <tr>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>3</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>3, 1</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>3</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;'>3, 4</td>
                       </tr>
                       <tr>
                         <td style='text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;'/>
                         <td style='text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;'/>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;'>4</td>
                         <td style='text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;'>4, 1</td>
                       </tr>
                     </tbody>
                   </table>
                   <div id='H' class='figure'>
                     <p class='FigureTitle' style='text-align:center;'>Figure</p>
                   </div>
                   <div id='F' class='example'>
                     <p class='example-title'>EXAMPLE A.7</p>
                     <p id='G'>This is not generalised further.</p>
                   </div>
                 </div>
               </div>
             </div>
           </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes unlabelled notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
          <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
                       <note id='A' keep-with-next='true' keep-lines-together='true'>
               <name>NOTE 1</name>
               <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e'>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </note>
             <note id='B' keep-with-next='true' keep-lines-together='true' notag='true' unnumbered='true'>
               <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </note>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
        <br/>
        <div>
        <h1 class="ForewordTitle">Foreword</h1>
                       <div id='A' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>
                   <span class='note_label'>NOTE 1</span>
                   &#160; These results are based on a study carried out on three
                   different types of kernel.#{' '}
                 </p>
               </div>
               <div id='B' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>
                   &#160; These results are based on a study carried out on three
                   different types of kernel.#{' '}
                 </p>
               </div>
             </div>
        <p class="zzSTDTitle1"/>
        </div>
        </body>
        </html>
    OUTPUT
    doc = <<~OUTPUT
        <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head><style/></head>
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
                             <div id='A' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p class='Note'>
                   <span class='note_label'>NOTE 1</span>
                   <span style='mso-tab-count:1'>&#160; </span>
                    These results are based on a study carried out on three different
                   types of kernel.#{' '}
                 </p>
               </div>
               <div id='B' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p class='Note'>
                   <span class='note_label'/>
                   <span style='mso-tab-count:1'>&#160; </span>
                    These results are based on a study carried out on three different
                   types of kernel.#{' '}
                 </p>
               </div>
            </div>
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes sequences of notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
            <note id='note1'>
              <name>NOTE 1</name>
              <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                These results are based on a study carried out on three different
                types of kernel.
              </p>
            </note>
            <note id='note2'>
              <name>NOTE 2</name>
              <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
                These results are based on a study carried out on three different
                types of kernel.
              </p>
            </note>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                   <div>
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div id="note1" class="Note">
                       <p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                     </div>
                     <div id="note2" class="Note">
                       <p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                     </div>
                   </div>
                   <p class="zzSTDTitle1"/>
                 </div>
               </body>
           </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes multi-para notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
          <name>NOTE</name>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <div class="Note">
                    <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                    <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
                  </div>
                </div>
                <p class="zzSTDTitle1"/>
              </div>
            </body>
        </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes non-para notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note id="A"><name>NOTE</name>
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
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <div id="A" class="Note"><p><span class="note_label">NOTE</span>&#160; </p>
            <dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
            <ul>
            <li>C</li></ul>
        </div>
                </div>
                <p class="zzSTDTitle1"/>
              </div>
            </body>
        </html>

    OUTPUT
    doc = <<~OUTPUT
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head><style/></head>
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="A" class="Note"><p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#160; </span></p>
          <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">A</p></td><td valign="top"><p class="Note">B</p></td></tr></table>
          <ul>
          <li>C</li></ul>
      </div>
            </div>
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes paragraphs containing notes" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">ABC <note id="B"><name>NOTE 1</name><p id="C">XYZ</p></note>
      <note id="B1"><name>NOTE 2</name><p id="C1">XYZ1</p></note></p>
      </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div>
                  <h1 class='ForewordTitle'>Foreword</h1>
                  <p id='A'>
                    ABC
                    <div id='B' class='Note'>
                      <p>
                        <span class='note_label'>NOTE 1</span>
                        &#160; XYZ
                      </p>
                    </div>
                    <div id='B1' class='Note'>
                      <p>
                        <span class='note_label'>NOTE 2</span>
                        &#160; XYZ1
                      </p>
                    </div>
                  </p>
                </div>
                <p class='zzSTDTitle1'/>
              </div>
            </body>
          </html>
    OUTPUT

    doc = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
      <head>
          <style/>
        </head>
        <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <p id='A'>ABC </p>
              <div id='B' class='Note'>
                <p class='Note'>
                  <span class='note_label'>NOTE 1</span>
                  <span style='mso-tab-count:1'>&#160; </span>
                  XYZ
                </p>
              </div>
              <div id='B1' class='Note'>
                <p class='Note'>
                  <span class='note_label'>NOTE 2</span>
                  <span style='mso-tab-count:1'>&#160; </span>
                  XYZ1
                </p>
              </div>
            </div>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to xmlpp(doc)
  end

  it "converts notes and admonitions intended for coverpage" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note id="FB" coverpage="true" unnumbered="true"><p>XYZ</p></note>
          <admonition id="FC" coverpage="true" unnumbered="true" type="warning"><p>XYZ</p></admonition>
      </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword displayorder='1'>
            <note id='FB' coverpage='true' unnumbered='true'>
               <name>NOTE</name>
               <p>XYZ</p>
             </note>
             <admonition id='FC' coverpage='true' unnumbered='true' type='warning'>
               <name>WARNING</name>
               <p>XYZ</p>
             </admonition>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
                <div id='FB' class='Note' coverpage='true'>
                 <p>
                   <span class='note_label'>NOTE</span>
                   &#160; XYZ
                 </p>
               </div>
               <div id='FC' class='Admonition' coverpage='true'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
            </div>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
                <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
            <head>
                <style/>
              </head>
      <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
                <div id='FB' class='Note' coverpage='true'>
                 <p class='Note'>
                   <span class='note_label'>NOTE</span>
                   <span style='mso-tab-count:1'>&#160; </span>
                   XYZ
                 </p>
               </div>
               <div id='FC' class='Admonition' coverpage='true'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
            </div>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to xmlpp(doc)
  end

  it "numbers notes in tables and figures separately from notes outside them" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="F"><note id="FB"><p>XYZ</p></note></figure>
          <table id="T"><note id="TB"><p>XYZ</p></note></table>
          <p id="A">ABC <note id="B"><p id="C">XYZ</p></note>
      </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword displayorder='1'>
            <figure id='F'>
              <name>Figure 1</name>
              <note id='FB'>
                <name>NOTE</name>
                <p>XYZ</p>
              </note>
            </figure>
            <table id='T'>
              <name>Table 1</name>
              <note id='TB'>
                <name>NOTE</name>
                <p>XYZ</p>
              </note>
            </table>
            <p id='A'>
              ABC
              <note id='B'>
                <name>NOTE</name>
                <p id='C'>XYZ</p>
              </note>
            </p>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes figures" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
        <name>Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
        <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
        <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
        <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
        <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
        <fn reference="a">
        <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
      </fn>
        <dl>
        <dt>A</dt>
        <dd><p>B</p></dd>
        </dl>
      </figure>
      <figure id="figure-B">
      <pre alt="A B">A &#x3c;
      B</pre>
      </figure>
      <figure id="figure-C" unnumbered="true">
      <pre>A &#x3c;
      B</pre>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
          <?xml version='1.0'?>
           <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
        <name>Figure 1&#xA0;&#x2014; Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
        <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
        <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
        <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
        <image src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' mimetype='application/xml'/>
        <fn reference="a">
        <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
      </fn>
        <dl>
        <dt>A</dt>
        <dd><p>B</p></dd>
        </dl>
      </figure>
      <figure id="figure-B">
      <name>Figure 2</name>
      <pre alt="A B">A &#x3c;
      B</pre>
      </figure>
      <figure id="figure-C" unnumbered="true">
      <pre>A &#x3c;
      B</pre>
      </figure>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                               <br/>
                               <div>
                                 <h1 class="ForewordTitle">Foreword</h1>
                                 <div id="figureA-1" class="figure" style='page-break-after: avoid;page-break-inside: avoid;'>
                         <img src="rice_images/rice_image1.png" height="20" width="30" alt="alttext" title="titletxt"/>
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
                         <img src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto'/>
                         <a href="#_" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:_"><span><span id="_" class="TableFootnoteRef">a</span>&#160; </span>
                         <p id="_">The time <span class="stem">(#(t_90)#)</span> was estimated to be 18,2 min for this example.</p>
                       </div></aside>
                         <p  style='page-break-after:avoid;'><b>Key</b></p><dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
                       <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right <i>sample</i> divider
                       <a class='FootnoteRef' href='#fn:1'>
                  <sup>1</sup>
                </a>
                        </p></div>
                               <div class="figure" id="figure-B">
                <pre>A &#x3c;
                B</pre>
                <p class="FigureTitle" style="text-align:center;">Figure 2</p>
                </div>
                               <div class="figure" id="figure-C">
                <pre>A &#x3c;
                B</pre>
                </div>
                               </div>
                               <p class="zzSTDTitle1"/>
                               <aside id='fn:1' class='footnote'>
                  <p>X</p>
                </aside>
                             </div>
                           </body>
                       </html>
    OUTPUT

    word = <<~OUTPUT
                 <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
               <head><style/></head>
               <body lang="EN-US" link="blue" vlink="#954F72">
                 <div class="WordSection1">
                   <p>&#160;</p>
                 </div>
                 <p><br clear="all" class="section"/></p>
                 <div class="WordSection2">
                   <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                   <div>
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div id="figureA-1" class="figure"  style='page-break-after: avoid;page-break-inside: avoid;'>
               <img src="rice_images/rice_image1.png" height="20" width="30" alt="alttext" title="titletxt"/>
               <img src="rice_images/rice_image1.png" height='20' width='auto'/>
               <img src='_.gif' height='20' width='auto'/>
               <img src='_.xml' height='20' width='auto'/>
               <a href="#_" class="TableFootnoteRef">a</a><aside><div id="ftn_"><span><span id="_" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#160; </span></span>
               <p id="_">The time <span class="stem">(#(t_90)#)</span> was estimated to be 18,2 min for this example.</p>
             </div></aside>
               <p  style='page-break-after:avoid;'><b>Key</b></p><table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">A</p></td><td valign="top"><p>B</p></td></tr></table>
                <p class='FigureTitle' style='text-align:center;'>
         Figure 1&#160;&#8212; Split-it-right <i>sample</i> divider
         <span style='mso-bookmark:_Ref'>
           <a href='#ftn1' epub:type='footnote' class='FootnoteRef'>
             <sup>1</sup>
           </a>
         </span>
       </p>
      </div>
                     <div class="figure" id="figure-B">
      <pre>A &#x3c;
      B</pre>
                   <p class="FigureTitle" style="text-align:center;">Figure 2</p>
                    </div>
       <div id='figure-C' class='figure'>
         <pre>A &#x3c; B</pre>
      </div>
                   </div>
                   <p>&#160;</p>
                 </div>
                 <p><br clear="all" class="section"/></p>
                 <div class="WordSection3">
                   <p class="zzSTDTitle1"/>
                    <aside id='ftn1'>
         <p>X</p>
       </aside>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true).gsub(/&lt;/, "&#x3c;")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to xmlpp(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes SVG" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1">
          <image src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj4KICA8Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPgogIDxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz4KPC9zdmc+Cg==" id="_d3731866-1a07-435a-a6c2-1acd41023a4e" mimetype="image/svg+xml" height="auto" width="auto"/>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword displayorder="1">
            <figure id='figureA-1'>
              <name>Figure 1</name>
                <image id='_d3731866-1a07-435a-a6c2-1acd41023a4e' src='' mimetype='image/svg+xml' height='auto' width='auto'>
                 <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                   <circle fill='#009' r='45' cx='50' cy='50'/>
                   <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                 </svg>
                 <emf src='data:application/x-msmetafile;base64,AQAAAPgAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAVAQAACgAAAACAAAARgAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADEAIAAoAGMANABlADgAZgA5AGUALAAgADIAMAAyADEALQAwADUALQAyADQAKQAgAAAAaQBtAGEAZwBlADIAMAAyADEAMAA5ADIANQAtADMANQAzADAAOAAtADEAaAA2AG8AeABmAGYALgBlAG0AZgAAAAAAAAARAAAADAAAAAEAAAAkAAAAJAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAIAAABGAAAALAAAACAAAABTY3JlZW49MTAyMDV4MTMxODFweCwgMjE2eDI3OW1tAEYAAAAwAAAAIwAAAERyYXdpbmc9MTAwLjB4MTAwLjBweCwgMjYuNXgyNi41bW0AABIAAAAMAAAAAQAAABMAAAAMAAAAAgAAABYAAAAMAAAAGAAAABgAAAAMAAAAAAAAABQAAAAMAAAADQAAACcAAAAYAAAAAQAAAAAAAAAAAJkABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACkBAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACkBAAAqAMAAKgDAACkBAAAcQIAAKQEAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAOgEAAKQEAAA/AAAAqAMAAD8AAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAD8AAAA6AQAAOgEAAD8AAABxAgAAPwAAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACoAwAAPwAAAKQEAAA6AQAApAQAAHECAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAAJwAAABgAAAABAAAAAAAAAP///wAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAJ0BAABFAQAANgAAABAAAADPAwAARQEAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABfBAAA7QEAAGQEAADjAgAA2wMAAJEDAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAUgMAAD4EAABhAgAAcwQAAJ0BAAAOBAAANgAAABAAAACdAQAAyQIAADYAAAAQAAAA4gIAAMkCAAA2AAAAEAAAAOICAAAaAgAANgAAABAAAACdAQAAGgIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAOAAAAFAAAAAAAAAAAAAAAVAQAAA=='/>
               </image>
            </figure>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~HTML
      #{HTML_HDR}
              <br/>
                <div>
                  <h1 class='ForewordTitle'>Foreword</h1>
                  <div id='figureA-1' class='figure'>
                    <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                      <circle fill='#009' r='45' cx='50' cy='50'/>
                      <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                    </svg>
                    <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
                  </div>
                </div>
                <p class='zzSTDTitle1'/>
              </div>
            </body>
          </html>
    HTML

    doc = <<~DOC
          <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
      <head>
      <style>
              </style>
        </head>
            <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='figureA-1' class='figure'>
              <img src='_.emf' height='auto' width='auto'/>
                <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
              </div>
            </div>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    DOC

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(/&lt;/, "&#x3c;")
    .gsub(%r{data:application/x-msmetafile[^"']+},
          "data:application/x-msmetafile")))
      .to be_equivalent_to xmlpp(presxml
      .gsub(%r{data:application/x-msmetafile[^"']+},
            "data:application/x-msmetafile"))
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/['"][^'".]+(?<!odf1)(?<!odf)\.emf['"]/, "'_.emf'")
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'"))))
      .to be_equivalent_to xmlpp(doc)
  end

  it "converts SVG (Word)" do
    FileUtils.rm_rf "spec/assets/odf1.emf"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1">
        <image src="spec/assets/odf.svg" mimetype="image/svg+xml"/>
        <image src="spec/assets/odf1.svg" mimetype="image/svg+xml"/>
        <image src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj4KICA8Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPgogIDxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz4KPC9zdmc+Cg==" id="_d3731866-1a07-435a-a6c2-1acd41023a4e" mimetype="image/svg+xml" height="auto" width="auto"/>
        <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword displayorder='1'>
            <figure id='figureA-1'>
              <name>Figure 1</name>
              <image src='spec/assets/odf.svg' mimetype='image/svg+xml'>
                <emf src='spec/assets/odf.emf'/>
              </image>
              <image src='spec/assets/odf1.svg' mimetype='image/svg+xml'>
                <emf src='data:application/x-msmetafile;base64,AQAAAMwAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAKAQAACgAAAACAAAALwAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADEAIAAoAGMANABlADgAZgA5AGUALAAgADIAMAAyADEALQAwADUALQAyADQAKQAgAAAAbwBkAGYAMQAuAGUAbQBmAAAAAAAAAAAAEQAAAAwAAAABAAAAJAAAACQAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAACAAAARgAAACwAAAAgAAAAU2NyZWVuPTEwMjA1eDEzMTgxcHgsIDIxNngyNzltbQBGAAAAMAAAACMAAABEcmF3aW5nPTEwMC4weDEwMC4wcHgsIDI2LjV4MjYuNW1tAAASAAAADAAAAAEAAAATAAAADAAAAAIAAAAWAAAADAAAABgAAAAYAAAADAAAAAAAAAAUAAAADAAAAA0AAAAnAAAAGAAAAAEAAAAAAAAAAACZAAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAApAQAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAApAQAAKgDAACoAwAApAQAAHECAACkBAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAADoBAACkBAAAPwAAAKgDAAA/AAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA/AAAAOgEAADoBAAA/AAAAcQIAAD8AAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAqAMAAD8AAACkBAAAOgEAAKQEAABxAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAACcAAAAYAAAAAQAAAAAAAAD///8ABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACdAQAARQEAADYAAAAQAAAAzwMAAEUBAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAXwQAAO0BAABkBAAA4wIAANsDAACRAwAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAFIDAAA+BAAAYQIAAHMEAACdAQAADgQAADYAAAAQAAAAnQEAAMkCAAA2AAAAEAAAAOICAADJAgAANgAAABAAAADiAgAAGgIAADYAAAAQAAAAnQEAABoCAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAADgAAABQAAAAAAAAAAAAAACgEAAA='/>
              </image>
              <image src='' id='_d3731866-1a07-435a-a6c2-1acd41023a4e' mimetype='image/svg+xml' height='auto' width='auto'>
                <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                  <circle fill='#009' r='45' cx='50' cy='50'/>
                  <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                </svg>
                <emf src='data:application/x-msmetafile;base64,AQAAAPgAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAVAQAACgAAAACAAAARQAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADEAIAAoAGMANABlADgAZgA5AGUALAAgADIAMAAyADEALQAwADUALQAyADQAKQAgAAAAaQBtAGEAZwBlADIAMAAyADEAMAA5ADIANQAtADMANAA4ADgANQAtAHkAeQA0ADkANQA2AC4AZQBtAGYAAAAAAAAAAAARAAAADAAAAAEAAAAkAAAAJAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAIAAABGAAAALAAAACAAAABTY3JlZW49MTAyMDV4MTMxODFweCwgMjE2eDI3OW1tAEYAAAAwAAAAIwAAAERyYXdpbmc9MTAwLjB4MTAwLjBweCwgMjYuNXgyNi41bW0AABIAAAAMAAAAAQAAABMAAAAMAAAAAgAAABYAAAAMAAAAGAAAABgAAAAMAAAAAAAAABQAAAAMAAAADQAAACcAAAAYAAAAAQAAAAAAAAAAAJkABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACkBAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACkBAAAqAMAAKgDAACkBAAAcQIAAKQEAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAOgEAAKQEAAA/AAAAqAMAAD8AAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAD8AAAA6AQAAOgEAAD8AAABxAgAAPwAAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACoAwAAPwAAAKQEAAA6AQAApAQAAHECAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAAJwAAABgAAAABAAAAAAAAAP///wAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAJ0BAABFAQAANgAAABAAAADPAwAARQEAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABfBAAA7QEAAGQEAADjAgAA2wMAAJEDAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAUgMAAD4EAABhAgAAcwQAAJ0BAAAOBAAANgAAABAAAACdAQAAyQIAADYAAAAQAAAA4gIAAMkCAAA2AAAAEAAAAOICAAAaAgAANgAAABAAAACdAQAAGgIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAOAAAAFAAAAAAAAAAAAAAAVAQAAA=='/>
              </image>
              <image src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' mimetype='application/xml'/>
            </figure>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    output = <<~OUTPUT
          <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
      <head>
      <style>
              </style>
        </head>
        <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='figureA-1' class='figure'>
                <img src='spec/assets/odf.emf'/>
                <img src='_.emf'/>
                <img src='_.emf' height='auto' width='auto'/>
                 <img src='_.xml' height='20' width='auto'/>
                 <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
              </div>
            </div>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
     .convert("test", input, true)
     .gsub(/&lt;/, "&#x3c;")
    .gsub(%r{data:application/x-msmetafile[^"']+},
          "data:application/x-msmetafile")))
      .to be_equivalent_to xmlpp(presxml
      .gsub(%r{data:application/x-msmetafile[^"']+},
            "data:application/x-msmetafile"))
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/['"][^'".]+(?<!odf1)(?<!odf)\.emf['"]/, "'_.emf'")
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to xmlpp(output)
  end

  context "disable inkscape" do
    it "converts SVG (Word) with inkscape disabled" do
      FileUtils.rm_rf "spec/assets/odf1.emf"
      allow(IsoDoc::PresentationXMLConvert)
        .to receive(:inkscape_installed?).and_return(nil)
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to receive(:inkscape_installed?)

      input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <foreword>
              <figure id="figureA-1">
                <image src="spec/assets/odf.svg" mimetype="image/svg+xml"/>
                <image src="spec/assets/odf1.svg" mimetype="image/svg+xml"/>
                <image src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj4KICA8Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPgogIDxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz4KPC9zdmc+Cg==" id="_d3731866-1a07-435a-a6c2-1acd41023a4e" mimetype="image/svg+xml" height="auto" width="auto"/>
              </figure>
            </foreword>
          </preface>
        </iso-standard>
      INPUT
      expect do
        IsoDoc::PresentationXMLConvert.new({})
          .convert("test", input, true)
      end.to raise_error("Inkscape missing in PATH, unable" \
                         "to convert EMF to SVG. Aborting.")
    end
  end

  it "processes examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <example id="samplecode" keep-with-next="true" keep-lines-together="true">
          <name>Title</name>
        <p>Hello</p>
        <sourcecode id="X">
        <name>Sample</name>
        </sourcecode>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
            <example id='samplecode' keep-with-next='true' keep-lines-together='true'>
              <name>EXAMPLE&#xA0;&#x2014; Title</name>
              <p>Hello</p>
              <sourcecode id='X'>
                <name>Sample</name>
              </sourcecode>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                       <div>
                         <h1 class="ForewordTitle">Foreword</h1>
                         <div id="samplecode" class="example" style="page-break-after: avoid;page-break-inside: avoid;">
                         <p class="example-title">EXAMPLE&#160;&#8212; Title</p>
                 <p>Hello</p>
                 <pre id='X' class='prettyprint '>
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;
             </pre>
          <p class='SourceTitle' style='text-align:center;'>Sample</p>
                         </div>
                       </div>
                       <p class="zzSTDTitle1"/>
                     </div>
                   </body>
               </html>
    OUTPUT
    doc = <<~OUTPUT
          <html  xmlns:epub='http://www.idpf.org/2007/ops' lang='en'><head><style>
              </style>
        </head>
        <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='samplecode' class='example' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class='example-title'>EXAMPLE&#160;&#8212; Title</p>
                <p>Hello</p>
                <p id='X' class='Sourcecode'>
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;
          </p>
                <p class='SourceTitle' style='text-align:center;'>Sample</p>
              </div>
            </div>
            <p>&#160;</p>
          </div>
          <p>
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes sequences of examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <example id="samplecode">
        <p>Hello</p>
      </example>
          <example id="samplecode2">
          <name>Title</name>
        <p>Hello</p>
      </example>
          <example id="samplecode3" unnumbered="true">
        <p>Hello</p>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
            <example id='samplecode'>
              <name>EXAMPLE 1</name>
              <p>Hello</p>
            </example>
            <example id='samplecode2'>
              <name>EXAMPLE 2&#xA0;&#x2014; Title</name>
              <p>Hello</p>
            </example>
            <example id='samplecode3' unnumbered='true'>
              <name>EXAMPLE</name>
              <p>Hello</p>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes sourcecode" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <sourcecode lang="ruby" id="samplecode">
          <name>Ruby <em>code</em></name>
        puts x
      </sourcecode>
      <sourcecode unnumbered="true">
      Que?
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
            <sourcecode lang='ruby' id='samplecode'>
              <name>
                Figure 1&#xA0;&#x2014; Ruby
                <em>code</em>
              </name>
               puts x
            </sourcecode>
            <sourcecode unnumbered='true'> Que? </sourcecode>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                         <br/>
                         <div>
                           <h1 class="ForewordTitle">Foreword</h1>
                           <pre id="samplecode" class="prettyprint lang-rb"><br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160; <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; puts x<br/>&#160;&#160;&#160;&#160;&#160;</pre>
                           <p class="SourceTitle" style="text-align:center;">Figure 1&#160;&#8212; Ruby <i>code</i></p>
                           <pre class='prettyprint '> Que? </pre>
                         </div>
                         <p class="zzSTDTitle1"/>
                       </div>
                     </body>
                 </html>
    OUTPUT

    doc = <<~OUTPUT
         <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
              <head><style/></head>
              <body lang="EN-US" link="blue" vlink="#954F72">
                <div class="WordSection1">
                  <p>&#160;</p>
                </div>
                <p>
                  <br clear="all" class="section"/>
                </p>
                <div class="WordSection2">
                  <p>
                    <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                  </p>
                    <div>
                      <h1 class="ForewordTitle">Foreword</h1>
                      <p id="samplecode" class="Sourcecode"><br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160; <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; puts x<br/>&#160;&#160;&#160;&#160;&#160; </p><p class="SourceTitle" style="text-align:center;">Figure 1&#160;&#8212; Ruby <i>code</i></p>
                      <p class='Sourcecode'> Que? </p>
                    </div>
                       <p>&#160;</p>
      </div>
      <p>
        <br clear="all" class="section"/>
      </p>
      <div class="WordSection3">
                    <p class="zzSTDTitle1"/>
                  </div>
                </body>
            </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes sourcecode with escapes preserved" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <sourcecode id="samplecode">
          <name>XML code</name>
        &lt;xml&gt;
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <pre id="samplecode" class="prettyprint "><br/>&#160;&#160;&#160; <br/>&#160; &lt;xml&gt;<br/></pre>
                    <p class="SourceTitle" style="text-align:center;">XML code</p>
                  </div>
                  <p class="zzSTDTitle1"/>
                </div>
              </body>
          </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes sourcecode with annotations" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <sourcecode id="_">puts "Hello, world." <callout target="A">1</callout>
         %w{a b c}.each do |x|
           puts x <callout target="B">2</callout>
         end<annotation id="A">
           <p id="_">This is <em>one</em> callout</p>
         </annotation><annotation id="B">
           <p id="_">This is another callout</p>
         </annotation></sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <pre id="_" class="prettyprint ">puts "Hello, world."  &lt;1&gt;<br/>&#160;&#160; %w{a b c}.each do |x|<br/>&#160;&#160;&#160;&#160; puts x  &lt;2&gt;<br/>&#160;&#160; end<br/><br/>&lt;1&gt; This is one callout<br/>&lt;2&gt; This is another callout</pre>
                  </div>
                  <p class="zzSTDTitle1"/>
                </div>
              </body>
          </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
          <preface><foreword displayorder="1">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution" keep-with-next="true" keep-lines-together="true">
          <name>CAUTION</name>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6b" type="caution" keep-with-next="true" keep-lines-together="true" notag="true">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
      <br/>
        <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <div class="Admonition" id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' style='page-break-after: avoid;page-break-inside: avoid;'><p class="AdmonitionTitle" style="text-align:center;">CAUTION</p>
        <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        </div>
        <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6b' class='Admonition' style='page-break-after: avoid;page-break-inside: avoid;'>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        </div>
        </div>
        <p class="zzSTDTitle1"/>
        </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes admonitions with titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
          <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
          <preface><foreword displayorder="1">
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
    output = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div class="Admonition" id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a">
                             <p class='AdmonitionTitle' style='text-align:center;'>Title</p>
         <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </div>
       <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6b' class='Admonition'>
         <p class='AdmonitionTitle' style='text-align:center;'>Title</p>
            <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
          </div>
                  </div>
                  <p class="zzSTDTitle1"/>
                </div>
              </body>
          </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes formulae" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true"  keep-with-next="true" keep-lines-together="true">
        <stem type="AsciiMath">r = 1 %</stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
        <dt>
          <stem type="AsciiMath">r</stem>
        </dt>
        <dd>
          <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
        </dd>
      </dl>
          <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
        <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml"  type='presentation'>
          <preface><foreword displayorder="1">
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true"  keep-with-next="true" keep-lines-together="true">
        <stem type="AsciiMath">r = 1 %</stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
        <dt>
          <stem type="AsciiMath">r</stem>
        </dt>
        <dd>
          <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
        </dd>
      </dl>
          <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
          <name>NOTE</name>
        <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935"><name>1</name>
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" style='page-break-after: avoid;page-break-inside: avoid;'><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div><p style='page-break-after:avoid;'>where</p><dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d" class="formula_dl"><dt>
              <span class="stem">(#(r)#)</span>
            </dt><dd>
              <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
            </dd></dl>


              <div id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0" class="Note"><p><span class="note_label">NOTE</span>&#160; [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div></div>

                    <div id="_be9158af-7e93-4ee2-90c5-26d31c181935"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div></div>
                    </div>
                  <p class="zzSTDTitle1"/>
                </div>
              </body>
          </html>
    OUTPUT

    word = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
           <head>
             <style>
             </style>
           </head>
           <body lang='EN-US' link='blue' vlink='#954F72'>
             <div class='WordSection1'>
               <p>&#160;</p>
             </div>
             <p>
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection2'>
               <p>
                 <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
               </p>
               <div>
                 <h1 class='ForewordTitle'>Foreword</h1>
                 <div id='_be9158af-7e93-4ee2-90c5-26d31c181934' style='page-break-after: avoid;page-break-inside: avoid;'><div class='formula'>
                   <p>
                     <span class='stem'>(#(r = 1 %)#)</span>
                     <span style='mso-tab-count:1'>&#160; </span>
                   </p>
                 </div>
                 <p>where</p>
                 <table class='formula_dl'>
                   <tr>
                     <td valign='top' align='left'>
                       <p align='left' style='margin-left:0pt;text-align:left;'>
                         <span class='stem'>(#(r)#)</span>
                       </p>
                     </td>
                     <td valign='top'>
                       <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
                     </td>
                   </tr>
                 </table>
                 <div id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0' class='Note'>
                   <p class='Note'>
                     <span class='note_label'>NOTE</span>
                     <span style='mso-tab-count:1'>&#160; </span>
                     [durationUnits] is essentially a duration statement without the "P"
                     prefix. "P" is unnecessary because between "G" and "U" duration is
                     always expressed.
                   </p>
                 </div>
                 </div>
                 <div id='_be9158af-7e93-4ee2-90c5-26d31c181935'><div class='formula'>
                   <p>
                     <span class='stem'>(#(r = 1 %)#)</span>
                     <span style='mso-tab-count:1'>&#160; </span>
                     (1)
                   </p>
                   </div>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <p>
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection3'>
               <p class='zzSTDTitle1'/>
             </div>
           </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(word)
  end

  it "processes paragraph attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8">Vache Equipment<br/>
      Fictitious<br/>
      World</p>
          <p align="justify" keep-with-next="true" keep-lines-together="true">Justify</p>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <p id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" style="text-align:left;">Vache Equipment<br/>
          Fictitious<br/>
          World
              </p>
              <p style="text-align:justify;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
                  </div>
                  <p class="zzSTDTitle1"/>
                </div>
              </body>
          </html>
    OUTPUT

    word = <<~OUTPUT
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head><style/></head>
          <body lang="EN-US" link="blue" vlink="#954F72">
            <div class="WordSection1">
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection2">
              <p><br  clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" align="left" style="text-align:left;">Vache Equipment<br/>
      Fictitious<br/>
      World
          </p>
          <p style="text-align:justify;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
              </div>
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection3">
              <p class="zzSTDTitle1"/>
            </div>
          </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(word)
  end

  it "processes blockquotes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <quote id="_044bd364-c832-4b78-8fea-92242402a1d1">
        <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality></source>
        <author>ISO</author>
        <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      </quote>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml"  type='presentation'>
          <preface><foreword displayorder="1">
          <quote id="_044bd364-c832-4b78-8fea-92242402a1d1">
        <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality>ISO 7301:2011, Clause 1</source>
        <author>ISO</author>
        <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      </quote>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div class="Quote" id="_044bd364-c832-4b78-8fea-92242402a1d1">


        <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<i>Oryza sativa</i> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      <p class="QuoteAttribution">&#8212; ISO, ISO 7301:2011, Clause 1</p></div>
              </div>
              <p class="zzSTDTitle1"/>
            </div>
          </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes term domains" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms>
          <term id="_extraneous_matter"><name>1.1.</name><preferred>extraneous matter</preferred><admitted>EM</admitted>
      <domain>rice</domain>
      <definition><p id="_318b3939-be09-46c4-a284-93f9826b981e">organic and inorganic components other than whole or broken kernels</p></definition>
      </term>
          </terms>
          </sections>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                     <p class="zzSTDTitle1"/>
                     <div><h1/>
             <p class="TermNum" id="_extraneous_matter">1.1.</p><p class="Terms" style="text-align:left;">extraneous matter</p><p class="AltTerms" style="text-align:left;">EM</p>

             <p id="_318b3939-be09-46c4-a284-93f9826b981e">&lt;rice&gt; organic and inorganic components other than whole or broken kernels</p>
             </div>
                   </div>
                 </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes permissions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <permission id="_"   keep-with-next="true" keep-lines-together="true" model="default">
        <label>/ogc/recommendation/wfs/2</label>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit><eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></inherit>
        <subject>user</subject>
        <subject>non-user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </permission>
          </foreword></preface>
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="2">
      <title>Bibliography</title>
      <bibitem id="rfc2616" type="standard">  <fetched>2020-03-27</fetched>  <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title>  <uri type="xml">https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri>  <uri type="src">https://www.rfc-editor.org/info/rfc2616</uri>  <docidentifier type="IETF">RFC 2616</docidentifier>  <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier>  <docidentifier type="DOI">10.17487/RFC2616</docidentifier>  <date type="published">    <on>1999-06</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">R. Fielding</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Gettys</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Mogul</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">H. Frystyk</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">L. Masinter</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">P. Leach</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">T. Berners-Lee</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>  <series type="main">    <title format="text/plain" language="en" script="Latn">RFC</title>    <number>2616</number>  </series>  <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <permission id="_" keep-with-next="true" keep-lines-together="true" model="default"><name>Permission 1:<br/>/ogc/recommendation/wfs/2</name><p><em>Subject: user</em><br/>
      <em>Subject: non-user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em><br/>
      <em>Inherits: <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></em><br/>
      <em>Control-class: Technical</em><br/>
      <em>Priority: P0</em><br/>
      <em>Family: System and Communications Protection</em><br/>
      <em>Family: System and Communications Protocols</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></permission>
          </foreword></preface>
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="2">
      <title depth="1">Bibliography</title>
      <bibitem id="rfc2616" type="standard"><formattedref>R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE. <em>Hypertext Transfer Protocol&#x2009;&#x2014;&#x2009;HTTP/1.1</em>. In: RFC. June 1999. Fremont, CA. <link target="https://www.rfc-editor.org/info/rfc2616">https://www.rfc-editor.org/info/rfc2616</link>.</formattedref><uri type="xml">https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri><uri type="src">https://www.rfc-editor.org/info/rfc2616</uri><docidentifier type="metanorma-ordinal">[1]</docidentifier><docidentifier type="IETF">IETF RFC 2616</docidentifier><docidentifier type="IETF" scope="anchor">IETF RFC2616</docidentifier><docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier></bibitem>
      </references></bibliography>
          </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div class="permission" id='_' style='page-break-after: avoid;page-break-inside: avoid;'>
                    <p class="RecommendationTitle">Permission 1:<br/>/ogc/recommendation/wfs/2</p>
                    <p><i>Subject: user</i><br/>
                    <i>Subject: non-user</i><br/>
            <i>Inherits: /ss/584/2015/level/1</i><br/>
            <i>Inherits: <a href='#rfc2616'>RFC 2616 (HTTP/1.1)</a></i><br/>
            <i>Control-class: Technical</i><br/>
            <i>Priority: P0</i><br/>
            <i>Family: System and Communications Protection</i><br/>
            <i>Family: System and Communications Protocols</i></p>
              <div class="requirement-description">
                <p id="_">I recommend <i>this</i>.</p>
              </div>
              <div class="requirement-description">
                <p id="_">As for the measurement targets,</p>
              </div>
              <div class="requirement-measurement-target">
                <p id="_">The measurement target shall be measured as:</p>
                <div id="_"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div></div>
              </div>
              <div class="requirement-verification">
                <p id="_">The following code will be run for verification:</p>
                <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
              </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
            </div>
                  </div>
                  <p class="zzSTDTitle1"/>
                   <br/>
             <div>
               <h1 class='Section3'>Bibliography</h1>
               <p id='rfc2616' class='Biblio'>
                 [1]&#160; IETF RFC 2616, R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE.#{' '}
                 <i>Hypertext Transfer Protocol&#8201;&#8212;&#8201;HTTP/1.1</i>
                 . In: RFC. June 1999. Fremont, CA.
                <a href='https://www.rfc-editor.org/info/rfc2616'>https://www.rfc-editor.org/info/rfc2616</a>.
               </p>
             </div>
                </div>
              </body>
            </html>
    OUTPUT
    expect((IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes requirements" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <requirement id="A" unnumbered="true"  keep-with-next="true" keep-lines-together="true" model="default">
        <title>A New Requirement</title>
        <label>/ogc/recommendation/wfs/2</label>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false"  keep-with-next="true" keep-lines-together="true">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </requirement>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <requirement id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default"><name>Requirement:<br/>/ogc/recommendation/wfs/2. A New Requirement</name><p><em>Subject: user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" keep-with-next="true" keep-lines-together="true" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></requirement>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                        <br/>
                      <div>
                        <h1 class="ForewordTitle">Foreword</h1>
                        <div class="require" id='A' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class="RecommendationTitle">Requirement:<br/>/ogc/recommendation/wfs/2. A New Requirement</p><p><i>Subject: user</i><br/><i>Inherits: /ss/584/2015/level/1</i></p>
                  <div class="requirement-description">
                    <p id="_">I recommend <i>this</i>.</p>
                  </div>
                  <div class="requirement-description">
                    <p id="_">As for the measurement targets,</p>
                  </div>
                  <div class="requirement-measurement-target"  style='page-break-after: avoid;page-break-inside: avoid;'>
                    <p id="_">The measurement target shall be measured as:</p>
                    <div id="B"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span> &#160; (1)</p></div></div>
                  </div>
                  <div class="requirement-verification">
                    <p id="_">The following code will be run for verification:</p>
                    <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                      <p class="zzSTDTitle1"/>
                    </div>
                  </body>
                </html>
    OUTPUT
    expect((IsoDoc::PresentationXMLConvert.new({})
  .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes requirements in French" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          <script>Latn</script>
          </bibdata>
          <preface><foreword>
          <requirement id="A" unnumbered="true" model="default">
        <title>A New Requirement</title>
        <label>/ogc/recommendation/wfs/2</label>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </requirement>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
          <language current="true">fr</language>
          <script current="true">Latn</script>
          </bibdata>
          <preface><foreword displayorder="1">
          <requirement id="A" unnumbered="true" model="default"><name>Exigence:<br/>/ogc/recommendation/wfs/2. A New Requirement</name><p><em>Sujet: user</em><br/>
      <em>H&#xE9;rite: /ss/584/2015/level/1</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
        if (success)
        recommendation(label: success-response)
       end
       </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></requirement>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"fr"')}
                       <br/>
                       <div>
                         <h1 class='ForewordTitle'>Avant-propos</h1>
                         <div class='require' id="A">
                           <p class='RecommendationTitle'>
                             Exigence:
                             <br/>
                             /ogc/recommendation/wfs/2. A New Requirement
                           </p>
                           <p>
                             <i>Sujet: user</i><br/>
                               <i>H&#233;rite: /ss/584/2015/level/1</i>
                           </p>
                           <div class='requirement-description'>
                             <p id='_'>
                               I recommend
                               <i>this</i>
                               .
                             </p>
                           </div>
                           <div class='requirement-description'>
                             <p id='_'>As for the measurement targets,</p>
                           </div>
                           <div class='requirement-measurement-target'>
                             <p id='_'>The measurement target shall be measured as:</p>
                             <div id='B'><div class='formula'>
                               <p>
                                 <span class='stem'>(#(r/1 = 0)#)</span>
                                 &#160; (1)
                               </p>
                               </div>
                             </div>
                           </div>
                           <div class='requirement-verification'>
                             <p id='_'>The following code will be run for verification:</p>
                             <pre id='_' class='prettyprint '>
                               CoreRoot(success): HttpResponse
                               <br/>
                               &#160; if (success)
                               <br/>
                               &#160; recommendation(label: success-response)
                               <br/>
                               &#160;end
                               <br/>
                               &#160;
                             </pre>
                           </div>
                          <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                         </div>
                       </div>
                       <p class='zzSTDTitle1'/>
                     </div>
                   </body>
                 </html>
    OUTPUT
    expect(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes recommendation" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <recommendation id="_" obligation="shall,could"   keep-with-next="true" keep-lines-together="true" model="default">
        <label>/ogc/recommendation/wfs/2</label>
        <inherit>/ss/584/2015/level/1</inherit>
        <classification><tag>type</tag><value>text</value></classification>
        <classification><tag>language</tag><value>BASIC</value></classification>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </recommendation>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <recommendation id="_" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default"><name>Recommendation 1:<br/>/ogc/recommendation/wfs/2</name><p><em>Obligation: shall,could</em><br/>
      <em>Subject: user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em><br/>
      <em>Type: text</em><br/>
      <em>Language: BASIC</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></recommendation>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                      <div>
                        <h1 class="ForewordTitle">Foreword</h1>
                <div class="recommend"  id='_' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class="RecommendationTitle">Recommendation 1:<br/>/ogc/recommendation/wfs/2</p><p><i>Obligation: shall,could</i><br/><i>Subject: user</i><br/><i>Inherits: /ss/584/2015/level/1</i><br/><i>Type: text</i><br/><i>Language: BASIC</i></p>
                  <div class="requirement-description">
                    <p id="_">I recommend <i>this</i>.</p>
                  </div>
                  <div class="requirement-description">
                    <p id="_">As for the measurement targets,</p>
                  </div>
                  <div class="requirement-measurement-target">
                    <p id="_">The measurement target shall be measured as:</p>
                    <div id="_"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div></div>
                  </div>
                  <div class="requirement-verification">
                    <p id="_">The following code will be run for verification:</p>
                    <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
                          <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                      <p class="zzSTDTitle1"/>
                    </div>
                  </body>
                </html>
    OUTPUT
    expect((IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes pseudocode" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
              <preface><foreword>
        <figure id="_" class="pseudocode" keep-with-next="true" keep-lines-together="true"><name>Label</name><p id="_">  <strong>A</strong><br/>
              <smallcap>B</smallcap></p>
      <p id="_">  <em>C</em></p></figure>
      </preface></itu-standard>
    INPUT

    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
          <language current="true">en</language>
          </bibdata>
              <preface><foreword displayorder="1">
        <figure id="_" class="pseudocode" keep-with-next="true" keep-lines-together="true"><name>Figure 1&#xA0;&#x2014; Label</name><p id="_">&#xA0;&#xA0;<strong>A</strong><br/>
      &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;<smallcap>B</smallcap></p>
      <p id="_">&#xA0;&#xA0;<em>C</em></p></figure>
      </foreword></preface>
      </itu-standard>

    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                       <div>
                         <h1 class="ForewordTitle">Foreword</h1>
                         <div id="_" class="pseudocode" style='page-break-after: avoid;page-break-inside: avoid;'><p id="_">&#160;&#160;<b>A</b><br/>
                 &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<span style="font-variant:small-caps;">B</span></p>
                 <p id="_">&#160;&#160;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
                       </div>
                       <p class="zzSTDTitle1"/>
                     </div>
                   </body>
          </html>
    OUTPUT

    FileUtils.rm_f "test.doc"
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    IsoDoc::WordConvert.new({}).convert("test", presxml, false)
    expect(xmlpp(File.read("test.doc")
      .gsub(%r{^.*<h1 class="ForewordTitle">Foreword</h1>}m, "")
      .gsub(%r{</div>.*}m, "</div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
             <div class="pseudocode"  style='page-break-after: avoid;page-break-inside: avoid;'><a name="_" id="_"></a><p class="pseudocode"><a name="_" id="_"></a>&#xA0;&#xA0;<b>A</b><br/>
        &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;<span style="font-variant:small-caps;">B</span></p>
        <p class="pseudocode" style="page-break-after:avoid;"><a name="_" id="_"></a>&#xA0;&#xA0;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
      OUTPUT
  end

  it "does not label embedded figures, sourcecode" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
              <preface><foreword>
              <example>
              <sourcecode id="B"><name>Label</name>A B C</sourcecode>
        <figure id="A" class="pseudocode"><name>Label</name><p id="_">  <strong>A</strong></p></figure>
              <sourcecode id="B1">A B C</sourcecode>
        <figure id="A1" class="pseudocode"><p id="_">  <strong>A</strong></p></figure>
      </example>
      </preface></itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
            <h1 class='ForewordTitle'>Foreword</h1>
                     <div class='example'>
                       <pre id='B' class='prettyprint '>
                         A B C
                       </pre>
                         <p class='SourceTitle' style='text-align:center;'>Label</p>
                       <div id='A' class='pseudocode'>
                         <p id='_'>
                           &#160;&#160;
                           <b>A</b>
                         </p>
                         <p class='SourceTitle' style='text-align:center;'>Label</p>
                       </div>
                       <pre id='B1' class='prettyprint '>A B C</pre>
                       <div id='A1' class='pseudocode'>
                         <p id='_'>
                           &#160;&#160;
                           <b>A</b>
                         </p>
                       </div>
                     </div>
                   </div>
                   <p class='zzSTDTitle1'/>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes passthrough with compatible format" do
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <passthrough format="html,rfc">&lt;A&gt;</passthrough><em>Hello</em><passthrough format="html,rfc">&lt;/A&gt;</passthrough>
      </foreword></preface>
      </iso-standard>
    INPUT
    expect((File.read("test.html")
      .gsub(%r{^.*<h1 class="ForewordTitle">Foreword</h1>}m, "")
      .gsub(%r{</div>.*}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <A><i>Hello</i></A>
      OUTPUT
  end

  it "aborts if passthrough results in malformed XML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.html.err"
    begin
      input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
        <passthrough format="html,rfc">&lt;A&gt;</passthrough><em>Hello</em>
        </foreword></preface>
        </iso-standard>
      INPUT
      expect do
        IsoDoc::HtmlConvert.new({})
          .convert("test", input, false)
      end.to raise_error(SystemExit)
    rescue SystemExit
    end
    expect(File.exist?("test.html.err")).to be true
  end

  it "ignores passthrough with incompatible format" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <passthrough format="doc,rfc">&lt;A&gt;</passthrough>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div>
                  <h1 class='ForewordTitle'>Foreword</h1>
                </div>
                <p class='zzSTDTitle1'/>
              </div>
            </body>
          </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
     .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes svgmap" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
        <svgmap id='_'>
          <target href='http://www.example.com'>
            <xref target='ref1'>Computer</xref>
          </target>
        </svgmap>
        <figure id='_'>
        <image src='action_schemaexpg1.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto'/>
      </figure>
      <svgmap id='_'>
        <figure id='_'>
          <image src='action_schemaexpg2.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto' alt='Workmap'/>
        </figure>
          <target href='mn://support_resource_schema'>
            <eref bibitemid='express_action_schema' citeas=''>
              <localityStack>
                <locality type='anchor'>
                  <referenceFrom>action_schema.basic</referenceFrom>
                </locality>
              </localityStack>
              Coffee
            </eref>
          </target>
        </svgmap>
      </sections>
      <bibliography>
        <references hidden='true' normative='false'>
          <bibitem id='express_action_schema' type='internal'>
            <docidentifier type='repository'>express/action_schema</docidentifier>
          </bibitem>
        </references>
      </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
               <sections>
                 <figure id='_'>
                   <image src='action_schemaexpg1.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto'>
                      <emf src='./action_schemaexpg1.emf'/>
                    </image>
                 </figure>
                 <figure id='_'>
                   <image src='action_schemaexpg2.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto' alt='Workmap'>
                      <emf src='./action_schemaexpg2.emf'/>
                    </image>
                 </figure>
               </sections>
               <bibliography>
                 <references hidden='true' normative='false' displayorder="1">
                   <bibitem id='express_action_schema' type='internal'>
                     <docidentifier type='repository'>express/action_schema</docidentifier>
                   </bibitem>
                 </references>
               </bibliography>
             </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"\.\\}, '"./')
      .gsub(%r{'\.\\}, "'./"))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes toc" do
    input = <<~INPUT
          <standard-document xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='1.10.2'>
        <bibdata type='standard'>
          <title language='en' format='text/plain'>Document title</title>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>published</stage>
          </status>
          <copyright>
            <from>2021</from>
          </copyright>
          <ext>
            <doctype>article</doctype>
          </ext>
        </bibdata>
        <sections>
          <clause id='clause1' inline-header='false' obligation='normative'>
            <title>Clause 1</title>
            <clause id='clause1A' inline-header='false' obligation='normative'>
              <title>Clause 1A</title>
              <clause id='clause1Aa' inline-header='false' obligation='normative'>
                <title>Clause 1Aa</title>
              </clause>
              <clause id='clause1Ab' inline-header='false' obligation='normative'>
                <title>Clause 1Ab</title>
              </clause>
            </clause>
            <clause id='clause1B' inline-header='false' obligation='normative'>
              <title>Clause 1B</title>
              <clause id='clause1Ba' inline-header='false' obligation='normative'>
                <title>Clause 1Ba</title>
              </clause>
            </clause>
          </clause>
          <clause id='clause2' inline-header='false' obligation='normative'>
            <title>Clause 2</title>
            <p id='A'>And introducing: </p>
            <toc>
              <ul id='B'>
                <li>
                  <xref target='clause1A'>Clause 1A</xref>
                </li>
                <li>
                  <ul id='C'>
                    <li>
                      <xref target='clause1Aa'>Clause 1Aa</xref>
                    </li>
                    <li>
                      <xref target='clause1Ab'>Clause 1Ab</xref>
                    </li>
                  </ul>
                </li>
                <li>
                  <xref target='clause1B'>Clause 1B</xref>
                </li>
                <li>
                  <ul id='D'>
                    <li>
                      <xref target='clause1Ba'>Clause 1Ba</xref>
                    </li>
                  </ul>
                </li>
              </ul>
            </toc>
            <toc>
              <ul id='E'>
                <li>
                  <xref target='clause1A'>Clause 1A</xref>
                </li>
                <li>
                  <xref target='clause1B'>Clause 1B</xref>
                </li>
              </ul>
            </toc>
          </clause>
        </sections>
      </standard-document>
    INPUT
    presxml = <<~INPUT
          <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation" version="1.10.2">
        <bibdata type="standard">
          <title language="en" format="text/plain">Document title</title>
          <language current="true">en</language>
          <script current="true">Latn</script>
          <status>
            <stage>published</stage>
          </status>
          <copyright>
            <from>2021</from>
          </copyright>
          <ext>
            <doctype>article</doctype>
          </ext>
        </bibdata>
        <sections>
          <clause id="clause1" inline-header="false" obligation="normative" displayorder="1">
            <title depth="1">1.<tab/>Clause 1</title>
            <clause id="clause1A" inline-header="false" obligation="normative">
              <title depth="2">1.1.<tab/>Clause 1A</title>
              <clause id="clause1Aa" inline-header="false" obligation="normative">
                <title depth="3">1.1.1.<tab/>Clause 1Aa</title>
              </clause>
              <clause id="clause1Ab" inline-header="false" obligation="normative">
                <title depth="3">1.1.2.<tab/>Clause 1Ab</title>
              </clause>
            </clause>
            <clause id="clause1B" inline-header="false" obligation="normative">
              <title depth="2">1.2.<tab/>Clause 1B</title>
              <clause id="clause1Ba" inline-header="false" obligation="normative">
                <title depth="3">1.2.1.<tab/>Clause 1Ba</title>
              </clause>
            </clause>
          </clause>
          <clause id="clause2" inline-header="false" obligation="normative" displayorder="2">
            <title depth="1">2.<tab/>Clause 2</title>
            <p id="A">And introducing: </p>
            <toc>
              <ul id="B">
                <li>
                  <xref target="clause1A">1.1<tab/>Clause 1A</xref>
                </li>
                <li>
                  <ul id="C">
                    <li>
                      <xref target="clause1Aa">1.1.1<tab/>Clause 1Aa</xref>
                    </li>
                    <li>
                      <xref target="clause1Ab">1.1.2<tab/>Clause 1Ab</xref>
                    </li>
                  </ul>
                </li>
                <li>
                  <xref target="clause1B">1.2<tab/>Clause 1B</xref>
                </li>
                <li>
                  <ul id="D">
                    <li>
                      <xref target="clause1Ba">1.2.1<tab/>Clause 1Ba</xref>
                    </li>
                  </ul>
                </li>
              </ul>
            </toc>
            <toc>
              <ul id="E">
                <li>
                  <xref target="clause1A">1.1<tab/>Clause 1A</xref>
                </li>
                <li>
                  <xref target="clause1B">1.2<tab/>Clause 1B</xref>
                </li>
              </ul>
            </toc>
          </clause>
        </sections>
      </standard-document>
    INPUT
    output = <<~OUTPUT
        #{HTML_HDR}
                     <p class='zzSTDTitle1'>Document title</p>
            <div id='clause1'>
              <h1>1.&#160; Clause 1</h1>
              <div id='clause1A'>
                <h2>1.1.&#160; Clause 1A</h2>
                <div id='clause1Aa'>
                  <h3>1.1.1.&#160; Clause 1Aa</h3>
                </div>
                <div id='clause1Ab'>
                  <h3>1.1.2.&#160; Clause 1Ab</h3>
                </div>
              </div>
              <div id='clause1B'>
                <h2>1.2.&#160; Clause 1B</h2>
                <div id='clause1Ba'>
                  <h3>1.2.1.&#160; Clause 1Ba</h3>
                </div>
              </div>
            </div>
            <div id='clause2'>
              <h1>2.&#160; Clause 2</h1>
              <p id='A'>And introducing: </p>
              <div class='toc'>
                <ul id='B'>
                  <li>
                    <a href='#clause1A'>1.1&#160; Clause 1A</a>
                  </li>
                  <li>
                    <ul id='C'>
                      <li>
                        <a href='#clause1Aa'>1.1.1&#160; Clause 1Aa</a>
                      </li>
                      <li>
                        <a href='#clause1Ab'>1.1.2&#160; Clause 1Ab</a>
                      </li>
                    </ul>
                  </li>
                  <li>
                    <a href='#clause1B'>1.2&#160; Clause 1B</a>
                  </li>
                  <li>
                    <ul id='D'>
                      <li>
                        <a href='#clause1Ba'>1.2.1&#160; Clause 1Ba</a>
                      </li>
                    </ul>
                  </li>
                </ul>
              </div>
              <div class='toc'>
                <ul id='E'>
                  <li>
                    <a href='#clause1A'>1.1&#160; Clause 1A</a>
                  </li>
                  <li>
                    <a href='#clause1B'>1.2&#160; Clause 1B</a>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
     .convert("test", input, true)
     .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end
end
