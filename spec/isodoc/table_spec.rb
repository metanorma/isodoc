require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    mock_uuid_increment
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
            <foreword id="fwd">
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
              <td align="center"><dl><dt>6,06</dt><dd>Definition</dd></dl></td>
            </tr>
          </tfoot>
          <dl key="true">
             <name>Key</name>
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
              <source status="specialisation">
          <origin bibitemid="ISO712" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>2</referenceFrom>
              </locality>
            </localityStack>
          </origin>
        </source>
        <note><p>This is a table about rice</p></note>
        </table>
        <table id="tableD-2" unnumbered="true">
        <tbody><tr><td>A</td></tr></tbody>
        </table>
        </foreword>
        </preface>
        <annex id="Annex1">
        <table id="AnnexTable">
        <tbody><tr><td>A</td></td></tbody>
        </table>
        <table>
        <tbody><tr><td>B</td></td></tbody>
        </table>
        </annex>
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
                <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">
                      Repeatability and reproducibility of
                      <em>husked</em>
                      rice yield
                      <fn reference="1" original-reference="1" target="_" original-id="_">
                         <p>X</p>
                         <fmt-fn-label>
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </fmt-fn-label>
                      </fn>
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="tableD-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Repeatability and reproducibility of
                         <em>husked</em>
                         rice yield
                         <fn reference="1" original-reference="1" id="_" target="_">
                            <p>X</p>
                            <fmt-fn-label>
                               <sup>
                                  <semx element="autonum" source="_">1</semx>
                               </sup>
                            </fmt-fn-label>
                         </fn>
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="tableD-1">1</semx>
                   </fmt-xref-label>
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
                         <td valign="middle" align="center">
                            Drago
                            <fn reference="a" id="_" target="_">
                               <p original-id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td valign="bottom" align="center">
                            Balilla
                            <fn reference="a" id="_" target="_">
                               <p id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
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
                         <td align="left">
                            Reproducibility limit,
                            <stem type="AsciiMath" id="_">R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">R</semx>
                            </fmt-stem>
                            (= 2,83
                            <stem type="AsciiMath" id="_">s_R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">s_R</semx>
                            </fmt-stem>
                            )
                         </td>
                         <td align="center">2,89</td>
                         <td align="center">0,57</td>
                         <td align="center">2,26</td>
                         <td align="center">
                            <dl>
                               <dt>6,06</dt>
                               <dd>Definition</dd>
                            </dl>
                         </td>
                      </tr>
                   </tfoot>
                   <dl key="true">
                      <name id="_">Key</name>
                      <fmt-name>
                         <semx element="name" source="_">Key</semx>
                      </fmt-name>
                      <dt>Drago</dt>
                      <dd>A type of rice</dd>
                   </dl>
                   <source status="generalisation">
                      [SOURCE:
                      <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>1</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">ISO 712, Section 1</fmt-xref>
                      </semx>
                      —
                      <semx element="modification" source="_">with adjustments</semx>
                      ;
                      <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>2</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">ISO 712, Section 2</fmt-xref>
                      </semx>
                      ]
                   </source>
                   <note>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <p>This is a table about rice</p>
                   </note>
                   <fmt-footnote-container>
                      <fmt-fn-body id="_" target="_" reference="a">
                         <semx element="fn" source="_">
                            <p id="_">
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                                  <span class="fmt-caption-delim">
                                     <tab/>
                                  </span>
                               </fmt-fn-label>
                               Parboiled rice.
                            </p>
                         </semx>
                      </fmt-fn-body>
                   </fmt-footnote-container>
                </table>
                <table id="tableD-2" unnumbered="true">
                   <tbody>
                      <tr>
                         <td>A</td>
                      </tr>
                   </tbody>
                </table>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="3">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      International Organization for Standardization.
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>ISO 712, </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <annex id="Annex1" autonum="A" displayorder="4">
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Annex1">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(informative)</span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="Annex1">A</semx>
             </fmt-xref-label>
             <table id="AnnexTable" autonum="A.1">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="Annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AnnexTable">1</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexTable">1</semx>
                </fmt-xref-label>
                <tbody>
                   <tr>
                      <td>A</td>
                   </tr>
                </tbody>
             </table>
             <table>
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                   </span>
                </fmt-name>
                <tbody>
                   <tr>
                      <td>B</td>
                   </tr>
                </tbody>
             </table>
          </annex>
          <bibliography>
         </bibliography>
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      X
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
            #{HTML_HDR}
                         <br/>
               <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p class="TableTitle" style="text-align:center;">
                      Table 1 — Repeatability and reproducibility of
                      <i>husked</i>
                      rice yield
                      <a class="FootnoteRef" href="#fn:_7">
                         <sup>1</sup>
                      </a>
                   </p>
                   <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;width:70%;page-break-after: avoid;page-break-inside: avoid;table-layout:fixed;" title="tool tip">
                      <caption>
                         <span style="display:none">long desc</span>
                      </caption>
                      <colgroup>
                         <col style="width: 30%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 10%;"/>
                      </colgroup>
                      <thead>
                         <tr>
                            <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                            <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="colgroup">Rice sample</td>
                         </tr>
                         <tr>
                            <td style="text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Arborio</td>
                            <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">
                               Drago
                               <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                            </td>
                            <td style="text-align:center;vertical-align:bottom;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">
                               Balilla
                               <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                            </td>
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
                            <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                               Reproducibility limit,
                               <span class="stem">(#(R)#)</span>
                               (= 2,83
                               <span class="stem">(#(s_R)#)</span>
                               )
                            </td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,89</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">0,57</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,26</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                               <div class="figdl">
                                  <dl>
                                     <dt>
                                        <p>6,06</p>
                                     </dt>
                                     <dd>Definition</dd>
                                  </dl>
                               </div>
                            </td>
                         </tr>
                      </tfoot>
                      <div class="figdl">
                         <p class="ListTitle">Key</p>
                         <dl>
                            <dt>
                               <p>Drago</p>
                            </dt>
                            <dd>A type of rice</dd>
                         </dl>
                      </div>
                      <div class="BlockSource">
                         <p>
                            [SOURCE:
                            <a href="#ISO712">ISO 712, Section 1</a>
                            — with adjustments;
                            <a href="#ISO712">ISO 712, Section 2</a>
                            ]
                         </p>
                      </div>
                      <div class="Note">
                         <p>
                            <span class="note_label">NOTE  </span>
                            This is a table about rice
                         </p>
                      </div>
                      <aside id="fn:tableD-1a" class="footnote">
                         <p id="_">
                            <span class="TableFootnoteRef">a</span>
                              Parboiled rice.
                         </p>
                      </aside>
                   </table>
                   <table id="tableD-2" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <div>
                   <h1>1.  Normative References</h1>
                   <p id="ISO712" class="NormRef">
                      ISO 712, International Organization for Standardization.
                      <i>Cereals and cereal products</i>
                      .
                   </p>
                </div>
                <br/>
                <div id="Annex1" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (informative)
                   </h1>
                   <p class="TableTitle" style="text-align:center;">Table A.1</p>
                   <table id="AnnexTable" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                         </tr>
                      </tbody>
                   </table>
                   <p class="TableTitle" style="text-align:center;">Table</p>
                   <table class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <aside id="fn:_7" class="footnote">
                   <p>
                      X
                   </p>
                </aside>
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
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" style="text-align:center;">
                       Table 1 — Repeatability and reproducibility of
                       <i>husked</i>
                        rice yield
                       <span style="mso-bookmark:_Ref" class="MsoFootnoteReference"><a class="FootnoteRef" href="#ftn_7" epub:type="footnote">1</a></span>
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
                           <a href="#tableD-1a" class="TableFootnoteRef">a</a>
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
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                         <div class="figdl">
                           <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">6,06<span style="mso-tab-count:1">  </span>Definition</p>
                         </div>
                       </td>
                     </tr>
                   </tfoot>
                   <div class="figdl">
                     <p class="ListTitle">Key</p>
                     <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">Drago<span style="mso-tab-count:1">  </span>A type of rice</p>
                   </div>
                   <div class="BlockSource">
                     <p>[SOURCE: <a href="#ISO712">ISO 712, Section 1</a>
             — with adjustments; <a href="#ISO712">ISO 712, Section 2</a>]</p>
                   </div>
                   <div class="Note">
                     <p class="Note"><span class="note_label">NOTE<span style="mso-tab-count:1">  </span></span>This is a table about rice</p>
                   </div>
                   <aside id="ftntableD-1a">
                     <p id="_">
                        <span class="TableFootnoteRef">a</span>
                        <span style="mso-tab-count:1">  </span>
                        Parboiled rice.
                     </p>
                  </aside>
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
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
                        <div class="WordSection3">
                <div>
                   <h1>
                      1.
                      <span style="mso-tab-count:1">  </span>
                      Normative References
                   </h1>
                   <p id="ISO712" class="NormRef">
                      ISO 712, International Organization for Standardization.
                      <i>Cereals and cereal products</i>
                      .
                   </p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="Annex1" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (informative)
                   </h1>
                   <p class="TableTitle" style="text-align:center;">Table A.1</p>
                   <div align="center" class="table_container">
                      <table id="AnnexTable" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">A</td>
                            </tr>
                         </tbody>
                      </table>
                   </div>
                   <p class="TableTitle" style="text-align:center;">Table</p>
                   <div align="center" class="table_container">
                      <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">B</td>
                            </tr>
                         </tbody>
                      </table>
                   </div>
                </div>
                <aside id="ftn_7">
                   <p>X</p>
                </aside>
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
      .convert("test", pres_output, true)
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "passes on classes of tables from Presentation XML" do
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
          <clause type="toc" displayorder="1" id="_">
      <fmt-title depth="1">Table of contents</fmtfmt--title>
      </clause>
      <foreword id="_" displayorder="2"><fmt-title>Foreword</fmt-title>
        <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true" class="modspec">
          <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
        </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div id="_">
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
           <p class="section-break">
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection3'>
           </div>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
  .convert("test", presxml, true))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes tables with big cells" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
            <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
        <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
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
             <p class="section-break">
               <br clear='all' class='section'/>
             </p>
             <div class='WordSection2'>
               <p class="page-break">
                 <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
               </p>
               <div id="_">
                 <h1 class='ForewordTitle'>Foreword</h1>
                 <p class='TableTitle' style='text-align:center;'>
                   Repeatability and reproducibility of
                   <i>husked</i>
                    rice yield
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
             <p class="section-break">
               <br clear='all' class='section'/>
             </p>
             <div class="WordSection3"/>
           </body>
         </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", input, true))
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes tables with many rows" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield</p>
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3"/>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
        .convert("test", input, true))
        .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield</p>
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3"/>
        </body>
      </html>

    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
        .convert("test", input, true))
        .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes tables with large rows" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
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
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <p class="page-break">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_">
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield</p>
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
                       <div class="ol_wrap">
                         <ol type="a">
                           <li>3</li>
                           <li>3</li>
                           <li>3</li>
                         </ol>
                         </div>
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
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3"/>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
           .convert("test", input, true))
           .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword displayorder="1"><fmt-title>Foreword</fmt-title>
          <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
      <fmt-name>Repeatability and reproducibility of <em>husked</em> rice yield</fmt-name>
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
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <p class="page-break">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_">
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of <i>husked</i> rice yield</p>
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
                       <div class="ol_wrap">
                         <ol type="a">
                           <li>3</li>
                           <li>3</li>
                           <li>3</li>
                         </ol>
                         </div>
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
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3"/>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
               .convert("test", input, true))
               .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
