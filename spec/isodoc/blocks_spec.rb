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
              <preface>
              <clause type="toc" id="_" displayorder="1">
                <title depth="1">Table of contents</title>
              </clause>
              </preface>
              <sections>
              <p class="zzSTDTitle1" displayorder="2">Document title</p>
                <clause id="A" inline-header="false" obligation="normative" displayorder="3">
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
                   <br/>
      <div class="TOC" id="_">
        <h1 class="IntroTitle">Table of contents</h1>
      </div>
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
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
             <clause type="toc" id="_" displayorder="1">
              <title depth="1">Table of contents</title>
            </clause>
          <foreword displayorder="2">
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
                 <pre id='X' class='sourcecode'>
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
          <br/>
          &#160;&#160;&#160;&#160;&#160;&#160;&#160;
             </pre>
          <p class='SourceTitle' style='text-align:center;'>Sample</p>
                         </div>
                       </div>
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
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
                  <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
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
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
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
             <clause type="toc" id="_" displayorder="1">
              <title depth="1">Table of contents</title>
            </clause>
          <foreword displayorder="2">
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(output)
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
          <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
          <foreword displayorder="2">
          <formula id="_" unnumbered="true"  keep-with-next="true" keep-lines-together="true">
        <stem type="AsciiMath">r = 1 %</stem>
        <p keep-with-next="true">where</p>
      <dl id="_" class="formula_dl">
        <dt>
          <stem type="AsciiMath">r</stem>
        </dt>
        <dd>
          <p id="_">is the repeatability limit.</p>
        </dd>
      </dl>
          <note id="_">
          <name>NOTE</name>
        <p id="_">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_"><name>1</name>
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
                    <div id="_" style='page-break-after: avoid;page-break-inside: avoid;'><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div><p style='page-break-after: avoid;'>where</p><dl id="_" class="formula_dl"><dt>
              <span class="stem">(#(r)#)</span>
            </dt><dd>
              <p id="_">is the repeatability limit.</p>
            </dd></dl>


              <div id="_" class="Note"><p><span class="note_label">NOTE</span>&#160; [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div></div>

                    <div id="_"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div></div>
                    </div>
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
             <p class="section-break">
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection2'>
               <p class="page-break">
                 <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
               </p>
                     <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
               <div>
                 <h1 class='ForewordTitle'>Foreword</h1>
                 <div id='_' style='page-break-after: avoid;page-break-inside: avoid;'><div class='formula'>
                   <p>
                     <span class='stem'>(#(r = 1 %)#)</span>
                     <span style='mso-tab-count:1'>&#160; </span>
                   </p>
                 </div>
                 <p style="page-break-after: avoid;">where</p>
                 <table id="_" class='formula_dl'>
                   <tr>
                     <td valign='top' align='left'>
                       <p align='left' style='margin-left:0pt;text-align:left;'>
                         <span class='stem'>(#(r)#)</span>
                       </p>
                     </td>
                     <td valign='top'>
                       <p id='_'>is the repeatability limit.</p>
                     </td>
                   </tr>
                 </table>
                 <div id='_' class='Note'>
                   <p class='Note'>
                     <span class='note_label'>NOTE</span>
                     <span style='mso-tab-count:1'>&#160; </span>
                     [durationUnits] is essentially a duration statement without the "P"
                     prefix. "P" is unnecessary because between "G" and "U" duration is
                     always expressed.
                   </p>
                 </div>
                 </div>
                 <div id='_'><div class='formula'>
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
             <p class="section-break">
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection3'>
             </div>
           </body>
         </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(word)
  end

  it "processes paragraph attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <clause type="toc" id="_toc" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
          <foreword displayorder="2">
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
                    <p id="_" style="text-align:left;">Vache Equipment<br/>
          Fictitious<br/>
          World
              </p>
              <p style="text-align:justify;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
                  </div>
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
            <p class="section-break"><br clear="all" class="section"/></p>
            <div class="WordSection2">
              <p class="page-break"><br  clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                    <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p id="_" align="left" style="text-align:left;">Vache Equipment<br/>
      Fictitious<br/>
      World
          </p>
          <p style="text-align:justify;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
              </div>
              <p>&#160;</p>
            </div>
            <p class="section-break"><br clear="all" class="section"/></p>
            <div class="WordSection3">
            </div>
          </body>
      </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to xmlpp(word)
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
          <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        <foreword displayorder="2">
          <quote id="_">
        <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality>ISO&#xa0;7301:2011, Clause 1</source>
        <author>ISO</author>
        <p id="_">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      </quote>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div class="Quote" id="_">


        <p id="_">This International Standard gives the minimum specifications for rice (<i>Oryza sativa</i> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      <p class="QuoteAttribution">&#8212; ISO, ISO&#xa0;7301:2011, Clause 1</p></div>
              </div>
            </div>
          </body>
      </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes term domains" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        </preface>
          <sections>
          <terms displayorder="2">
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
                     <div>
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
        <identifier>/ogc/recommendation/wfs/2</identifier>
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
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="3">
      <title>Bibliography</title>
      <bibitem id="rfc2616" type="standard">  <fetched>2020-03-27</fetched>  <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title>  <docidentifier type="IETF">RFC 2616</docidentifier>  <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier>  <docidentifier type="DOI">10.17487/RFC2616</docidentifier>  <date type="published">    <on>1999-06</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">R. Fielding</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Gettys</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Mogul</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">H. Frystyk</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">L. Masinter</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">P. Leach</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">T. Berners-Lee</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>  <series type="main">    <title format="text/plain" language="en" script="Latn">RFC</title>    <number>2616</number>  </series>  <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        <foreword displayorder="2">
          <permission id="_" keep-with-next="true" keep-lines-together="true" model="default"><name>Permission 1:<br/>/ogc/recommendation/wfs/2</name><p><em>Subject: user</em><br/>
      <em>Subject: non-user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em><br/>
      <em>Inherits: <xref type="inline" target="rfc2616">RFC 2616 (HTTP/1.1)</xref></em><br/>
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
          <bibliography><references id="_" obligation="informative" normative="false" displayorder="3">
      <title depth="1">Bibliography</title>
      <bibitem id="rfc2616" type="standard"><formattedref>R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE. <em>Hypertext Transfer Protocol&#x2009;&#x2014;&#x2009;HTTP/1.1</em>. In: RFC. 1999. Fremont, CA.</formattedref>
      <docidentifier type="metanorma-ordinal">[1]</docidentifier>
      <docidentifier type="IETF">IETF&#xa0;RFC&#xa0;2616</docidentifier>
      <docidentifier type="IETF" scope="anchor">IETF&#xa0;RFC2616</docidentifier>
      <docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier>
      <docidentifier scope="biblio-tag">IETF RFC 2616</docidentifier>
      <biblio-tag>[1]<tab/>IETF&#xa0;RFC&#xa0;2616, </biblio-tag>
      </bibitem>
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
                <pre id="_" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
              </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
            </div>
                  </div>
                   <br/>
             <div>
               <h1 class='Section3'>Bibliography</h1>
               <p id="rfc2616" class="Biblio">[1]  IETF&#xa0;RFC&#xa0;2616, R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE. <i>Hypertext Transfer Protocol — HTTP/1.1</i>. In: RFC. 1999. Fremont, CA.</p>
             </div>
                </div>
              </body>
            </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes requirements" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <requirement id="A" unnumbered="true"  keep-with-next="true" keep-lines-together="true" model="default">
        <title>A New Requirement</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
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
          <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
          <foreword displayorder="2">
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
                    <pre id="_" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes recommendation" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <recommendation id="_" obligation="shall,could"   keep-with-next="true" keep-lines-together="true" model="default">
        <identifier>/ogc/recommendation/wfs/2</identifier>
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
          <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        <foreword displayorder="2">
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
                    <pre id="_" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
                          <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes passthrough with compatible format" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <passthrough format="html,rfc">&lt;A&gt;</passthrough><em>Hello</em><passthrough format="html,rfc">&lt;/A&gt;</passthrough>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
    IsoDoc::HtmlConvert.new({}).convert("test", presxml, false)
    expect(xmlpp(File.read("test.html")
      .gsub(%r{^.*<h1 class="ForewordTitle">Foreword</h1>}m, "")
      .gsub(%r{</div>.*}m, ""))).to be_equivalent_to xmlpp(<<~OUTPUT)
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
      presxml = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
      expect do
        IsoDoc::HtmlConvert.new({})
          .convert("test", presxml, false)
      end.to raise_error(SystemExit)
    rescue SystemExit
    end
    expect(File.exist?("test.html.err")).to be true
  end

  it "ignores passthrough with incompatible format" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
          <clause type="toc" id="_toc" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        <foreword displayorder="2">
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
              </div>
            </body>
          </html>
    OUTPUT
    presxml = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
     .convert("test", presxml, true)))).to be_equivalent_to xmlpp(output)
  end

  it "ignores columnbreak" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
          <clause type="toc" id="_toc" displayorder="1">
           <title depth="1">Table of contents</title>
           <columnbreak/>
          </clause>
        <foreword displayorder="2">
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div>
                  <h1 class='ForewordTitle'>Foreword</h1>
                </div>
              </div>
            </body>
          </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
     .convert("test", input, true)))).to be_equivalent_to xmlpp(output)
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
        <preface>
          <clause type="toc" id="_" displayorder="1">
           <title depth="1">Table of contents</title>
          </clause>
        </preface>
        <sections>
        <p class="zzSTDTitle1" displayorder="2">Document title</p>
          <clause id="clause1" inline-header="false" obligation="normative" displayorder="3">
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
          <clause id="clause2" inline-header="false" obligation="normative" displayorder="4">
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
     .convert("test", input, true)
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end
end
