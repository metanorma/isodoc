require "spec_helper"

RSpec.describe IsoDoc do
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
        <source status="generalisation">[SOURCE: <origin bibitemid="ISO712" type="inline" citeas=""><localityStack><locality type="section"><referenceFrom>1</referenceFrom></locality></localityStack>, Section 1</origin>, modified – with adjustments]</source>
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
                   <bibliography>
           <references id="_normative_references" obligation="informative" normative="true" displayorder="2">
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
                                 <div id="figureA-1" class="figure" style='page-break-after: avoid;page-break-inside: avoid;'>
                         <img src="rice_images/rice_image1.png" height="20" width="30" alt="alttext" title="titletxt"/>
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
                         <img src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto'/>
                         <a href="#_" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:_"><span><span id="_" class="TableFootnoteRef">a</span>&#160; </span>
                         <p id="_">The time <span class="stem">(#(t_90)#)</span> was estimated to be 18,2 min for this example.</p>
                       </div></aside>
                         <p  style='page-break-after:avoid;'><b>Key</b></p><dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
                <div class="BlockSource">
                  <p>[SOURCE: <a href="#ISO712">, Section 1</a>, modified – with adjustments]</p>
                </div>
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
                                            <div>
               <h1>1.  Normative References</h1>
               <p id="ISO712" class="NormRef">ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
             </div>
             <aside id="fn:1" class="footnote">
               <p>X</p>
             </aside>
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
               <div class="BlockSource">
               <p>[SOURCE: <a href="#ISO712">, Section 1</a>, modified – with adjustments]</p>
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
                 <p><br clear="all" class="section"/></p>
                 <div class="WordSection3">
                   <p class="zzSTDTitle1"/>
                               <div>
               <h1>1.<span style="mso-tab-count:1">  </span>Normative References</h1>
               <p id="ISO712" class="NormRef">ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
             </div>
                    <aside id='ftn1'>
         <p>X</p>
       </aside>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
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

  it "processes subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword>
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
           </foreword></preface>
           </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <foreword displayorder="1">
            <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
              <name>Figure 1 — Overall title</name>
              <figure id="note1">
                <name>Figure 1-1 — Subfigure 1</name>
                <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
              </figure>
              <figure id="note2">
                <name>Figure 1-2 — Subfigure 2</name>
                <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
              </figure>
            </figure>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div>
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
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
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
            </div>
            <p> </p>
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
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

  it "processes figure classes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" class="diagram">
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <preface>
           <foreword displayorder='1'>
             <figure id='figureA-1' keep-with-next='true' keep-lines-together='true' class='diagram'>
               <name>
                 Diagram 1&#xa0;&#x2014; Split-it-right
                 <em>sample</em>
                  divider
                 <fn reference='1'>
                   <p>X</p>
                 </fn>
               </name>
               <image src='rice_images/rice_image1.png' height='20' width='30' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png' alt='alttext' title='titletxt'/>
               <image src='rice_images/rice_image1.png' height='20' width='auto' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' mimetype='image/png'/>
               <image src='data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7' height='20' width='auto' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' mimetype='image/png'/>
               <image src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='auto' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' mimetype='application/xml'/>
               <fn reference='a'>
                 <p id='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>
                   The time
                   <stem type='AsciiMath'>t_90</stem>
                    was estimated to be 18,2 min for this example.
                 </p>
               </fn>
               <dl>
                 <dt>A</dt>
                 <dd>
                   <p>B</p>
                 </dd>
               </dl>
             </figure>
             <figure id='figure-B' class='plate'>
               <name>Plate 1</name>
               <pre alt='A B'>A &#x3c; B</pre>
             </figure>
             <figure id='figure-C' unnumbered='true' class='diagram'>
               <pre>A &#x3c; B</pre>
             </figure>
           </foreword>
         </preface>
       </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true).gsub(/&lt;/, "&#x3c;")))
      .to be_equivalent_to xmlpp(presxml)
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
           <foreword displayorder='1'>
             <figure id='figureA-1'>
               <name>Figure 1</name>
               <image src='' mimetype='image/svg+xml' height='' width=''>
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true)
        .gsub(/&lt;/, "&#x3c;")
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_equivalent_to xmlpp(presxml
           .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
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
      <?xml version='1.0'?>
           <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <preface>
           <foreword displayorder='1'>
             <figure id='figureA-1'>
               <name>Figure 1</name>
               <image src='' id='_d3731866-1a07-435a-a6c2-1acd41023a4e' mimetype='image/svg+xml' height='' width=''>
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
              <img src='_.emf' height='' width=''/>
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(/&lt;/, "&#x3c;")
      .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64")))
      .to be_equivalent_to xmlpp(presxml
         .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
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
                <emf src='data:image/emf;base64,AQAAANAAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEALAQAACgAAAACAAAAMQAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADIALgAxACAAKAA5AGMANgBkADQAMQBlACwAIAAyADAAMgAyAC0AMAA3AC0AMQA0ACkAIAAAAG8AZABmADEALgBlAG0AZgAAAAAAAAAAABEAAAAMAAAAAQAAACQAAAAkAAAAAACAPwAAAAAAAAAAAACAPwAAAAAAAAAAAgAAAEYAAAAsAAAAIAAAAFNjcmVlbj0xMDIwNXgxMzE4MXB4LCAyMTZ4Mjc5bW0ARgAAADAAAAAjAAAARHJhd2luZz0xMDAuMHgxMDAuMHB4LCAyNi41eDI2LjVtbQAAEgAAAAwAAAABAAAAEwAAAAwAAAACAAAAFgAAAAwAAAAYAAAAGAAAAAwAAAAAAAAAFAAAAAwAAAANAAAAJwAAABgAAAABAAAAAAAAAAAAmQAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAKQEAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAKQEAACoAwAAqAMAAKQEAABxAgAApAQAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA6AQAApAQAAD8AAACoAwAAPwAAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAPwAAADoBAAA6AQAAPwAAAHECAAA/AAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAKgDAAA/AAAApAQAADoBAACkBAAAcQIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAnAAAAGAAAAAEAAAAAAAAA////AAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAAnQEAAEUBAAA2AAAAEAAAAM8DAABFAQAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAF8EAADtAQAAZAQAAOMCAADbAwAAkQMAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABSAwAAPgQAAGECAABzBAAAnQEAAA4EAAA2AAAAEAAAAJ0BAADJAgAANgAAABAAAADiAgAAyQIAADYAAAAQAAAA4gIAABoCAAA2AAAAEAAAAJ0BAAAaAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAAA4AAAAUAAAAAAAAAAAAAAAsBAAA'/>
              </image>
              <image src='' id='_d3731866-1a07-435a-a6c2-1acd41023a4e' mimetype='image/svg+xml' height='' width=''>
                <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
                  <circle fill='#009' r='45' cx='50' cy='50'/>
                  <path d='M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z' fill='#FFF'/>
                </svg>
                <emf src='data:image/emf;base64,AQAAAPwAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAWAQAACgAAAACAAAARwAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADIALgAxACAAKAA5AGMANgBkADQAMQBlACwAIAAyADAAMgAyAC0AMAA3AC0AMQA0ACkAIAAAAGkAbQBhAGcAZQAyADAAMgAyADAAOQAxADMALQA4ADMAMAAzADIALQBsADkAcQByAG8AZgAuAGUAbQBmAAAAAAAAAAAAEQAAAAwAAAABAAAAJAAAACQAAAAAAIA/AAAAAAAAAAAAAIA/AAAAAAAAAAACAAAARgAAACwAAAAgAAAAU2NyZWVuPTEwMjA1eDEzMTgxcHgsIDIxNngyNzltbQBGAAAAMAAAACMAAABEcmF3aW5nPTEwMC4weDEwMC4wcHgsIDI2LjV4MjYuNW1tAAASAAAADAAAAAEAAAATAAAADAAAAAIAAAAWAAAADAAAABgAAAAYAAAADAAAAAAAAAAUAAAADAAAAA0AAAAnAAAAGAAAAAEAAAAAAAAAAACZAAYAAAAlAAAADAAAAAEAAAA7AAAACAAAABsAAAAQAAAApAQAAHECAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAApAQAAKgDAACoAwAApAQAAHECAACkBAAABQAAADQAAAAAAAAAAAAAAP//////////AwAAADoBAACkBAAAPwAAAKgDAAA/AAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAAA/AAAAOgEAADoBAAA/AAAAcQIAAD8AAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAqAMAAD8AAACkBAAAOgEAAKQEAABxAgAAPQAAAAgAAAA8AAAACAAAAD4AAAAYAAAAAAAAAAAAAAD//////////yUAAAAMAAAABQAAgCgAAAAMAAAAAQAAACcAAAAYAAAAAQAAAAAAAAD///8ABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACdAQAARQEAADYAAAAQAAAAzwMAAEUBAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAXwQAAO0BAABkBAAA4wIAANsDAACRAwAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAFIDAAA+BAAAYQIAAHMEAACdAQAADgQAADYAAAAQAAAAnQEAAMkCAAA2AAAAEAAAAOICAADJAgAANgAAABAAAADiAgAAGgIAADYAAAAQAAAAnQEAABoCAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAADgAAABQAAAAAAAAAAAAAAFgEAAA='/>
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
                <img src='spec/assets/odf.emf'  height='' width=''/>
                <img src='_.emf'  height='' width=''/>
                <img src='_.emf' height='' width=''/>
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
     .convert("test", input, true)
     .gsub(/&lt;/, "&#x3c;"))
          .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
      .to be_equivalent_to xmlpp(presxml
        .gsub(%r{data:image/emf;base64,[^"']+}, "data:image/emf;base64"))
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
        IsoDoc::PresentationXMLConvert.new(presxml_options)
          .convert("test", input, true)
      end.to raise_error("Inkscape missing in PATH, unable" \
                         "to convert image spec/assets/odf1.svg. Aborting.")
    end
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
                       <pre id='B' class='sourcecode'>
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
                       <pre id='B1' class='sourcecode'>A B C</pre>
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
                     <biblio-tag>[1]<tab/>express/action_schema,</biblio-tag>
                   </bibitem>
                 </references>
               </bibliography>
             </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"\.\\}, '"./')
      .gsub(%r{'\.\\}, "'./"))
      .to be_equivalent_to xmlpp(output)
  end
end
