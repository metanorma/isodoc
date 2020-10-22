require "spec_helper"

RSpec.describe IsoDoc do
  it "processes English" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
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
         <preferred>Term2</preferred>
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

        presxml = <<~"PRESXML"
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <bibdata>
           <language current="true">en</language>
         </bibdata>
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>See <xref target='M'>Clause 5</xref></p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
             <title depth='2'>Introduction Subsection</title>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type="scope">
           <title depth='1'>1.<tab/>Scope</title> 
             <p id='E'>Text</p>
           </clause>
           <clause id='H' obligation='normative'>
           <title depth='1'>3.<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id='I' obligation='normative'>
             <title depth='2'>3.1.<tab/>Normal Terms</title>
               <term id='J'>
               <name>3.1.1.</name>
                 <preferred>Term2</preferred>
               </term>
             </terms>
             <definitions id='K'>
             <title>3.2.</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id='L'>
           <title>4.</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id='M' inline-header='false' obligation='normative'>
           <title depth='1'>5.<tab/>Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
             <title depth='2'>5.1.<tab/>Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
             <title depth='2'>5.2.<tab/>Clause 4.2</title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex A</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id='Q' inline-header='false' obligation='normative'>
           <title depth='2'>A.1.<tab/>Annex A.1</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
             <title depth='3'>A.1.1.<tab/>Annex A.1a</title>
             </clause>
           </clause>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
            <title depth='1'>2.<tab/>Normative References</title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth="1">Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
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
          <p class="Terms" style="text-align:left;">Term2</p>

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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "defaults to English" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>tlh</language>
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
         <preferred>Term2</preferred>
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
        <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <bibdata>
           <language current="true">tlh</language>
         </bibdata>
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>See <xref target='M'>Clause 5</xref></p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
             <title depth='2'>Introduction Subsection</title>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type="scope">
           <title depth='1'>1.<tab/>Scope</title>
             <p id='E'>Text</p>
           </clause>
           <clause id='H' obligation='normative'>
           <title depth='1'>3.<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id='I' obligation='normative'>
             <title depth='2'>3.1.<tab/>Normal Terms</title>
               <term id='J'>
               <name>3.1.1.</name>
                 <preferred>Term2</preferred>
               </term>
             </terms>
             <definitions id='K'>
             <title>3.2.</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id='L'>
           <title>4.</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id='M' inline-header='false' obligation='normative'>
           <title depth='1'>5.<tab/>Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
             <title depth='2'>5.1.<tab/>Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
             <title depth='2'>5.2.<tab/>Clause 4.2</title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex A</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id='Q' inline-header='false' obligation='normative'>
           <title depth='2'>A.1.<tab/>Annex A.1</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
             <title depth='3'>A.1.1.<tab/>Annex A.1a</title>
             </clause>
           </clause>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
            <title depth='1'>2.<tab/>Normative References</title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth="1">Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes French" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
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
         <preferred>Term2</preferred>
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

        presxml = <<~"PRESXML"
        <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <bibdata>
           <language current="true">fr</language>
         </bibdata>
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>See <xref target='M'>Article 5</xref></p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
             <title depth='2'>Introduction Subsection</title>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type="scope">
           <title depth='1'>1.<tab/>Scope</title>
             <p id='E'>Text</p>
           </clause>
           <clause id='H' obligation='normative'>
           <title depth='1'>3.<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id='I' obligation='normative'>
             <title depth='2'>3.1.<tab/>Normal Terms</title>
               <term id='J'>
               <name>3.1.1.</name>
                 <preferred>Term2</preferred>
               </term>
             </terms>
             <definitions id='K'>
             <title>3.2.</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id='L'>
           <title>4.</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id='M' inline-header='false' obligation='normative'>
           <title depth='1'>5.<tab/>Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
             <title depth='2'>5.1.<tab/>Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
             <title depth='2'>5.2.<tab/>Clause 4.2</title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
           <title>
             <strong>Annexe A</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id='Q' inline-header='false' obligation='normative'>
           <title depth='2'>A.1.<tab/>Annex A.1</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
             <title depth='3'>A.1.1.<tab/>Annex A.1a</title>
             </clause>
           </clause>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
            <title depth='1'>2.<tab/>Normative References</title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth="1">Bibliographie</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
        PRESXML

    output = <<~"OUTPUT"
            #{HTML_HDR.gsub(/ lang="en">/, ' lang="fr">')}
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
          <p class="Terms" style="text-align:left;">Term2</p>

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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes Simplified Chinese" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>zh</language>
      <script>Hans</script>
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
         <preferred>Term2</preferred>
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

        presxml = <<~"PRESXML"
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <bibdata>
           <language current="true">zh</language>
           <script current="true">Hans</script>
         </bibdata>
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>See <xref target='M'>&#x6761;5</xref></p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
               <title depth='2'>Introduction Subsection</title>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type="scope">
           <title depth='1'>1.<tab/>Scope</title>
             <p id='E'>
               <eref type='inline' bibitemid='ISO712'><locality type='table'><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO 712&#x3001;&#x7B2C;1&#x2013;1&#x8868;</eref></p>
           </clause>
           <clause id='H' obligation='normative'>
           <title depth='1'>3.<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id='I' obligation='normative'>
             <title depth='2'>3.1.<tab/>Normal Terms</title>
               <term id='J'>
               <name>3.1.1.</name>
                 <preferred>Term2</preferred>
               </term>
             </terms>
             <definitions id='K'>
             <title>3.2.</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id='L'>
           <title>4.</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id='M' inline-header='false' obligation='normative'>
           <title depth='1'>5.<tab/>Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
             <title depth='2'>5.1.<tab/>Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
             <title depth='2'>5.2.<tab/>Clause 4.2</title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
          <title>
   <strong>&#x9644;&#x4EF6;A</strong>
   <br/>
   &#xFF08;&#x89C4;&#x8303;&#x6027;&#x9644;&#x5F55;&#xFF09;
   <br/>
   <br/>
   <strong>Annex</strong>
 </title>
           <clause id='Q' inline-header='false' obligation='normative'>
           <title depth='2'>A.1.<tab/>Annex A.1</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
             <title depth='3'>A.1.1.<tab/>Annex A.1a</title>
             </clause>
           </clause>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
            <title depth='1'>2.<tab/>Normative References</title>
             <bibitem id='ISO712' type='standard'>
               <title format='text/plain'>Cereals and cereal products</title>
               <docidentifier>ISO 712</docidentifier>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
             </bibitem>
           </references>
           <clause id='S' obligation='informative'>
             <title depth="1">Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
       PRESXML

        output = <<~"OUTPUT"
    #{HTML_HDR.gsub(/ lang="en">/, ' lang="zh">')}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id='A'>
  See
  <a href='#M'>&#26465;5</a>
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
                 <h1>1.&#12288;Scope</h1>
                 <p id="E">
                 <a href='#ISO712'>ISO 712&#12289;&#31532;1&#8211;1&#34920;</a>
                 </p>
               </div>
               <div>
                 <h1>2.&#12288;Normative References</h1>
                 <p id="ISO712" class="NormRef">ISO 712, <i>Cereals and cereal products</i></p>
               </div>
               <div id="H"><h1>3.&#12288;Terms, definitions, symbols and abbreviated terms</h1>
       <div id="I">
                <h2>3.1.&#12288;Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1.</p>
                <p class="Terms" style="text-align:left;">Term2</p>

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
                 <h1>5.&#12288;Clause 4</h1>
                 <div id="N">
                <h2>5.1.&#12288;Introduction</h2>
              </div>
                 <div id="O">
                <h2>5.2.&#12288;Clause 4.2</h2>
              </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>&#38468;&#20214;A</b><br/>&#65288;&#35268;&#33539;&#24615;&#38468;&#24405;&#65289;<br/><br/><b>Annex</b></h1>
                 <div id="Q">
                <h2>A.1.&#12288;Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1.&#12288;Annex A.1a</h3>
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes i18n file" do
    mock_i18n
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>eo</language>
      <script>Latn</script>
      <status>
      <stage>published</stage>
      <substage>withdrawn</substage>
      </status>
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
         <preferred>Term2</preferred>
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

        presxml = <<~OUTPUT
         <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
             <bibdata>
             <language current="true">eo</language>
             <script current="true">Latn</script>
             <status>
             <stage language=''>published</stage>
<stage language='eo'>publikigita</stage>
<substage language=''>withdrawn</substage>
<substage language='eo'>fortirita</substage>
</status>
<ext>
<doctype language=''>brochure</doctype>
<doctype language='eo'>bro&#x15D;uro</doctype>
</ext>
             </bibdata>
  <localized-strings>
  <i18n_foreword>Anta&#x16D;parolo</i18n_foreword>
  <i18n_introduction>Enkonduko</i18n_introduction>
  <i18n_clause>kla&#x16D;zo</i18n_clause>
  <i18n_table>Tabelo</i18n_table>
  <i18n_source>SOURCE</i18n_source>
  <i18n_modified>modified</i18n_modified>
  <i18n_scope>Amplekso</i18n_scope>
  <i18n_symbols>Simboloj kai mallongigitaj terminoj</i18n_symbols>
  <i18n_annex>Aldono</i18n_annex>
  <i18n_normref>Normaj cita&#x135;oj</i18n_normref>
  <i18n_bibliography>Bibliografio</i18n_bibliography>
  <i18n_inform_annex>informa</i18n_inform_annex>
  <i18n_all_parts>&#x109;iuj partoj</i18n_all_parts>
  <i18n_norm_annex>normative</i18n_norm_annex>
  <i18n_locality>
    <i18n_table>Tabelo</i18n_table>
  </i18n_locality>
  <i18n_doctype_dict>
    <i18n_brochure>bro&#x15D;uro</i18n_brochure>
    <i18n_conference_proceedings>konferencaktoj</i18n_conference_proceedings>
  </i18n_doctype_dict>
  <i18n_stage_dict>
    <i18n_published>publikigita</i18n_published>
  </i18n_stage_dict>
  <i18n_substage_dict>
    <i18n_withdrawn>fortirita</i18n_withdrawn>
  </i18n_substage_dict>
  <i18n_array>elem1</i18n_array>
  <i18n_array>elem2</i18n_array>
  <i18n_array>
    <i18n_elem3>elem4</i18n_elem3>
    <i18n_elem5>elem6</i18n_elem5>
  </i18n_array>
  <i18n_language>eo</i18n_language>
  <i18n_script>Latn</i18n_script>
</localized-strings>
             <preface>
             <foreword obligation="informative">
                <title>Foreword</title>
                <p id='A'>See <xref target='M'>kla&#x16D;zo 5</xref></p>
              </foreword>
               <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
                <title depth="2">Introduction Subsection</title>
              </clause>
              </introduction></preface><sections>
              <clause id="D" obligation="normative" type="scope">
                <title depth="1">1.<tab/>Scope</title>
                <p id="E"><eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO 712, Tabelo 1&#x2013;1</eref></p>
              </clause>

              <clause id="H" obligation="normative"><title depth="1">3.<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
                <title depth="2">3.1.<tab/>Normal Terms</title>
                <term id="J"><name>3.1.1.</name>
                <preferred>Term2</preferred>
              </term>
              </terms>
              <definitions id="K"><title>3.2.</title>
                <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
                </dl>
              </definitions>
              </clause>
              <definitions id="L"><title>4.</title>
                <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
                </dl>
              </definitions>
              <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
                <title depth="2">5.1.<tab/>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title depth="2">5.2.<tab/>Clause 4.2</title>
              </clause></clause>

              </sections><annex id="P" inline-header="false" obligation="normative">
                <title><strong>Aldono A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
                <clause id="Q" inline-header="false" obligation="normative">
                <title depth="2">A.1.<tab/>Annex A.1</title>
                <clause id="Q1" inline-header="false" obligation="normative">
                <title depth="3">A.1.1.<tab/>Annex A.1a</title>
                </clause>
              </clause>
              </annex><bibliography><references id="R" obligation="informative" normative="true">
                <title depth="1">2.<tab/>Normative References</title>
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
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p id='A'>
  See
  <a href='#M'>kla&#365;zo 5</a>
</p>
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
                 <a href='#ISO712'>ISO 712, Tabelo 1&#8211;1</a>
               </p>
             </div>
             <div>
               <h1>2.&#160; Normative References</h1>
               <p id='ISO712' class='NormRef'>
                 ISO 712,
                 <i>Cereals and cereal products</i>
               </p>
             </div>
             <div id='H'>
               <h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1>
               <div id='I'>
                 <h2>3.1.&#160; Normal Terms</h2>
                 <p class='TermNum' id='J'>3.1.1.</p>
                 <p class='Terms' style='text-align:left;'>Term2</p>
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
               </div>
               <div id='O'>
                 <h2>5.2.&#160; Clause 4.2</h2>
               </div>
             </div>
             <br/>
             <div id='P' class='Section3'>
               <h1 class='Annex'>
                 <b>Aldono A</b>
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

        expect(xmlpp(IsoDoc::PresentationXMLConvert.new({i18nyaml: "spec/assets/i18n.yaml"}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({i18nyaml: "spec/assets/i18n.yaml"}).convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  private

  def mock_i18n
    allow_any_instance_of(::IsoDoc::I18n).to receive(:load_yaml).with("eo", "Latn", "spec/assets/i18n.yaml").and_return(YAML.load_file("spec/assets/i18n.yaml"))
  end

end
