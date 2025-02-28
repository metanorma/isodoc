require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes figures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword id="fwd">
            <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
          <name>Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
          <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
          <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
          <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
          <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
          <fn reference="a">
          <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
        </fn>
          <fn reference="b">
          <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa853">Second footnote.</p>
        </fn>
          <dl>
          <dt>A</dt>
          <dd><p>B</p></dd>
          </dl>
                <source status="generalisation">
          <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
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
          <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
            <localityStack>
              <locality type="section">
                <referenceFrom>2</referenceFrom>
              </locality>
            </localityStack>
          </origin>
        </source>
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
            <annex id="Annex">
            <figure id="AnnexFigure">
        <pre>A &#x3c;
        B</pre>
        </figure>
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
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">
                      Split-it-right
                      <em>sample</em>
                      divider
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
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Split-it-right
                         <em>sample</em>
                         divider
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
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_" mimetype="application/xml"/>
                   <p keep-with-next="true">
                      <strong>Key</strong>
                   </p>
                   <dl class="formula_dl">
                      <dt>
                         <p>
                            <sup>a</sup>
                         </p>
                      </dt>
                      <dd>
                         <p id="_">
                            The time
                            <stem type="AsciiMath" id="_">t_90</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">t_90</semx>
                            </fmt-stem>
                            was estimated to be 18,2 min for this example.
                         </p>
                      </dd>
                      <dt>
                         <p>
                            <sup>b</sup>
                         </p>
                      </dt>
                      <dd>
                         <p id="_">Second footnote.</p>
                      </dd>
                      <dt>A</dt>
                      <dd>
                         <p>B</p>
                      </dd>
                   </dl>
                   <source status="generalisation">
                      [SOURCE:
                      <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
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
                      <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
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
                </figure>
                <figure id="figure-B" autonum="2">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figure-B">2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figure-B">2</semx>
                   </fmt-xref-label>
                   <pre alt="A B">A &lt;
         B</pre>
                </figure>
                <figure id="figure-C" unnumbered="true">
                   <pre>A &lt;
         B</pre>
                </figure>
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
          <annex id="Annex" autonum="A" displayorder="4">
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
             <figure id="AnnexFigure" autonum="A.1">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="Annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AnnexFigure">1</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="Annex">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexFigure">1</semx>
                </fmt-xref-label>
                <pre>A &lt;
         B</pre>
             </figure>
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
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                      <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                      <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
                      <img src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto"/>
                      <p style="page-break-after: avoid;">
                         <b>Key</b>
                      </p>
                      <div class="figdl">
                         <dl class="formula_dl">
                            <dt>
                               <p>
                                  <sup>a</sup>
                               </p>
                            </dt>
                            <dd>
                               <p id="_">
                                  The time
                                  <span class="stem">(#(t_90)#)</span>
                                  was estimated to be 18,2 min for this example.
                               </p>
                            </dd>
                            <dt>
                               <p>
                                  <sup>b</sup>
                               </p>
                            </dt>
                            <dd>
                               <p id="_">Second footnote.</p>
                            </dd>
                            <dt>
                               <p>A</p>
                            </dt>
                            <dd>
                               <p>B</p>
                            </dd>
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
                      <p class="FigureTitle" style="text-align:center;">
                         Figure 1 — Split-it-right
                         <i>sample</i>
                         divider
                         <a class="FootnoteRef" href="#fn:1">
                            <sup>1</sup>
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
                <div>
                   <h1>1.  Normative References</h1>
                   <p id="ISO712" class="NormRef">
                      ISO 712, International Organization for Standardization.
                      <i>Cereals and cereal products</i>
                      .
                   </p>
                </div>
                <br/>
                <div id="Annex" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (informative)
                   </h1>
                   <div id="AnnexFigure" class="figure">
                      <pre>A &lt;
         B</pre>
                      <p class="FigureTitle" style="text-align:center;">Figure A.1</p>
                   </div>
                </div>
                <aside id="fn:1" class="footnote">
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
                     <div id="figureA-1" class="figure"  style='page-break-after: avoid;page-break-inside: avoid;'>
               <img src="rice_images/rice_image1.png" height="20" width="30" alt="alttext" title="titletxt"/>
               <img src="rice_images/rice_image1.png" height='20' width='auto'/>
               <img src='_.gif' height='20' width='auto'/>
               <img src='_.xml' height='20' width='auto'/>
               <p  style='page-break-after: avoid;'><b>Key</b></p><table class="formula_dl">
                               <tr>
                    <td valign="top" align="left">
                        <p align="left" style="margin-left:0pt;text-align:left;">
                           <p>
                              <sup>a</sup>
                           </p>
                        </p>
                    </td>
                    <td valign="top">
                       <p id="_">
                          The time
                          <span class="stem">(#(t_90)#)</span>
                          was estimated to be 18,2 min for this example.
                       </p>
                    </td>
                 </tr>
                                 <tr>
                   <td valign="top" align="left">
                      <p align="left" style="margin-left:0pt;text-align:left;">
                         <p>
                            <sup>b</sup>
                         </p>
                      </p>
                   </td>
                   <td valign="top">
                      <p id="_">Second footnote.</p>
                   </td>
                </tr>
              <tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">A</p></td><td valign="top"><p>B</p></td></tr></table>
               <div class="BlockSource">
               <p>[SOURCE: <a href="#ISO712">ISO&#xa0;712, Section 1</a> &#x2014; with adjustments; <a href="#ISO712">ISO 712, Section 2</a>]</p>
               </div>
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
                 <p class="section-break"><br clear="all" class="section"/></p>
                 <div class="WordSection3">
                               <div>
               <h1>1.<span style="mso-tab-count:1">  </span>Normative References</h1>
               <p id="ISO712" class="NormRef">ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
             </div>
                      <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
         </p>
         <div id="Annex" class="Section3">
            <h1 class="Annex">
               <b>Annex A</b>
               <br/>
               (informative)
            </h1>
            <div id="AnnexFigure" class="figure">
               <pre>A &lt;
  B</pre>
               <p class="FigureTitle" style="text-align:center;">Figure A.1</p>
            </div>
         </div>
                    <aside id='ftn1'>
         <p>X</p>
       </aside>
               </body>
             </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword id="fwd">
           <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <figure id="note1">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         <figure id="note2">
       <name>Subfigure 2</name>
         <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
         </figure>
       </figure>
        <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered='true'>
         <name>Overall title</name>
         <figure id="note3">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </figure>
         <figure id="figureA-3" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <figure id="note4" unnumbered="true">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </figure>
           </foreword></preface>
           </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Overall title</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                         <span class="fmt-caption-delim"> — </span>
                         <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <figure id="note1" autonum="1-1">
                      <name id="_">Subfigure 1</name>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="figureA-1">1</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="note1">1</semx>
                         </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="note1">1</semx>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                   <figure id="note2" autonum="1-2">
                      <name id="_">Subfigure 2</name>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="figureA-1">1</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="note2">2</semx>
                         </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">Subfigure 2</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="note2">2</semx>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                   </figure>
                </figure>
                <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered="true">
                   <name id="_">Overall title</name>
                   <fmt-name>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <figure id="note3" autonum="-1">
                      <name id="_">Subfigure 1</name>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="figureA-2"/>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="note3">1</semx>
                         </span>
                         <span class="fmt-caption-delim"> — </span>
                         <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-2">(??)</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="note3">1</semx>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                </figure>
                <figure id="figureA-3" keep-with-next="true" keep-lines-together="true" autonum="2">
                   <name id="_">Overall title</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-3">2</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-3">2</semx>
                   </fmt-xref-label>
                   <figure id="note4" unnumbered="true">
                      <name id="_">Subfigure 1</name>
                      <fmt-name>
                         <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                </figure>
             </foreword>
          </preface>
       </iso-standard>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
                            <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note1" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Figure 1-1 — Subfigure 1</p>
                      </div>
                      <div id="note2" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <p class="FigureTitle" style="text-align:center;">Figure 1-2 — Subfigure 2</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note3" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Figure -1 — Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note4" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
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
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                <div id="note1" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  <p class="FigureTitle" style="text-align:center;">Figure 1-1 — Subfigure 1</p>
                </div>
                <div id="note2" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                  <p class="FigureTitle" style="text-align:center;">Figure 1-2 — Subfigure 2</p>
                </div>
                <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
              </div>
                          <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
               <div id="note3" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  <p class="FigureTitle" style="text-align:center;">Figure -1 — Subfigure 1</p>
               </div>
               <p class="FigureTitle" style="text-align:center;">Overall title</p>
            </div>
            <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
               <div id="note4" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
               </div>
               <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
            </div>
            </div>
            <p> </p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes figure classes, existing figure keys" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" class="diagram">
        <name>Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
        <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
        <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
        <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
        <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
        <fn reference="a">
        <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
      </fn>
        <dl><name>Key of figure</name>
        <dt>A</dt>
        <dd><p>B</p></dd>
        </dl>
      </figure>
      <figure id="figure-B" class="plate">
      <pre alt="A B">A &#x3c;
      B</pre>
      </figure>
      <figure id="figure-C" unnumbered="true" class="diagram">
      <pre>A &#x3c;
      B</pre>
      </figure>
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
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" class="diagram" autonum="1">
                   <name id="_">
                      Split-it-right
                      <em>sample</em>
                      divider
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
                         <span class="fmt-element-name">Diagram</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Split-it-right
                         <em>sample</em>
                         divider
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
                      <span class="fmt-element-name">Diagram</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_" mimetype="application/xml"/>
                   <dl class="formula_dl">
                      <name id="_">Key of figure</name>
                      <fmt-name>
                         <semx element="name" source="_">Key of figure</semx>
                      </fmt-name>
                      <dt>
                         <p>
                            <sup>a</sup>
                         </p>
                      </dt>
                      <dd>
                         <p id="_">
                            The time
                            <stem type="AsciiMath" id="_">t_90</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">t_90</semx>
                            </fmt-stem>
                            was estimated to be 18,2 min for this example.
                         </p>
                      </dd>
                      <dt>A</dt>
                      <dd>
                         <p>B</p>
                      </dd>
                   </dl>
                </figure>
                <figure id="figure-B" class="plate" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Plate</span>
                         <semx element="autonum" source="figure-B">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Plate</span>
                      <semx element="autonum" source="figure-B">1</semx>
                   </fmt-xref-label>
                   <pre alt="A B">A &lt;
       B</pre>
                </figure>
                <figure id="figure-C" unnumbered="true" class="diagram">
                   <pre>A &lt;
       B</pre>
                </figure>
             </foreword>
          </preface>
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true).gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes raw SVG" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1">
          <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                   <circle fill='#009' r='45' cx='50' cy='50'/>
                   <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                 </svg>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <?xml version='1.0'?>
             <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <preface>
      <clause type="toc" id="_" displayorder="1">
      <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
             <foreword displayorder='2' id="_">
                      <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <figure id="figureA-1" autonum="1">
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="figureA-1">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="figureA-1">1</semx>
            </fmt-xref-label>
                 <image src='' mimetype='image/svg+xml' height='auto' width='auto'>
                   <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                     <circle fill='#009' r='45' cx='50' cy='50'/>
                     <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                   </svg>
                 </image>
               </figure>
             </foreword>
           </preface>
         </iso-standard>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true)
        .gsub(/&lt;/, "&#x3c;")
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))))
      .to be_equivalent_to Xml::C14n.format(presxml
           .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
  end

  it "processes SVG" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1">
          <image src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj4KICA8Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPgogIDxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz4KPC9zdmc+Cg==" id="_d3731866-1a07-435a-a6c2-1acd41023a4e" mimetype="image/svg+xml" height="200" width="200"/>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
             <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <preface>
      <clause type="toc" id="_" displayorder="1">
      <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
             <foreword displayorder='2' id="_">
                 <title id="_">Foreword</title>
        <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
        </fmt-title>
        <figure id="figureA-1" autonum="1">
           <fmt-name>
              <span class="fmt-caption-label">
                 <span class="fmt-element-name">Figure</span>
                 <semx element="autonum" source="figureA-1">1</semx>
              </span>
           </fmt-name>
           <fmt-xref-label>
              <span class="fmt-element-name">Figure</span>
              <semx element="autonum" source="figureA-1">1</semx>
           </fmt-xref-label>
                 <image src='' id='_' mimetype='image/svg+xml' height='200' width='200'>
                   <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                     <circle fill='#009' r='45' cx='50' cy='50'/>
                     <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                   </svg>
                   <emf src='data:image/emf;base64,AQAAAPwAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAWAQAACgAAAACAAAARwAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADIALgAxACAAKAA5AGMANgBkADQAMQBlACwAIAAyADAAMgAyAC0AMAA3AC0AMQA0ACkAIAAAAGkAbQBhAGcAZQAyADAAMgAyADAAOQAxADMALQA4ADMAMQA3ADYALQA2AHcAYwB1AGMAdgAuAGUAbQBmAAAAAAAAAAAAEQAAAAwAAAABAAAAJAAAACQAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAACAAAARgAAACwAAAAgAAAAU2NyZWVuPTEwMjA1eDEzMTgxcHgsIDIxNngyNzltbQBGAAAAMAAAACMAAABEcmF3aW5nPTEwMC4weDEwMC4wcHgsIDI2LjV4MjYuNW1tAAASAAAADAAAAAEAAAATAAAADAAAAAIAAAAWAAAADAAAABgAAAAYAAAADAAAAAAAAAAUAAAADAAAAA0AAAAnAAAAGAAAAAEAAAAAAAAAAACZAAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAApAQAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAApAQAAKgDAACoAwAApAQAAHECAACkBAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAADoBAACkBAAAPwAAAKgDAAA/AAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA/AAAAOgEAADoBAAA/AAAAcQIAAD8AAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAqAMAAD8AAACkBAAAOgEAAKQEAABxAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAACcAAAAYAAAAAQAAAAAAAAD///8ABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACdAQAARQEAADYAAAAQAAAAzwMAAEUBAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAXwQAAO0BAABkBAAA4wIAANsDAACRAwAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAFIDAAA+BAAAYQIAAHMEAACdAQAADgQAADYAAAAQAAAAnQEAAMkCAAA2AAAAEAAAAOICAADJAgAANgAAABAAAADiAgAAGgIAADYAAAAQAAAAnQEAABoCAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAADgAAABQAAAAAAAAAAAAAAFgEAAA='/>
                 </image>
               </figure>
             </foreword>
           </preface>
         </iso-standard>
    OUTPUT

    html = <<~HTML
      #{HTML_HDR}
              <br/>
                <div id="_">
                  <h1 class='ForewordTitle'>Foreword</h1>
                  <div id='figureA-1' class='figure'>
                    <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' height="200" width="200">
                      <circle fill='#009' r='45' cx='50' cy='50'/>
                      <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                    </svg>
                    <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
                  </div>
                </div>
              </div>
            </body>
          </html>
    HTML

    doc = <<~DOC
      #{WORD_HDR}
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div id="_">
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='figureA-1' class='figure'>
              <img src='_.emf' height='200' width='200'/>
                <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
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
    DOC

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(output
      .gsub(/&lt;/, "&#x3c;")
      .sub(%r{<metanorma-extension>.*</metanorma-extension}m, "")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))))
      .to be_equivalent_to Xml::C14n.format(presxml
         .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to strip_guid(Xml::C14n.format(html))
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", output, true)
      .gsub(/['"][^'".]+(?<!odf1)(?<!odf)\.emf['"]/, "'_.emf'")
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'"))))
      .to be_equivalent_to strip_guid(Xml::C14n.format(doc))
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
      <clause type="toc" id="_" displayorder="1">
      <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
            <foreword displayorder='2' id="_">
                <title id="_">Foreword</title>
        <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
        </fmt-title>
        <figure id="figureA-1" autonum="1">
           <fmt-name>
              <span class="fmt-caption-label">
                 <span class="fmt-element-name">Figure</span>
                 <semx element="autonum" source="figureA-1">1</semx>
              </span>
           </fmt-name>
           <fmt-xref-label>
              <span class="fmt-element-name">Figure</span>
              <semx element="autonum" source="figureA-1">1</semx>
           </fmt-xref-label>
                <image src='spec/assets/odf.svg' mimetype='image/svg+xml'>
                  <emf src='spec/assets/odf.emf'/>
                </image>
                <image src='spec/assets/odf1.svg' mimetype='image/svg+xml'>
                  <emf src='data:image/emf;base64,AQAAANAAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEALAQAACgAAAACAAAAMQAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADIALgAxACAAKAA5AGMANgBkADQAMQBlACwAIAAyADAAMgAyAC0AMAA3AC0AMQA0ACkAIAAAAG8AZABmADEALgBlAG0AZgAAAAAAAAAAABEAAAAMAAAAAQAAACQAAAAkAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAgAAAEYAAAAsAAAAIAAAAFNjcmVlbj0xMDIwNXgxMzE4MXB4LCAyMTZ4Mjc5bW0ARgAAADAAAAAjAAAARHJhd2luZz0xMDAuMHgxMDAuMHB4LCAyNi41eDI2LjVtbQAAEgAAAAwAAAABAAAAEwAAAAwAAAACAAAAFgAAAAwAAAAYAAAAGAAAAAwAAAAAAAAAFAAAAAwAAAANAAAAJwAAABgAAAABAAAAAAAAAAAAmQAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAKQEAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAKQEAACoAwAAqAMAAKQEAABxAgAApAQAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA6AQAApAQAAD8AAACoAwAAPwAAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAPwAAADoBAAA6AQAAPwAAAHECAAA/AAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAKgDAAA/AAAApAQAADoBAACkBAAAcQIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAnAAAAGAAAAAEAAAAAAAAA////AAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAAnQEAAEUBAAA2AAAAEAAAAM8DAABFAQAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAF8EAADtAQAAZAQAAOMCAADbAwAAkQMAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABSAwAAPgQAAGECAABzBAAAnQEAAA4EAAA2AAAAEAAAAJ0BAADJAgAANgAAABAAAADiAgAAyQIAADYAAAAQAAAA4gIAABoCAAA2AAAAEAAAAJ0BAAAaAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAAA4AAAAUAAAAAAAAAAAAAAAsBAAA'/>
                </image>
                <image src='' id='_' mimetype='image/svg+xml' height='' width=''>
                  <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                    <circle fill='#009' r='45' cx='50' cy='50'/>
                    <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                  </svg>
                  <emf src='data:image/emf;base64,AQAAAPwAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAWAQAACgAAAACAAAARwAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADIALgAxACAAKAA5AGMANgBkADQAMQBlACwAIAAyADAAMgAyAC0AMAA3AC0AMQA0ACkAIAAAAGkAbQBhAGcAZQAyADAAMgAyADAAOQAxADMALQA4ADMAMAAzADIALQBsADkAcQByAG8AZgAuAGUAbQBmAAAAAAAAAAAAEQAAAAwAAAABAAAAJAAAACQAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAACAAAARgAAACwAAAAgAAAAU2NyZWVuPTEwMjA1eDEzMTgxcHgsIDIxNngyNzltbQBGAAAAMAAAACMAAABEcmF3aW5nPTEwMC4weDEwMC4wcHgsIDI2LjV4MjYuNW1tAAASAAAADAAAAAEAAAATAAAADAAAAAIAAAAWAAAADAAAABgAAAAYAAAADAAAAAAAAAAUAAAADAAAAA0AAAAnAAAAGAAAAAEAAAAAAAAAAACZAAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAApAQAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAApAQAAKgDAACoAwAApAQAAHECAACkBAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAADoBAACkBAAAPwAAAKgDAAA/AAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA/AAAAOgEAADoBAAA/AAAAcQIAAD8AAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAqAMAAD8AAACkBAAAOgEAAKQEAABxAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAACcAAAAYAAAAAQAAAAAAAAD///8ABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACdAQAARQEAADYAAAAQAAAAzwMAAEUBAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAXwQAAO0BAABkBAAA4wIAANsDAACRAwAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAFIDAAA+BAAAYQIAAHMEAACdAQAADgQAADYAAAAQAAAAnQEAAMkCAAA2AAAAEAAAAOICAADJAgAANgAAABAAAADiAgAAGgIAADYAAAAQAAAAnQEAABoCAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAADgAAABQAAAAAAAAAAAAAAFgEAAA='/>
                </image>
                <image src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto' id='_' mimetype='application/xml'/>
              </figure>
            </foreword>
          </preface>
        </iso-standard>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div id="_">
              <h1 class='ForewordTitle'>Foreword</h1>
              <div id='figureA-1' class='figure'>
                <img src='spec/assets/odf.emf'  height='' width=''/>
                <img src='_.emf'  height='' width=''/>
                <img src='_.emf' height='' width=''/>
                 <img src='_.xml' height='20' width='auto'/>
                 <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
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
    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(output
      .sub(%r{<metanorma-extension>.*</metanorma-extension}m, "")
     .gsub(/&lt;/, "&#x3c;"))
          .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_equivalent_to Xml::C14n.format(presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", output, true)
      .gsub(/['"][^'".]+(?<!odf1)(?<!odf)\.emf['"]/, "'_.emf'")
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to strip_guid(Xml::C14n.format(word))
  end

  it "does not label embedded figures, sourcecode" do
    input = <<~INPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata>
            <language>en</language>
            </bibdata>
                <preface>
      <clause type="toc" id="_" displayorder="1">
        <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
                <foreword id="_" displayorder="2"><fmt-title>Foreword</fmt-title>
                <example>
                <sourcecode id="B"><name>Label</name>A B C</sourcecode>
          <figure id="A" class="pseudocode"><fmt-name>Label</fmt-name><p id="_">  <strong>A</strong></p></figure>
                <sourcecode id="B1">A B C</sourcecode>
          <figure id="A1" class="pseudocode"><p id="_">  <strong>A</strong></p></figure>
        </example></foreword>
        </preface></itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div id="_">
            <h1 class='ForewordTitle'>Foreword</h1>
                     <div class='example'>
                       <pre id='B' class='sourcecode'>A B C</pre>
                       <div id='A' class='pseudocode'>
                         <p id='_'>
                           &#160;&#160;
                           <b>A</b>
                         </p>
                         <p class='SourceTitle' style='text-align:center;'>Label</p>
                       </div>
                       <pre id='B1' class='sourcecode'>A B C</pre>
                       <div id='A1' class='pseudocode'>
                         <p id='_'>
                           &#160;&#160;
                           <b>A</b>
                         </p>
                       </div>
                     </div>
                   </div>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <image src='spec/assets/action_schemaexpg1.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto'/>
      </figure>
      <svgmap id='_'>
        <figure id='_'>
          <image src='spec/assets/action_schemaexpg2.svg' id='_' mimetype='image/svg+xml' height='auto' width='auto' alt='Workmap'/>
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
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <svgmap id="_">
                <target href="http://www.example.com">
                   <xref target="ref1" id="_">Computer</xref>
                   <semx element="xref" source="_">
                      <fmt-xref target="ref1">Computer</fmt-xref>
                   </semx>
                </target>
             </svgmap>
             <figure id="_">
                <image src="spec/assets/action_schemaexpg1.svg" id="_" mimetype="image/svg+xml" height="auto" width="auto"/>
             </figure>
             <svgmap id="_">
                <figure original-id="_">
                   <image src="spec/assets/action_schemaexpg2.svg" mimetype="image/svg+xml" height="auto" width="auto" alt="Workmap" original-id="_"/>
                </figure>
                <target href="mn://support_resource_schema">
                   <eref bibitemid="express_action_schema" citeas="" id="_">
                      <localityStack>
                         <locality type="anchor">
                            <referenceFrom>action_schema.basic</referenceFrom>
                         </locality>
                      </localityStack>
                      Coffee
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref target="express_action_schema">

               Coffee
             </fmt-xref>
                   </semx>
                </target>
             </svgmap>
             <semx element="svgmap" source="_">
                <figure id="_">
                   <image src="spec/assets/action_schemaexpg2.svg" id="_" mimetype="image/svg+xml" height="auto" width="auto" alt="Workmap"/>
                </figure>
             </semx>
          </sections>
          <bibliography>
             <references hidden="true" normative="false" displayorder="2" id="_">
                <bibitem id="express_action_schema" type="internal">
                   <docidentifier type="repository">express/action_schema</docidentifier>
                   <docidentifier scope="biblio-tag">express/action_schema</docidentifier>
                   <biblio-tag>
                      [1]
                      <tab/>
                      express/action_schema,
                   </biblio-tag>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT
    FileUtils.rm_rf("spec/assets/action_schemaexpg1.emf")
    FileUtils.rm_rf("spec/assets/action_schemaexpg2.emf")
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"\.\\}, '"./')
      .gsub(%r{'\.\\}, "'./")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
