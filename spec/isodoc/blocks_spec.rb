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
                   <figure id="H"><name>Imago</name></figure>
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <p class="zzSTDTitle1" displayorder="2">Document title</p>
            <clause id="A" inline-header="false" obligation="normative" displayorder="3">
               <title id="_">Change Clause</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="A">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Change Clause</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </fmt-xref-label>
               <amend id="B" change="modify" path="//table[2]" path_end="//table[2]/following-sibling:example[1]" title="Change">
                  <autonumber type="table">2</autonumber>
                  <autonumber type="example">A.7</autonumber>
                  <description>
                     <p original-id="C">
                        <em>
                       This table contains information on polygon cells which are not
                       included in ISO 10303-52. Remove table 2 completely and replace
                       with:
                     </em>
                     </p>
                  </description>
                  <newcontent original-id="D">
                     <table number="2" autonum="2" original-id="E">
                        <name original-id="_">Edges of triangle and quadrilateral cells</name>
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
                     <figure unnumbered="true" original-id="H">
                        <name original-id="_">Imago</name>
                     </figure>
                     <example number="A.7" autonum="A.7" original-id="F">
                        <p original-id="G">This is not generalised further.</p>
                     </example>
                  </newcontent>
               </amend>
               <semx element="amend" source="B">
                  <p id="C">
                     <em>
                       This table contains information on polygon cells which are not
                       included in ISO 10303-52. Remove table 2 completely and replace
                       with:
                     </em>
                  </p>
                  <quote id="D">
                     <table id="E" number="2" autonum="2">
                        <name id="_">Edges of triangle and quadrilateral cells</name>
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">Table</span>
                              <semx element="autonum" source="E">2</semx>
                           </span>
                           <span class="fmt-caption-delim">\u00a0— </span>
                           <semx element="name" source="_">Edges of triangle and quadrilateral cells</semx>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Table</span>
                           <semx element="autonum" source="E">2</semx>
                        </fmt-xref-label>
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
                     <figure id="H" unnumbered="true">
                        <name id="_">Imago</name>
                        <fmt-name id="_">
                           <semx element="name" source="_">Imago</semx>
                        </fmt-name>
                     </figure>
                     <example id="F" number="A.7" autonum="A.7">
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">EXAMPLE</span>
                              <semx element="autonum" source="F">A.7</semx>
                           </span>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="F">A.7</semx>
                        </fmt-xref-label>
                        <fmt-xref-label container="A">
                           <span class="fmt-xref-container">
                              <span class="fmt-element-name">Clause</span>
                              <semx element="autonum" source="A">1</semx>
                           </span>
                           <span class="fmt-comma">,</span>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="F">A.7</semx>
                        </fmt-xref-label>
                        <p id="G">This is not generalised further.</p>
                     </example>
                  </quote>
               </semx>
            </clause>
         </sections>
      </standard-document>
    OUTPUT
    html = <<~OUTPUT
      <div id="A">
         <h1>1.\u00a0 Change Clause</h1>
         <p id="C">
            <i>
                       This table contains information on polygon cells which are not
                       included in ISO 10303-52. Remove table 2 completely and replace
                       with:
                     </i>
         </p>
         <div class="Quote" id="D">
            <p class="TableTitle" style="text-align:center;">Table 2\u00a0— Edges of triangle and quadrilateral cells</p>
            <table id="E" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
               <tbody>
                  <tr>
                     <th colspan="2" style="font-weight:bold;text-align:center;vertical-align:middle;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">triangle</th>
                     <th colspan="2" style="font-weight:bold;text-align:center;vertical-align:middle;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">quadrilateral</th>
                  </tr>
                  <tr>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">edge</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">vertices</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">edge</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">vertices</td>
                  </tr>
                  <tr>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">1</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">1, 2</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">1</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">1, 2</td>
                  </tr>
                  <tr>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">2</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">2, 3</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">2</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">2, 3</td>
                  </tr>
                  <tr>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">3</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">3, 1</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">3</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.0pt;">3, 4</td>
                  </tr>
                  <tr>
                     <td style="text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;"/>
                     <td style="text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;"/>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;">4</td>
                     <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;">4, 1</td>
                  </tr>
               </tbody>
            </table>
            <div id="H" class="figure">
               <p class="FigureTitle" style="text-align:center;">Imago</p>
            </div>
            <div id="F" class="example">
               <p class="example-title">EXAMPLE A.7</p>
               <p id="G">This is not generalised further.</p>
            </div>
         </div>
      </div>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")

    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml

    expect(strip_guid(Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)).at("//div[@id ='A']").to_html))
      .to be_html5_equivalent_to fix_whitespaces(html)
  end

  it "processes examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword id="fwd">
            <example id="samplecode" keep-with-next="true" keep-lines-together="true">
              <name>Title</name>
              <p>Hello</p>
      <sourcecode id="X">
      <name>Sample</name>
      </sourcecode>
            </example>
          </foreword>
        </preface>
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
                <example id="samplecode" keep-with-next="true" keep-lines-together="true" autonum="">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                      </span>
                      <span class="fmt-caption-delim">\u00a0— </span>
                      <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                   </fmt-xref-label>
                   <p>Hello</p>
                   <sourcecode id="X">
                      <name id="_">Sample</name>
                      <fmt-name id="_">
                         <semx element="name" source="_">Sample</semx>
                      </fmt-name>
                      <fmt-sourcecode id="_">
                    </fmt-sourcecode>
                   </sourcecode>
                </example>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
              <br/>
              <div id="fwd">
                <h1 class="ForewordTitle">Foreword</h1>
                <div id="samplecode" class="example" style="page-break-after: avoid;page-break-inside: avoid;">
                  <p class="example-title">EXAMPLE\u00a0&#8212; Title</p>
                  <p>Hello</p>
                  <pre id="X" class="sourcecode"><br/><br/></pre>
                  <p class='SourceTitle' style='text-align:center;'>Sample</p>
                </div>
              </div>
            </div>
          </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
              <p class="page-break">
           <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
            <div id="fwd">
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='samplecode' class='example' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class='example-title'>EXAMPLE\u00a0&#8212; Title</p>
                <p>Hello</p>
                      <p id="X" class="Sourcecode">
                         <br/>\u00a0
                         <br/>\u00a0
                      </p>
                <p class='SourceTitle' style='text-align:center;'>Sample</p>
              </div>
            </div>
            <p>\u00a0</p>
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
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
    expect(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html4_equivalent_to word
  end

  it "processes sequences of examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
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
                <example id="samplecode" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="samplecode">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode">1</semx>
                   </fmt-xref-label>
                   <p>Hello</p>
                </example>
                <example id="samplecode2" autonum="2">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="samplecode2">2</semx>
                      </span>
                      <span class="fmt-caption-delim">\u00a0— </span>
                      <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode2">2</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode2">2</semx>
                   </fmt-xref-label>
                   <p>Hello</p>
                </example>
                <example id="samplecode3" unnumbered="true">
                   <p>Hello</p>
                </example>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))
      .to be_xml_equivalent_to output
  end

  it "processes formulae" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
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
          <annex id="Annex">
           <formula id="AnnexFormula">
           <stem type="AsciiMath">r = 1 %</stem>
           </formula>
          </annex>
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
                <formula id="_" unnumbered="true" keep-with-next="true" keep-lines-together="true">
                   <stem type="AsciiMath" id="_">r = 1 %</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">r = 1 %</semx>
                   </fmt-stem>
                   <p keep-with-next="true">where</p>
                   <dl id="_" class="formula_dl">
                      <dt>
                         <stem type="AsciiMath" id="_">r</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">r</semx>
                         </fmt-stem>
                      </dt>
                      <dd>
                         <p id="_">is the repeatability limit.</p>
                      </dd>
                   </dl>
                   <note id="_" autonum="">
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
                      <p id="_">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
                   </note>
                </formula>
                <formula id="_" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-autonum-delim">(</span>
                         1
                         <span class="fmt-autonum-delim">)</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Formula</span>
                      <span class="fmt-autonum-delim">(</span>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </fmt-xref-label>
                   <fmt-xref-label container="fwd">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="fwd">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Formula</span>
                      <span class="fmt-autonum-delim">(</span>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </fmt-xref-label>
                   <stem type="AsciiMath" id="_">r = 1 %</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">r = 1 %</semx>
                   </fmt-stem>
                </formula>
             </foreword>
          </preface>
          <annex id="Annex" autonum="A" displayorder="3">
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Annex">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(informative)</span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="Annex">A</semx>
             </fmt-xref-label>
             <formula id="AnnexFormula" autonum="A.1">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-autonum-delim">(</span>
                      <semx element="autonum" source="Annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AnnexFormula">1</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="Annex">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexFormula">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref-label>
                <stem type="AsciiMath" id="_">r = 1 %</stem>
                <fmt-stem type="AsciiMath">
                   <semx element="stem" source="_">r = 1 %</semx>
                </fmt-stem>
             </formula>
          </annex>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div id="fwd">
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div id="_" style='page-break-after: avoid;page-break-inside: avoid;'><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div><p style='page-break-after: avoid;'>where</p>
                    <div class="figdl">
                    <dl id="_" class="formula_dl"><dt>
              <span class="stem">(#(r)#)</span>
            </dt><dd>
              <p id="_">is the repeatability limit.</p>
            </dd></dl>
            </div>


              <div id="_" class="Note"><p><span class="note_label">NOTE\u00a0 </span>[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div></div>

                    <div id="_"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span>\u00a0 (1)</p></div></div>
                    </div>
                                    <br/>
                <div id="Annex" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (informative)
                   </h1>
                   <div id="AnnexFormula">
                      <div class="formula">
                         <p>
                            <span class="stem">(#(r = 1 %)#)</span>
                            \u00a0 (A.1)
                         </p>
                      </div>
                   </div>
                </div>
                </div>
              </body>
          </html>
    OUTPUT

    word = <<~OUTPUT
       #{WORD_HDR}
       <p class="page-break">
         <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
       </p>
                <div id="fwd">
                  <h1 class='ForewordTitle'>Foreword</h1>
                  <div id='_' style='page-break-after: avoid;page-break-inside: avoid;'><div class='formula'>
                    <p>
                      <span class='stem'>(#(r = 1 %)#)</span>
                      <span style='mso-tab-count:1'>\u00a0 </span>
                    </p>
                  </div>
                  <p style="page-break-after: avoid;">where</p>
                  <div align="left">
                  <table id="_" style="text-align:left;" class="formula_dl">
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
                  </div>
                  <div id='_' class='Note'>
                    <p class='Note'>
                      <span class='note_label'>NOTE<span style='mso-tab-count:1'>\u00a0 </span></span>
                      [durationUnits] is essentially a duration statement without the "P"
                      prefix. "P" is unnecessary because between "G" and "U" duration is
                      always expressed.
                    </p>
                  </div>
                  </div>
                  <div id='_'><div class='formula'>
                    <p>
                      <span class='stem'>(#(r = 1 %)#)</span>
                      <span style='mso-tab-count:1'>\u00a0 </span>
                      (1)
                    </p>
                    </div>
                  </div>
                </div>
                <p>\u00a0</p>
              </div>
              <p class="section-break">
                <br clear='all' class='section'/>
              </p>
              <div class='WordSection3'>
                      <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
         </p>
         <div id="Annex" class="Section3">
            <h1 class="Annex">
               <b>Annex A</b>
               <br/>
               (informative)
            </h1>
            <div id="AnnexFormula">
               <div class="formula">
                  <p>
                     <span class="stem">(#(r = 1 %)#)</span>
                     <span style="mso-tab-count:1">\u00a0 </span>
                     (A.1)
                  </p>
                  </div>
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
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
    expect(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html4_equivalent_to word
  end

  it "processes paragraph attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <clause type="toc" id="_toc" displayorder="1">
          <fmt-title id="_" depth="1">Table of contents</fmt-title>
          </clause>
          <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
          <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8">Vache Equipment<br/>
      Fictitious<br/>
      World</p>
          <p align="justify" keep-with-next="true" keep-lines-together="true" style="font-size:9pt">Justify</p>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div id="_">
                    <h1 class="ForewordTitle">Foreword</h1>
                    <p id="_" style="text-align:left;">Vache Equipment<br/>
          Fictitious<br/>
          World
              </p>
              <p style="text-align:justify;font-size:9pt;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
                  </div>
                </div>
              </body>
          </html>
    OUTPUT

    word = <<~OUTPUT
      #{WORD_HDR}
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
              <div id="_">
                <h1 class="ForewordTitle">Foreword</h1>
                <p id="_" align="left" style="text-align:left;">Vache Equipment<br/>
      Fictitious<br/>
      World
          </p>
          <p style="text-align:justify;font-size:9pt;page-break-after: avoid;page-break-inside: avoid;">Justify</p>
              </div>
              <p>\u00a0</p>
            </div>
            <p class="section-break"><br clear="all" class="section"/></p>
            <div class="WordSection3">
            </div>
          </body>
      </html>
    OUTPUT

    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({}).convert("test", input,
                                                                 true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to fix_whitespaces(html)

    output = Nokogiri::HTML4(IsoDoc::WordConvert.new({}).convert("test", input,
                                                                 true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html4_equivalent_to fix_whitespaces(word)
  end

  it "processes blockquotes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <quote id="_044bd364-c832-4b78-8fea-92242402a1d1">
        <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality></source>
        <author>ISO</author>
        <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      </quote>
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
               <quote id="_">
                  <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011" id="_">
                     <locality type="clause">
                        <referenceFrom>1</referenceFrom>
                     </locality>
                  </source>
                  <author id="_">ISO</author>
                  <p id="_">
                     This International Standard gives the minimum specifications for rice (
                     <em>Oryza sativa</em>
                     L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).
                  </p>
                  <attribution>
                     <p>
                        —
                        <semx element="author" source="_">ISO</semx>
                        ,
                        <semx element="source" source="_">
                           <fmt-eref type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011">
                              <locality type="clause">
                                 <referenceFrom>1</referenceFrom>
                              </locality>
                              ISO\u00a07301:2011, Clause 1
                           </fmt-eref>
                        </semx>
                     </p>
                  </attribution>
               </quote>
            </foreword>
         </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
              <br/>
              <div id="fwd">
                <h1 class="ForewordTitle">Foreword</h1>
                <div class="Quote" id="_">


        <p id="_">This International Standard gives the minimum specifications for rice (<i>Oryza sativa</i> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
      <div class="QuoteAttribution"><p>&#8212; ISO, ISO\u00a07301:2011, Clause 1</p></div></div>
              </div>
            </div>
          </body>
      </html>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)

    expect(strip_guid(pres_output)).to be_xml_equivalent_to presxml

    expect(strip_guid(IsoDoc::HtmlConvert.new({}).convert("test", pres_output,
                                                          true)))
      .to be_html5_equivalent_to output
  end

  it "processes passthrough with compatible format" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <passthrough formats="html,rfc">&lt;A&gt;</passthrough><em>Hello</em><passthrough formats="html,rfc">&lt;/A&gt;</passthrough>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
           <clause type="toc" id="_" displayorder="1">
           <fmt-title id="_" depth="1">Table of contents</fmt-title>
           </clause>
           <foreword id="A" displayorder="2">
                    <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
              <passthrough formats=" html rfc ">&lt;A&gt;</passthrough>
              <em>Hello</em>
              <passthrough formats=" html rfc ">&lt;/A&gt;</passthrough>
           </foreword>
        </preface>
      </iso-standard>
    INPUT
    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)

    xml = Nokogiri::XML(output)
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(strip_guid(xml.to_xml))
      .to be_xml_equivalent_to presxml

    IsoDoc::HtmlConvert.new({}).convert("test", output, false)
    expect(Nokogiri::HTML5(File.read("test.html"))
      .at("//*[@id = 'A']").to_html)
      .to be_html5_equivalent_to(<<~OUTPUT)
        <div id="A">
            <h1 class="ForewordTitle">
               <a class="anchor" href="#A"/>
               <a class="header" href="#A">Foreword</a>
            </h1>
            <a>
               <i>Hello</i>
            </a>
         </div>
      OUTPUT

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input.sub("html,rfc", "all"), true)
    xml = Nokogiri::XML(output)
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(strip_guid(xml.to_xml))
      .to be_xml_equivalent_to presxml
  end

  it "aborts if passthrough results in malformed XML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.html.err"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <passthrough formats="html,rfc">&lt;A&gt;</passthrough><em>Hello</em>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = IsoDoc::PresentationXMLConvert
      .new(presxml_options
      .merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
    expect do
      IsoDoc::HtmlConvert.new({})
        .convert("test", presxml, false)
    end.to raise_error(SystemExit, /Malformed Output XML/)
  end

  it "ignores passthrough with incompatible format" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
         <preface>
            <clause type="toc" id="_toc" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <fmt-title id="_">Foreword</fmt-title>
               <passthrough formats="doc,rfc">&lt;A&gt;</passthrough>
            </foreword>
         </preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      <html lang="en">
      <head></head>
      <body lang="en">
        <div class="title-section">
          <p>\u00a0</p>
        </div><br>
        <div class="prefatory-section">
          <p>\u00a0</p>
        </div><br>
        <div class="main-section"><br>
          <div id="_">
            <h1 class="ForewordTitle">Foreword</h1>
          </div><br>
          <div id="_" class="TOC">
            <h1 class="IntroTitle">Table of contents</h1>
          </div>
        </div>
      </body>
      </html>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
    .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to fix_whitespaces(html)
  end

  it "ignores columnbreak" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
               <clause type="toc" id="_toc" displayorder="1">
                  <fmt-title id="_" depth="1">Table of contents</fmt-title>
                  <columnbreak/>
               </clause>
               <foreword id="_" displayorder="2">
                  <fmt-title id="_">Foreword</fmt-title>
               </foreword>
            </preface>
         </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="_">
                  <h1 class='ForewordTitle'>Foreword</h1>
                </div>
              </div>
            </body>
          </html>
    OUTPUT
    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
    .convert("test", input, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to fix_whitespaces(html)
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
               <fmt-title depth="1" id="_">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <p class="zzSTDTitle1" displayorder="2">Document title</p>
            <clause id="clause1" inline-header="false" obligation="normative" displayorder="3">
               <title id="_">Clause 1</title>
               <fmt-title depth="1" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="clause1">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 1</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="clause1">1</semx>
               </fmt-xref-label>
               <clause id="clause1A" inline-header="false" obligation="normative">
                  <title id="_">Clause 1A</title>
                  <fmt-title depth="2" id="_">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="clause1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1A">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 1A</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="clause1">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="clause1A">1</semx>
                  </fmt-xref-label>
                  <clause id="clause1Aa" inline-header="false" obligation="normative">
                     <title id="_">Clause 1Aa</title>
                     <fmt-title depth="3" id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1A">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1Aa">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Clause 1Aa</semx>
                     </fmt-title>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="clause1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1A">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1Aa">1</semx>
                     </fmt-xref-label>
                  </clause>
                  <clause id="clause1Ab" inline-header="false" obligation="normative">
                     <title id="_">Clause 1Ab</title>
                     <fmt-title depth="3" id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1A">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1Ab">2</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Clause 1Ab</semx>
                     </fmt-title>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="clause1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1A">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1Ab">2</semx>
                     </fmt-xref-label>
                  </clause>
               </clause>
               <clause id="clause1B" inline-header="false" obligation="normative">
                  <title id="_">Clause 1B</title>
                  <fmt-title depth="2" id="_">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="clause1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1B">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 1B</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="clause1">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="clause1B">2</semx>
                  </fmt-xref-label>
                  <clause id="clause1Ba" inline-header="false" obligation="normative">
                     <title id="_">Clause 1Ba</title>
                     <fmt-title depth="3" id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1B">2</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1Ba">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Clause 1Ba</semx>
                     </fmt-title>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="clause1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1B">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="clause1Ba">1</semx>
                     </fmt-xref-label>
                  </clause>
               </clause>
            </clause>
            <clause id="clause2" inline-header="false" obligation="normative" displayorder="4">
               <title id="_">Clause 2</title>
               <fmt-title depth="1" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="clause2">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 2</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="clause2">2</semx>
               </fmt-xref-label>
               <p id="A">And introducing: </p>
               <toc>
                  <ul id="B">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <xref target="clause1A" id="_">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1A">1</semx>
                           <span class="fmt-caption-delim">
                              <tab/>
                           </span>
                           Clause 1A
                        </xref>
                        <semx element="xref" source="_">
                           <fmt-xref target="clause1A">
                              <semx element="autonum" source="clause1">1</semx>
                              <span class="fmt-autonum-delim">.</span>
                              <semx element="autonum" source="clause1A">1</semx>
                              <span class="fmt-caption-delim">
                                 <tab/>
                              </span>
                              Clause 1A
                           </fmt-xref>
                        </semx>
                     </li>
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <ul id="C">
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">—</semx>
                              </fmt-name>
                              <xref target="clause1Aa" id="_">
                                 <semx element="autonum" source="clause1">1</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1A">1</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1Aa">1</semx>
                                 <span class="fmt-caption-delim">
                                    <tab/>
                                 </span>
                                 Clause 1Aa
                              </xref>
                              <semx element="xref" source="_">
                                 <fmt-xref target="clause1Aa">
                                    <semx element="autonum" source="clause1">1</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1A">1</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1Aa">1</semx>
                                    <span class="fmt-caption-delim">
                                       <tab/>
                                    </span>
                                    Clause 1Aa
                                 </fmt-xref>
                              </semx>
                           </li>
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">—</semx>
                              </fmt-name>
                              <xref target="clause1Ab" id="_">
                                 <semx element="autonum" source="clause1">1</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1A">1</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1Ab">2</semx>
                                 <span class="fmt-caption-delim">
                                    <tab/>
                                 </span>
                                 Clause 1Ab
                              </xref>
                              <semx element="xref" source="_">
                                 <fmt-xref target="clause1Ab">
                                    <semx element="autonum" source="clause1">1</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1A">1</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1Ab">2</semx>
                                    <span class="fmt-caption-delim">
                                       <tab/>
                                    </span>
                                    Clause 1Ab
                                 </fmt-xref>
                              </semx>
                           </li>
                        </ul>
                     </li>
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <xref target="clause1B" id="_">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1B">2</semx>
                           <span class="fmt-caption-delim">
                              <tab/>
                           </span>
                           Clause 1B
                        </xref>
                        <semx element="xref" source="_">
                           <fmt-xref target="clause1B">
                              <semx element="autonum" source="clause1">1</semx>
                              <span class="fmt-autonum-delim">.</span>
                              <semx element="autonum" source="clause1B">2</semx>
                              <span class="fmt-caption-delim">
                                 <tab/>
                              </span>
                              Clause 1B
                           </fmt-xref>
                        </semx>
                     </li>
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <ul id="D">
                           <li id="_">
                              <fmt-name id="_">
                                 <semx element="autonum" source="_">—</semx>
                              </fmt-name>
                              <xref target="clause1Ba" id="_">
                                 <semx element="autonum" source="clause1">1</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1B">2</semx>
                                 <span class="fmt-autonum-delim">.</span>
                                 <semx element="autonum" source="clause1Ba">1</semx>
                                 <span class="fmt-caption-delim">
                                    <tab/>
                                 </span>
                                 Clause 1Ba
                              </xref>
                              <semx element="xref" source="_">
                                 <fmt-xref target="clause1Ba">
                                    <semx element="autonum" source="clause1">1</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1B">2</semx>
                                    <span class="fmt-autonum-delim">.</span>
                                    <semx element="autonum" source="clause1Ba">1</semx>
                                    <span class="fmt-caption-delim">
                                       <tab/>
                                    </span>
                                    Clause 1Ba
                                 </fmt-xref>
                              </semx>
                           </li>
                        </ul>
                     </li>
                  </ul>
               </toc>
               <toc>
                  <ul id="E">
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <xref target="clause1A" id="_">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1A">1</semx>
                           <span class="fmt-caption-delim">
                              <tab/>
                           </span>
                           Clause 1A
                        </xref>
                        <semx element="xref" source="_">
                           <fmt-xref target="clause1A">
                              <semx element="autonum" source="clause1">1</semx>
                              <span class="fmt-autonum-delim">.</span>
                              <semx element="autonum" source="clause1A">1</semx>
                              <span class="fmt-caption-delim">
                                 <tab/>
                              </span>
                              Clause 1A
                           </fmt-xref>
                        </semx>
                     </li>
                     <li id="_">
                        <fmt-name id="_">
                           <semx element="autonum" source="_">—</semx>
                        </fmt-name>
                        <xref target="clause1B" id="_">
                           <semx element="autonum" source="clause1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="clause1B">2</semx>
                           <span class="fmt-caption-delim">
                              <tab/>
                           </span>
                           Clause 1B
                        </xref>
                        <semx element="xref" source="_">
                           <fmt-xref target="clause1B">
                              <semx element="autonum" source="clause1">1</semx>
                              <span class="fmt-autonum-delim">.</span>
                              <semx element="autonum" source="clause1B">2</semx>
                              <span class="fmt-caption-delim">
                                 <tab/>
                              </span>
                              Clause 1B
                           </fmt-xref>
                        </semx>
                     </li>
                  </ul>
               </toc>
            </clause>
         </sections>
      </standard-document>
    INPUT
    html = <<~OUTPUT
        #{HTML_HDR}
                     <p class='zzSTDTitle1'>Document title</p>
            <div id='clause1'>
              <h1>1.\u00a0 Clause 1</h1>
              <div id='clause1A'>
                <h2>1.1.\u00a0 Clause 1A</h2>
                <div id='clause1Aa'>
                  <h3>1.1.1.\u00a0 Clause 1Aa</h3>
                </div>
                <div id='clause1Ab'>
                  <h3>1.1.2.\u00a0 Clause 1Ab</h3>
                </div>
              </div>
              <div id='clause1B'>
                <h2>1.2.\u00a0 Clause 1B</h2>
                <div id='clause1Ba'>
                  <h3>1.2.1.\u00a0 Clause 1Ba</h3>
                </div>
              </div>
            </div>
            <div id='clause2'>
              <h1>2.\u00a0 Clause 2</h1>
              <p id='A'>And introducing: </p>
              <div class='toc'>
              <div class="ul_wrap">
                <ul id='B'>
                  <li id="_">
                    <a href='#clause1A'>1.1\u00a0 Clause 1A</a>
                  </li>
                  <li id="_">
                  <div class="ul_wrap">
                    <ul id='C'>
                      <li id="_">
                        <a href='#clause1Aa'>1.1.1\u00a0 Clause 1Aa</a>
                      </li>
                      <li id="_">
                        <a href='#clause1Ab'>1.1.2\u00a0 Clause 1Ab</a>
                      </li>
                    </ul>
                    </div>
                  </li>
                  <li id="_">
                    <a href='#clause1B'>1.2\u00a0 Clause 1B</a>
                  </li>
                  <li id="_">
                  <div class="ul_wrap">
                    <ul id='D'>
                      <li id="_">
                        <a href='#clause1Ba'>1.2.1\u00a0 Clause 1Ba</a>
                      </li>
                    </ul>
                    </div>
                  </li>
                </ul>
                </div>
              </div>
              <div class='toc'>
                  <div class="ul_wrap">
                <ul id='E'>
                  <li id="_">
                    <a href='#clause1A'>1.1\u00a0 Clause 1A</a>
                  </li>
                  <li id="_">
                    <a href='#clause1B'>1.2\u00a0 Clause 1B</a>
                  </li>
                </ul>
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
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
  end
end
