require "spec_helper"

RSpec.describe IsoDoc do
  it "processes document with no content" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface/>
          <sections/>
        </iso-standard>
    INPUT
    <html xmlns:epub="http://www.idpf.org/2007/ops">
  <head/>
  <body lang="en">
    <div class="title-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="prefatory-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="main-section">
      <p class="zzSTDTitle1"/>
    </div>
  </body>
</html>
    OUTPUT
    end

  it "processes section names" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract obligation="informative">
         <title>Foreword</title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
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
       <definitions id="K">
         <title>Definitions</title>
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
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    #{HTML_HDR}
    <br/>
        <div>
        <h1 class="AbstractTitle">Abstract</h1>
        </div>

                <br/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p id="A">This is a preamble</p>
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
                  <h1>2.&#160; Normative references</h1>
                  <p>There are no normative references in this document.</p>
                </div>
                <div id="H"><h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1><p>For the purposes of this document,
            the following terms and definitions apply.</p>
        <div id="I">
           <h2>3.1. Normal Terms</h2>
           <p class="TermNum" id="J">3.1.1.</p>
           <p class="Terms" style="text-align:left;">Term2</p>
      
         </div><div id="K"><h2>3.2. Definitions</h2>
           <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
         </div></div>
                <div id="L" class="Symbols">
                  <h1>4.&#160; Symbols and abbreviated terms</h1>
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
                  <div id="O1">
           <h2>5.3. </h2>
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
        </html>
OUTPUT
  end

  it "processes section names (Word)" do
    expect(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract obligation="informative">
         <title>Foreword</title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
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
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
          <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head/>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection2">
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div>
                   <h1 class="AbstractTitle">Abstract</h1>
                </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">Introduction</h1>
                 <div id="C">
          <h2>Introduction Subsection</h2>
        </div>
               </div>
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1.<span style="mso-tab-count:1">&#160; </span>Scope</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2.<span style="mso-tab-count:1">&#160; </span>Normative references</h1>
                 <p>There are no normative references in this document.</p>
               </div>
               <div id="H"><h1>3.<span style="mso-tab-count:1">&#160; </span>Terms, definitions, symbols and abbreviated terms</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1.</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and abbreviated terms</h2>
          <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4.<span style="mso-tab-count:1">&#160; </span>Symbols and abbreviated terms</h1>
                 <table class="dl">
                   <tr>
                     <td valign="top" align="left">
                       <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                     </td>
                     <td valign="top">Definition</td>
                   </tr>
                 </table>
               </div>
               <div id="M">
                 <h1>5.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
                 <div id="N">
          <h2>5.1. Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
                 <div id="O1">
          <h2>5.3. </h2>
        </div>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
          </div>
        </div>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
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
  end

    it "processes section names suppressing section numbering" do
    expect(IsoDoc::HtmlConvert.new({suppressheadingnumbers: true}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
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
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    #{HTML_HDR}
              <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>

        </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="D">
               <h1>Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>Normative references</h1>
               <p>There are no normative references in this document.</p>
             </div>
             <div id="H"><h1>Terms, definitions, symbols and abbreviated terms</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <div id="I"><h2>Normal Terms</h2>

          <p class="TermNum" id="J">3.1.1.</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>Symbols and abbreviated terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
             <div id="L" class="Symbols">
               <h1>Symbols and abbreviated terms</h1>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
             <div id="M">
               <h1>Clause 4</h1>
               <div id="N"><h2>Introduction</h2>

        </div>
               <div id="O"><h2>Clause 4.2</h2>

        </div>
               <div id="O1"><h2/>
        </div>
             </div>
             <br/>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
               <div id="Q"><h2>Annex A.1</h2>

          <div id="Q1"><h3>Annex A.1a</h3>

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
    end

  it "processes simple terms & definitions" do
        expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
               <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="J">1.1.</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "warn about external source for terms & definitions that does not point anywhere" do
        expect{ IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true) }.to output(/not referenced/).to_stderr
               <iso-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
        </sections>
</iso-standard>
INPUT
end

  it "processes terms & definitions with external source" do
        expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
               <iso-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
        </sections>
        <bibliography>
        <references id="_normative_references" obligation="informative"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem></references>
</bibliography>
        </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div>
                 <h1>1.&#160; Normative references</h1>
                 <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i></p>
               </div>
               <div id="H"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document, the terms and definitions
         given in <a href="#ISO712">ISO 712</a> and the following apply.</p>
       <p class="TermNum" id="J">2.1.</p>
                <p class="Terms" style="text-align:left;">Term2</p>
              </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes empty terms & definitions with external source" do
        expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
               <iso-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
         <termdocsource type="inline" bibitemid="ISO712"/>
         <termdocsource type="inline" bibitemid="ISO712"/>
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
       </terms>
        </sections>
        <bibliography>
        <references id="_normative_references" obligation="informative"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem></references>
</bibliography>
        </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div>
                 <h1>1.&#160; Normative references</h1>
                 <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i></p>
               </div>
               <div id="H"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document,
         the terms and definitions given in <a href="#ISO712">ISO 712</a>, <a href="#ISO712">ISO 712</a> and <a href="#ISO712">ISO 712</a> apply.</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
  end


  it "processes empty terms & definitions" do
        expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
               <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
       </terms>
        </sections>
        </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="H"><h1>1.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes inline section headers" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections>
      </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>1.&#160; Clause 4</h1>
                 <div id="N">
          <h2>1.1. Introduction</h2>
        </div>
                 <div id="O">
          <span class="zzMoveToFollowing"><b>1.2. Clause 4.2 </b></span>
        </div>
               </div>
             </div>
           </body>
       </html>
OUTPUT
    end

        it "processes inline section headers with suppressed heading numbering" do
    expect(IsoDoc::HtmlConvert.new({suppressheadingnumbers: true}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections>
      </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>Clause 4</h1>
                 <div id="N">
          <h2>Introduction</h2>
        </div>
                 <div id="O">
          <span class="zzMoveToFollowing"><b>Clause 4.2 </b></span>
        </div>
               </div>
             </div>
           </body>
       </html>
OUTPUT
    end

        it "processes sections without titles" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
       <introduction id="M" inline-header="false" obligation="normative"><clause id="N" inline-header="false" obligation="normative">
         <title>Intro</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
       </clause></clause>
       </preface>
       <sections>
       <clause id="M1" inline-header="false" obligation="normative"><clause id="N1" inline-header="false" obligation="normative">
       </clause>
       <clause id="O1" inline-header="true" obligation="normative">
       </clause></clause>
       </sections>

      </iso-standard>
    INPUT
    #{HTML_HDR}
             <br/>
             <div class="Section3" id="M">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="N"><h2>Intro</h2>
     
        </div>
               <div id="O"><span class="zzMoveToFollowing"><b> </b></span>
        </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="M1">
               <h1>1.&#160; </h1>
               <div id="N1"><h2>1.1. </h2>
        </div>
               <div id="O1"><span class="zzMoveToFollowing"><b>1.2.  </b></span>
        </div>
             </div>
           </div>
         </body>
       </html>
OUTPUT
    end


end
