require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
            <foreword>
              <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
          <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
          <colgroup>
          <col width="30%"/>
          <col width="20%"/>
          <col width="20%"/>
          <col width="20%"/>
          <col width="10%"/>
          </colgroup>
          <thead>
            <tr>
              <td rowspan="2" align="left">Description</td>
              <td colspan="4" align="center">Rice sample</td>
            </tr>
            <tr>
              <td valign="top" align="left">Arborio</td>
              <td valign="middle" align="center">Drago<fn reference="a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
        </fn></td>
              <td valign="bottom" align="center">Balilla<fn reference="a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
        </fn></td>
              <td align="center">Thaibonnet</td>
            </tr>
            </thead>
            <tbody>
            <tr>
              <th align="left">Number of laboratories retained after eliminating outliers</th>
              <td align="center">13</td>
              <td align="center">11</td>
              <td align="center">13</td>
              <td align="center">13</td>
            </tr>
            <tr>
              <td align="left">Mean value, g/100 g</td>
              <td align="center">81,2</td>
              <td align="center">82,0</td>
              <td align="center">81,8</td>
              <td align="center">77,7</td>
            </tr>
            </tbody>
            <tfoot>
            <tr>
              <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
              <td align="center">2,89</td>
              <td align="center">0,57</td>
              <td align="center">2,26</td>
              <td align="center">6,06</td>
            </tr>
          </tfoot>
          <dl>
          <dt>Drago</dt>
        <dd>A type of rice</dd>
        </dl>
              <source status="generalisation">
          <origin bibitemid="ISO712" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>1</referenceFrom>
              </locality>
            </localityStack>
          </origin>
          <modification>
            <p id="_">with adjustments</p>
          </modification>
        </source>
        <note><p>This is a table about rice</p></note>
        </table>
        <table id="tableD-2" unnumbered="true">
        <tbody><tr><td>A</td></tr></tbody>
        </table>
        </foreword>
        </preface>
        <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
        <bibitem id="ISO712" type="standard">
          <title format="text/plain">Cereals or cereal products</title>
          <title type="main" format="text/plain">Cereals and cereal products</title>
          <docidentifier type="ISO">ISO 712</docidentifier>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
            </organization>
          </contributor>
        </bibitem>
      </bibliography>
        </iso-standard>
    INPUT

    presxml = <<~OUTPUT
            <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
              <preface>
                <clause type="toc" displayorder="1" id="_">
              <title depth="1">Table of contents</title>
            </clause>
            <foreword displayorder="2">
                  <table id='tableD-1' alt='tool tip' summary='long desc' width='70%' keep-with-next='true' keep-lines-together='true'>
                    <name>
                      Table 1&#xA0;&#x2014; Repeatability and reproducibility of
                      <em>husked</em>
                       rice yield
                      <fn reference='1'>
                        <p>X</p>
                      </fn>
                    </name>
                     <colgroup>
        <col width='30%'/>
        <col width='20%'/>
        <col width='20%'/>
        <col width='20%'/>
        <col width='10%'/>
      </colgroup>
                    <thead>
                      <tr>
                        <td rowspan='2' align='left'>Description</td>
                        <td colspan='4' align='center'>Rice sample</td>
                      </tr>
                      <tr>
                        <td valign="top" align='left'>Arborio</td>
                        <td valign="middle" align='center'>
                          Drago
                          <fn reference='a'>
                            <p id='_'>Parboiled rice.</p>
                          </fn>
                        </td>
                        <td valign="bottom" align='center'>
                          Balilla
                          <fn reference='a'>
                            <p id='_'>Parboiled rice.</p>
                          </fn>
                        </td>
                        <td align='center'>Thaibonnet</td>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <th align='left'>Number of laboratories retained after eliminating outliers</th>
                        <td align='center'>13</td>
                        <td align='center'>11</td>
                        <td align='center'>13</td>
                        <td align='center'>13</td>
                      </tr>
                      <tr>
                        <td align='left'>Mean value, g/100 g</td>
                        <td align='center'>81,2</td>
                        <td align='center'>82,0</td>
                        <td align='center'>81,8</td>
                        <td align='center'>77,7</td>
                      </tr>
                    </tbody>
                    <tfoot>
                      <tr>
                        <td align='left'>
                          Reproducibility limit,
                          <stem type='AsciiMath'>R</stem>
                           (= 2,83
                          <stem type='AsciiMath'>s_R</stem>
                          )
                        </td>
                        <td align='center'>2,89</td>
                        <td align='center'>0,57</td>
                        <td align='center'>2,26</td>
                        <td align='center'>6,06</td>
                      </tr>
                    </tfoot>
                    <dl>
                      <dt>Drago</dt>
                      <dd>A type of rice</dd>
                    </dl>
                    <source status="generalisation">[SOURCE: <xref type="inline" target="ISO712">, Section 1</xref>
            – with adjustments]</source>
                    <note>
                      <name>NOTE</name>
                      <p>This is a table about rice</p>
                    </note>
                  </table>
                  <table id='tableD-2' unnumbered='true'>
                    <tbody>
                      <tr>
                        <td>A</td>
                      </tr>
                    </tbody>
                  </table>
                </foreword>
              </preface>
                       <bibliography>
           <references id="_" obligation="informative" normative="true" displayorder="3">
             <title depth="1">1.<tab/>Normative References</title>
             <bibitem id="ISO712" type="standard">
               <formattedref>International Organization for Standardization. <em>Cereals and cereal products</em>.</formattedref>
               <docidentifier type="ISO">ISO 712</docidentifier>
               <biblio-tag>ISO 712, </biblio-tag>
             </bibitem>
           </references>
         </bibliography>
            </iso-standard>
    OUTPUT

    html = <<~OUTPUT
            #{HTML_HDR}
                         <br/>
                     <div>
                       <h1 class="ForewordTitle">Foreword</h1>
                       <p class="TableTitle" style="text-align:center;">Table 1&#160;&#8212; Repeatability and reproducibility of <i>husked</i> rice yield
                       <a class='FootnoteRef' href='#fn:1'>
          <sup>1</sup>
        </a>
                        </p>
                       <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;width:70%;page-break-after: avoid;page-break-inside: avoid;table-layout:fixed;" title="tool tip" >
                       <caption>
                       <span style="display:none">long desc</span>
                       </caption>
                        <colgroup>
           <col style='width: 30%;'/>
           <col style='width: 20%;'/>
           <col style='width: 20%;'/>
           <col style='width: 20%;'/>
           <col style='width: 10%;'/>
         </colgroup>
                         <thead>
                           <tr>
                             <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                             <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="colgroup">Rice sample</td>
                           </tr>
                           <tr>
                             <td style="text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Arborio</td>
                             <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:tableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#160; </span>
                 <p id="_">Parboiled rice.</p>
               </div></aside></td>
                             <td style="text-align:center;vertical-align:bottom;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                             <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Thaibonnet</td>
                           </tr>
                         </thead>
                         <tbody>
                           <tr>
                             <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                           </tr>
                           <tr>
                             <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                             <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                             <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                             <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                             <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
                           </tr>
                         </tbody>
                         <tfoot>
                           <tr>
                             <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,89</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">0,57</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,26</td>
                             <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">6,06</td>
                           </tr>
                         </tfoot>
                                  <dl>
             <dt>
               <p>Drago</p>
             </dt>
             <dd>A type of rice</dd>
           </dl>
           <div class="BlockSource">
             <p>[SOURCE: <a href="#ISO712">, Section 1</a> –
      with adjustments]</p>
           </div>
           <div class="Note">
             <p><span class="note_label">NOTE</span>  This is a table about rice</p>
           </div>
                         </table>
                       <table id="tableD-2" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                         <tbody>
                           <tr>
                             <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                           </tr>
                         </tbody>
                       </table>
                     </div>
                     <p class="zzSTDTitle1"/>
                      <div>
                 <h1>1.  Normative References</h1>
                 <p id="ISO712" class="NormRef">ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
               </div>
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
             <p> </p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <p>
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div class="TOC" id="_">
         <p class="zzContents">Table of contents</p>
       </div>
       <p>
         <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
       </p>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" style="text-align:center;">
                       Table 1 — Repeatability and reproducibility of
                       <i>husked</i>
                        rice yield
                       <span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#ftn1" epub:type="footnote"><sup>1</sup></a></span>
                     </p>
               <div align="center" class="table_container">
                 <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                   <colgroup>
                     <col width="30%"/>
                     <col width="20%"/>
                     <col width="20%"/>
                     <col width="20%"/>
                     <col width="10%"/>
                   </colgroup>
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Rice sample</td>
                     </tr>
                     <tr>
                       <td valign="top" align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Arborio</td>
                       <td valign="middle" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                           Drago
                           <a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">  </span></span><p id="_">Parboiled rice.</p></div></aside>
                         </td>
                       <td valign="bottom" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                           Balilla
                           <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                         </td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Thaibonnet</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">11</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">82,0</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,8</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">77,7</td>
                     </tr>
                   </tbody>
                   <tfoot>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                           Reproducibility limit,
                           <span class="stem">(#(R)#)</span>
                            (= 2,83
                           <span class="stem">(#(s_R)#)</span>
                           )
                         </td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">2,89</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">0,57</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">2,26</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">6,06</td>
                     </tr>
                   </tfoot>
                   <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">Drago<span style="mso-tab-count:1">  </span>A type of rice</p>
             <div class="BlockSource">
               <p>[SOURCE: <a href="#ISO712">, Section 1</a> –
      with adjustments]</p>
             </div>
             <div class="Note">
               <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">  </span>This is a table about rice</p>
             </div>
                 </table>
               </div>
               <div align="center" class="table_container">
                 <table id="tableD-2" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                   <tbody>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">A</td>
                     </tr>
                   </tbody>
                 </table>
               </div>
             </div>
             <p> </p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
               <div>
                <h1>1.<span style="mso-tab-count:1">  </span>Normative References</h1>
                <p id="ISO712" class="NormRef">ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
              </div>
             <aside id="ftn1">
               <p>X</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(word)
  end

  it "passes on classes of tables from Presentation XML" do
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
          <clause type="toc" displayorder="1" id="_">
      <title depth="1">Table of contents</title>
      </clause>
      <foreword displayorder="2">
        <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true" class="modspec">
          <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
        </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p class='TableTitle' style='text-align:center;'>
                 Repeatability and reproducibility of
                 <i>husked</i>
                  rice yield
               </p>
               <table id='tableD-1' class='modspec' style='border-width:1px;border-spacing:0;width:70%;page-break-after: avoid;page-break-inside: avoid;' title='tool tip'>
                 <caption>
                   <span style='display:none'>long desc</span>
                 </caption>
               </table>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
               <head><style/></head>
             <body lang='EN-US' link='blue' vlink='#954F72'>
           <div class='WordSection1'>
             <p>&#xa0;</p>
           </div>
           <p>
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection2'>
             <p>
               <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
             </p>
             <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p>
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p class='TableTitle' style='text-align:center;'>
                 Repeatability and reproducibility of
                 <i>husked</i>
                  rice yield
               </p>
               <div align='center' class='table_container'>
                 <table id='tableD-1' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;' title='tool tip' summary='long desc' width='70%'/>
               </div>
             </div>
             <p>&#xa0;</p>
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
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes tables with big cells" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
            <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
        <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
        <thead>
          <tr>
            <td>
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
      Description Description Description Description Description Description Description Description Description
            </td>
            <td>Rice sample</td>
          </tr>
        </thead>
        </table>
        </foreword>
        </preface>
        </iso-standard>
    INPUT

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
                 <p class='TableTitle' style='text-align:center;'>
                   Repeatability and reproducibility of
                   <i>husked</i>
                    rice yield
                   <span style='mso-bookmark:_Ref'>
                     <a class='FootnoteRef' href='#ftn1' epub:type='footnote'>
                       <sup>1</sup>
                     </a>
                   </span>
                 </p>
                 <div align='center' class='table_container'>
                   <table id='tableD-1' class='MsoISOTableBig' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;' title='tool tip' summary='long desc' width='70%'>
                     <thead>
                       <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                            Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                           Description Description Description Description Description
                         </td>
                         <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Rice sample</td>
                       </tr>
                     </thead>
                   </table>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <p>
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection3'>
               <p class='zzSTDTitle1'/>
               <aside id='ftn1'>
                 <p>X</p>
               </aside>
             </div>
           </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", input, true)
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes tables with many rows" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
      <thead>
        <tr>
          <td>X</td>
        </tr>
      </thead>
      <tbody>
      <tr><td>1</td></tr>
      <tr><td>2</td></tr>
      <tr><td>3</td></tr>
      <tr><td>4</td></tr>
      <tr><td>5</td></tr>
      <tr><td>6</td></tr>
      <tr><td>7</td></tr>
      <tr><td>8</td></tr>
      <tr><td>9</td></tr>
      <tr><td>10</td></tr>
      </tbody>
      </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head>
          <style>
          </style>
        </head>
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p> </p>
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
              <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield<span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#ftn1" epub:type="footnote"><sup>1</sup></a></span></p>
              <div align="center" class="table_container">
                <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                  <thead>
                    <tr>
                      <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">X</td>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">1</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">2</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">3</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">4</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">5</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">6</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">7</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">8</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">9</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">10</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <p> </p>
          </div>
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
            <aside id="ftn1">
              <p>X</p>
            </aside>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert.new({})
        .convert("test", input, true)
        .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(output)

    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
      <thead>
        <tr>
          <td>X</td>
        </tr>
      </thead>
      <tbody>
      <tr><td>1</td></tr>
      <tr><td>2</td></tr>
      <tr><td>3</td></tr>
      <tr><td>4</td></tr>
      <tr><td>5</td></tr>
      <tr><td>6</td></tr>
      <tr><td>7</td></tr>
      <tr><td>8</td></tr>
      <tr><td>9</td></tr>
      <tr><td>10</td></tr>
      <tr><td>11</td></tr>
      <tr><td>12</td></tr>
      <tbody>
      </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
              <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head>
          <style>
          </style>
        </head>
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p> </p>
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
              <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield<span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#ftn1" epub:type="footnote"><sup>1</sup></a></span></p>
              <div align="center" class="table_container">
                <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                  <thead>
                    <tr>
                      <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">X</td>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">1</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">2</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">3</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">4</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">5</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">6</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">7</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">8</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">9</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">10</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">11</td>
                    </tr>
                    <tr>
                      <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">12</td>
                    </tr>
                    <tr/>
                  </tbody>
                </table>
              </div>
            </div>
            <p> </p>
          </div>
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
            <aside id="ftn1">
              <p>X</p>
            </aside>
          </div>
        </body>
      </html>

    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert.new({})
        .convert("test", input, true)
        .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes tables with large rows" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
      <thead>
        <tr>
          <td>X</td>
        </tr>
      </thead>
      <tbody>
      <tr><td><p>1</p><p>2</p><p>3</p></td></tr>
      <tr><td>2</td></tr>
      <tr><td><ol><li>3</li><li>3</li><li>3</li></ol></td></tr>
      <tr><td><p>1</p><p>2</p><p>3</p></td></tr>
      <tr><td><p>1</p><p>2</p><p>3</p></td></tr>
      <tr><td>5<br/>5<br/>5<br/>5</td></tr>
      </tbody>
      </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head> <style> </style> </head>
               <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p> </p>
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
               <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield<span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#ftn1" epub:type="footnote"><sup>1</sup></a></span></p>
               <div align="center" class="table_container">
                 <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                   <thead>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">X</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                         <p>1</p>
                         <p>2</p>
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">2</td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                         <ol type="a">
                           <li>3</li>
                           <li>3</li>
                           <li>3</li>
                         </ol>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                         <p>1</p>
                         <p>2</p>
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                         <p>1</p>
                         <p>2</p>
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">5<br/>5<br/>5<br/>5</td>
                     </tr>
                   </tbody>
                 </table>
               </div>
             </div>
             <p> </p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <aside id="ftn1">
               <p>X</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert.new({})
           .convert("test", input, true)
           .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(output)

    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
      <thead>
        <tr>
          <td>X</td>
        </tr>
      </thead>
      <tbody>
      <tr><td><p>1</p><p>2</p></td><td><p>3</p></td></tr>
      <tr><td>2</td></tr>
      <tr><td><ol><li>3</li><li>3</li><li>3</li></ol></td></tr>
      <tr><td><p>1</p><p>2</p></td><td><p>3</p></td></tr>
      <tr><td><p>1</p><p>2</p></td><td><p>3</p></td></tr>
      <tr><td>5<br/>5</td><td><br/>5<br/>5</td></tr>
      </tbody>
      </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
        <head> <style> </style> </head>
                     <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p> </p>
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
               <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield<span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#ftn1" epub:type="footnote"><sup>1</sup></a></span></p>
               <div align="center" class="table_container">
                 <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                   <thead>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">X</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>1</p>
                         <p>2</p>
                       </td>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">2</td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <ol type="a">
                           <li>3</li>
                           <li>3</li>
                           <li>3</li>
                         </ol>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>1</p>
                         <p>2</p>
                       </td>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>1</p>
                         <p>2</p>
                       </td>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">
                         <p>3</p>
                       </td>
                     </tr>
                     <tr>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">5<br/>5</td>
                       <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;"><br/>5<br/>5</td>
                     </tr>
                   </tbody>
                 </table>
               </div>
             </div>
             <p> </p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <aside id="ftn1">
               <p>X</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert.new({})
               .convert("test", input, true)
               .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to xmlpp(output)
  end
end
