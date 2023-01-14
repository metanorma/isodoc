require "spec_helper"

RSpec.describe IsoDoc do
  it "processes Relaton bibliographies" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISBN"/>
        <eref bibitemid="ISSN"/>
        <eref bibitemid="ISO16634"/>
        <eref bibitemid="ref1"/>
        <eref bibitemid="ref10"/>
        <eref bibitemid="ref12"/>
        <eref bibitemid="zip_ffs"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO16634" type="standard">
        <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
        <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
        <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
        <date type="published"><on>--</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
        <extent type="part">
        <referenceFrom>all</referenceFrom>
        </extent>
      </bibitem>
      <bibitem id="ISO20483" type="standard">
        <title format="text/plain">Cereals and pulses</title>
        <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
        <date type="published"><from>2013</from><to>2014</to></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref1">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="ICC">ICC/167</docidentifier>
      </bibitem>
      <note><p>This is an annotation of ISO 20483:2013-2014</p></note>
          <bibitem id="zip_ffs"><formattedref format="application/x-isodoc+xml">Title 5</formattedref><docidentifier type="metanorma">[5]</docidentifier></bibitem>
      </references><references id="_bibliography" obligation="informative" normative="false">
        <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
        <title format="text/plain">Chemicals for analytical laboratory use</title>
        <docidentifier type="ISBN">ISBN</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISBN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
        <title format="text/plain">Instruments for analytical laboratory use</title>
        <docidentifier type="ISSN.electronic">ABC</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>Journal Publishers</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <note><p>This is an annotation of document ISSN.</p></note>
      <note><p>This is another annotation of document ISSN.</p></note>
      <bibitem id="ISO3696" type="standard">
        <title format="text/plain">Water for analytical laboratory use</title>
        <docidentifier type="ISO">ISO 3696</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 3696)</note>
      </bibitem>
      <bibitem id="ref10">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="metanorma">[10]</docidentifier>
      </bibitem>
      <bibitem id="ref10a" hidden="true">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 20</docidentifier>
      </bibitem>
      <bibitem id="ref11">
      <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 10</docidentifier>
      </bibitem>
      <bibitem id="ref12">
        <formattedref format="application/x-isodoc+xml">CitationWorks. 2019. <em>How to cite a reference</em>.</formattedref>
        <docidentifier type="metanorma">[Citn]</docidentifier>
        <docidentifier type="IETF">RFC 20</docidentifier>
      </bibitem>
      <bibitem id="ref10b">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 20</docidentifier>
      </bibitem>
      <bibitem id="ref10c">
        <title>Internet Calendaring &#x26; Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="DOI">ABC 20</docidentifier>
      </bibitem>
      </references>
      </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
          <foreword displayorder="1">
            <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
              <eref bibitemid='ISO712'>[110]</eref>
              <eref bibitemid='ISBN'>[1]</eref>
              <eref bibitemid='ISSN'>[2]</eref>
              <eref bibitemid='ISO16634'>ISO 16634:-- (all parts)</eref>
              <eref bibitemid='ref1'>ICC/167</eref>
              <eref bibitemid='ref10'>[4]</eref>
              <eref bibitemid='ref12'>Citn</eref>
              <eref bibitemid='zip_ffs'>[5]</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id='_normative_references' obligation='informative' normative='true' displayorder="2">
          <title depth='1'>1.<tab/>Normative References</title>
            <p>
              The following documents are referred to in the text in such a way that
              some or all of their content constitutes requirements of this document.
              For dated references, only the edition cited applies. For undated
              references, the latest edition of the referenced document (including any
              amendments) applies.
            </p>
            <bibitem id='ISO712' type='standard'>
               <formattedref>International Organization for Standardization. <em>Cereals and cereal products</em>.</formattedref>
              <docidentifier type='ISO'>ISO 712</docidentifier>
              <docidentifier type='metanorma'>[110]</docidentifier>
              <biblio-tag>[110], ISO 712, </biblio-tag>
            </bibitem>
            <bibitem id='ISO16634' type='standard'>
               <formattedref><em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em>.</formattedref>
              <docidentifier type='ISO'>ISO 16634:-- (all parts)</docidentifier>
              <note format='text/plain' type='Unpublished-Status' reference='1'>Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
              <biblio-tag>ISO 16634:-- (all parts)<fn reference="_"><p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p></fn>, </biblio-tag>
            </bibitem>
            <bibitem id='ISO20483' type='standard'>
              <formattedref>International Organization for Standardization. <em>Cereals and pulses</em>. 2013&#x2013;2014.</formattedref>
              <docidentifier type='ISO'>ISO 20483:2013-2014</docidentifier>
              <biblio-tag>ISO 20483:2013-2014, </biblio-tag>
            </bibitem>
            <bibitem id='ref1'>
              <formattedref format='application/x-isodoc+xml'>
                <smallcap>Standard No I.C.C 167</smallcap>
                .
                <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                 (see
                <link target='http://www.icc.or.at'/>
                )#{' '}
              </formattedref>
              <docidentifier type='ICC'>ICC/167</docidentifier>
              <biblio-tag>ICC/167, </biblio-tag>
            </bibitem>
            <note>
              <name>NOTE</name>
              <p>This is an annotation of ISO 20483:2013-2014</p>
            </note>
            <bibitem id='zip_ffs'>
              <formattedref format='application/x-isodoc+xml'>Title 5</formattedref>
              <docidentifier type='metanorma'>[5]</docidentifier>
              <biblio-tag>[5] </biblio-tag>
            </bibitem>
          </references>
          <references id='_bibliography' obligation='informative' normative='false' displayorder="3">
            <title depth="1">Bibliography</title>
            <bibitem id='ISBN' type='book'>
              <formattedref><em>Chemicals for analytical laboratory use</em>. n.p.: n.d. ISBN: ISBN.</formattedref>
              <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
              <docidentifier type='ISBN'>ISBN</docidentifier>
              <biblio-tag>[1]<tab/></biblio-tag>
            </bibitem>
            <bibitem id='ISSN' type='journal'>
            <formattedref><em>Instruments for analytical laboratory use</em>. n.d. ISSN ABC.</formattedref>
              <docidentifier type='metanorma-ordinal'>[2]</docidentifier>
              <docidentifier type='ISSN.electronic'>ISSN ABC</docidentifier>
              <biblio-tag>[2]<tab/></biblio-tag>
            </bibitem>
            <note>
              <name>NOTE</name>
              <p>This is an annotation of document ISSN.</p>
            </note>
            <note>
              <name>NOTE</name>
              <p>This is another annotation of document ISSN.</p>
            </note>
            <bibitem id='ISO3696' type='standard'>
              <formattedref><em>Water for analytical laboratory use</em>.</formattedref>
              <docidentifier type='metanorma-ordinal'>[3]</docidentifier>
              <docidentifier type='ISO'>ISO 3696</docidentifier>
              <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 3696)</note>
              <biblio-tag>[3]<tab/>ISO 3696<fn reference="_"><p>Under preparation. (Stage at the time of publication ISO/DIS 3696)</p></fn>, </biblio-tag>
            </bibitem>
            <bibitem id='ref10'>
              <formattedref format='application/x-isodoc+xml'>
                <smallcap>Standard No I.C.C 167</smallcap>
                .
                <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                 (see
                <link target='http://www.icc.or.at'/>
                )
              </formattedref>
              <docidentifier type='metanorma-ordinal'>[4]</docidentifier>
              <biblio-tag>[4]<tab/></biblio-tag>
            </bibitem>
            <bibitem id="ref10a" hidden="true">
            <formattedref><em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>.</formattedref>
              <docidentifier type="IETF">IETF RFC 20</docidentifier>
            </bibitem>
            <bibitem id='ref11'>
            <formattedref><em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>.</formattedref>
              <docidentifier type='metanorma-ordinal'>[5]</docidentifier>
              <docidentifier type='IETF'>IETF RFC 10</docidentifier>
              <biblio-tag>[5]<tab/>IETF RFC 10, </biblio-tag>
            </bibitem>
            <bibitem id='ref12'>
              <formattedref format='application/x-isodoc+xml'>
                CitationWorks. 2019.
                <em>How to cite a reference</em>
                .#{' '}
              </formattedref>
              <docidentifier type='metanorma'>[Citn]</docidentifier>
              <docidentifier type='IETF'>IETF RFC 20</docidentifier>
              <biblio-tag>Citn<tab/>IETF RFC 20, </biblio-tag>
            </bibitem>
            <bibitem id="ref10b">
            <formattedref><em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>.</formattedref>
              <docidentifier type='metanorma-ordinal'>[6]</docidentifier>
              <docidentifier type="IETF">IETF RFC 20</docidentifier>
              <biblio-tag>[6]<tab/>IETF RFC 20, </biblio-tag>
            </bibitem>
            <bibitem id='ref10c'>
            <formattedref><em>Internet Calendaring &#x26; Scheduling Core Object Specification (iCalendar)</em>.</formattedref>
        <docidentifier type='metanorma-ordinal'>[7]</docidentifier>
        <docidentifier type='DOI'>DOI ABC 20</docidentifier>
        <biblio-tag>[7]<tab/></biblio-tag>
      </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    PRESXML

    html = <<~OUTPUT
      #{HTML_HDR}
                      <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
                 <a href="#ISO712">[110]</a>
                 <a href="#ISBN">[1]</a>
                 <a href="#ISSN">[2]</a>
                 <a href="#ISO16634">ISO 16634:-- (all parts)</a>
                 <a href="#ref1">ICC/167</a>
                 <a href="#ref10">[4]</a>
                 <a href="#ref12">Citn</a>
                 <a href="#zip_ffs">[5]</a>
               </p>
             </div>
             <p class="zzSTDTitle1"/>
             <div>
               <h1>1.  Normative References</h1>
               <p>
               The following documents are referred to in the text in such a way that
               some or all of their content constitutes requirements of this document.
               For dated references, only the edition cited applies. For undated
               references, the latest edition of the referenced document (including any
               amendments) applies.
             </p>
               <p id="ISO712" class="NormRef">[110], ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
               <p id="ISO16634" class="NormRef">ISO 16634:-- (all parts)<a class="FootnoteRef" href="#fn:_"><sup>_</sup></a>, <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>.</p>
               <p id="ISO20483" class="NormRef">ISO 20483:2013-2014, International Organization for Standardization. <i>Cereals and pulses</i>. 2013–2014.</p>
               <p id="ref1" class="NormRef">ICC/167,
                 <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                 )
               </p>
               <div class="Note">
                 <p><span class="note_label">NOTE</span>  This is an annotation of ISO 20483:2013-2014</p>
               </div>
               <p id="zip_ffs" class="NormRef">[5] Title 5</p>
             </div>
             <br/>
                          <div>
               <h1 class="Section3">Bibliography</h1>
               <p id="ISBN" class="Biblio">[1]   <i>Chemicals for analytical laboratory use</i>. n.p.: n.d. ISBN: ISBN.</p>
               <p id="ISSN" class="Biblio">[2]   <i>Instruments for analytical laboratory use</i>. n.d. ISSN ABC.</p>
               <div class="Note">
                 <p><span class="note_label">NOTE</span>  This is an annotation of document ISSN.</p>
               </div>
               <div class="Note">
                 <p><span class="note_label">NOTE</span>  This is another annotation of document ISSN.</p>
               </div>
               <p id="ISO3696" class="Biblio">[3]  ISO 3696<a class="FootnoteRef" href="#fn:_"><sup>_</sup></a>, <i>Water for analytical laboratory use</i>.</p>
               <p id="ref10" class="Biblio">[4] 
                 <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                 )
               </p>
               <p id="ref11" class="Biblio">[5]  IETF RFC 10, <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
               <p id="ref12" class="Biblio">Citn  IETF RFC 20,
                 CitationWorks. 2019.
                 <i>How to cite a reference</i>
                 .
               </p>
               <p id="ref10b" class="Biblio">[6]  IETF RFC 20, <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
               <p id="ref10c" class="Biblio">[7]   <i>Internet Calendaring &amp; Scheduling Core Object Specification (iCalendar)</i>.</p>
             </div>
             <aside id="fn:_" class="footnote">
               <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT

    doc = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection1">
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div>
             <h1 class="ForewordTitle">Foreword</h1>
             <p class="MsoNormal">
               <a name="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f" id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f"/>
               <a href="#ISO712">[110]</a>
               <a href="#ISBN">[1]</a>
               <a href="#ISSN">[2]</a>
               <a href="#ISO16634">ISO 16634:-- (all parts)</a>
               <a href="#ref1">ICC/167</a>
               <a href="#ref10">[4]</a>
               <a href="#ref12">Citn</a>
               <a href="#zip_ffs">[5]</a>
             </p>
           </div>
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <p class="zzSTDTitle1"/>
           <div>
             <h1>1.<span style="mso-tab-count:1">  </span>Normative References</h1>
             <p class="MsoNormal">
               The following documents are referred to in the text in such a way that
               some or all of their content constitutes requirements of this document.
               For dated references, only the edition cited applies. For undated
               references, the latest edition of the referenced document (including any
               amendments) applies.
             </p>
             <p class="NormRef"><a name="ISO712" id="ISO712"/>[110], ISO 712, International Organization for Standardization. <i>Cereals and cereal products</i>.</p>
             <p class="NormRef"><a name="ISO16634" id="ISO16634"/>ISO 16634:-- (all parts)<span style="mso-bookmark:_Ref"><a class="FootnoteRef" href="#_ftn1" type="footnote" style="mso-footnote-id:ftn1" name="_ftnref1" title="" id="_ftnref1"><span class="MsoFootnoteReference"><span style="mso-special-character:footnote"/></span></a></span>, <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>.</p>
             <p class="NormRef"><a name="ISO20483" id="ISO20483"/>ISO 20483:2013-2014, International Organization for Standardization. <i>Cereals and pulses</i>. 2013–2014.</p>
             <p class="NormRef"><a name="ref1" id="ref1"/>ICC/167,
                 <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                 )
               </p>
             <div class="Note">
               <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">  </span>This is an annotation of ISO 20483:2013-2014</p>
             </div>
             <p class="NormRef"><a name="zip_ffs" id="zip_ffs"/>[5] Title 5</p>
           </div>
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
                      <div>
             <h1 class="Section3">Bibliography</h1>
             <p class="Biblio"><a name="ISBN" id="ISBN"/>[1]<span style="mso-tab-count:1">  </span><i>Chemicals for analytical laboratory use</i>. n.p.: n.d. ISBN: ISBN.</p>
             <p class="Biblio"><a name="ISSN" id="ISSN"/>[2]<span style="mso-tab-count:1">  </span><i>Instruments for analytical laboratory use</i>. n.d. ISSN ABC.</p>
             <div class="Note">
               <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">  </span>This is an annotation of document ISSN.</p>
             </div>
             <div class="Note">
               <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">  </span>This is another annotation of document ISSN.</p>
             </div>
             <p class="Biblio"><a name="ISO3696" id="ISO3696"/>[3]<span style="mso-tab-count:1">  </span>ISO 3696<span style="mso-element:field-begin"/> NOTEREF _Ref \\f \\h<span style="mso-element:field-separator"/><span class="MsoFootnoteReference">_</span><span style="mso-element:field-end"/>, <i>Water for analytical laboratory use</i>.</p>
             <p class="Biblio"><a name="ref10" id="ref10"/>[4]<span style="mso-tab-count:1">  </span><span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                 )
               </p>
             <p class="Biblio"><a name="ref11" id="ref11"/>[5]<span style="mso-tab-count:1">  </span>IETF RFC 10, <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
             <p class="Biblio"><a name="ref12" id="ref12"/>Citn<span style="mso-tab-count:1">  </span>IETF RFC 20,
       CitationWorks. 2019.
                 <i>How to cite a reference</i>
                 .
               </p>
             <p class="Biblio"><a name="ref10b" id="ref10b"/>[6]<span style="mso-tab-count:1">  </span>IETF RFC 20, <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
             <p class="Biblio"><a name="ref10c" id="ref10c"/>[7]<span style="mso-tab-count:1">  </span><i>Internet Calendaring &amp; Scheduling Core Object Specification (iCalendar)</i>.</p>
           </div>
         </div>
         <div style="mso-element:footnote-list">
           <div style="mso-element:footnote" id="ftn1">
             <p class="MsoFootnoteText"><a style="mso-footnote-id:ftn1" href="#_ftn1" name="_ftnref1" title="" id="_ftnref1"><span class="MsoFootnoteReference"><span style="mso-special-character:footnote"/></span></a>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
           </div>
         </div>
       </body>
    OUTPUT

    FileUtils.rm_rf("test.doc")
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<fn reference="[^"]+"}m, "<fn reference=\"_\"")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    IsoDoc::WordConvert.new({})
      .convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc")
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(/epub:/, "")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")
      .gsub(/NOTEREF _Ref\d+/, "NOTEREF _Ref")
    expect(xmlpp(html))
      .to be_equivalent_to xmlpp(doc)
  end

  it "marks references sections as hidden" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
      <bibliography>
      <references>
      <bibitem hidden="true"/>
      <bibitem hidden="true"/>
      <bibitem hidden="true"/>
      </references>
      <references>
      <bibitem hidden="true"/>
      <bibitem>
      <bibitem hidden="true"/>
      </references>
      </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibliography>
          <references hidden='true'>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
          </references>
          <references>
            <bibitem hidden='true'/>
            <bibitem/>
          </references>
        </bibliography>
      </iso-standard>
    PRESXML
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes hidden references sections in Relaton bibliographies" do
    presxml = <<~PRESXML
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
          <foreword>
            <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
              <eref bibitemid='ISO712'>[110]</eref>
              <eref bibitemid='ISBN'>[1]</eref>
              <eref bibitemid='ISSN'>[2]</eref>
              <eref bibitemid='ISO16634'>ISO 16634:-- (all parts)</eref>
              <eref bibitemid='ref1'>ICC/167</eref>
              <eref bibitemid='ref10'>[10]</eref>
              <eref bibitemid='ref12'>Citn</eref>
              <eref bibitemid='zip_ffs'>[5]</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id='_normative_references' obligation='informative' normative='true' hidden="true">
          <title depth='1'>1.<tab/>Normative References</title>
            <p>
              The following documents are referred to in the text in such a way that
              some or all of their content constitutes requirements of this document.
              For dated references, only the edition cited applies. For undated
              references, the latest edition of the referenced document (including any
              amendments) applies.
            </p>
            <bibitem id='ISO712' type='standard'>
              <title format='text/plain'>Cereals or cereal products</title>
              <title type='main' format='text/plain'>Cereals and cereal products</title>
              <docidentifier type='ISO'>ISO 712</docidentifier>
              <docidentifier type='metanorma'>[110]</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id='ISO16634' type='standard'>
              <title language='x' format='text/plain'>
                Cereals, pulses, milled cereal products, xxxx, oilseeds and animal
                feeding stuffs
              </title>
              <title language='en' format='text/plain'>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
              <docidentifier type='ISO'>ISO 16634:-- (all parts)</docidentifier>
              <date type='published'>
                <on>--</on>
              </date>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <note format='text/plain' type='Unpublished-Status' reference='1'>Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
              <extent type='part'>
                <referenceFrom>all</referenceFrom>
              </extent>
            </bibitem>
            <bibitem id='ISO20483' type='standard'>
              <title format='text/plain'>Cereals and pulses</title>
              <docidentifier type='ISO'>ISO 20483:2013-2014</docidentifier>
              <date type='published'>
                <from>2013</from>
                <to>2014</to>
              </date>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id='ref1'>
              <formattedref format='application/x-isodoc+xml'>
                <smallcap>Standard No I.C.C 167</smallcap>
                .
                <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                 (see
                <link target='http://www.icc.or.at'/>
                )
              </formattedref>
              <docidentifier type='ICC'>ICC/167</docidentifier>
            </bibitem>
            <note>
              <name>NOTE</name>
              <p>This is an annotation of ISO 20483:2013-2014</p>
            </note>
            <bibitem id='zip_ffs'>
              <formattedref format='application/x-isodoc+xml'>Title 5</formattedref>
              <docidentifier type='metanorma'>[5]</docidentifier>
            </bibitem>
          </references>
          <references id='_bibliography' obligation='informative' normative='false' hidden="true">
            <title depth="1">Bibliography</title>
            <bibitem id='ISBN' type='ISBN'>
              <title format='text/plain'>Chemicals for analytical laboratory use</title>
              <docidentifier type='ISBN'>ISBN</docidentifier>
              <docidentifier type='metanorma'>[1]</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISBN</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id='ISSN' type='ISSN'>
              <title format='text/plain'>Instruments for analytical laboratory use</title>
              <docidentifier type='ISSN'>ISSN</docidentifier>
              <docidentifier type='metanorma'>[2]</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISSN</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <note>
              <name>NOTE</name>
              <p>This is an annotation of document ISSN.</p>
            </note>
            <note>
              <name>NOTE</name>
              <p>This is another annotation of document ISSN.</p>
            </note>
            <bibitem id='ISO3696' type='standard'>
              <title format='text/plain'>Water for analytical laboratory use</title>
              <docidentifier type='ISO'>ISO 3696</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id='ref10'>
              <formattedref format='application/x-isodoc+xml'>
                <smallcap>Standard No I.C.C 167</smallcap>
                .
                <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                 (see
                <link target='http://www.icc.or.at'/>
                )
              </formattedref>
              <docidentifier type='metanorma'>[10]</docidentifier>
            </bibitem>
            <bibitem id='ref11'>
              <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
              <docidentifier type='IETF'>RFC 10</docidentifier>
            </bibitem>
            <bibitem id='ref12'>
              <formattedref format='application/x-isodoc+xml'>
                CitationWorks. 2019.
                <em>How to cite a reference</em>
                .
              </formattedref>
              <docidentifier type='metanorma'>[Citn]</docidentifier>
              <docidentifier type='IETF'>RFC 20</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    PRESXML

    html = <<~OUTPUT
          #{HTML_HDR}
      <br/>
                   <div>
                     <h1 class='ForewordTitle'>Foreword</h1>
                     <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                       <a href='#ISO712'>[110]</a>
                       <a href='#ISBN'>[1]</a>
                       <a href='#ISSN'>[2]</a>
                       <a href='#ISO16634'>ISO 16634:-- (all parts)</a>
                       <a href='#ref1'>ICC/167</a>
                       <a href='#ref10'>[10]</a>
                       <a href='#ref12'>Citn</a>
                       <a href='#zip_ffs'>[5]</a>
                     </p>
                   </div>
                   <p class='zzSTDTitle1'/>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes hidden references sections in Relaton bibliographies" do
    presxml = <<~PRESXML
              <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
                <bibdata>
                  <language current="true">en</language>
                </bibdata>
                <preface>
                  <foreword>
                    <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                      <eref bibitemid='ISO712'>[110]</eref>
                      <eref bibitemid='ISBN'>[1]</eref>
                      <eref bibitemid='ISSN'>[2]</eref>
                      <eref bibitemid='ISO16634'>ISO 16634:-- (all parts)</eref>
                      <eref bibitemid='ref1'>ICC/167</eref>
                      <eref bibitemid='ref10'>[10]</eref>
                      <eref bibitemid='ref12'>Citn</eref>
                      <eref bibitemid='zip_ffs'>[5]</eref>
                    </p>
                  </foreword>
                </preface>
                <bibliography>
                  <references id='_normative_references' obligation='informative' normative='true'>
                  <title depth='1'>1.<tab/>Normative References</title>
                    <p>
                      The following documents are referred to in the text in such a way that
                      some or all of their content constitutes requirements of this document.
                      For dated references, only the edition cited applies. For undated
                      references, the latest edition of the referenced document (including any
                      amendments) applies.
                    </p>
                    <bibitem id='ISO712' type='standard' hidden="true">
                      <title format='text/plain'>Cereals or cereal products</title>
                      <title type='main' format='text/plain'>Cereals and cereal products</title>
                      <docidentifier type='ISO'>ISO 712</docidentifier>
                      <docidentifier type='metanorma'>[110]</docidentifier>
                      <contributor>
                        <role type='publisher'/>
                        <organization>
                          <name>International Organization for Standardization</name>
                        </organization>
                      </contributor>
                    </bibitem>
                    <bibitem id='ISO16634' type='standard'>
                      <formattedref language='en' format='text/plain'><em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em></formattedref>
                      <docidentifier type='ISO'>ISO 16634:-- (all parts)</docidentifier>
                      <date type='published'>
                        <on>--</on>
                      </date>
                      <contributor>
                        <role type='publisher'/>
                        <organization>
                          <abbreviation>ISO</abbreviation>
                        </organization>
                      </contributor>
                      <note format='text/plain' type='Unpublished-Status' reference='1'>Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
                      <extent type='part'>
                        <referenceFrom>all</referenceFrom>
                      </extent>
                      <biblio-tag>ISO 16634:-- (all parts), </biblio-tag>
                    </bibitem>
      </references></bibliography></iso-standard>
    PRESXML

    html = <<~OUTPUT
          #{HTML_HDR}
      <br/>
                   <div>
                     <h1 class='ForewordTitle'>Foreword</h1>
                     <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                       [110]
                       [1]
                       [2]
                       <a href='#ISO16634'>ISO 16634:-- (all parts)</a>
                       ICC/167
                       [10]
                       Citn
                       [5]
                     </p>
                   </div>
                   <p class='zzSTDTitle1'/>
                   <div>
        <h1>1.&#160; Normative References</h1>
        <p>
           The following documents are referred to in the text in such a way
          that some or all of their content constitutes requirements of this
          document. For dated references, only the edition cited applies. For
          undated references, the latest edition of the referenced document
          (including any amendments) applies.
        </p>
        <p id='ISO16634' class='NormRef'>
          ISO 16634:-- (all parts),
          <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>
        </p>
      </div>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "selects the primary identifier" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="IEC" primary="true">IEC 217</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <foreword displayorder='1'>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          <eref bibitemid='ISO712'>IEC 217</eref>
        </p>
      </foreword>
    PRESXML
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "selects multiple primary identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO" primary="true">ISO 712</docidentifier>
        <docidentifier type="IEC" primary="true">IEC 217</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <foreword displayorder='1'>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          <eref bibitemid='ISO712'>ISO 712&#xA0;/ IEC 217</eref>
        </p>
      </foreword>
    PRESXML
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true),
    ).at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "enforces consistent metanorma-ordinal numbering" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="IEC">IEC 217</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[3]</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABC</docidentifier>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <bibliography>
         <references id='_normative_references' obligation='informative' normative='false' displayorder='1'>
           <title depth='1'>Bibliography</title>
           <bibitem id='ref1' type='standard'>
             <formattedref><em>Cereals or cereal products</em>.</formattedref>
             <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
             <docidentifier type='IEC'>IEC 217</docidentifier>
             <biblio-tag>[1]<tab/>IEC 217, </biblio-tag>
           </bibitem>
           <bibitem id='ref2' type='standard'>
             <formattedref><em>Cereals or cereal products</em>.</formattedref>
             <docidentifier type='metanorma-ordinal'>[2]</docidentifier>
             <biblio-tag>[2]<tab/></biblio-tag>
           </bibitem>
           <bibitem id='ref3' type='standard'>
             <formattedref><em>Cereals or cereal products</em>.</formattedref>
             <docidentifier type='metanorma-ordinal'>[3]</docidentifier>
             <docidentifier>ABC</docidentifier>
             <biblio-tag>[3]<tab/>ABC, </biblio-tag>
           </bibitem>
         </references>
       </bibliography>
    PRESXML
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true),
    ).at("//xmlns:bibliography").to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "enforces consistent references numbering with hidden items: metanorma identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[1]</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard" hidden="true">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[2]</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier type="metanorma">[3]</docidentifier>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <bibliography>
        <references id='_normative_references' obligation='informative' normative='false' displayorder='1'>
          <title depth='1'>Bibliography</title>
          <bibitem id='ref1' type='standard'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
            <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
            <biblio-tag>[1]<tab/></biblio-tag>
          </bibitem>
          <bibitem id='ref2' type='standard' hidden='true'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
          </bibitem>
          <bibitem id='ref3' type='standard'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
            <docidentifier type='metanorma-ordinal'>[2]</docidentifier>
            <biblio-tag>[2]<tab/></biblio-tag>
          </bibitem>
        </references>
      </bibliography>
    PRESXML
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true),
    ).at("//xmlns:bibliography").to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "enforces consistent references numbering with hidden items: metanorma-ordinal identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ref1" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABC</docidentifier>
      </bibitem>
      <bibitem id="ref2" type="standard" hidden="true">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABD</docidentifier>
      </bibitem>
      <bibitem id="ref3" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <docidentifier>ABE</docidentifier>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
      <bibliography>
        <references id='_normative_references' obligation='informative' normative='false' displayorder='1'>
          <title depth='1'>Bibliography</title>
          <bibitem id='ref1' type='standard'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
            <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
            <docidentifier>ABC</docidentifier>
            <biblio-tag>[1]<tab/>ABC, </biblio-tag>
          </bibitem>
          <bibitem id='ref2' type='standard' hidden='true'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
            <docidentifier>ABD</docidentifier>
          </bibitem>
          <bibitem id='ref3' type='standard'>
            <formattedref><em>Cereals or cereal products</em>.</formattedref>
            <docidentifier type='metanorma-ordinal'>[2]</docidentifier>
            <docidentifier>ABE</docidentifier>
            <biblio-tag>[2]<tab/>ABE, </biblio-tag>
          </bibitem>
        </references>
      </bibliography>
    PRESXML
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true),
    ).at("//xmlns:bibliography").to_xml))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "suppresses document identifier if requested to" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard" suppress_identifier="true">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref1" suppress_identifier="true">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="ICC">ICC/167</docidentifier>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
          <bibliography>
        <references id='_normative_references' obligation='informative' normative='true' displayorder='1'>
          <title depth='1'>
            1.
            <tab/>
            Normative References
          </title>
          <p>
            The following documents are referred to in the text in such a way that
            some or all of their content constitutes requirements of this document.
            For dated references, only the edition cited applies. For undated
            references, the latest edition of the referenced document (including any
            amendments) applies.
          </p>
          <bibitem id='ISO712' type='standard' suppress_identifier='true'>
            <formattedref>
              International Organization for Standardization.
              <em>Cereals and cereal products</em>
              .
            </formattedref>
            <docidentifier type='ISO'>ISO 712</docidentifier>
            <docidentifier type='metanorma'>[110]</docidentifier>
            <biblio-tag>[110] </biblio-tag>
          </bibitem>
          <bibitem id='ref1' suppress_identifier='true'>
            <formattedref format='application/x-isodoc+xml'>
              <smallcap>Standard No I.C.C 167</smallcap>
              .
              <em>
                Determination of the protein content in cereal and cereal products for
                food and animal feeding stuffs according to the Dumas combustion
                method
              </em>
               (see
              <link target='http://www.icc.or.at'/>
              )
            </formattedref>
            <docidentifier type='ICC'>ICC/167</docidentifier>
            <biblio-tag/>
          </bibitem>
        </references>
      </bibliography>
    PRESXML
    html = <<~OUTPUT
      #{HTML_HDR}
             <p class='zzSTDTitle1'/>
             <div>
               <h1>1.&#xa0; Normative References</h1>
               <p>
                 The following documents are referred to in the text in such a way that
                 some or all of their content constitutes requirements of this
                 document. For dated references, only the edition cited applies. For
                 undated references, the latest edition of the referenced document
                 (including any amendments) applies.
               </p>
               <p id='ISO712' class='NormRef'>
                 [110] International Organization for Standardization.
                 <i>Cereals and cereal products</i>
                 .
               </p>
               <p id='ref1' class='NormRef'>
                 <span style='font-variant:small-caps;'>Standard No I.C.C 167</span>
                 .
                 <i>
                   Determination of the protein content in cereal and cereal products
                   for food and animal feeding stuffs according to the Dumas combustion
                   method
                 </i>
                  (see
                 <a href='http://www.icc.or.at'>http://www.icc.or.at</a>
                 )
               </p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    doc = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(xmlpp(Nokogiri::XML(doc)
    .at("//xmlns:bibliography").to_xml))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
   .convert("test", doc, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "renders footnote in metanorma docidentifier" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <language>en</language>
                </bibdata>
                <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="ISO712" type="standard" suppress_identifier="true">
              <title type="title-intro" format="text/plain" language="en" script="Latn">International vocabulary of metrology</title>
              <title type="title-main" format="text/plain" language="en" script="Latn">Basic and general concepts and associated terms (VIM)</title>
              <title type="main" format="text/plain" language="en" script="Latn">International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</title>
              <uri type="src">https://www.iso.org/standard/45324.html</uri>  <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:45324:en</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/04/53/45324.detail.rss</uri>  <uri type="pub">https://isotc.iso.org/livelink/livelink/Open/8389141</uri>  
                    <docidentifier type="ISO" primary="true">ISO/IEC Guide 99:2007</docidentifier>
                    <docidentifier type="metanorma">[ISO/IEC Guide 99:2007<fn reference="1"><p id="_f6ba916e-f2ee-05fe-7ee3-b5d891a37db3">Also known as JCGM 200</p></fn>]</docidentifier>  
                    <docidentifier type="URN">urn:iso:std:iso-iec:guide:99:ed-1</docidentifier>  
                  <docnumber>99</docnumber>  <date type="published">    <on>2007-12</on>  </date>  <contributor>    <role type="publisher"/>    <organization>
                <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <contributor>    <role type="publisher"/>    <organization>
      <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>      <uri>www.iec.ch</uri>    </organization>  </contributor>  <edition>1</edition>  <language>en</language>  <script>Latn</script>
            </bibitem>
            </references>
            </bibliography>
            </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <bibliography>
         <references id="_" obligation="informative" normative="true" displayorder="1">
           <title depth="1">1.<tab/>Normative References</title>
           <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
           <bibitem id="ISO712" type="standard" suppress_identifier="true">
             <formattedref>International Organization for Standardization and International Electrotechnical Commission. <em>International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</em>. 1st edition. December 2007. <link target="https://www.iso.org/standard/45324.html">https://www.iso.org/standard/45324.html</link>.</formattedref>
             <uri type="src">https://www.iso.org/standard/45324.html</uri>
             <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:45324:en</uri>
             <uri type="rss">https://www.iso.org/contents/data/standard/04/53/45324.detail.rss</uri>
             <uri type="pub">https://isotc.iso.org/livelink/livelink/Open/8389141</uri>
             <docidentifier type="ISO" primary="true">ISO/IEC Guide 99:2007</docidentifier>
             <docidentifier type="metanorma">[ISO/IEC Guide 99:2007]</docidentifier>
             <docidentifier type="URN">URN urn:iso:std:iso-iec:guide:99:ed-1</docidentifier>
             <biblio-tag>ISO/IEC Guide 99:2007<fn reference="1"><p id="_">Also known as JCGM 200</p></fn> </biblio-tag>
           </bibitem>
         </references>
       </bibliography>
    PRESXML
    html = <<~OUTPUT
      #{HTML_HDR}
             <p class="zzSTDTitle1"/>
             <div>
               <h1>1.  Normative References</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <p id="ISO712" class="NormRef">ISO/IEC Guide 99:2007<a class="FootnoteRef" href="#fn:1"><sup>1</sup></a> International Organization for Standardization and International Electrotechnical Commission. <i>International vocabulary of metrology — Basic and general concepts and associated terms (VIM)</i>. 1st edition. December 2007. <a href="https://www.iso.org/standard/45324.html">https://www.iso.org/standard/45324.html</a>.</p>
             </div>
             <aside id="fn:1" class="footnote">
               <p id="_">Also known as JCGM 200</p>
             </aside>
           </div>
         </body>
       </html>
    OUTPUT
    doc = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(strip_guid(xmlpp(Nokogiri::XML(doc)
    .at("//xmlns:bibliography").to_xml)))
      .to be_equivalent_to xmlpp(presxml)
    expect(strip_guid(xmlpp(IsoDoc::HtmlConvert.new({})
   .convert("test", doc, true))))
      .to be_equivalent_to xmlpp(html)
  end
end
