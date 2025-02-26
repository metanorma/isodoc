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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">Document title</p>
             <clause id="A" inline-header="false" obligation="normative" displayorder="3">
                <title id="_">Change Clause</title>
                <fmt-title depth="1">
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
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="E">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
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
                         <fmt-name>
                            <semx element="name" source="_">Imago</semx>
                         </fmt-name>
                      </figure>
                      <example id="F" number="A.7" autonum="A.7">
                         <fmt-name>
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
          <h1 class="ForewordTitle">Foreword</h1>
          <div align="right">
             <b>Units in mm</b>
          </div>
          <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
             <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
             <img src="rice_images/rice_image1.png" height="20" width="auto"/>
             <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
             <img src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto"/>
             <a href="#figureA-1a" class="TableFootnoteRef">a)</a>
             <p class="ListTitle">
                Key
                <a id="DL1"/>
             </p>
             <p class="dl">A: B</p>
             <div class="BlockSource">
                <p>
                   [SOURCE:
                   <a href="#ISO712">ISO 712, Section 1</a>
                   — with adjustments]
                </p>
             </div>
             <div id="note1" class="Note">
                <p>
                   <span class="note_label">NOTE  </span>
                </p>
                This is a note
             </div>
             <aside id="fn:figureA-1a" class="footnote">
                <p id="_">
                   <span class="TableFootnoteRef">Footnote a)</span>
                     The time
                   <span class="stem">(#(t_90)#)</span>
                   was estimated to be 18,2 min for this example.
                </p>
             </aside>
             <p class="FigureTitle" style="text-align:center;">
                Figure 1 — Split-it-right
                <i>sample</i>
                divider
                <a class="FootnoteRef" href="#fn:1">
                   <sup>1)</sup>
                </a>
             </p>
          </div>
          <div id="figure-B" class="figure">
             <pre>A &lt;
         B</pre>
             <p class="FigureTitle" style="text-align:center;">Figure 2</p>
          </div>
          <div id="figure-C" class="figure">
             <pre>A &lt;
         B</pre>
          </div>
       </div>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
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
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="fwd" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <example id="samplecode" keep-with-next="true" keep-lines-together="true" autonum="">
                    <name id="_">Title</name>
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">EXAMPLE</span>
                       </span>
                       <span class="fmt-caption-delim"> — </span>
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
                       <fmt-name>
                          <semx element="name" source="_">Sample</semx>
                       </fmt-name>
                                      <fmt-sourcecode>

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
                         <p class="example-title">EXAMPLE&#160;&#8212; Title</p>
                 <p>Hello</p>
                      <pre id="X" class="sourcecode">
                         <br/>
                          
                         <br/>
                          
                      </pre>
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
                <p class='example-title'>EXAMPLE&#160;&#8212; Title</p>
                <p>Hello</p>
                      <p id="X" class="Sourcecode">
                         <br/>
                          
                         <br/>
                          
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
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
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="fwd" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <example id="samplecode" autonum="1">
                    <fmt-name>
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
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">EXAMPLE</span>
                          <semx element="autonum" source="samplecode2">2</semx>
                       </span>
                       <span class="fmt-caption-delim"> — </span>
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
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">EXAMPLE</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Example</span>
                       <semx element="autonum" source="samplecode3">(??)</semx>
                    </fmt-xref-label>
                    <fmt-xref-label container="fwd">
                       <span class="fmt-xref-container">
                          <semx element="foreword" source="fwd">Foreword</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Example</span>
                       <semx element="autonum" source="samplecode3">(??)</semx>
                    </fmt-xref-label>
                    <p>Hello</p>
                 </example>
              </foreword>
           </preface>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
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
                      <fmt-name>
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
                   <fmt-name>
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
             <fmt-title>
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
                <fmt-name>
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


              <div id="_" class="Note"><p><span class="note_label">NOTE  </span>[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div></div>

                    <div id="_"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div></div>
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
                              (A.1)
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
                     <span class='note_label'>NOTE<span style='mso-tab-count:1'>&#160; </span></span>
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
                    <span style="mso-tab-count:1">  </span>
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
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes paragraph attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <clause type="toc" id="_toc" displayorder="1">
          <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
          <foreword id="_" displayorder="2"><fmt-title>Foreword</fmt-title>
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
              <p>&#160;</p>
            </div>
            <p class="section-break"><br clear="all" class="section"/></p>
            <div class="WordSection3">
            </div>
          </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(word)
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
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
                            <fmt-eref type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011" id="_">
                               <locality type="clause">
                                  <referenceFrom>1</referenceFrom>
                               </locality>
                               ISO 7301:2011, Clause 1
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
      <div class="QuoteAttribution"><p>&#8212; ISO, ISO&#xa0;7301:2011, Clause 1</p></div></div>
              </div>
            </div>
          </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes permissions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <permission id="A"   keep-with-next="true" keep-lines-together="true" model="default">
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
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </permission>
          </foreword></preface>
          <annex id="Annex">
          <permission id="AnnexPermission" model="default">
          <description>
          <p id="_">As for the measurement targets,</p>
        </description>
          </permission>
          </annex>
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <permission id="A" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Permission</span>
                         <semx element="autonum" source="A">1</semx>
                         <span class="fmt-caption-delim">
                            :
                            <br/>
                         </span>
                         <semx element="identifier" source="A">/ogc/recommendation/wfs/2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">
                      <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref>
                   </inherit>
                   <subject id="_">user</subject>
                   <subject id="_">non-user</subject>
                   <classification>
                      <tag id="_">control-class</tag>
                      <value id="_">Technical</value>
                   </classification>
                   <classification>
                      <tag id="_">priority</tag>
                      <value id="_">P0</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protection</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protocols</value>
                   </classification>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
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
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C"><body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body></sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2"><body>success-response()</body></sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                   </component>
                   <fmt-provision id="A" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                      <p>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Subject:
                            <semx element="subject" source="_">non-user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">
                               <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616" id="_">RFC 2616 (HTTP/1.1)</eref>
                               <semx element="eref" source="_">
                                  <fmt-xref type="inline" target="rfc2616">RFC 2616 (HTTP/1.1)</fmt-xref>
                               </semx>
                            </semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Control-class</semx>
                            :
                            <semx element="value" source="_">Technical</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Priority</semx>
                            :
                            <semx element="value" source="_">P0</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Family</semx>
                            :
                            <semx element="value" source="_">System and Communications Protection</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Family</semx>
                            :
                            <semx element="value" source="_">System and Communications Protocols</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name>
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1"><body>
                               CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                               </body><fmt-sourcecode autonum="1">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                         </semx>
                      </div>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
          <annex id="Annex" autonum="A" displayorder="3">
             <fmt-title>
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
             <permission id="AnnexPermission" model="default" autonum="A.1">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="AnnexPermission">
                         <semx element="autonum" source="Annex">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="AnnexPermission">1</semx>
                      </semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Permission</span>
                   <semx element="autonum" source="Annex">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexPermission">1</semx>
                </fmt-xref-label>
                <description id="_">
                   <p original-id="_">As for the measurement targets,</p>
                </description>
                <fmt-provision id="AnnexPermission" model="default" autonum="A.1">
                   <div type="requirement-description">
                      <semx element="description" source="_">
                         <p id="_">As for the measurement targets,</p>
                      </semx>
                   </div>
                </fmt-provision>
             </permission>
          </annex>
          <bibliography>
             <references id="_" obligation="informative" normative="false" displayorder="4">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="rfc2616" type="standard">
                   <formattedref>
                      R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE.
                      <em>Hypertext Transfer Protocol — HTTP/1.1</em>
                      . 1999. Fremont, CA.
                   </formattedref>
                   <fetched>2020-03-27</fetched>
                   <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="IETF">IETF RFC 2616</docidentifier>
                   <docidentifier type="IETF" scope="anchor">IETF RFC2616</docidentifier>
                   <docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 2616</docidentifier>
                   <date type="published">
                      <on>1999-06</on>
                   </date>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">R. Fielding</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">J. Gettys</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">J. Mogul</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">H. Frystyk</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">L. Masinter</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">P. Leach</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">T. Berners-Lee</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <language>en</language>
                   <script>Latn</script>
                   <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>
                   <series type="main">
                      <title format="text/plain" language="en" script="Latn">RFC</title>
                      <number>2616</number>
                   </series>
                   <place>Fremont, CA</place>
                   <biblio-tag>
                      [1]
                      <tab/>
                      IETF RFC 2616,
                   </biblio-tag>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                  <div id="fwd">
                    <h1 class="ForewordTitle">Foreword</h1>
                    <div class="permission" id='A' style='page-break-after: avoid;page-break-inside: avoid;'>
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
                <div id="B"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div></div>
              </div>
              <div class="requirement-verification">
                <p id="_">The following code will be run for verification:</p>
                <pre id="C" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
              </div>
              <div class='requirement-component1'> <p id='_'>Hello</p>
               </div>
            </div>
         </div>
         <br/>
         <div id="Annex" class="Section3">
            <h1 class="Annex">
               <b>Annex A</b>
               <br/>
               (informative)
            </h1>
            <div class="permission" id="AnnexPermission">
               <p class="RecommendationTitle">Permission A.1</p>
               <div class="requirement-description">
                  <p id="_">As for the measurement targets,</p>
            </div>
            </div>
                  </div>
                   <br/>
             <div>
               <h1 class='Section3'>Bibliography</h1>
               <p id="rfc2616" class="Biblio">[1]  IETF&#xa0;RFC&#xa0;2616, R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE. <i>Hypertext Transfer Protocol — HTTP/1.1</i>. 1999. Fremont, CA.</p>
             </div>
                </div>
              </body>
            </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes requirements" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
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
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <requirement id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Requirement</span>
                         <span class="fmt-caption-delim">
                            :
                            <br/>
                         </span>
                         <semx element="identifier" source="A">/ogc/recommendation/wfs/2</semx>
                         .
                         <semx element="title" source="A">A New Requirement</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Requirement</span>
                      <semx element="autonum" source="A">(??)</semx>
                   </fmt-xref-label>
                   <title>A New Requirement</title>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
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
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" keep-with-next="true" keep-lines-together="true" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C"><body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body></sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2"><body>success-response()</body></sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                   </component>
                   <fmt-provision id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default">
                      <p>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div keep-with-next="true" keep-lines-together="true" type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name>
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1"><body>
                               CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                               </body><fmt-sourcecode autonum="1">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                         </semx>
                      </div>
                   </fmt-provision>
                </requirement>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                        <br/>
                      <div id="fwd">
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
                    <pre id="C" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes recommendation" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <recommendation id="A" obligation="shall,could"   keep-with-next="true" keep-lines-together="true" model="default">
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
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <recommendation id="A" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Recommendation</span>
                         <semx element="autonum" source="A">1</semx>
                         <span class="fmt-caption-delim">
                            :
                            <br/>
                         </span>
                         <semx element="identifier" source="A">/ogc/recommendation/wfs/2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <classification>
                      <tag id="_">type</tag>
                      <value id="_">text</value>
                   </classification>
                   <classification>
                      <tag id="_">language</tag>
                      <value id="_">BASIC</value>
                   </classification>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
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
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C"><body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body></sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2"><body>success-response()</body></sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                   </component>
                   <fmt-provision id="A" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                      <p>
                         <em>Obligation: shall,could</em>
                         <br/>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Type</semx>
                            :
                            <semx element="value" source="_">text</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Language</semx>
                            :
                            <semx element="value" source="_">BASIC</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name>
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1"><body>
                               CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                               </body><fmt-sourcecode autonum="1">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                         </semx>
                      </div>
                   </fmt-provision>
                </recommendation>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                      <div id="fwd">
                        <h1 class="ForewordTitle">Foreword</h1>
                <div class="recommend"  id='A' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class="RecommendationTitle">Recommendation 1:<br/>/ogc/recommendation/wfs/2</p><p><i>Obligation: shall,could</i><br/><i>Subject: user</i><br/><i>Inherits: /ss/584/2015/level/1</i><br/><i>Type: text</i><br/><i>Language: BASIC</i></p>
                  <div class="requirement-description">
                    <p id="_">I recommend <i>this</i>.</p>
                  </div>
                  <div class="requirement-description">
                    <p id="_">As for the measurement targets,</p>
                  </div>
                  <div class="requirement-measurement-target">
                    <p id="_">The measurement target shall be measured as:</p>
                    <div id="B"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div></div>
                  </div>
                  <div class="requirement-verification">
                    <p id="_">The following code will be run for verification:</p>
                    <pre id="C" class="sourcecode">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
                  </div>
                          <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
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
           <fmt-title depth="1">Table of contents</fmt-title>
           </clause>
           <foreword id="A" displayorder="2">
                    <title id="_">Foreword</title>
         <fmt-title depth="1">
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
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::HtmlConvert.new({}).convert("test", output, false)
    expect(Nokogiri::XML(Xml::C14n.format(File.read("test.html")))
      .at("//*[@id = 'A']").to_xml)
    .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
           <div id="A">
                   <h1 class="ForewordTitle">
                      <a class="anchor" href="#A"/>
                      <a class="header" href="#A">Foreword</a>
                   </h1>
                   <A>
                      <i>Hello</i>
                   </A>
                </div>
      OUTPUT

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input.sub("html,rfc", "all"), true)
    xml = Nokogiri::XML(output)
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "aborts if passthrough results in malformed XML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.html.err"
    begin
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
          <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
        <foreword id="_" displayorder="2"><fmt-title>Foreword</fmt-title>
      <passthrough formats="doc,rfc">&lt;A&gt;</passthrough>
      </foreword></preface>
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", rfc: "rfc" }))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)

  end

  it "ignores columnbreak" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
          <clause type="toc" id="_toc" displayorder="1">
          <fmt-title depth="1">Table of contents</fmt-title>
           <columnbreak/>
          </clause>
        <foreword id="_" displayorder="2"><fmt-title>Foreword</fmt-title>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="_">
                  <h1 class='ForewordTitle'>Foreword</h1>
                </div>
              </div>
            </body>
          </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
     .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
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
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">Document title</p>
             <clause id="clause1" inline-header="false" obligation="normative" displayorder="3">
                <title id="_">Clause 1</title>
                <fmt-title depth="1">
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
                   <fmt-title depth="2">
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
                      <fmt-title depth="3">
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
                      <fmt-title depth="3">
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
                   <fmt-title depth="2">
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
                      <fmt-title depth="3">
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
                <fmt-title depth="1">
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
                      <li>
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
                      <li>
                         <ul id="C">
                            <li>
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
                            <li>
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
                      <li>
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
                      <li>
                         <ul id="D">
                            <li>
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
                      <li>
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
                      <li>
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
              <div class="ul_wrap">
                <ul id='B'>
                  <li>
                    <a href='#clause1A'>1.1&#160; Clause 1A</a>
                  </li>
                  <li>
                  <div class="ul_wrap">
                    <ul id='C'>
                      <li>
                        <a href='#clause1Aa'>1.1.1&#160; Clause 1Aa</a>
                      </li>
                      <li>
                        <a href='#clause1Ab'>1.1.2&#160; Clause 1Ab</a>
                      </li>
                    </ul>
                    </div>
                  </li>
                  <li>
                    <a href='#clause1B'>1.2&#160; Clause 1B</a>
                  </li>
                  <li>
                  <div class="ul_wrap">
                    <ul id='D'>
                      <li>
                        <a href='#clause1Ba'>1.2.1&#160; Clause 1Ba</a>
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
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end
end
