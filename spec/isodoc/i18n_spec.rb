require "spec_helper"

RSpec.describe IsoDoc do
  let(:input) { <<~INPUT }
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    <language>LANGUAGE</language>
          <script>SCRIPT</script>
                <status>
          <stage>published</stage>
          <substage>withdrawn</substage>
          </status>
          <edition>2</edition>
          <ext>
          <doctype>brochure</doctype>
          </ext>
    </bibdata>
    <preface>
    <foreword obligation="informative">
       <title>Foreword</title>
       <p id="A">See <xref target="M"/></p>
             <p id="A">See <xref target="tab"/></p>
             <table id="tab"/>
     </foreword>
      <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
       <title>Introduction Subsection</title>
     </clause>
     </introduction></preface><sections>
     <clause id="D" obligation="normative" type="scope">
       <title>Scope</title>
       <p id="E"><eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref></p>
     </clause>

     <clause id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
       <title>Normal Terms</title>
       <term id="J">
       <preferred><expression><name>Term2</name></expression></preferred>
     </term>
     </terms>
     <definitions id="K">
       <dl>
       <dt>Symbol</dt>
       <dd>Definition</dd>
       </dl>
     </definitions>
     </clause>
     <definitions id="L">
       <dl>
       <dt>Symbol</dt>
       <dd>Definition</dd>
       </dl>
     </definitions>
     <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
       <title>Introduction</title>
       <note id="M-n1"/>
     </clause>
     <clause id="O" inline-header="false" obligation="normative">
       <title>Clause 4.2</title>
     </clause></clause>

     </sections><annex id="P" inline-header="false" obligation="normative">
       <title>Annex</title>
       <clause id="Q" inline-header="false" obligation="normative">
       <title>Annex A.1</title>
       <clause id="Q1" inline-header="false" obligation="normative">
       <title>Annex A.1a</title>
       </clause>
     </clause>
     </annex><bibliography><references id="R" obligation="informative" normative="true">
       <title>Normative References</title>
                      <bibitem id="ISO712" type="standard">
      <title format="text/plain">Cereals and cereal products</title>
      <docidentifier>ISO 712</docidentifier>
      <contributor>
        <role type="publisher"/>
        <organization>
          <abbreviation>ISO</abbreviation>
        </organization>
      </contributor>
    </bibitem>
     </references><clause id="S" obligation="informative">
       <title>Bibliography</title>
       <references id="T" obligation="informative" normative="false">
       <title>Bibliography Subsection</title>
     </references>
     </clause>
     </bibliography>
     </iso-standard>
  INPUT

  it "processes English" do
    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
            <script current="true">Latn</script>
            <status>
               <stage>published</stage>
               <substage>withdrawn</substage>
            </status>
            <edition language="">2</edition>
            <edition language="en">second edition</edition>
            <ext>
               <doctype>brochure</doctype>
            </ext>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword obligation="informative" displayorder="2" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="A">
                  See
          <xref target="M" id="_"/>
          <semx element="xref" source="_">
             <fmt-xref target="M">
                <span class="fmt-element-name">Clause</span>
                <semx element="autonum" source="M">5</semx>
             </fmt-xref>
          </semx>
               </p>
            <p id="A">
            See
            <xref target="tab" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="tab">
                  <span class="fmt-element-name">Table</span>
                  <semx element="autonum" source="tab">1</semx>
               </fmt-xref>
            </semx>
         </p>
         <table id="tab" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Table</span>
                  <semx element="autonum" source="tab">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Table</span>
               <semx element="autonum" source="tab">1</semx>
            </fmt-xref-label>
         </table>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <clause id="C" inline-header="false" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref-label>
                        <p id="E">
            <eref type="inline" bibitemid="ISO712" id="_">
               <locality type="table">
                  <referenceFrom>1</referenceFrom>
                  <referenceTo>1</referenceTo>
               </locality>
            </eref>
            <semx element="eref" source="_">
               <fmt-xref type="inline" target="ISO712">ISO\u00a0712,  Table 1–1</fmt-xref>
            </semx>
         </p>
            </clause>
            <clause id="H" obligation="normative" displayorder="6">
               <title id="_">Terms, definitions, symbols and abbreviated terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">3</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
                     <preferred id="_">
                        <expression>
                           <name>Term2</name>
                        </expression>
                     </preferred>
                     <fmt-preferred>
                        <p>
                           <semx element="preferred" source="_">
                              <strong>Term2</strong>
                           </semx>
                        </p>
                     </fmt-preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Symbols</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Symbols</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="7">
               <title id="_">Symbols</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symbols</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">4</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
            <note id="M-n1" autonum="">
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
               <fmt-xref-label container="N">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </fmt-xref-label>
            </note>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" obligation="informative" normative="true" displayorder="5">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref-label>
                        <bibitem id="ISO712" type="standard">
            <biblio-tag>ISO\u00a0712, </biblio-tag>
            <formattedref>
               <em>Cereals and cereal products</em>
               .
            </formattedref>
            <title format="text/plain">Cereals and cereal products</title>
            <docidentifier>ISO\u00a0712</docidentifier>
            <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
            <contributor>
               <role type="publisher"/>
               <organization>
                  <abbreviation>ISO</abbreviation>
               </organization>
            </contributor>
         </bibitem>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(normative)</span>
               <span class="fmt-caption-delim">
                  <br/>
                  <br/>
               </span>
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
            <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
               <title id="_">Annex A.1</title>
               <fmt-title id="_" depth="2">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Annex A.1</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref-label>
               <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                  <title id="_">Annex A.1a</title>
                  <fmt-title id="_" depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="P">A</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex A.1a</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q1">1</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="10">
               <title id="_">Bibliography</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <references id="T" obligation="informative" normative="false">
                  <title id="_">Bibliography Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Bibliography Subsection</semx>
                  </fmt-title>
               </references>
            </clause>
         </bibliography>
      </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
              #{HTML_HDR}
                     <br/>
                     <div id="_">
                       <h1 class="ForewordTitle">Foreword</h1>
                       <p id='A'>
        See
        <a href='#M'>Clause 5</a>
      </p>
            <p id="A">
               See
               <a href="#tab">Table 1</a>
            </p>
            <p class="TableTitle" style="text-align:center;">Table 1</p>
            <table id="tab" class="MsoISOTable" style="border-width:1px;border-spacing:0;"/>
                     </div>
                     <br/>
                     <div class="Section3" id="B">
                       <h1 class="IntroTitle">Introduction</h1>
                       <div id="C">
                <h2>Introduction Subsection</h2>
              </div>
                     </div>
                     <div id="D">
                       <h1>1.\u00a0 Scope</h1>
                                   <p id="E">
               <a href="#ISO712">ISO\u00a0712,  Table 1–1</a>
            </p>
                     </div>
                     <div>
                       <h1>2.\u00a0 Normative References</h1>
                                  <p id="ISO712" class="NormRef">
              ISO\u00a0712,
              <i>Cereals and cereal products</i>
              .
           </p>
                     </div>
                     <div id="H"><h1>3.\u00a0 Terms, definitions, symbols and abbreviated terms</h1>
             <div id="I">
                <h2>3.1.\u00a0 Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div><div id="K"><h2>3.2.\u00a0 Symbols</h2>
               <div class="figdl">
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
                </div>
              </div></div>
                     <div id="L" class="Symbols">
                       <h1>4.\u00a0 Symbols</h1>
                        <div class="figdl">
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                       </div>
                     </div>
                     <div id="M">
                       <h1>5.\u00a0 Clause 4</h1>
                       <div id="N">
                <h2>5.1.\u00a0 Introduction</h2>
                               <div id="M-n1" class="Note">
                  <p>
                     <span class="note_label">NOTE\u00a0 </span>
                  </p>
               </div>
              </div>
                       <div id="O">
                <h2>5.2.\u00a0 Clause 4.2</h2>
              </div>
                     </div>
                     <br/>
                     <div id="P" class="Section3">
                       <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                       <div id="Q">
                <h2>A.1.\u00a0 Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1.\u00a0 Annex A.1a</h3>
                </div>
              </div>
                     </div>
                     <br/>
                     <div>
                       <h1 class="Section3">Bibliography</h1>
                       <div>
                         <h2 class="Section3">Bibliography Subsection</h2>
                       </div>
                     </div>
                   </div>
                 </body>
             </html>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input.sub("LANGUAGE", "en").sub("SCRIPT", "Latn"), true)
    pres_output_to_compare = strip_guid(
      pres_output.sub(%r{<localized-strings>.*</localized-strings>}m, ""),
    )
    expect(pres_output_to_compare).to be_xml_equivalent_to(presxml)

    html_output = IsoDoc::HtmlConvert.new({}).convert("test", pres_output, true)
    html_output_to_compare = strip_guid(html_output)
    expect(html_output_to_compare).to be_html5_equivalent_to html
  end

  it "defaults to English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>tlh</language>
                  <status>
            <stage>published</stage>
            <substage>withdrawn</substage>
            </status>
            <edition>2</edition>
            <ext>
            <doctype>brochure</doctype>
            </ext>
      </bibdata>
      <preface>
      <foreword obligation="informative" id="A">
         <title>Foreword</title>
         <p>See <xref target="A"/></p>
       </foreword>
       </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">tlh</language>
             <status>
                <stage>published</stage>
                <substage>withdrawn</substage>
             </status>
             <edition language="">2</edition>
             <edition language="tlh">second edition</edition>
             <ext>
                <doctype>brochure</doctype>
             </ext>
          </bibdata>
                    <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword obligation="informative" id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   See
            <xref target="A" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="A">
                  <semx element="foreword" source="A">Foreword</semx>
               </fmt-xref>
            </semx>
                </p>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)

    pres_output_to_compare = strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))

    expect(pres_output_to_compare).to be_xml_equivalent_to output
  end

  it "processes French" do
    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">fr</language>
            <script current="true">Latn</script>
            <status>
               <stage>published</stage>
               <substage>withdrawn</substage>
            </status>
            <edition language="">2</edition>
            <edition language="fr">deuxième édition</edition>
            <ext>
               <doctype>brochure</doctype>
            </ext>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Sommaire</fmt-title>
            </clause>
            <foreword obligation="informative" displayorder="2" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="A">
                  See
          <xref target="M" id="_"/>
          <semx element="xref" source="_">
             <fmt-xref target="M">
                <span class="fmt-element-name">Article</span>
                <semx element="autonum" source="M">5</semx>
             </fmt-xref>
          </semx>
               </p>
            <p id="A">
            See
            <xref target="tab" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="tab">
                  <span class="fmt-element-name">Tableau</span>
                  <semx element="autonum" source="tab">1</semx>
               </fmt-xref>
            </semx>
         </p>
         <table id="tab" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Tableau</span>
                  <semx element="autonum" source="tab">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Tableau</span>
               <semx element="autonum" source="tab">1</semx>
            </fmt-xref-label>
         </table>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <clause id="C" inline-header="false" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Article</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref-label>
                        <p id="E">
            <eref type="inline" bibitemid="ISO712" id="_">
               <locality type="table">
                  <referenceFrom>1</referenceFrom>
                  <referenceTo>1</referenceTo>
               </locality>
            </eref>
            <semx element="eref" source="_">
               <fmt-xref type="inline" target="ISO712">ISO\u00a0712,  Tableau 1–1</fmt-xref>
            </semx>
         </p>
            </clause>
            <clause id="H" obligation="normative" displayorder="6">
               <title id="_">Terms, definitions, symbols and abbreviated terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Article</span>
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Article</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">3</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Article</span>
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
                     <preferred id="_">
                        <expression>
                           <name>Term2</name>
                        </expression>
                     </preferred>
                     <fmt-preferred>
                        <p>
                           <semx element="preferred" source="_">
                              <strong>Term2</strong>
                           </semx>
                        </p>
                     </fmt-preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Symboles</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Symboles</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Article</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="7">
               <title id="_">Symboles</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symboles</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Article</span>
                  <semx element="autonum" source="L">4</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Article</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Article</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
            <note id="M-n1" autonum="">
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
               <fmt-xref-label container="N">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Article</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </fmt-xref-label>
            </note>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Article</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" obligation="informative" normative="true" displayorder="5">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Article</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref-label>
                        <bibitem id="ISO712" type="standard">
            <biblio-tag>ISO\u00a0712, </biblio-tag>
            <formattedref>
               <em>Cereals and cereal products</em>
               .
            </formattedref>
            <title format="text/plain">Cereals and cereal products</title>
            <docidentifier>ISO\u00a0712</docidentifier>
            <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
            <contributor>
               <role type="publisher"/>
               <organization>
                  <abbreviation>ISO</abbreviation>
               </organization>
            </contributor>
         </bibitem>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annexe</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(normative)</span>
               <span class="fmt-caption-delim">
                  <br/>
                  <br/>
               </span>
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annexe</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
            <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
               <title id="_">Annex A.1</title>
               <fmt-title id="_" depth="2">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Annex A.1</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Annexe</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref-label>
               <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                  <title id="_">Annex A.1a</title>
                  <fmt-title id="_" depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="P">A</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex A.1a</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Annexe</span>
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q1">1</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="10">
               <title id="_">Bibliography</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <references id="T" obligation="informative" normative="false">
                  <title id="_">Bibliography Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Bibliography Subsection</semx>
                  </fmt-title>
               </references>
            </clause>
         </bibliography>
      </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
                  #{HTML_HDR.gsub(' lang="en">', ' lang="fr">').sub('Table of contents', 'Sommaire')}
                     <br/>
                     <div id="_">
                       <h1 class="ForewordTitle">Foreword</h1>
                       <p id='A'>
        See
        <a href='#M'>Article 5</a>
      </p>
                  <p id="A">
               See
               <a href="#tab">Tableau 1</a>
            </p>
            <p class="TableTitle" style="text-align:center;">Tableau 1</p>
            <table id="tab" class="MsoISOTable" style="border-width:1px;border-spacing:0;"/>
                     </div>
                     <br/>
                     <div class="Section3" id="B">
                       <h1 class="IntroTitle">Introduction</h1>
                       <div id="C">
                <h2>Introduction Subsection</h2>
              </div>
                     </div>
                     <div id="D">
                       <h1>1.\u00a0 Scope</h1>
                                   <p id="E">
               <a href="#ISO712">ISO\u00a0712,  Tableau 1–1</a>
            </p>
                     </div>
                     <div>
                       <h1>2.\u00a0 Normative References</h1>
            <p id="ISO712" class="NormRef">
               ISO\u00a0712,
               <i>Cereals and cereal products</i>
               .
            </p>
                     </div>
                     <div id="H"><h1>3.\u00a0 Terms, definitions, symbols and abbreviated terms</h1>
             <div id="I">
                <h2>3.1.\u00a0 Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div><div id="K"><h2>3.2.\u00a0 Symboles</h2>
               <div class="figdl">
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
                </div>
              </div></div>
                     <div id="L" class="Symbols">
                       <h1>4.\u00a0 Symboles</h1>
                        <div class="figdl">
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                       </div>
                     </div>
                     <div id="M">
                       <h1>5.\u00a0 Clause 4</h1>
                       <div id="N">
                <h2>5.1.\u00a0 Introduction</h2>
                               <div id="M-n1" class="Note">
                  <p>
                     <span class="note_label">NOTE\u00a0 </span>
                  </p>
               </div>
              </div>
                       <div id="O">
                <h2>5.2.\u00a0 Clause 4.2</h2>
              </div>
                     </div>
                     <br/>
                     <div id="P" class="Section3">
                       <h1 class="Annex"><b>Annexe A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                       <div id="Q">
                <h2>A.1.\u00a0 Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1.\u00a0 Annex A.1a</h3>
                </div>
              </div>
                     </div>
                     <br/>
                     <div>
                       <h1 class="Section3">Bibliography</h1>
                       <div>
                         <h2 class="Section3">Bibliography Subsection</h2>
                       </div>
                     </div>
                   </div>
                 </body>
             </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input.sub("LANGUAGE", "fr").sub("SCRIPT", "Latn"), true)

    pres_output_to_compare = strip_guid(
      pres_output.sub(%r{<localized-strings>.*</localized-strings>}m, ""),
    )

    expect(pres_output_to_compare).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({}).convert("test", pres_output, true)
    html_output_to_compare = strip_guid(html_output)
    expect(html_output_to_compare).to be_html5_equivalent_to html
  end

  it "processes Simplified Chinese" do
    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">zh</language>
             <script current="true">Hans</script>
             <status>
                <stage>published</stage>
                <substage>withdrawn</substage>
             </status>
             <edition language="">2</edition>
             <edition language="zh">第第二版</edition>
             <ext>
                <doctype>brochure</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">目\u3000次</fmt-title>
             </clause>
             <foreword obligation="informative" id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">
                   See
                   <xref target="M" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="M">
                         <span class="fmt-element-name">条</span>
                         <semx element="autonum" source="M">5</semx>
                      </fmt-xref>
                   </semx>
                </p>
             <p id="A">
            See
            <xref target="tab" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="tab">
                  <span class="fmt-element-name">表</span>
                  <semx element="autonum" source="tab">1</semx>
               </fmt-xref>
            </semx>
         </p>
         <table id="tab" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">表</span>
                  <semx element="autonum" source="tab">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">表</span>
               <semx element="autonum" source="tab">1</semx>
            </fmt-xref-label>
         </table>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">
                   <eref type="inline" bibitemid="ISO712" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                         <referenceTo>1</referenceTo>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                   <fmt-xref type="inline" target="ISO712">ISO\u00a0712，  表1〜1</fmt-xref>
                   </semx>
                </p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="H">3</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">条</span>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">条</span>
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>Term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>Term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">符号</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">符号</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">条</span>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="7">
                <title id="_">符号</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">符号</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="L">4</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">条</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
           <note id="M-n1" autonum="">
              <fmt-name id="_">
                 <span class="fmt-caption-label">
                    <span class="fmt-element-name">注</span>
                 </span>
                 <span class="fmt-label-delim">
                    <tab/>
                 </span>
              </fmt-name>
              <fmt-xref-label>
                 <span class="fmt-element-name">注</span>
              </fmt-xref-label>
              <fmt-xref-label container="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">条</span>
                    <semx element="autonum" source="M">5</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="N">1</semx>
                 </span>
                 <span class="fmt-comma">，</span>
                 <span class="fmt-element-name">注</span>
              </fmt-xref-label>
           </note>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">条</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <biblio-tag>ISO\u00a0712， </biblio-tag>
                   <formattedref>
                      <em>Cereals and cereal products</em>
                      。
                   </formattedref>
                   <title format="text/plain">Cereals and cereal products</title>
                   <docidentifier>ISO\u00a0712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                </bibitem>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">附件</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">（规范性附录）</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">附件</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">附件</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">附件</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
      #{HTML_HDR.gsub(' lang="en">', ' lang="zh">').gsub('Table of contents', "目\u3000次")}
             <br/>
             <div id="_">
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">See <a href="#M">条5</a></p>
            <p id="A">
               See
               <a href="#tab">表1</a>
            </p>
            <p class="TableTitle" style="text-align:center;">表1</p>
            <table id="tab" class="MsoISOTable" style="border-width:1px;border-spacing:0;"/>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>

              </div>
             </div>
             <div id="D">
               <h1>1.\u3000Scope</h1>
               <p id="E">
               <a href="#ISO712">ISO\u00a0712，  表1〜1</a>
               </p>
             </div>
             <div><h1>2.\u3000Normative References</h1>

             <p id="ISO712" class="NormRef">ISO\u00a0712， <i>Cereals and cereal products</i>。</p>
              </div>
             <div id="H">
               <h1>3.\u3000Terms, definitions, symbols and abbreviated terms</h1>
               <div id="I"><h2>3.1.\u3000Normal Terms</h2>

                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>

              </div>
               <div id="K"><h2>3.2.\u3000符号</h2>
                <div class="figdl">
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
                </div>
              </div>
             </div>
             <div id="L" class="Symbols">
               <h1>4.\u3000符号</h1>
                <div class="figdl">
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
               </div>
             </div>
             <div id="M">
               <h1>5.\\u3000Clause 4</h1>
               <div id="N"><h2>5.1.\\u3000Introduction</h2>
               <div id="M-n1" class="Note">
                  <p>
                     <span class="note_label">注\\u3000</span>
                  </p>
               </div>
              </div>
               <div id="O"><h2>5.2.\u3000Clause 4.2</h2>

              </div>
             </div>
             <br/>
                             <div id="P" class="Section3">
                   <h1 class="Annex">
                      <b>附件A</b>
                      <br/>
                      （规范性附录）
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>A.1.\u3000Annex A.1</h2>
                      <div id="Q1">
                         <h3>A.1.1.\u3000Annex A.1a</h3>
                      </div>
                   </div>
                </div>
                <br/>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <div>
                      <h2 class="Section3">Bibliography Subsection</h2>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input.sub("LANGUAGE", "zh").sub("SCRIPT", "Hans"), true)
    pres_output_to_compare = strip_guid(
      pres_output.sub(%r{<localized-strings>.*</localized-strings>}m, ""),
    )
    expect(pres_output_to_compare).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({}).convert("test", pres_output, true)
    html_output_to_compare = strip_guid(html_output)
    expect(html_output_to_compare)
      .to be_html5_equivalent_to fix_whitespaces(html_output)
  end

  it "processes i18n file" do
    mock_i18n
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">eo</language>
             <script current="true">Latn</script>
             <status>
                <stage language="">published</stage>
                <stage language="eo">publikigita</stage>
                <substage language="">withdrawn</substage>
                <substage language="eo">fortirita</substage>
             </status>
             <edition language="">2</edition>
             <edition language="eo">eldono dua</edition>
             <ext>
                <doctype language="">brochure</doctype>
                <doctype language="eo">broŝuro</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1"/>
             </clause>
             <foreword obligation="informative" id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">
                   See
                   <xref target="M" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="M">
                         <span class="fmt-element-name">klaŭzo</span>
                         <semx element="autonum" source="M">5</semx>
                      </fmt-xref>
                   </semx>
                </p>
                <p id="A">
                   See
                   <xref target="tab" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="tab">
                         <span class="fmt-element-name">tabelo</span>
                         <semx element="autonum" source="tab">1</semx>
                      </fmt-xref>
                   </semx>
                </p>
                <table id="tab" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Tabelo</span>
                         <semx element="autonum" source="tab">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">tabelo</span>
                      <semx element="autonum" source="tab">1</semx>
                   </fmt-xref-label>
                </table>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">
                   <eref type="inline" bibitemid="ISO712" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                         <referenceTo>1</referenceTo>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">ISO\u00a0712, Tabelo 1–1</fmt-xref>
                   </semx>
                </p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="H">3</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">klaŭzo</span>
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>Term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>Term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Simboloj kai mallongigitaj terminoj</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Simboloj kai mallongigitaj terminoj</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="7">
                <title id="_">Simboloj kai mallongigitaj terminoj</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Simboloj kai mallongigitaj terminoj</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="L">4</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                   <note id="M-n1" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTO</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">noto</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="N">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">klaŭzo</span>
                            <semx element="autonum" source="M">5</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="N">1</semx>
                         </span>
                         <span class="fmt-comma">—</span>
                         <span class="fmt-element-name">noto</span>
                      </fmt-xref-label>
                   </note>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">klaŭzo</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">klaŭzo</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals and cereal products</title>
                   <docidentifier>ISO\u00a0712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO\u00a0712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <biblio-tag>ISO\u00a0712, </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">
                         <strong>Aldono</strong>
                      </span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">
                   <strong>aldono</strong>
                </span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">
                      <strong>aldono</strong>
                   </span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title id="_" depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">
                         <strong>aldono</strong>
                      </span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
              <html lang='eo'>
               <head/>
               <body lang='eo'>
                 <div class='title-section'>
                   <p>\u00a0</p>
                 </div>
                 <br/>
                 <div class='prefatory-section'>
                   <p>\u00a0</p>
                 </div>
                 <br/>
                 <div class='main-section'>
                   <br/>
                         <div id="_" class="TOC">
        <h1 class="IntroTitle"/>
      </div>
      <br/>
                   <div id="_">
                     <h1 class='ForewordTitle'>Foreword</h1>
                     <p id='A'>
        See
        <a href='#M'>kla&#365;zo 5</a>
      </p>
      <p id='A'>
        See
        <a href='#tab'>tabelo 1</a>
      </p>
      <p class='TableTitle' style='text-align:center;'>Tabelo 1</p>
      <table id='tab' class='MsoISOTable' style='border-width:1px;border-spacing:0;'/>
                   </div>
                   <br/>
                   <div class='Section3' id='B'>
                     <h1 class='IntroTitle'>Introduction</h1>
                     <div id='C'>
                       <h2>Introduction Subsection</h2>
                     </div>
                   </div>
                   <div id='D'>
                     <h1>1.\u00a0 Scope</h1>
                     <p id='E'>
                       <a href='#ISO712'>ISO\u00a0712, Tabelo 1&#8211;1</a>
                     </p>
                   </div>
                   <div>
                     <h1>2.\u00a0 Normative References</h1>
                     <p id='ISO712' class='NormRef'>
                       ISO\u00a0712,
                       <i>Cereals and cereal products</i>.
                     </p>
                   </div>
                   <div id='H'>
                     <h1>3.\u00a0 Terms, definitions, symbols and abbreviated terms</h1>
                     <div id='I'>
                       <h2>3.1.\u00a0 Normal Terms</h2>
                       <p class='TermNum' id='J'>3.1.1.</p>
                       <p class='Terms' style='text-align:left;'><b>Term2</b></p>
                     </div>
                     <div id='K'>
                       <h2>3.2.\u00a0 Simboloj kai mallongigitaj terminoj</h2>
                        <div class="figdl">
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                       </div>
                     </div>
                   </div>
                   <div id='L' class='Symbols'>
                     <h1>4.\u00a0 Simboloj kai mallongigitaj terminoj</h1>
                      <div class="figdl">
                     <dl>
                       <dt>
                         <p>Symbol</p>
                       </dt>
                       <dd>Definition</dd>
                     </dl>
                     </div>
                   </div>
                   <div id='M'>
                     <h1>5.\u00a0 Clause 4</h1>
                     <div id='N'>
                       <h2>5.1.\u00a0 Introduction</h2>
                       <div id='M-n1' class='Note'>
        <p>
          <span class="note_label">NOTO\u00a0 </span>
        </p>
      </div>
                     </div>
                     <div id='O'>
                       <h2>5.2.\u00a0 Clause 4.2</h2>
                     </div>
                   </div>
                   <br/>
                   <div id='P' class='Section3'>
                     <h1 class='Annex'>
                       <b><b>Aldono</b> A</b>
                       <br/>
                       (normative)
                       <br/>
                       <br/>
                       <b>Annex</b>
                     </h1>
                     <div id='Q'>
                       <h2>A.1.\u00a0 Annex A.1</h2>
                       <div id='Q1'>
                         <h3>A.1.1.\u00a0 Annex A.1a</h3>
                       </div>
                     </div>
                   </div>
                   <br/>
                   <div>
                     <h1 class='Section3'>Bibliography</h1>
                     <div>
                       <h2 class='Section3'>Bibliography Subsection</h2>
                     </div>
                   </div>
                 </div>
               </body>
             </html>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options.merge({ i18nyaml: "spec/assets/i18n.yaml" }))
      .convert("test", input.sub("LANGUAGE", "eo").sub("SCRIPT", "Latn"), true)

    pres_output_to_compare = strip_guid(
      pres_output.sub(%r{<localized-strings>.*</localized-strings>}m, ""),
    )

    expect(pres_output_to_compare).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({ i18nyaml: "spec/assets/i18n.yaml" }).convert(
      "test", pres_output, true
    )
    html_output_to_compare = strip_guid(html_output)
    expect(html_output_to_compare).to be_html5_equivalent_to html
  end

  it "internationalises doctype" do
    mock_i18n
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>eo</language>
      <script>Latn</script>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">eo</language>
            <script current="true">Latn</script>
            <ext>
               <doctype language="">brochure</doctype>
               <doctype language="eo">broŝuro</doctype>
            </ext>
         </bibdata>
      </iso-standard>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options
        .merge({ i18nyaml: "spec/assets/i18n.yaml" }))
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml

    ext = <<~EXT
         <metanorma-extension>
      <presentation-metadata>
      <doctype-alias>conference proceedings</doctype-alias>
      </presentation-metadata>
      </metanorma-extension>
    EXT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">eo</language>
            <script current="true">Latn</script>
            <ext>
               <doctype language="">brochure</doctype>
               <doctype language="eo">konferencaktoj</doctype>
            </ext>
         </bibdata>
            <metanorma-extension>
             <presentation-metadata>
                <doctype-alias>conference proceedings</doctype-alias>
             </presentation-metadata>
          </metanorma-extension>
      </iso-standard>
    OUTPUT

    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options
        .merge({ i18nyaml: "spec/assets/i18n.yaml" }))
      .convert("test", input.sub("</bibdata>", "</bibdata>#{ext}"), true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "internationalises locality" do
    mock_i18n
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>eo</language>
      <script>Latn</script>
      <status>
      <stage>published</stage>
      <substage>withdrawn</substage>
      </status>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <preface>
      <foreword obligation="informative" id="_">
         <title>Foreword</title>
         <p id="A"><eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref></p>
       </foreword>
       </preface>
       <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
         <eref type="inline" bibitemid="ISO712" id="_">
            <locality type="locality:prelude">
               <referenceFrom>7</referenceFrom>
            </locality>
         </eref>
         <semx element="eref" source="_">
            <fmt-xref type="inline" target="ISO712">ISO\u00a0712, Preludo 7</fmt-xref>
         </semx>
      </p>
    OUTPUT
    xml_fragment = Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:p[@id='A']").to_xml
    expect(strip_guid(xml_fragment))
      .to be_xml_equivalent_to presxml
  end

  it "internationalises non-numeric edition" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>LANGUAGE</language>
      <script>SCRIPT</script>
      <edition>2.1</edition>
      </bibdata>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
            <script current="true">Latn</script>
            <edition language="">2.1</edition>
            <edition language="en">edition 2.1</edition>
         </bibdata>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("LANGUAGE", "en").sub("SCRIPT", "Latn"), true)
    expect(strip_guid(Canon.format_xml(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">zh</language>
            <script current="true">Hans</script>
            <edition language="">2.1</edition>
            <edition language="zh">第2.1版</edition>
         </bibdata>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("LANGUAGE", "zh").sub("SCRIPT", "Hans"), true)
    expect(strip_guid(Canon.format_xml(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes LTR within RTL" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
      <language>fa</language>
      <script>Arab</script>
      </bibdata>
      </iso-standard>
    INPUT
    expect(c.i18n.l10n("hello!", "en", "Latn")).to eq "&#x200e;hello!&#x200e;"
  end

  it "processes Hebrew RTL within LTR" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
      <language>en</language>
      </bibdata>
      </iso-standard>
    INPUT
    expect(c.i18n.l10n("hello!", "he", "Hebr")).to eq "&#x200f;hello!&#x200f;"
  end

  it "processes Arabic RTL within LTR" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
      <language>en</language>
      </bibdata>
      </iso-standard>
    INPUT
    expect(c.i18n.l10n("hello!", "fa", "Arab")).to eq "&#x61c;hello!&#x61c;"
  end

  it "does extended titles in CJK" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata><language>zh</language><script>Hans</script></bibdata>
        <boilerplate>
          <copyright-statement>
          <clause>
            <title>版權</title>
          </clause>
          <clause>
            <title>版權聲明</title>
          </clause>
          <clause language="en">
            <title>版權</title>
          </clause>
          </copyright-statement>
        </boilerplate>
        <preface>
        <floating-title>樣板</floating-title>
        <abstract obligation="informative" language="jp">
           <title>解題</title>
        </abstract>
        <foreword obligation="informative">
           <title>文件序言</title>
           <p id="A">This is a preamble</p>
         </foreword>
        <floating-title>介紹性陳述</floating-title>
          <introduction id="B" obligation="informative">
           <title>簡介</title>
           <clause id="C" inline-header="false" obligation="informative">
           <title>引言部分</title>
           <clause id="C" inline-header="false" obligation="informative">
           <title>附則</title>
         </clause>
         </introduction>
         <clause id="D"><title language="en">Ad</title></clause>
         </preface>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">zh</language>
             <script current="true">Hans</script>
          </bibdata>
          <boilerplate>
             <copyright-statement>
                <clause id="_">
                   <title id="_">版權</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">版\u3000權</semx>
                   </fmt-title>
                </clause>
                <clause id="_">
                   <title id="_">版權聲明</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">版權聲明</semx>
                   </fmt-title>
                </clause>
                <clause language="en" id="_">
                   <title id="_">版權</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">版\u3000權</semx>
                   </fmt-title>
                </clause>
             </copyright-statement>
          </boilerplate>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">目\u3000次</fmt-title>
             </clause>
             <floating-title original-id="_">樣\u3000板</floating-title>
             <p id="_" type="floating-title" displayorder="2">
                <semx element="floating-title" source="_">樣\u3000板</semx>
             </p>
             <abstract obligation="informative" language="jp" displayorder="3" id="_">
                <title id="_">解題</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">解\u3000題</semx>
                </fmt-title>
             </abstract>
             <foreword obligation="informative" displayorder="4" id="_">
                <title id="_">文件序言</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">文件序言</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <floating-title original-id="_">介紹性陳述</floating-title>
             <p id="_" type="floating-title" displayorder="5">
                <semx element="floating-title" source="_">介紹性陳述</semx>
             </p>
             <introduction id="B" obligation="informative" displayorder="6">
                <title id="_">簡介</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">簡\u3000介</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">引言部分</title>
                   <fmt-title id="_" depth="3">
                      <semx element="title" source="_">引言部分</semx>
                   </fmt-title>
                   <clause id="C" inline-header="false" obligation="informative">
                      <title id="_">附則</title>
                      <fmt-title id="_" depth="3">
                         <semx element="title" source="_">附則</semx>
                      </fmt-title>
                   </clause>
                </clause>
                <clause id="D">
                   <title language="en" id="_">Ad</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Ad</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
       </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "inserts localized-strings" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
      <language>ja</language>
      </bibdata>
      </iso-standard>
    INPUT
    xml = Nokogiri(IsoDoc::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true))
    expect(xml.at("//xmlns:localized-string[@language = 'ja']")).not_to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'en']")).to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'fr']")).to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'ja'][@key = 'scope']").text).to eq "適用範囲"

       input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
        <title language="en">Title</title>
      <language>ja</language>
      </bibdata>
      </iso-standard>
    INPUT
    xml = Nokogiri(IsoDoc::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true))
    expect(xml.at("//xmlns:localized-string[@language = 'ja']")).not_to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'en']")).not_to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'fr']")).to be nil
    expect(xml.at("//xmlns:localized-string[@language = 'ja'][@key = 'scope']").text).to eq "適用範囲"
    expect(xml.at("//xmlns:localized-string[@language = 'en'][@key = 'scope']").text).to eq "Scope"
  end

  private

  def mock_i18n
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with("eo", "Latn", nil, anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with("eo", "Latn", "spec/assets/i18n.yaml", anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
  end
end
