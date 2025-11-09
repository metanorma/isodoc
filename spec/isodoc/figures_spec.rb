require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes figures" do
    mock_uuid_increment
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
        <source status="specialisation">
          <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
            <localityStack>
              <locality type="section">
                <referenceFrom>3</referenceFrom>
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
            <clause type="toc" id="_8" displayorder="1">
               <fmt-title depth="1" id="_25">Table of contents</fmt-title>
            </clause>
            <foreword id="fwd" displayorder="2">
               <title id="_11">Foreword</title>
               <fmt-title depth="1" id="_26">
                  <semx element="title" source="_11">Foreword</semx>
               </fmt-title>
               <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_15">
                     Split-it-right
                     <em>sample</em>
                     divider
                     <fn original-id="_1" original-reference="1">
                        <p>X</p>
                     </fn>
                  </name>
                  <fmt-name id="_27">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Figure</span>
                        <semx element="autonum" source="figureA-1">1</semx>
                     </span>
                     <span class="fmt-caption-delim">\u00a0— </span>
                     <semx element="name" source="_15">
                        Split-it-right
                        <em>sample</em>
                        divider
                        <fn reference="1" id="_1" original-reference="1" target="_19">
                           <p>X</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_1">1</semx>
                                 </sup>
                              </span>
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
                  <fn reference="a" id="_2" target="_13">
                     <p original-id="_">
                        The time
                        <stem type="AsciiMath" id="_23">t_90</stem>
                        <fmt-stem type="AsciiMath">
                           <semx element="stem" source="_23">t_90</semx>
                        </fmt-stem>
                        was estimated to be 18,2 min for this example.
                     </p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_2">a</semx>
                           </sup>
                        </span>
                     </fmt-fn-label>
                  </fn>
                  <fn reference="b" id="_3" target="_14">
                     <p original-id="_">Second footnote.</p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_3">b</semx>
                           </sup>
                        </span>
                     </fmt-fn-label>
                  </fn>
                  <p keep-with-next="true">
                     <strong>Key</strong>
                  </p>
                  <dl class="formula_dl">
                     <dt>
                        <p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_2">a</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </p>
                     </dt>
                     <dd>
                        <fmt-fn-body id="_13" target="_2" reference="a">
                           <semx element="fn" source="_2">
                              <p id="_">
                                 The time
                                 <stem type="AsciiMath" id="_24">t_90</stem>
                                 <fmt-stem type="AsciiMath">
                                    <semx element="stem" source="_24">t_90</semx>
                                 </fmt-stem>
                                 was estimated to be 18,2 min for this example.
                              </p>
                           </semx>
                        </fmt-fn-body>
                     </dd>
                     <dt>
                        <p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_3">b</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </p>
                     </dt>
                     <dd>
                        <fmt-fn-body id="_14" target="_3" reference="b">
                           <semx element="fn" source="_3">
                              <p id="_">Second footnote.</p>
                           </semx>
                        </fmt-fn-body>
                     </dd>
                     <dt>A</dt>
                     <dd>
                        <p>B</p>
                     </dd>
                  </dl>
                  <source status="generalisation" id="_4">
                     <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>1</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                     <modification id="_5">
                        <p id="_">with adjustments</p>
                     </modification>
                  </source>
                  <fmt-source>
                     [SOURCE:
                     <semx element="source" source="_4">
                        <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_20">
                           <localityStack>
                              <locality type="section">
                                 <referenceFrom>1</referenceFrom>
                              </locality>
                           </localityStack>
                        </origin>
                        <semx element="origin" source="_20">
                           <fmt-xref type="inline" target="ISO712">ISO\u00a0712, Section 1</fmt-xref>
                        </semx>
                        —
                        <semx element="modification" source="_5">with adjustments</semx>
                     </semx>
                     ;
                     <semx element="source" source="_6">
                        <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_21">
                           <localityStack>
                              <locality type="section">
                                 <referenceFrom>2</referenceFrom>
                              </locality>
                           </localityStack>
                        </origin>
                        <semx element="origin" source="_21">
                           <fmt-xref type="inline" target="ISO712">ISO\u00a0712, Section 2</fmt-xref>
                        </semx>
                     </semx>
                     ;
                     <semx element="source" source="_7">
                        <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_22">
                           <localityStack>
                              <locality type="section">
                                 <referenceFrom>3</referenceFrom>
                              </locality>
                           </localityStack>
                        </origin>
                        <semx element="origin" source="_22">
                           <fmt-xref type="inline" target="ISO712">ISO\u00a0712, Section 3</fmt-xref>
                        </semx>
                     </semx>
                     ]
                  </fmt-source>
                  <source status="specialisation" id="_6">
                     <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>2</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                  </source>
                  <source status="specialisation" id="_7">
                     <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>3</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                  </source>
               </figure>
               <figure id="figure-B" autonum="2">
                  <fmt-name id="_28">
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
            <references id="_normative_references" obligation="informative" normative="true" displayorder="3">
               <title id="_12">Normative References</title>
               <fmt-title depth="1" id="_29">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_normative_references">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_12">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_normative_references">1</semx>
               </fmt-xref-label>
               <bibitem id="ISO712" type="standard">
                  <biblio-tag>ISO\u00a0712, </biblio-tag>
                  <formattedref>
                     International Organization for Standardization.
                     <em>Cereals and cereal products</em>
                     .
                  </formattedref>
                  <title format="text/plain">Cereals or cereal products</title>
                  <title type="main" format="text/plain">Cereals and cereal products</title>
                  <docidentifier type="ISO">ISO\u00a0712</docidentifier>
                  <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>International Organization for Standardization</name>
                     </organization>
                  </contributor>
               </bibitem>
            </references>
         </sections>
         <annex id="Annex" autonum="A" displayorder="4">
            <fmt-title id="_30">
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
               <fmt-name id="_31">
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
            <fmt-fn-body id="_19" target="_1" reference="1">
               <semx element="fn" source="_1">
                  <p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_1">1</semx>
                           </sup>
                        </span>
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
                      <a href="#figureA-1a" class="TableFootnoteRef">a</a>
                      <a href="#figureA-1b" class="TableFootnoteRef">b</a>
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
                               <div id="fn:figureA-1a" class="footnote">
                                  <p id="_">
                                     The time
                                     <span class="stem">(#(t_90)#)</span>
                                     was estimated to be 18,2 min for this example.
                                  </p>
                               </div>
                            </dd>
                            <dt>
                               <p>
                                  <sup>b</sup>
                               </p>
                            </dt>
                            <dd>
                               <div id="fn:figureA-1b" class="footnote">
                                  <p id="_">Second footnote.</p>
                               </div>
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
                            <a href="#ISO712">ISO\u00a0712, Section 1</a>
                            — with adjustments;
                            <a href="#ISO712">ISO\u00a0712, Section 2</a>
                            ;
                            <a href="#ISO712">ISO\u00a0712, Section 3</a>
                            ]
                         </p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">
                         Figure 1\u00a0— Split-it-right
                         <i>sample</i>
                         divider
                         <a class="FootnoteRef" href="#fn:_19">
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
                   <h1>1.\u00a0 Normative References</h1>
                   <p id="ISO712" class="NormRef">
                      ISO\u00a0712, International Organization for Standardization.
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
                <aside id="fn:_19" class="footnote">
                   <p>X</p>
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
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                      <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                      <img src='_.gif' height="20" width="auto"/>
                      <img src='_.xml' height="20" width="auto"/>
                      <a href="#figureA-1a" class="TableFootnoteRef">a</a>
                      <a href="#figureA-1b" class="TableFootnoteRef">b</a>
                      <p style="page-break-after: avoid;">
                         <b>Key</b>
                      </p>
                      <div align="left">
                         <table style="text-align:left;" class="formula_dl">
                            <tr>
                               <td valign="top" align="left">
                                  <p align="left" style="margin-left:0pt;text-align:left;">
                                     <p>
                                        <sup>a</sup>
                                     </p>
                                  </p>
                               </td>
                               <td valign="top">
                                  <div id="ftnfigureA-1a">
                                     <p id="_">
                                        The time
                                        <span class="stem">(#(t_90)#)</span>
                                        was estimated to be 18,2 min for this example.
                                     </p>
                                  </div>
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
                                  <div id="ftnfigureA-1b">
                                     <p id="_">Second footnote.</p>
                                  </div>
                               </td>
                            </tr>
                            <tr>
                               <td valign="top" align="left">
                                  <p align="left" style="margin-left:0pt;text-align:left;">A</p>
                               </td>
                               <td valign="top">
                                  <p>B</p>
                               </td>
                            </tr>
                         </table>
                      </div>
                      <div class="BlockSource">
                         <p>
                            [SOURCE:
                            <a href="#ISO712">ISO\u00a0712, Section 1</a>
                            — with adjustments;
                            <a href="#ISO712">ISO\u00a0712, Section 2</a>
                            ;
                            <a href="#ISO712">ISO\u00a0712, Section 3</a>
                            ]
                         </p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">
                         Figure 1\u00a0— Split-it-right
                         <i>sample</i>
                         divider
                         <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                            <a class="FootnoteRef" epub:type="footnote" href="#ftn_19">1</a>
                         </span>
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
                <p>\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
                <div>
                   <h1>
                      1.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Normative References
                   </h1>
                   <p id="ISO712" class="NormRef">
                      ISO\u00a0712, International Organization for Standardization.
                      <i>Cereals and cereal products</i>
                      .
                   </p>
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
                <aside id="ftn_19">
                   <p>X</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .gsub(/&lt;/, "&#x3c;")))
      .to be_xml_equivalent_to presxml

   output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
    .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to html

    FileUtils.rm_rf "spec/assets/odf1.emf"
    output = Nokogiri::HTML4(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html
        .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
        .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")))
      .to be_html4_equivalent_to word
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword displayorder="2" id="fwd">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_">Overall title</name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Figure</span>
                        <semx element="autonum" source="figureA-1">1</semx>
                     </span>
                        <span class="fmt-caption-delim">\u00a0— </span>
                        <semx element="name" source="_">Overall title</semx>
                  </fmt-name>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Figure</span>
                     <semx element="autonum" source="figureA-1">1</semx>
                  </fmt-xref-label>
                  <figure id="note1" autonum="1-1">
                     <name id="_">Subfigure 1</name>
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Figure</span>
                           <semx element="autonum" source="figureA-1">1</semx>
                           <span class="fmt-autonum-delim">-</span>
                           <semx element="autonum" source="note1">1</semx>
                        </span>
                           <span class="fmt-caption-delim">\u00a0— </span>
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
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Figure</span>
                           <semx element="autonum" source="figureA-1">1</semx>
                           <span class="fmt-autonum-delim">-</span>
                           <semx element="autonum" source="note2">2</semx>
                        </span>
                           <span class="fmt-caption-delim">\u00a0— </span>
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
                  <fmt-name id="_">
                     <semx element="name" source="_">Overall title</semx>
                  </fmt-name>
                  <figure id="note3" autonum="-1">
                     <name id="_">Subfigure 1</name>
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Figure</span>
                           <semx element="autonum" source="figureA-2"/>
                           <span class="fmt-autonum-delim">-</span>
                           <semx element="autonum" source="note3">1</semx>
                        </span>
                        <span class="fmt-caption-delim">\u00a0— </span>
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
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Figure</span>
                        <semx element="autonum" source="figureA-3">2</semx>
                     </span>
                     <span class="fmt-caption-delim">\u00a0— </span>
                     <semx element="name" source="_">Overall title</semx>
                  </fmt-name>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Figure</span>
                     <semx element="autonum" source="figureA-3">2</semx>
                  </fmt-xref-label>
                  <figure id="note4" unnumbered="true">
                     <name id="_">Subfigure 1</name>
                     <fmt-name id="_">
                        <semx element="name" source="_">Subfigure 1</semx>
                     </fmt-name>
                     <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                  </figure>
               </figure>
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
                         <p class="FigureTitle" style="text-align:center;">Figure 1-1\u00a0— Subfigure 1</p>
                      </div>
                      <div id="note2" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <p class="FigureTitle" style="text-align:center;">Figure 1-2\u00a0— Subfigure 2</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1\u00a0— Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note3" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Figure -1\u00a0— Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note4" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2\u00a0— Overall title</p>
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
                  <p class="FigureTitle" style="text-align:center;">Figure 1-1\u00a0— Subfigure 1</p>
                </div>
                <div id="note2" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                  <p class="FigureTitle" style="text-align:center;">Figure 1-2\u00a0— Subfigure 2</p>
                </div>
                <p class="FigureTitle" style="text-align:center;">Figure 1\u00a0— Overall title</p>
              </div>
                          <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
               <div id="note3" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  <p class="FigureTitle" style="text-align:center;">Figure -1\u00a0— Subfigure 1</p>
               </div>
               <p class="FigureTitle" style="text-align:center;">Overall title</p>
            </div>
            <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
               <div id="note4" class="figure">
                  <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                  <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
               </div>
               <p class="FigureTitle" style="text-align:center;">Figure 2\u00a0— Overall title</p>
            </div>
            </div>
            <p>\u00a0</p>
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
    expect(strip_guid(pres_output
      .gsub(/&lt;/, "&#x3c;")))
      .to be_xml_equivalent_to presxml
    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output))
      .to be_html5_equivalent_to html
    FileUtils.rm_rf "spec/assets/odf1.emf"
    word_output = IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")
    expect(strip_guid(word_output))
      .to be_html4_equivalent_to word
  end

  it "processes tabular subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword id="fwd">
           <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <table id="T" plain="true">
         <tbody>
         <tr>
         <td>
         <figure id="note1">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </td>
         <td>
         <figure id="note2">
       <name>Subfigure 2</name>
         <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
         </figure>
         </td>
         </tr>
         </tbody>
         </table>
       </figure>
        <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered='true'>
         <name>Overall title</name>
        <table id="T1" plain="true">
         <tbody>
         <tr>
         <td>
         <figure id="note3">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </td>
         </tr>
         </tbody>
         </table>
         </figure>
         <figure id="figureA-3" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <table id="T2" plain="true">
         <tbody>
         <tr>
         <td>
         <figure id="note4" unnumbered="true">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </tr>
         </tbody>
         </table>
         </figure>
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
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim">\u00a0— </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <table id="T" plain="true">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note1" autonum="1-1">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <span class="fmt-element-name">Figure</span>
                                        <semx element="autonum" source="">1</semx>
                                        <span class="fmt-autonum-delim">-</span>
                                        <semx element="autonum" source="note1">1</semx>
                                     </span>
                                     <span class="fmt-caption-delim">\u00a0— </span>
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
                            </td>
                            <td>
                               <figure id="note2" autonum="1-2">
                                  <name id="_">Subfigure 2</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <span class="fmt-element-name">Figure</span>
                                        <semx element="autonum" source="">1</semx>
                                        <span class="fmt-autonum-delim">-</span>
                                        <semx element="autonum" source="note2">2</semx>
                                     </span>
                                     <span class="fmt-caption-delim">\u00a0— </span>
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
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
                <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered="true">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <table id="T1" plain="true">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note3" autonum="-1">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <span class="fmt-element-name">Figure</span>
                                        <semx element="autonum" source=""/>
                                        <span class="fmt-autonum-delim">-</span>
                                        <semx element="autonum" source="note3">1</semx>
                                     </span>
                                     <span class="fmt-caption-delim">\u00a0— </span>
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
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
                <figure id="figureA-3" keep-with-next="true" keep-lines-together="true" autonum="2">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-3">2</semx>
                      </span>
                      <span class="fmt-caption-delim">\u00a0— </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-3">2</semx>
                   </fmt-xref-label>
                   <table id="T2" plain="true">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note4" unnumbered="true">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <semx element="name" source="_">Subfigure 1</semx>
                                  </fmt-name>
                                  <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                               </figure>
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
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
                      <table id="T">
                         <tbody>
                            <tr>
                               <td style="">
                                  <div id="note1" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">Figure 1-1\u00a0— Subfigure 1</p>
                                  </div>
                               </td>
                               <td style="">
                                  <div id="note2" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                                     <p class="FigureTitle" style="text-align:center;">Figure 1-2\u00a0— Subfigure 2</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Figure 1\u00a0— Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <table id="T1">
                         <tbody>
                            <tr>
                               <td style="">
                                  <div id="note3" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">Figure -1\u00a0— Subfigure 1</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <table id="T2">
                         <tbody>
                            <tr>
                               <td style="">
                                  <div id="note4" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Figure 2\u00a0— Overall title</p>
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
                      <div align="center" class="table_container">
                         <table id="T" class="MsoNormalTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                            <tbody>
                               <tr>
                                  <td style="page-break-after:auto;">
                                     <div id="note1" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">Figure 1-1\u00a0— Subfigure 1</p>
                                     </div>
                                  </td>
                                  <td style="page-break-after:auto;">
                                     <div id="note2" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                                        <p class="FigureTitle" style="text-align:center;">Figure 1-2\u00a0— Subfigure 2</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1\u00a0— Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div align="center" class="table_container">
                         <table id="T1" class="MsoNormalTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                            <tbody>
                               <tr>
                                  <td style="page-break-after:auto;">
                                     <div id="note3" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">Figure -1\u00a0— Subfigure 1</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div align="center" class="table_container">
                         <table id="T2" class="MsoNormalTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                            <tbody>
                               <tr>
                                  <td style="page-break-after:auto;">
                                     <div id="note4" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2\u00a0— Overall title</p>
                   </div>
                </div>
                <p>\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .gsub(/&lt;/, "&#x3c;")))
      .to be_xml_equivalent_to presxml
    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output))
      .to be_html5_equivalent_to html
    FileUtils.rm_rf "spec/assets/odf1.emf"
    word_output = IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")
    expect(strip_guid(word_output))
      .to be_html4_equivalent_to word
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
               <fmt-title depth="1" id="_">Table of contents</fmt-title>
            </clause>
            <foreword id="fwd" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title depth="1" id="_">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" class="diagram" autonum="1">
                  <name id="_">
                     Split-it-right
                     <em>sample</em>
                     divider
                     <fn original-id="_" original-reference="1">
                        <p>X</p>
                     </fn>
                  </name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Diagram</span>
                        <semx element="autonum" source="figureA-1">1</semx>
                     </span>
                     <span class="fmt-caption-delim">\u00a0— </span>
                     <semx element="name" source="_">
                        Split-it-right
                        <em>sample</em>
                        divider
                        <fn reference="1" id="_" original-reference="1" target="_">
                           <p>X</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_">1</semx>
                                 </sup>
                              </span>
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
                  <fn reference="a" id="_" target="_">
                     <p original-id="_">
                        The time
                        <stem type="AsciiMath" id="_">t_90</stem>
                        <fmt-stem type="AsciiMath">
                           <semx element="stem" source="_">t_90</semx>
                        </fmt-stem>
                        was estimated to be 18,2 min for this example.
                     </p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">a</semx>
                           </sup>
                        </span>
                     </fmt-fn-label>
                  </fn>
                  <dl class="formula_dl">
                     <name id="_">Key of figure</name>
                     <fmt-name id="_">
                        <semx element="name" source="_">Key of figure</semx>
                     </fmt-name>
                     <dt>
                        <p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_">a</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </p>
                     </dt>
                     <dd>
                        <fmt-fn-body id="_" target="_" reference="a">
                           <semx element="fn" source="_">
                              <p id="_">
                                 The time
                                 <stem type="AsciiMath" id="_">t_90</stem>
                                 <fmt-stem type="AsciiMath">
                                    <semx element="stem" source="_">t_90</semx>
                                 </fmt-stem>
                                 was estimated to be 18,2 min for this example.
                              </p>
                           </semx>
                        </fmt-fn-body>
                     </dd>
                     <dt>A</dt>
                     <dd>
                        <p>B</p>
                     </dd>
                  </dl>
               </figure>
               <figure id="figure-B" class="plate" autonum="1">
                  <fmt-name id="_">
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
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">1</semx>
                           </sup>
                        </span>
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
    expect(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true).gsub(/&lt;/, "&#x3c;")))
      .to be_xml_equivalent_to presxml
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
             <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <preface>
      <clause type="toc" id="_" displayorder="1">
      <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
             <foreword displayorder='2' id="_">
                      <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <figure id="figureA-1" autonum="1">
            <fmt-name id="_">
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
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
                     <circle fill='#009' r='45' cx='50' cy='50'/>
                     <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                   </svg>
                 </image>
               </figure>
             </foreword>
           </preface>
         </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(/&lt;/, "&#x3c;")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")
    expect(strip_guid(pres_output))
      .to be_xml_equivalent_to presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")
  end

  it "processes SVG with viewbox" do
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
      <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
             <foreword displayorder='2' id="_">
                 <title id="_">Foreword</title>
        <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
        </fmt-title>
        <figure id="figureA-1" autonum="1">
           <fmt-name id="_">
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
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
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
                    <div class="svg-container">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
                     <circle fill="#009" r="45" cx="50" cy="50"/>
                     <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
                  </svg>
               </div>
                    <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
                  </div>
                </div>
              </div>
            </body>
          </html>
    HTML

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(strip_guid(output
      .gsub(/&lt;/, "&#x3c;")
      .sub(%r{<metanorma-extension>.*</metanorma-extension}m, "")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_xml_equivalent_to presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)))
      .to be_html5_equivalent_to strip_guid(html)
  end

  it "processes SVG without viewbox" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1">
          <image src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMTAwIiB3aWR0aD0iMTAwIj4KICA8Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPgogIDxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz4KPC9zdmc+Cg==" id="_d3731866-1a07-435a-a6c2-1acd41023a4e" mimetype="image/svg+xml" height="200" width="200"/>
      </figure>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
             <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <preface>
      <clause type="toc" id="_" displayorder="1">
      <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
             <foreword displayorder='2' id="_">
                 <title id="_">Foreword</title>
        <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
        </fmt-title>
        <figure id="figureA-1" autonum="1">
           <fmt-name id="_">
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
                   <svg xmlns="http://www.w3.org/2000/svg"  height="100" width="100" preserveaspectratio="xMidYMin slice">
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
                    <div class="svg-container">
                  <svg xmlns="http://www.w3.org/2000/svg" height="100" width="100" preserveaspectratio="xMidYMin slice" viewbox="0 0 100 100">
                     <circle fill="#009" r="45" cx="50" cy="50"/>
                     <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
                  </svg>
               </div>
                    <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
                  </div>
                </div>
              </div>
            </body>
          </html>
    HTML

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    pres_cleaned = output
      .gsub(/&lt;/, "&#x3c;")
      .sub(%r{<metanorma-extension>.*</metanorma-extension}m, "")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")
    expect(strip_guid(pres_cleaned))
      .to be_xml_equivalent_to presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")
    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)
    expect(strip_guid(html_output))
      .to be_html5_equivalent_to strip_guid(html)
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
      <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
            <foreword displayorder='2' id="_">
                <title id="_">Foreword</title>
        <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
        </fmt-title>
        <figure id="figureA-1" autonum="1">
           <fmt-name id="_">
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
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
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

    output = IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)

    expect(strip_guid(output
      .sub(%r{<metanorma-extension>.*</metanorma-extension}m, "")
     .gsub(/&lt;/, "&#x3c;"))
          .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
      .to be_xml_equivalent_to presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")

   word_html = strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", output, true)
      .gsub(/['"][^'".]+(?<!odf1)(?<!odf)\.emf['"]/, "'_.emf'")
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))

   expect(Nokogiri::HTML4(word_html))
      .to be_html4_equivalent_to strip_guid(word)
  end

  it "does not label embedded figures, sourcecode" do
    <<~INPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata>
            <language>en</language>
            </bibdata>
                <preface>
      <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
                <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
                <example>
                <sourcecode id="B"><name>Label</name>A B C</sourcecode>
          <figure id="A" class="pseudocode"><fmt-name id="_">Label</fmt-name><p id="_">\u00a0\u00a0<strong>A</strong></p></figure>
                <sourcecode id="B1">A B C</sourcecode>
          <figure id="A1" class="pseudocode"><p id="_">\u00a0\u00a0<strong>A</strong></p></figure>
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
                           \u00a0\u00a0
                           <b>A</b>
                         </p>
                         <p class='SourceTitle' style='text-align:center;'>Label</p>
                       </div>
                       <pre id='B1' class='sourcecode'>A B C</pre>
                       <div id='A1' class='pseudocode'>
                         <p id='_'>
                           \u00a0\u00a0
                           <b>A</b>
                         </p>
                       </div>
                     </div>
                   </div>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)))
      .to be_html5_equivalent_to output
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
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
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
    expect(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"\.\\}, '"./')
      .gsub(%r{'\.\\}, "'./")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_xml_equivalent_to(output)

    # no repeat extraction of svgmap
    output1 = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <svgmap id="_">
               <target href="http://www.example.com">
                  <xref target="ref1" id="_">Computer</xref>
                  <semx element="xref" source="_">
                     <fmt-xref target="ref1">Computer</fmt-xref>
                  </semx>
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
                  <biblio-tag>
                     [1]
                     <tab/>
                     express/action_schema,
                  </biblio-tag>
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
    expect(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", output, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"\.\\}, '"./')
      .gsub(%r{'\.\\}, "'./")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
      .to be_xml_equivalent_to(output1)
  end
end
