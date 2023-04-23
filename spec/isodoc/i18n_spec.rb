require "spec_helper"

RSpec.describe IsoDoc do
=begin
  it "processes English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
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
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
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
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT

    presxml = <<~PRESXML
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
        <language current="true">en</language>
            <status>
        <stage>published</stage>
        <substage>withdrawn</substage>
      </status>
      <edition language=''>2</edition>
      <edition language='en'>second edition</edition>
      <ext>
        <doctype>brochure</doctype>
      </ext>
        </bibdata>
        <preface>
            <clause type="toc" displayorder="1">
      <title depth="1">Table of contents</title>
    </clause>
        <foreword obligation="informative" displayorder="2">
           <title>Foreword</title>
           <p id="A">See <xref target="M">Clause 5</xref></p>
         </foreword>
          <introduction id="B" obligation="informative" displayorder="3"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
           <title depth="2">Introduction Subsection</title>
         </clause>
         </introduction></preface><sections>
         <clause id="D" obligation="normative" type="scope" displayorder="4">
           <title depth="1">1.<tab/>Scope</title>
           <p id="E">Text</p>
         </clause>
         <clause id="H" obligation="normative" displayorder="6"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
           <title depth="2">3.1.<tab/>Normal Terms</title>
           <term id="J"><name>3.1.1.</name>
           <preferred><strong>Term2</strong></preferred>
         </term>
         </terms>
         <definitions id="K"><title>3.2.</title>
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         </clause>
         <definitions id="L" displayorder="7"><title>4.</title>
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         <clause id="M" inline-header="false" obligation="normative" displayorder="8"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
           <title depth="2">5.1.<tab/>Introduction</title>
         </clause>
         <clause id="O" inline-header="false" obligation="normative">
           <title depth="2">5.2.<tab/>Clause 4.2</title>
         </clause></clause>
         </sections><annex id="P" inline-header="false" obligation="normative" displayorder="9">
           <title><strong>Annex A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
           <clause id="Q" inline-header="false" obligation="normative">
           <title depth="2">A.1.<tab/>Annex A.1</title>
           <clause id="Q1" inline-header="false" obligation="normative">
           <title depth="3">A.1.1.<tab/>Annex A.1a</title>
           </clause>
         </clause>
         </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="5">
           <title depth="1">2.<tab/>Normative References</title>
         </references><clause id="S" obligation="informative" displayorder="10">
           <title depth="1">Bibliography</title>
           <references id="T" obligation="informative" normative="false">
           <title depth="2">Bibliography Subsection</title>
         </references>
         </clause>
         </bibliography>
         </iso-standard>
    PRESXML

    output = <<~"OUTPUT"
              #{HTML_HDR}
                     <br/>
                     <div>
                       <h1 class="ForewordTitle">Foreword</h1>
                       <p id='A'>
        See
        <a href='#M'>Clause 5</a>
      </p>
                     </div>
                     <br/>
                     <div class="Section3" id="B">
                       <h1 class="IntroTitle">Introduction</h1>
                       <div id="C">
                <h2>Introduction Subsection</h2>
              </div>
                     </div>
                     <p class="zzSTDTitle1"/>
                     <div id="D">
                       <h1>1.&#160; Scope</h1>
                       <p id="E">Text</p>
                     </div>
                     <div>
                       <h1>2.&#160; Normative References</h1>
                     </div>
                     <div id="H"><h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1>
             <div id="I">
                <h2>3.1.&#160; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div><div id="K"><h2>3.2.</h2>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div></div>
                     <div id="L" class="Symbols">
                       <h1>4.</h1>
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                     </div>
                     <div id="M">
                       <h1>5.&#160; Clause 4</h1>
                       <div id="N">
                <h2>5.1.&#160; Introduction</h2>
              </div>
                       <div id="O">
                <h2>5.2.&#160; Clause 4.2</h2>
              </div>
                     </div>
                     <br/>
                     <div id="P" class="Section3">
                       <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                       <div id="Q">
                <h2>A.1.&#160; Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1.&#160; Annex A.1a</h3>
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
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
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">See <xref target="M"/></p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
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
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
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
      <edition language=''>2</edition>
      <edition language='tlh'>second edition</edition>
      <ext>
        <doctype>brochure</doctype>
      </ext>
         </bibdata>
         <preface>
             <clause type="toc" displayorder="1"> <title depth="1">Table of contents</title> </clause>
         <foreword obligation="informative" displayorder="2">
            <title>Foreword</title>
            <p id="A">See <xref target="M">Clause 5</xref></p>
          </foreword>
           <introduction id="B" obligation="informative" displayorder="3"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
            <title depth="2">Introduction Subsection</title>
          </clause>
          </introduction></preface><sections>
          <clause id="D" obligation="normative" type="scope" displayorder="4">
            <title depth="1">1.<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder="6"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
            <title depth="2">3.1.<tab/>Normal Terms</title>
            <term id="J"><name>3.1.1.</name>
            <preferred><strong>Term2</strong></preferred>
          </term>
          </terms>
          <definitions id="K"><title>3.2.</title>
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          </clause>
          <definitions id="L" displayorder="7"><title>4.</title>
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder="8"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
            <title depth="2">5.1.<tab/>Introduction</title>
          </clause>
          <clause id="O" inline-header="false" obligation="normative">
            <title depth="2">5.2.<tab/>Clause 4.2</title>
          </clause></clause>
          </sections><annex id="P" inline-header="false" obligation="normative" displayorder="9">
            <title><strong>Annex A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
            <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1.<tab/>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
            <title depth="3">A.1.1.<tab/>Annex A.1a</title>
            </clause>
          </clause>
          </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="5">
            <title depth="1">2.<tab/>Normative References</title>
          </references><clause id="S" obligation="informative" displayorder="10">
            <title depth="1">Bibliography</title>
            <references id="T" obligation="informative" normative="false">
            <title depth="2">Bibliography Subsection</title>
          </references>
          </clause>
          </bibliography>
          </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes French" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
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
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
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
       </references><clause id="S" obligation="informative">
         <title>Bibliographie</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT

    presxml = <<~PRESXML
           <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata>
           <language current="true">fr</language>
               <status>
           <stage>published</stage>
           <substage>withdrawn</substage>
         </status>
         <edition language=''>2</edition>
         <edition language='fr'>deuxi&#xE8;me &#xE9;dition</edition>
         <ext>
           <doctype>brochure</doctype>
         </ext>
           </bibdata>
           <preface>
              <clause type="toc" displayorder="1">
        <title depth="1">Sommaire</title>
      </clause>
           <foreword obligation="informative" displayorder="2">
              <title>Foreword</title>
              <p id="A">See <xref target="M">Article 5</xref></p>
            </foreword>
             <introduction id="B" obligation="informative" displayorder="3"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
              <title depth="2">Introduction Subsection</title>
            </clause>
            </introduction></preface><sections>
            <clause id="D" obligation="normative" type="scope" displayorder="4">
              <title depth="1">1.<tab/>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="6"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
              <title depth="2">3.1.<tab/>Normal Terms</title>
              <term id="J"><name>3.1.1.</name>
              <preferred><strong>Term2</strong></preferred>
            </term>
            </terms>
            <definitions id="K"><title>3.2.</title>
              <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
              </dl>
            </definitions>
            </clause>
            <definitions id="L" displayorder="7"><title>4.</title>
              <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
              <title depth="2">5.1.<tab/>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">5.2.<tab/>Clause 4.2</title>
            </clause></clause>
            </sections><annex id="P" inline-header="false" obligation="normative" displayorder="9">
              <title><strong>Annexe A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
              <clause id="Q" inline-header="false" obligation="normative">
              <title depth="2">A.1.<tab/>Annex A.1</title>
              <clause id="Q1" inline-header="false" obligation="normative">
              <title depth="3">A.1.1.<tab/>Annex A.1a</title>
              </clause>
            </clause>
            </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="5">
              <title depth="1">2.<tab/>Normative References</title>
            </references><clause id="S" obligation="informative" displayorder="10">
              <title depth="1">Bibliographie</title>
              <references id="T" obligation="informative" normative="false">
              <title depth="2">Bibliography Subsection</title>
            </references>
            </clause>
            </bibliography>
            </iso-standard>
    PRESXML

    output = <<~"OUTPUT"
                  #{HTML_HDR.gsub(/ lang="en">/, ' lang="fr">').sub(/Table of contents/, 'Sommaire')}
                     <br/>
                     <div>
                       <h1 class="ForewordTitle">Foreword</h1>
                       <p id='A'>
        See
        <a href='#M'>Article 5</a>
      </p>
                     </div>
                     <br/>
                     <div class="Section3" id="B">
                       <h1 class="IntroTitle">Introduction</h1>
                       <div id="C">
                <h2>Introduction Subsection</h2>
              </div>
                     </div>
                     <p class="zzSTDTitle1"/>
                     <div id="D">
                       <h1>1.&#160; Scope</h1>
                       <p id="E">Text</p>
                     </div>
                     <div>
                       <h1>2.&#160; Normative References</h1>
                     </div>
                     <div id="H"><h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1>
             <div id="I">
                <h2>3.1.&#160; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div><div id="K"><h2>3.2.</h2>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div></div>
                     <div id="L" class="Symbols">
                       <h1>4.</h1>
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                     </div>
                     <div id="M">
                       <h1>5.&#160; Clause 4</h1>
                       <div id="N">
                <h2>5.1.&#160; Introduction</h2>
              </div>
                       <div id="O">
                <h2>5.2.&#160; Clause 4.2</h2>
              </div>
                     </div>
                     <br/>
                     <div id="P" class="Section3">
                       <h1 class="Annex"><b>Annexe A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                       <div id="Q">
                <h2>A.1.&#160; Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1.&#160; Annex A.1a</h3>
                </div>
              </div>
                     </div>
                     <br/>
                     <div>
                       <h1 class="Section3">Bibliographie</h1>
                       <div>
                         <h2 class="Section3">Bibliography Subsection</h2>
                       </div>
                     </div>
                   </div>
                 </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes Simplified Chinese" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata>
            <language>zh</language>
            <script>Hans</script>
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

    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
            <bibdata>
            <language current="true">zh</language>
            <script current="true">Hans</script>
                <status>
              <stage>published</stage>
              <substage>withdrawn</substage>
            </status>
            <edition language=''>2</edition><edition language='zh'>&#x7B2C;&#x7B2C;&#x4E8C;&#x7248;</edition>
            <ext>
              <doctype>brochure</doctype>
            </ext>
            </bibdata>
            <preface>
                <clause type="toc" displayorder="1">
              <title depth="1">目　次</title>
            </clause>
            <foreword obligation="informative" displayorder="2">
               <title>Foreword</title>
               <p id="A">See <xref target="M">&#x6761;5</xref></p>
             </foreword>
              <introduction id="B" obligation="informative" displayorder="3"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
               <title depth="2">Introduction Subsection</title>
             </clause>
             </introduction></preface><sections>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title depth="1">1.<tab/>Scope</title>
               <p id="E"><eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO&#xa0;712，第1～1表</eref></p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
               <title depth="2">3.1.<tab/>Normal Terms</title>
               <term id="J"><name>3.1.1.</name>
               <preferred><strong>Term2</strong></preferred>
             </term>
             </terms>
             <definitions id="K"><title>3.2.</title>
               <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
               </dl>
             </definitions>
             </clause>
             <definitions id="L" displayorder="7"><title>4.</title>
               <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
               </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title depth="2">5.1.<tab/>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">5.2.<tab/>Clause 4.2</title>
             </clause></clause>
             </sections><annex id="P" inline-header="false" obligation="normative" displayorder="9">
               <title><strong>&#x9644;&#x4EF6;A</strong><br/>&#xFF08;&#x89C4;&#x8303;&#x6027;&#x9644;&#x5F55;&#xFF09;<br/><br/><strong>Annex</strong></title>
               <clause id="Q" inline-header="false" obligation="normative">
               <title depth="2">A.1.<tab/>Annex A.1</title>
               <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1.<tab/>Annex A.1a</title>
               </clause>
             </clause>
             </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="5">
               <title depth="1">2.<tab/>Normative References</title>
               <bibitem id="ISO712" type="standard">
                  <formattedref><em>Cereals and cereal products</em>．</formattedref><docidentifier>ISO&#xa0;712</docidentifier>
                  <biblio-tag>ISO&#xa0;712,</biblio-tag>
               </bibitem>
             </references><clause id="S" obligation="informative" displayorder="10">
               <title depth="1">Bibliography</title>
               <references id="T" obligation="informative" normative="false">
               <title depth="2">Bibliography Subsection</title>
             </references>
             </clause>
             </bibliography>
             </iso-standard>
    PRESXML

    output = <<~"OUTPUT"
      #{HTML_HDR.gsub(/ lang="en">/, ' lang="zh">').gsub(/Table of contents/, '目　次')}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">See <a href="#M">条5</a></p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>

              </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="D">
               <h1>1.　Scope</h1>
               <p id="E">
                 <a href="#ISO712">ISO&#xa0;712，第1～1表</a>
               </p>
             </div>
             <div><h1>2.　Normative References</h1>

                <p id="ISO712" class="NormRef">ISO&#xa0;712, <i>Cereals and cereal products</i>．</p>
              </div>
             <div id="H">
               <h1>3.　Terms, definitions, symbols and abbreviated terms</h1>
               <div id="I"><h2>3.1.　Normal Terms</h2>

                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>

              </div>
               <div id="K"><h2>3.2.</h2>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div>
             </div>
             <div id="L" class="Symbols">
               <h1>4.</h1>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
             <div id="M">
               <h1>5.　Clause 4</h1>
               <div id="N"><h2>5.1.　Introduction</h2>

              </div>
               <div id="O"><h2>5.2.　Clause 4.2</h2>

              </div>
             </div>
             <br/>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>附件A</b><br/>（规范性附录）<br/><br/><b>Annex</b></h1>
               <div id="Q"><h2>A.1.　Annex A.1</h2>

                <div id="Q1"><h3>A.1.1.　Annex A.1a</h3>

                </div>
              </div>
             </div>
             <br/>
             <div><h1 class="Section3">Bibliography</h1>

                <div><h2 class="Section3">Bibliography Subsection</h2>

              </div>
              </div>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes i18n file" do
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

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
            <bibdata>
            <language current="true">eo</language>
            <script current="true">Latn</script>
            <status>
            <stage language="">published</stage><stage language="eo">publikigita</stage>
            <substage language="">withdrawn</substage><substage language="eo">fortirita</substage>
            </status>
            <edition language=''>2</edition>
            <edition language='eo'>eldono dua</edition>
            <ext>
            <doctype language="">brochure</doctype><doctype language="eo">bro&#x15D;uro</doctype>
            </ext>
            </bibdata><localized-strings><localized-string key="foreword" language="eo">Anta&#x16D;parolo</localized-string><localized-string key="introduction" language="eo">Enkonduko</localized-string><localized-string key="clause" language="eo">kla&#x16D;zo</localized-string><localized-string key="table" language="eo">tabelo</localized-string><localized-string key="source" language="eo">SOURCE</localized-string><localized-string key="modified" language="eo">modified</localized-string><localized-string key="scope" language="eo">Amplekso</localized-string><localized-string key="symbols" language="eo">Simboloj kai mallongigitaj terminoj</localized-string><localized-string key="annex" language="eo"><strong>aldono</strong></localized-string><localized-string key="normref" language="eo">Normaj cita&#x135;oj</localized-string><localized-string key="bibliography" language="eo">Bibliografio</localized-string><localized-string key="inform_annex" language="eo">informa</localized-string><localized-string key="all_parts" language="eo">&#x109;iuj partoj</localized-string><localized-string key="norm_annex" language="eo">normative</localized-string><localized-string key='figure' language='eo'>figur-etikedo duvorta</localized-string><localized-string key='example' language='eo'>Ekzempl-etikedo Duvorta</localized-string><localized-string key="note" language="eo">NOTO</localized-string><localized-string key="locality.table" language="eo">Tabelo</localized-string><localized-string key='locality.prelude' language='eo'>preludo</localized-string><localized-string key="doctype_dict.brochure" language="eo">bro&#x15D;uro</localized-string><localized-string key="doctype_dict.conference_proceedings" language="eo">konferencaktoj</localized-string><localized-string key="stage_dict.published" language="eo">publikigita</localized-string><localized-string key="substage_dict.withdrawn" language="eo">fortirita</localized-string><localized-string key="array.0" language="eo">elem1</localized-string><localized-string key="array.1" language="eo">elem2</localized-string><localized-string key="array.2.elem3" language="eo">elem4</localized-string><localized-string key="array.2.elem5" language="eo">elem6</localized-string>
            <localized-string key='ordinal_keys.0' language='eo'>number</localized-string>
            <localized-string key='SpelloutRules.sg' language='eo'>spellout-ordinal</localized-string>
            <localized-string key='SpelloutRules.pl' language='eo'>spellout-ordinal</localized-string>
            <localized-string key='edition_ordinal' language='eo'>eldono %Spellout</localized-string>
            <localized-string key='edition' language='eo'>eldono</localized-string>
            <localized-string key="language" language="eo">eo</localized-string><localized-string key="script" language="eo">Latn</localized-string></localized-strings>
            <preface>
              <clause type="toc" displayorder="1"><title depth="1"/></clause>
            <foreword obligation="informative" displayorder="2">
               <title>Foreword</title>
               <p id="A">See <xref target="M">kla&#x16D;zo 5</xref></p>
               <p id="A">See <xref target="tab">tabelo 1</xref></p>
               <table id="tab"><name>Tabelo 1</name></table>
             </foreword>
              <introduction id="B" obligation="informative" displayorder="3"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
               <title depth="2">Introduction Subsection</title>
             </clause>
             </introduction></preface><sections>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title depth="1">1.<tab/>Scope</title>
               <p id="E"><eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO&#xa0;712, Tabelo 1&#x2013;1</eref></p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
               <title depth="2">3.1.<tab/>Normal Terms</title>
               <term id="J"><name>3.1.1.</name>
               <preferred><strong>Term2</strong></preferred>
             </term>
             </terms>
             <definitions id="K"><title>3.2.</title>
               <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
               </dl>
             </definitions>
             </clause>
             <definitions id="L" displayorder="7"><title>4.</title>
               <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
               </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title depth="2">5.1.<tab/>Introduction</title>
               <note id="M-n1"><name>NOTO  </name></note>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">5.2.<tab/>Clause 4.2</title>
             </clause></clause>
             </sections><annex id="P" inline-header="false" obligation="normative" displayorder="9">
               <title><strong><strong>Aldono</strong> A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
               <clause id="Q" inline-header="false" obligation="normative">
               <title depth="2">A.1.<tab/>Annex A.1</title>
               <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1.<tab/>Annex A.1a</title>
               </clause>
             </clause>
             </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="5">
               <title depth="1">2.<tab/>Normative References</title>
               <bibitem id="ISO712" type="standard">
               <formattedref><em>Cereals and cereal products</em>.</formattedref>
        <docidentifier>ISO&#xa0;712</docidentifier>
         <biblio-tag>ISO&#xa0;712,</biblio-tag>
      </bibitem>
             </references><clause id="S" obligation="informative" displayorder="10">
               <title depth="1">Bibliography</title>
               <references id="T" obligation="informative" normative="false">
               <title depth="2">Bibliography Subsection</title>
             </references>
             </clause>
             </bibliography>
             </iso-standard>
    OUTPUT

    output = <<~OUTPUT
              <html lang='eo'>
               <head/>
               <body lang='eo'>
                 <div class='title-section'>
                   <p>&#160;</p>
                 </div>
                 <br/>
                 <div class='prefatory-section'>
                   <p>&#160;</p>
                 </div>
                 <br/>
                 <div class='main-section'>
                   <br/>
                         <div class="TOC">
        <h1 class="IntroTitle"/>
      </div>
      <br/>
                   <div>
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
                   <p class='zzSTDTitle1'/>
                   <div id='D'>
                     <h1>1.&#160; Scope</h1>
                     <p id='E'>
                       <a href='#ISO712'>ISO&#xa0;712, Tabelo 1&#8211;1</a>
                     </p>
                   </div>
                   <div>
                     <h1>2.&#160; Normative References</h1>
                     <p id='ISO712' class='NormRef'>
                       ISO&#xa0;712,
                       <i>Cereals and cereal products</i>.
                     </p>
                   </div>
                   <div id='H'>
                     <h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1>
                     <div id='I'>
                       <h2>3.1.&#160; Normal Terms</h2>
                       <p class='TermNum' id='J'>3.1.1.</p>
                       <p class='Terms' style='text-align:left;'><b>Term2</b></p>
                     </div>
                     <div id='K'>
                       <h2>3.2.</h2>
                       <dl>
                         <dt>
                           <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                       </dl>
                     </div>
                   </div>
                   <div id='L' class='Symbols'>
                     <h1>4.</h1>
                     <dl>
                       <dt>
                         <p>Symbol</p>
                       </dt>
                       <dd>Definition</dd>
                     </dl>
                   </div>
                   <div id='M'>
                     <h1>5.&#160; Clause 4</h1>
                     <div id='N'>
                       <h2>5.1.&#160; Introduction</h2>
                       <div id='M-n1' class='Note'>
        <p>
          <span class='note_label'>NOTO </span>
          &#160;
        </p>
      </div>
                     </div>
                     <div id='O'>
                       <h2>5.2.&#160; Clause 4.2</h2>
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
                       <h2>A.1.&#160; Annex A.1</h2>
                       <div id='Q1'>
                         <h3>A.1.1.&#160; Annex A.1a</h3>
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" })
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(output)
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
      <foreword obligation="informative">
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
      <foreword obligation='informative' displayorder='2'>
        <title>Foreword</title>
        <p id='A'>
          <eref type='inline' bibitemid='ISO712'>
            <locality type='locality:prelude'>
              <referenceFrom>7</referenceFrom>
            </locality>
            ISO&#xa0;712, Preludo 7
          </eref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ i18nyaml: "spec/assets/i18n.yaml" }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(presxml)
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
=end
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
            <clause>
              <title depth="1">版　權</title>
            </clause>
            <clause>
              <title depth="1">版權聲明</title>
            </clause>
            <clause language="en">
              <title depth="1">版　權</title>
            </clause>
          </copyright-statement>
        </boilerplate>
        <preface>
           <clause type="toc" id="_" displayorder="1">
             <title depth="1">目　次</title>
           </clause>
          <p type="floating-title" displayorder="2">樣　板</p>
          <abstract obligation="informative" language="jp" displayorder="3">
            <title>解　題</title>
          </abstract>
          <foreword obligation="informative" displayorder="4">
            <title>文件序言</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <p type="floating-title" displayorder="5">介紹性陳述</p>
          <introduction id="B" obligation="informative" displayorder="6">
            <title>簡　介</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="3">引言部分</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title depth="3">附則</title>
              </clause>
            </clause>
            <clause id="D">
              <title language="en" depth="2">Ad</title>
            </clause>
          </introduction>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
  .new(presxml_options).convert("test", input, true)
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
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
