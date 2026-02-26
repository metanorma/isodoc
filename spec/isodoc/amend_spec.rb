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
               <fmt-title depth="1" id="_">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <p class="zzSTDTitle1" displayorder="2">Document title</p>
            <clause id="A" inline-header="false" obligation="normative" displayorder="3">
               <title id="_">Change Clause</title>
               <fmt-title depth="1" id="_">
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
                     <table number="2" original-id="E">
                        <name>Edges of triangle and quadrilateral cells</name>
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
                        <name>Imago</name>
                     </figure>
                     <example number="A.7" original-id="F">
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@id ='A']").to_xml))
      .to be_html5_equivalent_to html
  end

  it "processes amend subclauses" do
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
                     <amend id="_2ecb7ba1-ced4-18d1-bc8c-d7d03139b0de" change="add">
                     <autonumber type="example">10</autonumber>
                        <description><p id="_5162a644-6c8a-c719-da08-3a79c4b52e06">Add the following terminological entries after 3.1.2.13:</p></description><newcontent>
                                        <example id='F'>
                           <p id='G'>This is not generalised further.</p>
                         </example>
      <clause id="_813c4603-f691-7798-852f-962a3686c35b" inline-header="false" obligation="normative">
      <title id="_d1ac9d3a-cabe-0e32-34f6-e6a8cf430fdf">3.1.2.14 <br/>canonical form</title>


      <p id="_144e133e-157f-fe37-f92b-0b4f4957c772">date and time expression where all its time scale components are <em>normalised</em> (3.1.2.15)</p>

      <example id="_ae7b575c-a248-e0c3-08e4-8a81f77bf1e7"><p id="_aa5637f7-8d6c-7be0-8841-5b529c05016e">example</p>
      </example>

      <note id="_adf7a5b8-f42d-92a4-3a5f-8f0b705ada16"><p id="_20334171-4bec-169b-3537-f090c6f2a415">Note 1 to entry: A</p>
      </note>

      <table id="_e7f7af33-50be-609f-7371-4b41d7cfb044"><tbody><tr id="_0f1bd2b3-ed7d-a2e8-a14d-5bd2e777d10b"><td id="_f52d480e-d647-33df-7f57-9ba9b36fe6b9" valign="top" align="left">A</td>
      <td id="_fff6ab0f-6be2-d2f4-4d1b-2f3acbff0321" valign="top" align="left">B</td>
      </tr></tbody>
      </table>
      <autonumber type="example">1</autonumber><autonumber type="table">3</autonumber></clause>
      <clause id="xxx"><title>container</title>
      <p>This is a container of a subclause.</p>
      <clause id="_204d0c25-9e04-1223-a5a5-adb046b5ab75" inline-header="false" obligation="normative">
      <title id="_f88ca02a-e3cf-23b0-0ae4-c113bacffa23">3.1.2.15 non-canonical form</title>


      <p id="_89d15cba-4db5-02f0-9b84-945c5fdd9966">date and time expression where all its time scale components are <em>unnormalised</em> (3.1.2.1511)</p>

      <example id="_f7af314a-70ec-dce3-920f-3ef224772bfe"><p id="_decaf598-4bc9-73d4-e063-3d21387462f8">example</p>
      </example>

      <note id="_da1d6423-d4cc-253a-217d-ee7b7d17ea5e"><p id="_011888c1-793b-12d1-685d-5da27c4debf8">A</p>
      </note>

      <table id="_3fd93bf4-cb80-ba33-f5ed-b708be27ea0e"><tbody><tr id="_e4e36c14-b89f-7283-4e29-a5e8d9a0c828"><td id="_c72c6213-228c-006b-1699-83f8f2251c42" valign="top" align="left">A</td>
      <td id="_2d29edc6-6006-e485-0631-7adf754fefd4" valign="top" align="left">B</td>
      </tr></tbody>
      </table>
      <autonumber type="example">1</autonumber><autonumber type="note">1</autonumber><autonumber type="table">4</autonumber></clause></newcontent></amend>
      </clause>
                  </clause>
                  </sections>
                  </standard-document>
    INPUT
    presxml = <<~INPUT
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
               <fmt-title depth="1" id="_">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <p class="zzSTDTitle1" displayorder="2">Document title</p>
            <clause id="A" inline-header="false" obligation="normative" displayorder="3">
               <title id="_">Change Clause</title>
               <fmt-title depth="1" id="_">
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
               <amend id="_" change="add">
                  <autonumber type="example">10</autonumber>
                  <description>
                     <p original-id="_">Add the following terminological entries after 3.1.2.13:</p>
                  </description>
                  <newcontent>
                     <example number="10" original-id="F">
                        <p original-id="G">This is not generalised further.</p>
                     </example>
                     <clause inline-header="false" obligation="normative" original-id="_">
                        <title original-id="_">
                           3.1.2.14
                           <br/>
                           canonical form
                        </title>
                        <p original-id="_">
                           date and time expression where all its time scale components are
                           <em>normalised</em>
                           (3.1.2.15)
                        </p>
                        <example number="1" original-id="_">
                           <p original-id="_">example</p>
                        </example>
                        <note unnumbered="true" original-id="_">
                           <p original-id="_">Note 1 to entry: A</p>
                        </note>
                        <table number="3" original-id="_">
                           <tbody>
                              <tr original-id="_">
                                 <td valign="top" align="left" original-id="_">A</td>
                                 <td valign="top" align="left" original-id="_">B</td>
                              </tr>
                           </tbody>
                        </table>
                        <autonumber type="example">1</autonumber>
                        <autonumber type="table">3</autonumber>
                     </clause>
                     <clause original-id="xxx">
                        <title>container</title>
                        <p>This is a container of a subclause.</p>
                        <clause inline-header="false" obligation="normative" original-id="_">
                           <title original-id="_">3.1.2.15 non-canonical form</title>
                           <p original-id="_">
                              date and time expression where all its time scale components are
                              <em>unnormalised</em>
                              (3.1.2.1511)
                           </p>
                           <example number="1" original-id="_">
                              <p original-id="_">example</p>
                           </example>
                           <note number="1" original-id="_">
                              <p original-id="_">A</p>
                           </note>
                           <table number="4" original-id="_">
                              <tbody>
                                 <tr original-id="_">
                                    <td valign="top" align="left" original-id="_">A</td>
                                    <td valign="top" align="left" original-id="_">B</td>
                                 </tr>
                              </tbody>
                           </table>
                           <autonumber type="example">1</autonumber>
                           <autonumber type="note">1</autonumber>
                           <autonumber type="table">4</autonumber>
                        </clause>
                     </clause>
                  </newcontent>
               </amend>
               <semx element="amend" source="_">
                  <p id="_">Add the following terminological entries after 3.1.2.13:</p>
                  <quote>
                     <example id="F" number="10" autonum="10">
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">EXAMPLE</span>
                              <semx element="autonum" source="F">10</semx>
                           </span>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="F">10</semx>
                        </fmt-xref-label>
                        <fmt-xref-label container="A">
                           <span class="fmt-xref-container">
                              <span class="fmt-element-name">Clause</span>
                              <semx element="autonum" source="A">1</semx>
                           </span>
                           <span class="fmt-comma">,</span>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="F">10</semx>
                        </fmt-xref-label>
                        <p id="G">This is not generalised further.</p>
                     </example>
                  </quote>
                  <quote id="xxx">
                     <p type="floating-title">container</p>
                     <p>This is a container of a subclause.</p>
                     <quote id="_" inline-header="false" obligation="normative">
                        <p id="_" type="floating-title">3.1.2.15 non-canonical form</p>
                        <p id="_">
                           date and time expression where all its time scale components are
                           <em>unnormalised</em>
                           (3.1.2.1511)
                        </p>
                        <example id="_" number="1" autonum="1">
                           <fmt-name id="_">
                              <span class="fmt-caption-label">
                                 <span class="fmt-element-name">EXAMPLE</span>
                                 <semx element="autonum" source="_">1</semx>
                              </span>
                           </fmt-name>
                           <fmt-xref-label>
                              <span class="fmt-element-name">Example</span>
                              <semx element="autonum" source="_">1</semx>
                           </fmt-xref-label>
                           <fmt-xref-label container="_">
                              <span class="fmt-xref-container"/>
                              <span class="fmt-comma">,</span>
                              <span class="fmt-element-name">Example</span>
                              <semx element="autonum" source="_">1</semx>
                           </fmt-xref-label>
                           <p id="_">example</p>
                        </example>
                        <note id="_" number="1" autonum="1">
                           <fmt-name id="_">
                              <span class="fmt-caption-label">
                                 <span class="fmt-element-name">NOTE</span>
                                 <semx element="autonum" source="_">1</semx>
                              </span>
                              <span class="fmt-label-delim">
                                 <tab/>
                              </span>
                           </fmt-name>
                           <fmt-xref-label>
                              <span class="fmt-element-name">Note</span>
                              <semx element="autonum" source="_">1</semx>
                           </fmt-xref-label>
                           <fmt-xref-label container="_">
                              <span class="fmt-xref-container"/>
                              <span class="fmt-comma">,</span>
                              <span class="fmt-element-name">Note</span>
                              <semx element="autonum" source="_">1</semx>
                           </fmt-xref-label>
                           <p id="_">A</p>
                        </note>
                        <table id="_" number="4" autonum="4">
                           <fmt-name id="_">
                              <span class="fmt-caption-label">
                                 <span class="fmt-element-name">Table</span>
                                 <semx element="autonum" source="_">4</semx>
                              </span>
                           </fmt-name>
                           <fmt-xref-label>
                              <span class="fmt-element-name">Table</span>
                              <semx element="autonum" source="_">4</semx>
                           </fmt-xref-label>
                           <tbody>
                              <tr id="_">
                                 <td id="_" valign="top" align="left">A</td>
                                 <td id="_" valign="top" align="left">B</td>
                              </tr>
                           </tbody>
                        </table>
                     </quote>
                  </quote>
                  <quote id="_" inline-header="false" obligation="normative">
                     <p id="_" type="floating-title">
                        3.1.2.14
                        <br/>
                        canonical form
                     </p>
                     <p id="_">
                        date and time expression where all its time scale components are
                        <em>normalised</em>
                        (3.1.2.15)
                     </p>
                     <example id="_" number="1" autonum="1">
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">EXAMPLE</span>
                              <semx element="autonum" source="_">1</semx>
                           </span>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="_">1</semx>
                        </fmt-xref-label>
                        <fmt-xref-label container="_">
                           <span class="fmt-xref-container"/>
                           <span class="fmt-comma">,</span>
                           <span class="fmt-element-name">Example</span>
                           <semx element="autonum" source="_">1</semx>
                        </fmt-xref-label>
                        <p id="_">example</p>
                     </example>
                     <note id="_" unnumbered="true">
                        <p id="_">Note 1 to entry: A</p>
                     </note>
                     <table id="_" number="3" autonum="3">
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">Table</span>
                              <semx element="autonum" source="_">3</semx>
                           </span>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Table</span>
                           <semx element="autonum" source="_">3</semx>
                        </fmt-xref-label>
                        <tbody>
                           <tr id="_">
                              <td id="_" valign="top" align="left">A</td>
                              <td id="_" valign="top" align="left">B</td>
                           </tr>
                        </tbody>
                     </table>
                  </quote>
               </semx>
            </clause>
         </sections>
      </standard-document>
    INPUT
    html = <<~OUTPUT
         <div id="A">
         <h1>1.\u00a0 Change Clause</h1>
         <p id="_">Add the following terminological entries after 3.1.2.13:</p>
         <div class="Quote">
            <div id="F" class="example">
               <p class="example-title">EXAMPLE 10</p>
               <p id="G">This is not generalised further.</p>
            </div>
         </div>
         <div class="Quote" id="xxx">
            <p class="h">container</p>
            <p>This is a container of a subclause.</p>
            <div class="Quote" id="_">
               <p class="h" id="_">3.1.2.15 non-canonical form</p>
               <p id="_">
                  date and time expression where all its time scale components are
                  <i>unnormalised</i>
                  (3.1.2.1511)
               </p>
               <div id="_" class="example">
                  <p class="example-title">EXAMPLE 1</p>
                  <p id="_">example</p>
               </div>
               <div id="_" class="Note">
                  <p>
                     <span class="note_label">NOTE 1\u00a0 </span>
                     A
                  </p>
               </div>
               <p class="TableTitle" style="text-align:center;">Table 4</p>
               <table id="_" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                  <tbody>
                     <tr>
                        <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                        <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                     </tr>
                  </tbody>
               </table>
            </div>
         </div>
         <div class="Quote" id="_">
            <p class="h" id="_">
               3.1.2.14
               <br/>
               canonical form
            </p>
            <p id="_">
               date and time expression where all its time scale components are
               <i>normalised</i>
               (3.1.2.15)
            </p>
            <div id="_" class="example">
               <p class="example-title">EXAMPLE 1</p>
               <p id="_">example</p>
            </div>
            <div id="_" class="Note">
               <p>Note 1 to entry: A</p>
            </div>
            <p class="TableTitle" style="text-align:center;">Table 3</p>
            <table id="_" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
               <tbody>
                  <tr>
                     <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                     <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                  </tr>
               </tbody>
            </table>
         </div>
      </div>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(Nokogiri::XML(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@id ='A']").to_xml))
      .to be_html5_equivalent_to html
  end
end
