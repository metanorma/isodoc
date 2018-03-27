require "spec_helper"

RSpec.describe IsoDoc do
  it "processes English" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      </bibdata>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><subclause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subclause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </clause>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><subclause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subclause>
       <subclause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subclause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subclause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <subclause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </subclause>
       </subclause>
       <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </iso-standard>
        INPUT
               <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection2">
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <br/>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">0.&#160; Introduction</h1>
                 <div id="C">
          <h2>0.1. Introduction Subsection</h2>
        </div>
                 <p>This is patent boilerplate</p>
               </div>
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1.&#160; Scope</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2.&#160; Normative References</h1>
                 <p>There are no normative references in this document.</p>
               </div>
               <div id="H"><h1>3.&#160; Terms and Definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and Abbreviated Terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4.&#160; Symbols and Abbreviated Terms</h1>
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
          <h2>5.1. Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
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
         </head>
       </html>
    OUTPUT
  end

  it "defaults to English" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>tlh</language>
      </bibdata>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><subclause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subclause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </clause>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><subclause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subclause>
       <subclause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subclause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subclause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <subclause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </subclause>
       </subclause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </iso-standard>
        INPUT
               <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection2">
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <br/>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">0.&#160; Introduction</h1>
                 <div id="C">
          <h2>0.1. Introduction Subsection</h2>
        </div>
                 <p>This is patent boilerplate</p>
               </div>
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1.&#160; Scope</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2.&#160; Normative References</h1>
                 <p>There are no normative references in this document.</p>
               </div>
               <div id="H"><h1>3.&#160; Terms and Definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and Abbreviated Terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4.&#160; Symbols and Abbreviated Terms</h1>
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
          <h2>5.1. Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
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
         </head>
       </html>
    OUTPUT
  end

  it "processes French" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
      </bibdata>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><subclause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subclause>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </clause>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><subclause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subclause>
       <subclause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subclause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subclause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <subclause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </subclause>
       </subclause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </iso-standard>
        INPUT
               <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection2">
               <br/>
               <div>
                 <h1 class="ForewordTitle">Avant-propos</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <br/>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">0.&#160; Introduction</h1>
                 <div id="C">
          <h2>0.1. Introduction Subsection</h2>
        </div>
                 <p>This is patent boilerplate</p>
               </div>
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1.&#160; Domaine d'application</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2.&#160; R&#233;f&#233;rences normatives</h1>
                 <p>Le pr&#233;sent document ne contient aucune r&#233;f&#233;rence normative.</p>
               </div>
               <div id="H"><h1>3.&#160; Terms et d&#233;finitions</h1><p>Pour les besoins du pr&#233;sent document, les termes et d&#233;finitions suivants s'appliquent.</p>
       <p>L'ISO et l'IEC tiennent &#224; jour des bases de donn&#233;es terminologiques
       destin&#233;es &#224; &#234;tre utilis&#233;es en normalisation, consultables aux adresses
       suivantes:</p>
       <ul>
       <li> <p>ISO Online browsing platform: disponible &#224; l'adresse
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: disponible &#224; l'adresse
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and Abbreviated Terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4.&#160; Symboles et termes abr&#233;g&#233;s</h1>
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
          <h2>5.1. Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annexe A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
          </div>
        </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">then Bibliographie</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "processes Simplified Chinese" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>zh</language>
      <script>Hans</script>
      </bibdata>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><subclause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subclause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E"><eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref></p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </clause>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><subclause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subclause>
       <subclause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subclause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subclause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <subclause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </subclause>
       </subclause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><references id="R" obligation="informative">
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
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </iso-standard>
        INPUT
               <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection2">
               <br/>
               <div>
                 <h1 class="ForewordTitle">&#21069;&#35328;</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <br/>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">0.&#160; &#24341;&#35328;</h1>
                 <div id="C">
                <h2>0.1. Introduction Subsection</h2>
              </div>
                 <p>This is patent boilerplate</p>
               </div>
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1.&#160; &#33539;&#22260;</h1>
                 <p id="E">
                   <a href="#ISO712">ISO 712&#12289;&#31532;1&#8211;<referenceto>1</referenceto>&#34920;</a>
                 </p>
               </div>
               <div>
                 <h1>2.&#160; &#35268;&#33539;&#24615;&#24341;&#29992;&#25991;&#20214;</h1>
                 <p>&#19979;&#21015;&#25991;&#20214;&#23545;&#20110;&#26412;&#25991;&#20214;&#30340;&#24212;&#29992;&#26159;&#24517;&#19981;&#21487;&#23569;&#30340;&#12290; &#20961;&#26159;&#27880;&#26085;&#26399;&#30340;&#24341;&#29992;&#25991;&#20214;&#65292;&#20165;&#27880;&#26085;&#26399;&#30340;&#29256;&#26412;&#36866;&#29992;&#20110;&#26412;&#25991;&#20214;&#12290; &#20961;&#26159;&#19981;&#27880;&#26085;&#26399;&#30340;&#24341;&#29992;&#25991;&#20214;&#65292;&#20854;&#26368;&#26032;&#29256;&#26412;&#65288;&#21253;&#25324;&#25152;&#26377;&#30340;&#20462;&#25913;&#21333;&#65289;&#36866;&#29992;&#20110;&#26412;&#25991;&#20214;&#12290;</p>
                 <p id="ISO712">ISO 712, <i> Cereals and cereal products</i></p>
               </div>
               <div id="H"><h1>3.&#160; &#26415;&#35821;&#21644;&#23450;&#20041;</h1><p>&#19979;&#21015;&#26415;&#35821;&#21644;&#23450;&#20041;&#36866;&#29992;&#20110;&#26412;&#25991;&#20214;&#12290;</p>
       <p>ISO&#21644;IEC&#29992;&#20110;&#26631;&#20934;&#21270;&#30340;&#26415;&#35821;&#25968;&#25454;&#24211;&#22320;&#22336;&#22914;&#19979;&#65306;</p>
       <ul>
       <li> <p>ISO&#22312;&#32447;&#27983;&#35272;&#24179;&#21488;:
         &#20301;&#20110;<a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia:
         &#20301;&#20110;<a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <div id="I">
                <h2>3.1. Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms">Term2</p>

              </div><div id="K"><h2>3.2. Symbols and Abbreviated Terms</h2>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div></div>
               <div id="L" class="Symbols">
                 <h1>4.&#160; &#31526;&#21495;&#12289;&#20195;&#21495;&#21644;&#32553;&#30053;&#35821;</h1>
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
                <h2>5.1. Introduction</h2>
              </div>
                 <div id="O">
                <h2>5.2. Clause 4.2</h2>
              </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex">&#38468;&#24405;A<br/>&#65288;&#35268;&#33539;&#24615;&#38468;&#24405;&#65289;<br/><br/><b>Annex</b></h1>
                 <div id="Q">
                <h2>A.1. Annex A.1</h2>
                <div id="Q1">
                <h3>A.1.1. Annex A.1a</h3>
                </div>
              </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">&#21442;&#32771;&#25991;&#29486;</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

end
