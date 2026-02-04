require "spec_helper"

RSpec.describe IsoDoc do
  it "processes Relaton bibliographies" do
    mock_uuid_increment
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
        <docidentifier type="ISSN">ISSN</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISSN</abbreviation>
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
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">en</language>
          </bibdata>

          <preface>
             <clause type="toc" id="_4" displayorder="1">
                <fmt-title depth="1" id="_26">Table of contents</fmt-title>
             </clause>
             <foreword id="_1" displayorder="2">
                <title id="_6">Foreword</title>
                <fmt-title depth="1" id="_27">
                   <semx element="title" source="_6">Foreword</semx>
                </fmt-title>
                <p id="_">
                   <eref bibitemid="ISO712" id="_16"/>
                   <semx element="eref" source="_16">
                      <fmt-xref target="ISO712">ISO\u00a0712</fmt-xref>
                   </semx>
                   <eref bibitemid="ISBN" id="_17"/>
                   <semx element="eref" source="_17">
                      <fmt-xref target="ISBN">[3]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISSN" id="_18"/>
                   <semx element="eref" source="_18">
                      <fmt-xref target="ISSN">[4]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISO16634" id="_19"/>
                   <semx element="eref" source="_19">
                      <fmt-xref target="ISO16634">ISO\u00a016634:--</fmt-xref>
                   </semx>
                   <eref bibitemid="ref1" id="_20"/>
                   <semx element="eref" source="_20">
                      <fmt-xref target="ref1">ICC/167</fmt-xref>
                   </semx>
                   <eref bibitemid="ref10" id="_21"/>
                   <semx element="eref" source="_21">
                      <fmt-xref target="ref10">[6]</fmt-xref>
                   </semx>
                   <eref bibitemid="ref12" id="_22"/>
                   <semx element="eref" source="_22">
                      <fmt-xref target="ref12">[Citn]</fmt-xref>
                   </semx>
                   <eref bibitemid="zip_ffs" id="_23"/>
                   <semx element="eref" source="_23">
                      <fmt-xref target="zip_ffs">[2]</fmt-xref>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <references id="_normative_references" obligation="informative" normative="true" displayorder="3">
                <title id="_7">Normative References</title>
                <fmt-title depth="1" id="_28">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_normative_references">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_7">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_normative_references">1</semx>
                </fmt-xref-label>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <biblio-tag>[1], ISO\u00a0712, </biblio-tag>
                   <formattedref>
                      International Organization for Standardization.
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="ISO">ISO\u00a0712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                </bibitem>
                <bibitem id="ISO16634" type="standard">
                   <biblio-tag>
                      ISO\u00a016634:--\u00a0(all\u00a0parts)
                      <fn id="_2" reference="1" original-reference="_2" target="_14">
                         <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                         <fmt-fn-label>
                            <span class="fmt-caption-label">
                               <sup>
                                  <semx element="autonum" source="_2">1</semx>
                               </sup>
                            </span>
                         </fmt-fn-label>
                      </fn>
                      ,
                   </biblio-tag>
                   <formattedref>
                      <em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em>
                      .
                   </formattedref>
                   <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
                   <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
                   <docidentifier type="ISO">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                   <date type="published">
                      <on>--</on>
                   </date>
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
                   <biblio-tag>ISO\u00a020483:2013-2014, </biblio-tag>
                   <formattedref>
                      International Organization for Standardization.
                      <em>Cereals and pulses</em>
                      . 2013–2014.
                   </formattedref>
                   <title format="text/plain">Cereals and pulses</title>
                   <docidentifier type="ISO">ISO\u00a020483:2013-2014</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a020483:2013-2014</docidentifier>
                   <date type="published">
                      <from>2013</from>
                      <to>2014</to>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                </bibitem>
                <bibitem id="ref1">
                   <biblio-tag>ICC/167, </biblio-tag>
                   <formattedref format="application/x-isodoc+xml">
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_24"/>
                      <semx element="link" source="_24">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      )
                   </formattedref>
                   <docidentifier type="ICC">ICC/167</docidentifier>
                   <docidentifier scope="biblio-tag">ICC/167</docidentifier>
                </bibitem>
                <note>
                   <fmt-name id="_29">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is an annotation of ISO 20483:2013-2014</p>
                </note>
                <bibitem id="zip_ffs">
                   <biblio-tag>[2] </biblio-tag>
                   <formattedref format="application/x-isodoc+xml">Title 5</formattedref>
                   <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                </bibitem>
             </references>
          </sections>
          <bibliography>
             <references id="_bibliography" obligation="informative" normative="false" displayorder="4">
                <title id="_8">Bibliography</title>
                <fmt-title depth="1" id="_30">
                   <semx element="title" source="_8">Bibliography</semx>
                </fmt-title>
                <bibitem id="ISBN" type="book">
                   <biblio-tag>
                      [3]
                      <tab/>
                   </biblio-tag>
                   <formattedref>
                      <em>Chemicals for analytical laboratory use</em>
                      . n.p.: n.d. ISBN: ISBN.
                   </formattedref>
                   <title format="text/plain">Chemicals for analytical laboratory use</title>
                   <docidentifier type="metanorma-ordinal">[3]</docidentifier>
                   <docidentifier type="ISBN">ISBN</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISBN</abbreviation>
                      </organization>
                   </contributor>
                </bibitem>
                <bibitem id="ISSN" type="journal">
                   <biblio-tag>
                      [4]
                      <tab/>
                   </biblio-tag>
                   <formattedref>
                      <em>Instruments for analytical laboratory use</em>
                      . n.d. ISSN: ISSN.
                   </formattedref>
                   <title format="text/plain">Instruments for analytical laboratory use</title>
                   <docidentifier type="metanorma-ordinal">[4]</docidentifier>
                   <docidentifier type="ISSN">ISSN</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISSN</abbreviation>
                      </organization>
                   </contributor>
                </bibitem>
                <note>
                   <fmt-name id="_31">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is an annotation of document ISSN.</p>
                </note>
                <note>
                   <fmt-name id="_32">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is another annotation of document ISSN.</p>
                </note>
                <bibitem id="ISO3696" type="standard">
                   <biblio-tag>
                      [5]
                      <tab/>
                      ISO\u00a03696
                      <fn id="_3" reference="2" original-reference="_3" target="_15">
                         <p>Under preparation. (Stage at the time of publication ISO/DIS 3696)</p>
                         <fmt-fn-label>
                            <span class="fmt-caption-label">
                               <sup>
                                  <semx element="autonum" source="_3">2</semx>
                               </sup>
                            </span>
                         </fmt-fn-label>
                      </fn>
                      ,
                   </biblio-tag>
                   <formattedref>
                      <em>Water for analytical laboratory use</em>
                      .
                   </formattedref>
                   <title format="text/plain">Water for analytical laboratory use</title>
                   <docidentifier type="metanorma-ordinal">[5]</docidentifier>
                   <docidentifier type="ISO">ISO\u00a03696</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a03696</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 3696)</note>
                </bibitem>
                <bibitem id="ref10">
                   <biblio-tag>
                      [6]
                      <tab/>
                   </biblio-tag>
                   <formattedref format="application/x-isodoc+xml">
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_25"/>
                      <semx element="link" source="_25">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      )
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[6]</docidentifier>
                </bibitem>
                <bibitem id="ref10a" hidden="true">
                   <formattedref>
                      <em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>
                      .
                   </formattedref>
                   <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                   <docidentifier type="IETF">IETF\u00a0RFC\u00a020</docidentifier>
                   <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a020</docidentifier>
                </bibitem>
                <bibitem id="ref11">
                   <biblio-tag>
                      [7]
                      <tab/>
                      IETF\u00a0RFC\u00a010,
                   </biblio-tag>
                   <formattedref>
                      <em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>
                      .
                   </formattedref>
                   <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                   <docidentifier type="metanorma-ordinal">[7]</docidentifier>
                   <docidentifier type="IETF">IETF\u00a0RFC\u00a010</docidentifier>
                   <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a010</docidentifier>
                </bibitem>
                <bibitem id="ref12">
                   <biblio-tag>
                      [Citn]
                      <tab/>
                      IETF\u00a0RFC\u00a020,
                   </biblio-tag>
                   <formattedref format="application/x-isodoc+xml">
                      CitationWorks. 2019.
                      <em>How to cite a reference</em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma">[Citn]</docidentifier>
                   <docidentifier type="IETF">IETF\u00a0RFC\u00a020</docidentifier>
                   <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a020</docidentifier>
                </bibitem>
                <bibitem id="ref10b">
                   <biblio-tag>
                      [8]
                      <tab/>
                      IETF\u00a0RFC\u00a020,
                   </biblio-tag>
                   <formattedref>
                      <em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>
                      .
                   </formattedref>
                   <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                   <docidentifier type="metanorma-ordinal">[8]</docidentifier>
                   <docidentifier type="IETF">IETF\u00a0RFC\u00a020</docidentifier>
                   <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a020</docidentifier>
                </bibitem>
                <bibitem id="ref10c">
                   <biblio-tag>
                      [9]
                      <tab/>
                   </biblio-tag>
                   <formattedref>
                      <em>Internet Calendaring &amp; Scheduling Core Object Specification (iCalendar)</em>
                      .
                   </formattedref>
                   <title>Internet Calendaring &amp; Scheduling Core Object Specification (iCalendar)</title>
                   <docidentifier type="metanorma-ordinal">[9]</docidentifier>
                   <docidentifier type="DOI">DOI\u00a0ABC\u00a020</docidentifier>
                </bibitem>
             </references>
          </bibliography>
          <fmt-footnote-container>
             <fmt-fn-body id="_14" target="_2" reference="1">
                <semx element="fn" source="_2">
                   <p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_2">1</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Under preparation. (Stage at the time of publication ISO/DIS 16634)
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_15" target="_3" reference="2">
                <semx element="fn" source="_3">
                   <p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_3">2</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Under preparation. (Stage at the time of publication ISO/DIS 3696)
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    PRESXML

    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="_1">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p id="_">
                      <a href="#ISO712">ISO\u00a0712</a>
                      <a href="#ISBN">[3]</a>
                      <a href="#ISSN">[4]</a>
                      <a href="#ISO16634">ISO\u00a016634:--</a>
                      <a href="#ref1">ICC/167</a>
                      <a href="#ref10">[6]</a>
                      <a href="#ref12">[Citn]</a>
                      <a href="#zip_ffs">[2]</a>
                   </p>
                </div>
                <div>
                   <h1>1.\u00a0 Normative References</h1>
                   <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                   <p id="ISO712" class="NormRef">
                      [1], ISO\u00a0712, International Organization for Standardization.
                      <i>Cereals and cereal products</i>
                      .
                   </p>
                   <p id="ISO16634" class="NormRef">
                      ISO\u00a016634:--\u00a0(all\u00a0parts)
                      <a class="FootnoteRef" href="#fn:_14">
                         <sup>1</sup>
                      </a>
                      ,
                      <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>
                      .
                   </p>
                   <p id="ISO20483" class="NormRef">
                      ISO\u00a020483:2013-2014, International Organization for Standardization.
                      <i>Cereals and pulses</i>
                      . 2013–2014.
                   </p>
                   <p id="ref1" class="NormRef">
                      ICC/167,
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE\u00a0 </span>
                         This is an annotation of ISO 20483:2013-2014
                      </p>
                   </div>
                   <p id="zip_ffs" class="NormRef">[2] Title 5</p>
                </div>
                <br/>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <p id="ISBN" class="Biblio">
                      [3]\u00a0
                      <i>Chemicals for analytical laboratory use</i>
                      . n.p.: n.d. ISBN: ISBN.
                   </p>
                   <p id="ISSN" class="Biblio">
                      [4]\u00a0
                      <i>Instruments for analytical laboratory use</i>
                      . n.d. ISSN: ISSN.
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE\u00a0 </span>
                         This is an annotation of document ISSN.
                      </p>
                   </div>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE\u00a0 </span>
                         This is another annotation of document ISSN.
                      </p>
                   </div>
                   <p id="ISO3696" class="Biblio">
                      [5]\u00a0 ISO\u00a03696
                      <a class="FootnoteRef" href="#fn:_15">
                         <sup>2</sup>
                      </a>
                      ,
                      <i>Water for analytical laboratory use</i>
                      .
                   </p>
                   <p id="ref10" class="Biblio">
                      [6]\u00a0
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <p id="ref11" class="Biblio">
                      [7]\u00a0 IETF\u00a0RFC\u00a010,
                      <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>
                      .
                   </p>
                   <p id="ref12" class="Biblio">
                      [Citn]\u00a0 IETF\u00a0RFC\u00a020, CitationWorks. 2019.
                      <i>How to cite a reference</i>
                      .
                   </p>
                   <p id="ref10b" class="Biblio">
                      [8]\u00a0 IETF\u00a0RFC\u00a020,
                      <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>
                      .
                   </p>
                   <p id="ref10c" class="Biblio">
                      [9]\u00a0
                      <i>Internet Calendaring &amp; Scheduling Core Object Specification (iCalendar)</i>
                      .
                   </p>
                </div>
                <aside id="fn:_14" class="footnote">
                   <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                </aside>
                <aside id="fn:_15" class="footnote">
                   <p>Under preparation. (Stage at the time of publication ISO/DIS 3696)</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT

    doc = <<~OUTPUT
      <html><body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
        <div class="WordSection2">
            <p class="MsoNormal">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always">
            </p>
            <div>
              <a name="_1" id="_1"></a>
              <h1 class="ForewordTitle">Foreword</h1>
              <p class="MsoNormal"><a name="_" id="_"></a>
                  <a href="#ISO712">ISO 712</a>
                  <a href="#ISBN">[3]</a>
                  <a href="#ISSN">[4]</a>
                  <a href="#ISO16634">ISO 16634:--</a>
                  <a href="#ref1">ICC/167</a>
                  <a href="#ref10">[6]</a>
                  <a href="#ref12">[Citn]</a>
                  <a href="#zip_ffs">[2]</a>
              </p>
            </div>
            <p class="MsoNormal"> </p>
        </div>
        <p class="MsoNormal">
            <br clear="all" class="section">
        </p>
        <div class="WordSection3">
            <div>
              <h1>1.<span style="mso-tab-count:1">  </span>Normative References</h1>
              <p class="MsoNormal">The following documents are referred to in the text in such a way that some or all of
                  their content constitutes requirements of this document. For dated references, only the edition cited
                  applies. For undated references, the latest edition of the referenced document (including any amendments)
                  applies.</p>
              <p class="NormRef"><a name="ISO712" id="ISO712"></a>[1], ISO 712, International Organization for
                  Standardization. <i>Cereals and cereal products</i>.</p>
              <p class="NormRef"><a name="ISO16634" id="ISO16634"></a>ISO 16634:-- (all parts)<span style="mso-bookmark:_Ref"
                    class="MsoFootnoteReference"><a class="FootnoteRef" type="footnote" href="#_ftn1"
                        style="mso-footnote-id:ftn1" name="_ftnref1" title="" id="_ftnref1"><span
                          class="MsoFootnoteReference"><span
                              style="mso-special-character:footnote"></span></span></a></span>, <i>Cereals, pulses, milled
                    cereal products, oilseeds and animal feeding stuffs</i>.</p>
              <p class="NormRef"><a name="ISO20483" id="ISO20483"></a>ISO 20483:2013-2014, International Organization for
                  Standardization. <i>Cereals and pulses</i>. 2013–2014.</p>
              <p class="NormRef"><a name="ref1" id="ref1"></a>ICC/167, <span style="font-variant:small-caps;">Standard No
                    I.C.C 167</span>. <i>Determination of the protein content in cereal and cereal products for food and
                    animal feeding stuffs according to the Dumas combustion method</i> (see <a
                    href="http://www.icc.or.at">http://www.icc.or.at</a>)</p>
              <div class="Note">
                  <p class="Note"><span class="note_label">NOTE<span style="mso-tab-count:1">  </span></span>This is an
                    annotation of ISO 20483:2013-2014</p>
              </div>
              <p class="NormRef"><a name="zip_ffs" id="zip_ffs"></a>[2] Title 5</p>
            </div>
            <p class="MsoNormal">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always">
            </p>
            <div>
              <h1 class="Section3">Bibliography</h1>

              <p class="Biblio"><a name="ISBN" id="ISBN"></a>[3]<span style="mso-tab-count:1">  </span><i>Chemicals for
                    analytical laboratory use</i>. n.p.: n.d. ISBN: ISBN.</p>
              <p class="Biblio"><a name="ISSN" id="ISSN"></a>[4]<span style="mso-tab-count:1">  </span><i>Instruments for
                    analytical laboratory use</i>. n.d. ISSN: ISSN.</p>
              <div class="Note">
                  <p class="Note"><span class="note_label">NOTE<span style="mso-tab-count:1">  </span></span>This is an
                    annotation of document ISSN.</p>
              </div>
              <div class="Note">
                  <p class="Note"><span class="note_label">NOTE<span style="mso-tab-count:1">  </span></span>This is another
                    annotation of document ISSN.</p>
              </div>
              <p class="Biblio"><a name="ISO3696" id="ISO3696"></a>[5]<span style="mso-tab-count:1">  </span>ISO 3696<span
                    style="mso-bookmark:_Ref" class="MsoFootnoteReference"><a class="FootnoteRef" type="footnote"
                        href="#_ftn2" style="mso-footnote-id:ftn2" name="_ftnref2" title="" id="_ftnref2"><span
                          class="MsoFootnoteReference"><span
                              style="mso-special-character:footnote"></span></span></a></span>, <i>Water for analytical
                    laboratory use</i>.</p>
              <p class="Biblio"><a name="ref10" id="ref10"></a>[6]<span style="mso-tab-count:1">  </span><span
                    style="font-variant:small-caps;">Standard No I.C.C 167</span>. <i>Determination of the protein content in
                    cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion
                    method</i> (see <a href="http://www.icc.or.at">http://www.icc.or.at</a>)</p>

              <p class="Biblio"><a name="ref11" id="ref11"></a>[7]<span style="mso-tab-count:1">  </span>IETF RFC 10,
                  <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
              <p class="Biblio"><a name="ref12" id="ref12"></a>[Citn]<span style="mso-tab-count:1">  </span>IETF RFC 20,
                  CitationWorks. 2019. <i>How to cite a reference</i>.</p>
              <p class="Biblio"><a name="ref10b" id="ref10b"></a>[8]<span style="mso-tab-count:1">  </span>IETF RFC 20,
                  <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</p>
              <p class="Biblio"><a name="ref10c" id="ref10c"></a>[9]<span style="mso-tab-count:1">  </span><i>Internet
                    Calendaring &amp; Scheduling Core Object Specification (iCalendar)</i>.</p>
            </div>
        </div>
        <div style="mso-element:footnote-list">
            <div style="mso-element:footnote" id="ftn1">
              <p class="MsoFootnoteText"><a style="mso-footnote-id:ftn1" href="#_ftn1" name="_ftnref1" title=""
                    id="_ftnref1"><span class="MsoFootnoteReference"><span
                          style="mso-special-character:footnote"></span></span></a>Under preparation. (Stage at the time of
                  publication ISO/DIS 16634)</p>
            </div>
            <div style="mso-element:footnote" id="ftn2">
              <p class="MsoFootnoteText"><a style="mso-footnote-id:ftn2" href="#_ftn2" name="_ftnref2" title=""
                    id="_ftnref2"><span class="MsoFootnoteReference"><span
                          style="mso-special-character:footnote"></span></span></a>Under preparation. (Stage at the time of
                  publication ISO/DIS 3696)</p>
            </div>
        </div>
      </body></html>
    OUTPUT

    FileUtils.rm_rf("test.doc")
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<fn reference="[^"]+"}m, "<fn reference=\"_\"")))
      .to be_xml_equivalent_to presxml

    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to html

    IsoDoc::WordConvert.new({})
      .convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true

    html = File.read("test.doc")
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub("epub:", "")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")
      .gsub(/NOTEREF _Ref\d+/, "NOTEREF _Ref")

    expect(Nokogiri::HTML4(strip_guid(html)))
      .to be_html4_equivalent_to doc
  end

  it "marks references sections as hidden" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
      <bibliography>
      <references>
      <title>Title</title>
      <bibitem hidden="true"/>
      <bibitem hidden="true"/>
      <bibitem hidden="true"/>
      </references>
      <references>
      <bibitem hidden="true"/>
      <bibitem/>
      </references>
      <references>
            <p/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
          </references>
      </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
          <preface> <clause type="toc" id="_" displayorder="1">
          <fmt-title id="_" depth="1">Table of contents</fmt-title>
          </clause>
         </preface>
        <bibliography>
          <references id="_" hidden='true'>
                   <title id="_">Title</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Title</semx>
         </fmt-title>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
          </references>
          <references id="_">
            <bibitem hidden='true'/>
          <bibitem>
            <docidentifier type="metanorma-ordinal">[1]</docidentifier>
         </bibitem>
          </references>
          <references id="_">
            <p/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
            <bibitem hidden='true'/>
          </references>
        </bibliography>
      </iso-standard>
    PRESXML
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "processes hidden references sections in Relaton bibliographies #1" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
        <clause type="toc" id="_toc" displayorder="1">
          <fmt-title id="_" depth="1">Table of contents</fmt-title>
          </clause>
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
          <title>Normative References</title>
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
            <bibitem id='ISBN' type='book'>
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
            <bibitem id='ISSN' type='journal'>
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
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
         </bibdata>
         <preface>
            <foreword id="_" displayorder="1">
               <title id="_">Foreword</title>
               <fmt-title depth="1" id="_">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="_">
                  <eref bibitemid="ISO712" id="_">[110]</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISO712">[110]</fmt-xref>
                  </semx>
                  <eref bibitemid="ISBN" id="_">[1]</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISBN">[1]</fmt-xref>
                  </semx>
                  <eref bibitemid="ISSN" id="_">[2]</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISSN">[2]</fmt-xref>
                  </semx>
                  <eref bibitemid="ISO16634" id="_">ISO 16634:-- (all parts)</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISO16634">ISO 16634:-- (all parts)</fmt-xref>
                  </semx>
                  <eref bibitemid="ref1" id="_">ICC/167</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref1">ICC/167</fmt-xref>
                  </semx>
                  <eref bibitemid="ref10" id="_">[10]</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref10">[10]</fmt-xref>
                  </semx>
                  <eref bibitemid="ref12" id="_">Citn</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref12">Citn</fmt-xref>
                  </semx>
                  <eref bibitemid="zip_ffs" id="_">[5]</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="zip_ffs">[5]</fmt-xref>
                  </semx>
               </p>
            </foreword>
            <clause type="toc" id="_toc" displayorder="2">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <references id="_normative_references" obligation="informative" normative="true" hidden="true" displayorder="3">
               <title id="_">Normative References</title>
               <fmt-title depth="1" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_normative_references"/>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_normative_references"/>
               </fmt-xref-label>
               <p>
              The following documents are referred to in the text in such a way that
              some or all of their content constitutes requirements of this document.
              For dated references, only the edition cited applies. For undated
              references, the latest edition of the referenced document (including any
              amendments) applies.
            </p>
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
               <bibitem id="ISO16634" type="standard">
                  <biblio-tag>
                     ISO\u00a016634:--\u00a0(all\u00a0parts)
                     <fn id="_" reference="1" original-reference="_" target="_">
                        <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                        <fmt-fn-label>
                           <span class="fmt-caption-label">
                              <sup>
                                 <semx element="autonum" source="_">1</semx>
                              </sup>
                           </span>
                        </fmt-fn-label>
                     </fn>
                     ,
                  </biblio-tag>
                  <formattedref>
                     <em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em>
                     .
                  </formattedref>
                  <title language="x" format="text/plain">
                Cereals, pulses, milled cereal products, xxxx, oilseeds and animal
                feeding stuffs
              </title>
                  <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
                  <docidentifier type="ISO">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                  <docidentifier scope="biblio-tag">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                  <date type="published">
                     <on>--</on>
                  </date>
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
                  <biblio-tag>ISO\u00a020483:2013-2014, </biblio-tag>
                  <formattedref>
                     International Organization for Standardization.
                     <em>Cereals and pulses</em>
                     . 2013–2014.
                  </formattedref>
                  <title format="text/plain">Cereals and pulses</title>
                  <docidentifier type="ISO">ISO\u00a020483:2013-2014</docidentifier>
                  <docidentifier scope="biblio-tag">ISO\u00a020483:2013-2014</docidentifier>
                  <date type="published">
                     <from>2013</from>
                     <to>2014</to>
                  </date>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>International Organization for Standardization</name>
                     </organization>
                  </contributor>
               </bibitem>
               <bibitem id="ref1">
                  <biblio-tag>ICC/167, </biblio-tag>
                  <formattedref format="application/x-isodoc+xml">
                     <smallcap>Standard No I.C.C 167</smallcap>
                     .
                     <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                     (see
                     <link target="http://www.icc.or.at" id="_"/>
                     <semx element="link" source="_">
                        <fmt-link target="http://www.icc.or.at"/>
                     </semx>
                     )
                  </formattedref>
                  <docidentifier type="ICC">ICC/167</docidentifier>
                  <docidentifier scope="biblio-tag">ICC/167</docidentifier>
               </bibitem>
               <note>
                  <name id="_">NOTE</name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-caption-delim"/>
                     <semx element="name" source="_">NOTE</semx>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is an annotation of ISO 20483:2013-2014</p>
               </note>
               <bibitem id="zip_ffs">
                  <biblio-tag/>
                  <formattedref format="application/x-isodoc+xml">Title 5</formattedref>
               </bibitem>
            </references>
         </sections>
         <bibliography>
            <references id="_bibliography" obligation="informative" normative="false" hidden="true" displayorder="4">
               <title depth="1" id="_">Bibliography</title>
               <fmt-title depth="1" id="_">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <bibitem id="ISBN" type="book">
                  <biblio-tag>
                     [1]
                     <tab/>
                  </biblio-tag>
                  <formattedref>
                     <em>Chemicals for analytical laboratory use</em>
                     . n.p.: n.d. ISBN: ISBN.
                  </formattedref>
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
                  <biblio-tag>
                     [2]
                     <tab/>
                  </biblio-tag>
                  <formattedref>
                     <em>Instruments for analytical laboratory use</em>
                     . n.d. ISSN: ISSN.
                  </formattedref>
                  <title format="text/plain">Instruments for analytical laboratory use</title>
                  <docidentifier type="ISSN">ISSN</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <abbreviation>ISSN</abbreviation>
                     </organization>
                  </contributor>
               </bibitem>
               <note>
                  <name id="_">NOTE</name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-caption-delim"/>
                     <semx element="name" source="_">NOTE</semx>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is an annotation of document ISSN.</p>
               </note>
               <note>
                  <name id="_">NOTE</name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-caption-delim"/>
                     <semx element="name" source="_">NOTE</semx>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is another annotation of document ISSN.</p>
               </note>
               <bibitem id="ISO3696" type="standard">
                  <biblio-tag>
                     [3]
                     <tab/>
                     ISO\u00a03696,
                  </biblio-tag>
                  <formattedref>
                     <em>Water for analytical laboratory use</em>
                     .
                  </formattedref>
                  <title format="text/plain">Water for analytical laboratory use</title>
                  <docidentifier type="ISO">ISO\u00a03696</docidentifier>
                  <docidentifier scope="biblio-tag">ISO\u00a03696</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <abbreviation>ISO</abbreviation>
                     </organization>
                  </contributor>
               </bibitem>
               <bibitem id="ref10">
                  <biblio-tag>
                     [4]
                     <tab/>
                  </biblio-tag>
                  <formattedref format="application/x-isodoc+xml">
                     <smallcap>Standard No I.C.C 167</smallcap>
                     .
                     <em>
                  Determination of the protein content in cereal and cereal products
                  for food and animal feeding stuffs according to the Dumas combustion
                  method
                </em>
                     (see
                     <link target="http://www.icc.or.at" id="_"/>
                     <semx element="link" source="_">
                        <fmt-link target="http://www.icc.or.at"/>
                     </semx>
                     )
                  </formattedref>
               </bibitem>
               <bibitem id="ref11">
                  <biblio-tag>
                     [5]
                     <tab/>
                     IETF\u00a0RFC\u00a010,
                  </biblio-tag>
                  <formattedref>
                     <em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>
                     .
                  </formattedref>
                  <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                  <docidentifier type="IETF">IETF\u00a0RFC\u00a010</docidentifier>
                  <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a010</docidentifier>
               </bibitem>
               <bibitem id="ref12">
                  <biblio-tag>
                     [Citn]
                     <tab/>
                     IETF\u00a0RFC\u00a020,
                  </biblio-tag>
                  <formattedref format="application/x-isodoc+xml">
                     CitationWorks. 2019.
                     <em>How to cite a reference</em>
                     .
                  </formattedref>
                  <docidentifier type="metanorma">[Citn]</docidentifier>
                  <docidentifier type="IETF">IETF\u00a0RFC\u00a020</docidentifier>
                  <docidentifier scope="biblio-tag">IETF\u00a0RFC\u00a020</docidentifier>
               </bibitem>
            </references>
         </bibliography>
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
                     Under preparation. (Stage at the time of publication ISO/DIS 16634)
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "processes hidden references sections in Relaton bibliographies #2" do
    input = <<~INPUT
              <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
                <bibdata>
                  <language current="true">en</language>
                </bibdata>
                <preface>
                <clause type="toc" id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f" displayorder="1"> <title depth="1">Table of contents</title> </clause>
                  <foreword>
                    <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                      <eref bibitemid='ISO712'>[110]</eref>
                      <eref bibitemid='ISO16634'>ISO 16634:-- (all parts)</eref>
                    </p>
                  </foreword>
                </preface>
                <bibliography>
                  <references id='_normative_references' obligation='informative' normative='true'>
                  <title>Normative References</title>
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
                    </bibitem>
      </references></bibliography></iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
         </bibdata>
         <preface>
            <foreword id="_" displayorder="1">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="_">
                  <eref bibitemid="ISO712" id="_">[110]</eref>
                  <semx element="eref" source="_">
                     <fmt-eref bibitemid="ISO712">[110]</fmt-eref>
                  </semx>
                  <eref bibitemid="ISO16634" id="_">ISO 16634:-- (all parts)</eref>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISO16634">ISO 16634:-- (all parts)</fmt-xref>
                  </semx>
               </p>
            </foreword>
            <clause type="toc" id="_" displayorder="2">
               <title depth="1" id="_">Table of contents</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Table of contents</semx>
               </fmt-title>
            </clause>
         </preface>
         <sections>
            <references id="_normative_references" obligation="informative" normative="true" displayorder="3">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_normative_references">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_normative_references">1</semx>
               </fmt-xref-label>
               <p>
                      The following documents are referred to in the text in such a way that
                      some or all of their content constitutes requirements of this document.
                      For dated references, only the edition cited applies. For undated
                      references, the latest edition of the referenced document (including any
                      amendments) applies.
                    </p>
               <bibitem id="ISO712" type="standard" hidden="true">
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
               <bibitem id="ISO16634" type="standard">
                  <formattedref language="en" format="text/plain">
                     <em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em>
                  </formattedref>
                  <docidentifier type="ISO">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                  <docidentifier scope="biblio-tag">ISO\u00a016634:--\u00a0(all\u00a0parts)</docidentifier>
                  <date type="published">
                     <on>--</on>
                  </date>
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
                  <biblio-tag>
                     ISO\u00a016634:--\u00a0(all\u00a0parts)
                     <fn id="_" reference="1" original-reference="_" target="_">
                        <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                        <fmt-fn-label>
                           <span class="fmt-caption-label">
                              <sup>
                                 <semx element="autonum" source="_">1</semx>
                              </sup>
                           </span>
                        </fmt-fn-label>
                     </fn>
                     ,
                  </biblio-tag>
               </bibitem>
            </references>
         </sections>
         <bibliography>
                  </bibliography>
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
                     Under preparation. (Stage at the time of publication ISO/DIS 16634)
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "renders mixed bibitems and bibliographic subclauses" do
    mock_uuid_increment
    input = <<~INPUT
         <iso-standard xmlns="http://riboseinc.com/isoxml">
             <bibdata>
             <language>en</language>
             </bibdata>
                      <bibliography>
        <clause id="A" obligation="informative">
          <title>Normative References</title>
          <p id="_">Text</p>
          <references id="B" unnumbered="true" normative="true">
            <bibitem id="iso122">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier type="metanorma">[<strong>A</strong>.<fn reference="1"><p id="_">hello</p></fn>]</docidentifier>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
            <p id="_">More text</p>
          </references>
          <references id="C" normative="true" obligation="informative">
            <title>Normative 1</title>
            <bibitem id="iso123">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier type="metanorma">[<strong>A</strong>.<fn reference="1"><p id="_">hello</p></fn>]</docidentifier>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
          </references>
        </clause>
        <clause id="D" obligation="informative">
          <title>Bibliography</title>
          <p id="_">Text</p>
          <references id="E" unnumbered="true" normative="false">
            <bibitem id="iso124">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier type="metanorma">[<strong>A</strong>.<fn reference="1"><p id="_">hello</p></fn>]</docidentifier>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
            <p id="_">More text</p>
          </references>
          <references id="F" normative="false" obligation="informative">
            <title>Bibliography 1</title>
            <bibitem id="iso125">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier type="metanorma">[<strong>A</strong>.<fn reference="1"><p id="_">hello</p></fn>]</docidentifier>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
          </references>
        </clause>
      </bibliography>
         </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
         </bibdata>
         <preface>
            <clause type="toc" id="_5" displayorder="1">
               <fmt-title depth="1" id="_14">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="A" obligation="informative" displayorder="2">
               <title id="_7">Normative References</title>
               <fmt-title depth="1" id="_15">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="A">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_7">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </fmt-xref-label>
               <p id="_">Text</p>
               <references id="B" unnumbered="true" normative="true">
                  <bibitem id="iso122">
                     <biblio-tag>
                        [
                        <strong>A</strong>
                        .], XYZ
                        <fn reference="1" id="_1" original-reference="1" target="_13">
                           <p original-id="_">hello</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_1">1</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </fn>
                        ,
                     </biblio-tag>
                     <formattedref format="application/x-isodoc+xml">
                        <em>Standard</em>
                     </formattedref>
                     <docidentifier type="metanorma">
                        [
                        <strong>A</strong>
                        .]
                     </docidentifier>
                     <docidentifier>XYZ</docidentifier>
                     <docidentifier scope="biblio-tag">XYZ</docidentifier>
                  </bibitem>
                  <p id="_">More text</p>
               </references>
               <references id="C" normative="true" obligation="informative">
                  <title id="_9">Normative 1</title>
                  <fmt-title depth="2" id="_16">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="A">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_9">Normative 1</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="A">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="C">1</semx>
                  </fmt-xref-label>
                  <bibitem id="iso123">
                     <biblio-tag>
                        [
                        <strong>A</strong>
                        .], XYZ
                        <fn reference="1" id="_2" original-reference="1" target="_13">
                           <p id="_">hello</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_2">1</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </fn>
                        ,
                     </biblio-tag>
                     <formattedref format="application/x-isodoc+xml">
                        <em>Standard</em>
                     </formattedref>
                     <docidentifier type="metanorma">
                        [
                        <strong>A</strong>
                        .]
                     </docidentifier>
                     <docidentifier>XYZ</docidentifier>
                     <docidentifier scope="biblio-tag">XYZ</docidentifier>
                  </bibitem>
               </references>
            </clause>
         </sections>
         <bibliography>
            <clause id="D" obligation="informative" displayorder="3">
               <title id="_10">Bibliography</title>
               <fmt-title depth="1" id="_17">
                  <semx element="title" source="_10">Bibliography</semx>
               </fmt-title>
               <p id="_">Text</p>
               <references id="E" unnumbered="true" normative="false">
                  <bibitem id="iso124">
                     <biblio-tag>
                        [
                        <strong>A</strong>
                        .]
                        <tab/>
                        XYZ
                        <fn reference="1" id="_3" original-reference="1" target="_13">
                           <p id="_">hello</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_3">1</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </fn>
                        ,
                     </biblio-tag>
                     <formattedref format="application/x-isodoc+xml">
                        <em>Standard</em>
                     </formattedref>
                     <docidentifier type="metanorma">
                        [
                        <strong>A</strong>
                        .]
                     </docidentifier>
                     <docidentifier>XYZ</docidentifier>
                     <docidentifier scope="biblio-tag">XYZ</docidentifier>
                  </bibitem>
                  <p id="_">More text</p>
               </references>
               <references id="F" normative="false" obligation="informative">
                  <title id="_12">Bibliography 1</title>
                  <fmt-title depth="2" id="_18">
                     <semx element="title" source="_12">Bibliography 1</semx>
                  </fmt-title>
                  <bibitem id="iso125">
                     <biblio-tag>
                        [
                        <strong>A</strong>
                        .]
                        <tab/>
                        XYZ
                        <fn reference="1" id="_4" original-reference="1" target="_13">
                           <p id="_">hello</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_4">1</semx>
                                 </sup>
                              </span>
                           </fmt-fn-label>
                        </fn>
                        ,
                     </biblio-tag>
                     <formattedref format="application/x-isodoc+xml">
                        <em>Standard</em>
                     </formattedref>
                     <docidentifier type="metanorma">
                        [
                        <strong>A</strong>
                        .]
                     </docidentifier>
                     <docidentifier>XYZ</docidentifier>
                     <docidentifier scope="biblio-tag">XYZ</docidentifier>
                  </bibitem>
               </references>
            </clause>
         </bibliography>
         <fmt-footnote-container>
            <fmt-fn-body id="_13" target="_1" reference="1">
               <semx element="fn" source="_1">
                  <p id="_">
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
                     hello
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </iso-standard>
    PRESXML
    html = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p>\u00a0</p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p>\u00a0</p>
            </div>
            <br/>
            <div class="main-section">
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <div>
                  <h1>1.\u00a0 Normative References</h1>
                  <p id="_">Text</p>
                  <div>
                     <p id="iso122" class="Biblio">
                        [<b>A</b>
                        .], XYZ
                        <a class="FootnoteRef" href="#fn:_13">
                           <sup>1</sup>
                        </a>
                        ,
                        <i>Standard</i>
                     </p>
                     <p id="_">More text</p>
                  </div>
                  <div>
                     <h2 class="Section3">1.1.\u00a0 Normative 1</h2>
                     <p id="iso123" class="Biblio">
                        [<b>A</b>
                        .], XYZ
                        <a class="FootnoteRef" href="#fn:_13">
                           <sup>1</sup>
                        </a>
                        ,
                        <i>Standard</i>
                     </p>
                  </div>
               </div>
               <br/>
               <div>
                  <h1 class="Section3">Bibliography</h1>
                  <p id="_">Text</p>
                  <div>
                     <p id="iso124" class="Biblio">
                        [<b>A</b>
                        .]\u00a0 XYZ
                        <a class="FootnoteRef" href="#fn:_13">
                           <sup>1</sup>
                        </a>
                        ,
                        <i>Standard</i>
                     </p>
                     <p id="_">More text</p>
                  </div>
                  <div>
                     <h2 class="Section3">Bibliography 1</h2>
                     <p id="iso125" class="Biblio">
                        [<b>A</b>
                        .]\u00a0 XYZ
                        <a class="FootnoteRef" href="#fn:_13">
                           <sup>1</sup>
                        </a>
                        ,
                        <i>Standard</i>
                     </p>
                  </div>
               </div>
               <aside id="fn:_13" class="footnote">
                  <p id="_">hello</p>
               </aside>
            </div>
         </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    xml = Nokogiri::XML(pres_output)
    xml.at("//xmlns:localized-strings").remove
    expect(strip_guid(xml.to_xml))
      .to be_xml_equivalent_to presxml

    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(strip_guid(output.to_html))
      .to be_html5_equivalent_to html
  end

  it "processes clauses containing normative references" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
           <bibliography>
       <clause id="D" obligation="informative">
        <title>Bibliography</title>
        <references id="E" obligation="informative" normative="false">
        <title>Bibliography Subsection 1</title>
      </references>
        <references id="F" obligation="informative" normative="false">
        <title>Bibliography Subsection 2</title>
      </references>
      </clause>
      <clause id="A" obligation="informative"><title>First References</title>
       <references id="B" obligation="informative" normative="true">
        <title>Normative References 1</title>
      </references>
       <references id="C" obligation="informative" normative="false">
        <title>Normative References 2</title>
      </references>
       </clause>

      </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="A" obligation="informative" displayorder="2">
                <title id="_">First References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">First References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref-label>
                <references id="B" obligation="informative" normative="true">
                   <title id="_">Normative References 1</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="A">1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="B">1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Normative References 1</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="B">1</semx>
                   </fmt-xref-label>
                </references>
                <references id="C" obligation="informative" normative="false">
                   <title id="_">Normative References 2</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="A">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="C">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Normative References 2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="C">2</semx>
                   </fmt-xref-label>
                </references>
             </clause>
          </sections>
          <bibliography>
             <clause id="D" obligation="informative" displayorder="3">
                <title id="_">Bibliography</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="E" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection 1</title>
                   <fmt-title id="_" depth="2">
                         <semx element="title" source="_">Bibliography Subsection 1</semx>
                   </fmt-title>
                </references>
                <references id="F" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection 2</title>
                   <fmt-title id="_" depth="2">
                         <semx element="title" source="_">Bibliography Subsection 2</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                 <div>
                   <h1>1.\u00a0 First References</h1>
                   <div>
                     <h2 class='Section3'>1.1.\u00a0 Normative References 1</h2>
                   </div>
                   <div>
                     <h2 class='Section3'>1.2.\u00a0 Normative References 2</h2>
                   </div>
                 </div>
                 <br/>
                 <div>
                   <h1 class='Section3'>Bibliography</h1>
                   <div>
                     <h2 class='Section3'>Bibliography Subsection 1</h2>
                   </div>
                   <div>
                     <h2 class='Section3'>Bibliography Subsection 2</h2>
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

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output))
      .to be_html5_equivalent_to html
  end
end
