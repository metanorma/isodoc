require "spec_helper"

RSpec.describe IsoDoc do
  it "processes document with no content" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface/>
          <sections/>
        </iso-standard>
    INPUT
    <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
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
     input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <boilerplate>
        <copyright-statement>
        <clause>
          <title>Copyright</title>
        </clause>
        </copyright-statement>
        <license-statement>
        <clause>
          <title>License</title>
        </clause>
        </license-statement>
        <legal-statement>
        <clause>
          <title>Legal</title>
        </clause>
        </legal-statement>
        <feedback-statement>
        <clause>
          <title>Feedback</title>
        </clause>
        </feedback-statement>
      </boilerplate>
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
       </introduction>
       <clause id="B1"><title>Dedication</title></clause>
       <clause id="B2"><title>Note to reader</title></clause>
       <acknowledgements obligation="informative">
         <title>Acknowledgements</title>
       </acknowledgements>
        </preface><sections>
        <note id="NN1"><p>Initial note</p></note>
        <admonition id="NN2" type="warning"><p>Initial admonition</p></admonition>
       <clause id="D" obligation="normative" type="scope">
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
       <title>Symbols and abbreviated terms</title>
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
         <references id="Q2" normative="false">
        <title>Annex Bibliography</title>
        </references>
       </clause>
       </annex>
       <annex id="P1" inline-header="false" obligation="normative">
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true">
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
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
  <boilerplate>
    <copyright-statement>
      <clause>
        <title depth="1">Copyright</title>
      </clause>
    </copyright-statement>
    <license-statement>
      <clause>
        <title depth="1">License</title>
      </clause>
    </license-statement>
    <legal-statement>
      <clause>
        <title depth="1">Legal</title>
      </clause>
    </legal-statement>
    <feedback-statement>
      <clause>
        <title depth="1">Feedback</title>
      </clause>
    </feedback-statement>
  </boilerplate>
  <preface>
    <abstract obligation='informative'>
      <title>Foreword</title>
    </abstract>
    <foreword obligation='informative'>
      <title>Foreword</title>
      <p id='A'>This is a preamble</p>
    </foreword>
    <introduction id='B' obligation='informative'>
      <title>Introduction</title>
      <clause id='C' inline-header='false' obligation='informative'>
        <title depth='2'>Introduction Subsection</title>
      </clause>
    </introduction>
    <clause id='B1'>
      <title depth='1'>Dedication</title>
    </clause>
    <clause id='B2'>
      <title depth='1'>Note to reader</title>
    </clause>
    <acknowledgements obligation='informative'>
      <title>Acknowledgements</title>
    </acknowledgements>
  </preface>
  <sections>
    <note id='NN1'>
      <name>NOTE</name>
      <p>Initial note</p>
    </note>
    <admonition id='NN2' type='warning'>
      <p>Initial admonition</p>
    </admonition>
    <clause id='D' obligation='normative' type='scope'>
      <title depth='1'>1.<tab/>Scope</title>
      <p id='E'>Text</p>
    </clause>
    <clause id='H' obligation='normative'>
      <title depth='1'>3.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
      <terms id='I' obligation='normative'>
        <title depth='2'>3.1.<tab/>Normal Terms</title>
        <term id='J'>
          <name>3.1.1.</name>
          <preferred>Term2</preferred>
        </term>
      </terms>
      <definitions id='K'>
      <title depth='2'>3.2.<tab/>Definitions</title>
        <dl>
          <dt>Symbol</dt>
          <dd>Definition</dd>
        </dl>
      </definitions>
    </clause>
    <definitions id='L'>
    <title depth='1'>4.<tab/>Symbols and abbreviated terms</title>
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
      <clause id='O1' inline-header='false' obligation='normative'>
        <title>5.3.</title>
      </clause>
    </clause>
  </sections>
  <annex id='P' inline-header='false' obligation='normative'>
    <title> <strong>Annex A</strong><br/>(normative)<br/><br/><strong>Annex</strong>
    </title>
    <clause id='Q' inline-header='false' obligation='normative'>
      <title depth='2'>A.1.<tab/>Annex A.1</title>
      <clause id='Q1' inline-header='false' obligation='normative'>
        <title depth='3'>A.1.1.<tab/>Annex A.1a</title>
      </clause>
      <references id='Q2' normative='false'>
        <title depth='3'>A.1.2.<tab/>Annex Bibliography</title>
      </references>
    </clause>
  </annex>
  <annex id='P1' inline-header='false' obligation='normative'>
    <title><strong>Annex B</strong><br/>(normative)</title>
  </annex>
  <bibliography>
    <references id='R' obligation='informative' normative='true'>
    <title depth='1'>2.<tab/>Normative References</title>
    </references>
    <clause id='S' obligation='informative'>
      <title depth='1'>Bibliography</title>
      <references id='T' obligation='informative' normative='false'>
        <title depth="2">Bibliography Subsection</title>
      </references>
    </clause>
  </bibliography>
</iso-standard>
       PRESXML

       html = <<~"OUTPUT"
    #{HTML_HDR}
    <div class='authority'>
  <div class='boilerplate-copyright'>
    <div>
      <h1>Copyright</h1>
    </div>
  </div>
  <div class='boilerplate-license'>
    <div>
      <h1>License</h1>
    </div>
  </div>
  <div class='boilerplate-legal'>
    <div>
      <h1>Legal</h1>
    </div>
  </div>
  <div class='boilerplate-feedback'>
    <div>
      <h1>Feedback</h1>
    </div>
  </div>
</div>
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
                <br/>
<div class='Section3' id='B1'>
  <h1 class='IntroTitle'>Dedication</h1>
</div>
<br/>
<div class='Section3' id='B2'>
  <h1 class='IntroTitle'>Note to reader</h1>
</div>
                <br/>
<div class='Section3' id=''>
  <h1 class='IntroTitle'>Acknowledgements</h1>
</div>
                <p class="zzSTDTitle1"/>
                 <div id='NN1' class='Note'>
   <p>
   <span class='note_label'>NOTE</span>
     &#160; Initial note
   </p>
 </div>
 <div id='NN2' class='Admonition'>
   <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
   <p>Initial admonition</p>
 </div>
                <div id="D">
                  <h1>1.&#160; Scope</h1>
                  <p id="E">Text</p>
                </div>
                <div>
                  <h1>2.&#160; Normative References</h1>
                </div>
                <div id="H"><h1>3.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
        <div id="I">
           <h2>3.1.&#160; Normal Terms</h2>
           <p class="TermNum" id="J">3.1.1.</p>
           <p class="Terms" style="text-align:left;">Term2</p>
      
         </div><div id="K"><h2>3.2.&#160; Definitions</h2>
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
           <h2>5.1.&#160; Introduction</h2>
         </div>
                  <div id="O">
           <h2>5.2.&#160; Clause 4.2</h2>
         </div>
                  <div id="O1">
           <h2>5.3.</h2>
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
           <div><h3 class="Section3">A.1.2.&#160; Annex Bibliography</h3></div>
         </div>

                </div>
                 <br/>
 <div id='P1' class='Section3'>
   <h1 class='Annex'>
     <b>Annex B</b>
     <br/>
     (normative)
   </h1>
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

word = <<~"OUTPUT"
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
         <head><style/></head>
         <body lang="EN-US" link="blue" vlink="#954F72">
            <div class="WordSection1">
              <p>&#160;</p>
            </div>
            <p>
              <br clear="all" class="section"/>
            </p>
            <div class="WordSection2">
              <div class="authority">
            <div class="boilerplate-copyright">
              <div><h1>Copyright</h1>

              </div>
            </div>
            <div class="boilerplate-license">
              <div><h1>License</h1>

              </div>
            </div>
            <div class="boilerplate-legal">
              <div><h1>Legal</h1>

              </div>
            </div>
            <div class="boilerplate-feedback">
              <div><h1>Feedback</h1>

              </div>
            </div>
          </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div>
                <h1 class="AbstractTitle">Abstract</h1>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p id="A">This is a preamble</p>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3" id="B">
                <h1 class="IntroTitle">Introduction</h1>
                <div id="C"><h2>Introduction Subsection</h2>

              </div>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3" id="B1">
                <h1 class="IntroTitle">Dedication</h1>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3" id="B2">
                <h1 class="IntroTitle">Note to reader</h1>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3" id="">
                <h1 class="IntroTitle">Acknowledgements</h1>
              </div>
              <p>&#160;</p>
            </div>
            <p>
              <br clear="all" class="section"/>
            </p>
            <div class="WordSection3">
              <p class="zzSTDTitle1"/>
              <div id="NN1" class="Note">
                <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#160; </span>Initial note</p>
              </div>
              <div id="NN2" class="Admonition"><p class="AdmonitionTitle" style="text-align:center;">WARNING</p>
              <p>Initial admonition</p>
            </div>
              <div id="D">
                <h1>1.<span style="mso-tab-count:1">&#160; </span>Scope</h1>
                <p id="E">Text</p>
              </div>
              <div><h1>2.<span style="mso-tab-count:1">&#160; </span>Normative References</h1>

            </div>
              <div id="H">
                <h1>3.<span style="mso-tab-count:1">&#160; </span>Terms, Definitions, Symbols and Abbreviated Terms</h1>
                <div id="I"><h2>3.1.<span style="mso-tab-count:1">&#160; </span>Normal Terms</h2>

                <p class="TermNum" id="J">3.1.1.</p>

                  <p class="Terms" style="text-align:left;">Term2</p>

              </div>
                <div id="K"><h2>3.2.<span style="mso-tab-count:1">&#160; </span>Definitions</h2>

                <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
              </div>
              </div>
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
                <div id="N"><h2>5.1.<span style="mso-tab-count:1">&#160; </span>Introduction</h2>

              </div>
                <div id="O"><h2>5.2.<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>

              </div>
                <div id="O1"><h2>5.3.</h2>

              </div>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div id="P" class="Section3">
                <h1 class="Annex"> <b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b>
            </h1>
                <div id="Q"><h2>A.1.<span style="mso-tab-count:1">&#160; </span>Annex A.1</h2>

              <div id="Q1"><h3>A.1.1.<span style="mso-tab-count:1">&#160; </span>Annex A.1a</h3>

              </div>
              <div><h3 class="Section3">A.1.2.<span style="mso-tab-count:1">&#160; </span>Annex Bibliography</h3>

              </div>
            </div>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div id="P1" class="Section3">
                <h1 class="Annex"><b>Annex B</b><br/>(normative)</h1>
              </div>
              <p>
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div><h1 class="Section3">Bibliography</h1>

              <div><h2 class="Section3">Bibliography Subsection</h2>

              </div>
            </div>
            </div>
          </body>
        </html>
OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(word)
  end

  it "processes footnotes in section names" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<aside .*</aside>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <boilerplate>
        <copyright-statement>
        <clause>
          <title>Copyright<fn reference="1"><p>A</p></fn></title>
        </clause>
        </copyright-statement>
        <license-statement>
        <clause>
          <title>License<fn reference="2"><p>A</p></fn></title>
        </clause>
        </license-statement>
        <legal-statement>
        <clause>
          <title>Legal<fn reference="3"><p>A</p></fn></title>
        </clause>
        </legal-statement>
        <feedback-statement>
        <clause>
          <title>Feedback<fn reference="4"><p>A</p></fn></title>
        </clause>
        </feedback-statement>
      </boilerplate>
      <preface>
      <abstract obligation="informative">
         <title>Foreword<fn reference="5"><p>A</p></fn></title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword<fn reference="6"><p>A</p></fn></title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative">
        <title>Introduction<fn reference="7"><p>A</p></fn></title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">Introduction Subsection<fn reference="8"><p>A</p></fn></title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope<fn reference="9"><p>A</p></fn></title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative">
<title>Terms, Definitions, Symbols and Abbreviated Terms<fn reference="10"><p>A</p></fn></title><terms id="I" obligation="normative">
         <title depth="2">Normal Terms<fn reference="11"><p>A</p></fn></title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <title depth="2">Definitions<fn reference="12"><p>A</p></fn></title>
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
       <clause id="M" inline-header="false" obligation="normative">
        <title>Clause 4<fn reference="13"><p>A</p></fn></title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">Introduction<fn reference="13a"><p>A</p></fn></title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">Clause 4.2<fn reference="14"><p>A</p></fn></title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative"><title depth="2">5.3.</title>
       </clause>
        </clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex<fn reference="15"><p>A</p></fn></title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">Annex A.1<fn reference="16"><p>A</p></fn></title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">Annex A.1a<fn reference="17"><p>A</p></fn></title>
         </clause>
         <references id="Q2" normative="false"><title depth="3">Annex Bibliography<fn reference="18"><p>A</p></fn></title></references>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References<fn reference="19"><p>A</p></fn></title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography<fn reference="20"><p>A</p></fn></title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection<fn reference="21"><p>A</p></fn></title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
     <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
         <head/>
         <body lang='en'>
           <div class='title-section'>
             <p>&#160;</p>
           </div>
           <br/>
           <div class='prefatory-section'>
             <p>&#160;</p>
           </div>
           <br/>
           <div class='main-section'>
             <div class='authority'>
               <div class='boilerplate-copyright'>
                 <div>
                   <h1>
                     Copyright
                     <a class='FootnoteRef' href='#fn:1'>
                       <sup>1</sup>
                     </a>
                   </h1>
                 </div>
               </div>
               <div class='boilerplate-license'>
                 <div>
                   <h1>
                     License
                     <a class='FootnoteRef' href='#fn:2'>
                       <sup>2</sup>
                     </a>
                   </h1>
                 </div>
               </div>
               <div class='boilerplate-legal'>
                 <div>
                   <h1>
                     Legal
                     <a class='FootnoteRef' href='#fn:3'>
                       <sup>3</sup>
                     </a>
                   </h1>
                 </div>
               </div>
               <div class='boilerplate-feedback'>
                 <div>
                   <h1>
                     Feedback
                     <a class='FootnoteRef' href='#fn:4'>
                       <sup>4</sup>
                     </a>
                   </h1>
                 </div>
               </div>
             </div>
             <br/>
             <div>
               <h1 class='AbstractTitle'>Abstract</h1>
             </div>
             <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p id='A'>This is a preamble</p>
             </div>
             <br/>
             <div class='Section3' id='B'>
               <h1 class='IntroTitle'>Introduction</h1>
               <div id='C'>
                 <h2>
                   Introduction Subsection
                   <a class='FootnoteRef' href='#fn:8'>
                     <sup>8</sup>
                   </a>
                 </h2>
               </div>
             </div>
             <p class='zzSTDTitle1'/>
                          <div id='D'>
               <h1>
                 Scope
                 <a class='FootnoteRef' href='#fn:9'>
                   <sup>9</sup>
                 </a>
               </h1>
               <p id='E'>Text</p>
             </div>
             <div>
              <h1>
  Normative References
  <a class='FootnoteRef' href='#fn:19'>
    <sup>19</sup>
  </a>
</h1>
             </div>
             <div id='H'>
               <h1>
                 Terms, Definitions, Symbols and Abbreviated Terms
                 <a class='FootnoteRef' href='#fn:10'>
                   <sup>10</sup>
                 </a>
               </h1>
               <div id='I'>
                 <h2>
                   Normal Terms
                   <a class='FootnoteRef' href='#fn:11'>
                     <sup>11</sup>
                   </a>
                 </h2>
                 <p class='TermNum' id='J'/>
                 <p class='Terms' style='text-align:left;'>Term2</p>
               </div>
               <div id='K'>
                 <h2>
                   Definitions
                   <a class='FootnoteRef' href='#fn:12'>
                     <sup>12</sup>
                   </a>
                 </h2>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
             </div>
             <div id='L' class='Symbols'>
               <h1>Symbols and abbreviated terms</h1>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
             <div id='M'>
               <h1>
                 Clause 4
                 <a class='FootnoteRef' href='#fn:13'>
                   <sup>13</sup>
                 </a>
               </h1>
               <div id='N'>
                 <h2>
                   Introduction
                   <a class='FootnoteRef' href='#fn:13a'>
                     <sup>13a</sup>
                   </a>
                 </h2>
               </div>
               <div id='O'>
                 <h2>
                   Clause 4.2
                   <a class='FootnoteRef' href='#fn:14'>
                     <sup>14</sup>
                   </a>
                 </h2>
               </div>
               <div id='O1'>
                 <h2>5.3.</h2>
               </div>
             </div>
             <br/>
             <div id='P' class='Section3'>
               <h1 class='Annex'>
                   Annex
                   <a class='FootnoteRef' href='#fn:15'>
                     <sup>15</sup>
                   </a>
               </h1>
               <div id='Q'>
                 <h2>
                   Annex A.1
                   <a class='FootnoteRef' href='#fn:16'>
                     <sup>16</sup>
                   </a>
                 </h2>
                 <div id='Q1'>
                   <h3>
                     Annex A.1a
                     <a class='FootnoteRef' href='#fn:17'>
                       <sup>17</sup>
                     </a>
                   </h3>
                 </div>
                 <div>
                   <h3 class="Section3">
                     Annex Bibliography
                     <a class='FootnoteRef' href='#fn:18'>
                       <sup>18</sup>
                     </a>
                   </h3>
                 </div>
               </div>
             </div>
             <br/>
             <div>
             <h1 class='Section3'>Bibliography</h1>
             <div>
             <h2 class='Section3'>
  Bibliography Subsection
  <a class='FootnoteRef' href='#fn:21'>
    <sup>21</sup>
  </a>
</h2>
               </div>
             </div>
           </div>
         </body>
       </html>
OUTPUT
  end

    it "processes section names suppressing section numbering" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({suppressheadingnumbers: true}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       <clause id="D" obligation="normative" type="scope">
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
        <iso-standard xmlns='http://riboseinc.com/isoxml'>
          <preface>
            <foreword obligation='informative'>
              <title>Foreword</title>
              <p id='A'>This is a preamble</p>
            </foreword>
            <introduction id='B' obligation='informative'>
              <title>Introduction</title>
              <clause id='C' inline-header='false' obligation='informative'>
                <title depth="2">Introduction Subsection</title>
              </clause>
            </introduction>
          </preface>
          <sections>
            <clause id='D' obligation='normative' type="scope">
              <title depth="1">Scope</title>
              <p id='E'>Text</p>
            </clause>
            <clause id='H' obligation='normative'>
              <title depth="1">Terms, Definitions, Symbols and Abbreviated Terms</title>
              <terms id='I' obligation='normative'>
                <title depth="2">Normal Terms</title>
                <term id='J'>
                <name>3.1.1.</name>
                  <preferred>Term2</preferred>
                </term>
              </terms>
              <definitions id='K'>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </clause>
            <definitions id='L'>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id='M' inline-header='false' obligation='normative'>
              <title depth="1">Clause 4</title>
              <clause id='N' inline-header='false' obligation='normative'>
                <title depth="2">Introduction</title>
              </clause>
              <clause id='O' inline-header='false' obligation='normative'>
                <title depth="2">Clause 4.2</title>
              </clause>
              <clause id='O1' inline-header='false' obligation='normative'> </clause>
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
              <title depth="2">Annex A.1</title>
              <clause id='Q1' inline-header='false' obligation='normative'>
                <title depth="3">Annex A.1a</title>
              </clause>
            </clause>
          </annex>
          <bibliography>
            <references id='R' obligation='informative' normative='true'>
              <title depth="1">Normative References</title>
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

    it "processes section titles without ID" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({suppressheadingnumbers: true}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
       </preface>
       </iso-standard>
       INPUT
       <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <introduction id='B' obligation='informative'>
      <title>Introduction</title>
      <clause obligation='informative'>
        <title depth="1">Introduction Subsection</title>
      </clause>
    </introduction>
  </preface>
</iso-standard>
       OUTPUT
    end

    it "processes simple terms & definitions" do
      input = <<~"INPUT"
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

    presxml = <<~"OUTPUT"
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <sections>
    <terms id='H' obligation='normative'>
    <title depth='1'>1.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
      <term id='J'>
      <name>1.1.</name>
        <preferred>Term2</preferred>
      </term>
    </terms>
  </sections>
</iso-standard>
    OUTPUT

    html = <<~"OUTPUT"
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="H"><h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
       <p class="TermNum" id="J">1.1.</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
        expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

  it "processes inline section headers" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
         <p>ABC</p>
       </clause></clause>

       </sections>
      </iso-standard>
    INPUT

    presxml = <<~"PRESXML"
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <sections>
    <clause id='M' inline-header='false' obligation='normative'>
    <title depth='1'>1.<tab/>Clause 4</title>
      <clause id='N' inline-header='false' obligation='normative'>
       <title depth='2'>1.1.<tab/>Introduction</title>
      </clause>
      <clause id='O' inline-header='true' obligation='normative'>
       <title depth='2'>1.2.<tab/>Clause 4.2</title>
        <p>ABC</p>
      </clause>
    </clause>
  </sections>
</iso-standard>
PRESXML

output = <<~"OUTPUT"
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>1.&#160; Clause 4</h1>
                 <div id="N">
          <h2>1.1.&#160; Introduction</h2>
        </div>
                 <div id="O">
          <span class="zzMoveToFollowing"><b>1.2.&#160; Clause 4.2&#160; </b></span>
          <p>ABC</p>
        </div>
               </div>
             </div>
           </body>
       </html>
OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
    end

        it "processes inline section headers with suppressed heading numbering" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({suppressheadingnumbers: true}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <sections>
    <clause id='M' inline-header='false' obligation='normative'>
      <title depth="1">Clause 4</title>
      <clause id='N' inline-header='false' obligation='normative'>
        <title depth="2">Introduction</title>
      </clause>
      <clause id='O' inline-header='true' obligation='normative'>
        <title depth="2">Clause 4.2</title>
      </clause>
    </clause>
  </sections>
</iso-standard>
OUTPUT
    end

        it "processes sections without titles" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <introduction id='M' inline-header='false' obligation='normative'>
      <clause id='N' inline-header='false' obligation='normative'>
        <title depth="2">Intro</title>
      </clause>
      <clause id='O' inline-header='true' obligation='normative'> </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='M1' inline-header='false' obligation='normative'>
      <title>1.</title>
<clause id='N1' inline-header='false' obligation='normative'>
  <title>1.1.</title>
</clause>
<clause id='O1' inline-header='true' obligation='normative'>
  <title>1.2.</title>
</clause>
    </clause>
  </sections>
</iso-standard>
OUTPUT
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
<iso-standard xmlns="http://riboseinc.com/isoxml">
            <bibliography>
        <clause id="D" obligation="informative">
         <title depth="1">Bibliography</title>
         <references id="E" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection 1</title>
       </references>
         <references id="F" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection 2</title>
       </references>
       </clause>
       <clause id="A" obligation="informative"><title depth="1">1.<tab/>First References</title>
        <references id="B" obligation="informative" normative="true">
         <title depth="2">1.1.<tab/>Normative References 1</title>
       </references>
        <references id="C" obligation="informative" normative="false">
         <title depth="2">1.2.<tab/>Normative References 2</title>
       </references>
        </clause>

       </bibliography>
       </iso-standard>
OUTPUT

html = <<~OUTPUT
    #{HTML_HDR}
      <p class='zzSTDTitle1'/>
      <div>
        <h1>1.&#160; First References</h1>
        <div>
          <h2 class='Section3'>1.1.&#160; Normative References 1</h2>
        </div>
        <div>
          <h2 class='Section3'>1.2.&#160; Normative References 2</h2>
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
            expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
            expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
            end


end
