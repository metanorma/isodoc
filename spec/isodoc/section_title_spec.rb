require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section names" do
    input = <<~INPUT
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
         <title>Abstract</title>
      </abstract>
      <foreword obligation="informative">
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
        <admonition id="NN2" type="warning">
        <name>WARNING</name>
        <p>Initial admonition</p></admonition>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
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
       <indexsect id="INDX">
       <title>Index</title>
       </indexsect>
       <colophon>
      <clause id="U1" obligation="informative">
         <title>Postface 1</title>
      </clause>
      <clause id="U2" obligation="informative">
         <title>Postface 2</title>
      </clause>
      </colophon>
       </iso-standard>
    INPUT

    presxml = <<~PRESXML
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <boilerplate>
             <copyright-statement>
                <clause>
                   <title id="_">Copyright</title>
                   <fmt-title depth="1">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Copyright</semx>
                      </span>
                   </fmt-title>
                </clause>
             </copyright-statement>
             <license-statement>
                <clause>
                   <title id="_">License</title>
                   <fmt-title depth="1">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">License</semx>
                      </span>
                   </fmt-title>
                </clause>
             </license-statement>
             <legal-statement>
                <clause>
                   <title id="_">Legal</title>
                   <fmt-title depth="1">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Legal</semx>
                      </span>
                   </fmt-title>
                </clause>
             </legal-statement>
             <feedback-statement>
                <clause>
                   <title id="_">Feedback</title>
                   <fmt-title depth="1">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Feedback</semx>
                      </span>
                   </fmt-title>
                </clause>
             </feedback-statement>
          </boilerplate>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <abstract obligation="informative" displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Abstract</semx>
                   </span>
                </fmt-title>
             </abstract>
             <foreword obligation="informative" displayorder="3">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Foreword</semx>
                   </span>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="4">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Introduction</semx>
                   </span>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction Subsection</semx>
                      </span>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="B1" displayorder="5">
                <title id="_">Dedication</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Dedication</semx>
                   </span>
                </fmt-title>
             </clause>
             <clause id="B2" displayorder="6">
                <title id="_">Note to reader</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Note to reader</semx>
                   </span>
                </fmt-title>
             </clause>
             <acknowledgements obligation="informative" displayorder="7">
                <title id="_">Acknowledgements</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Acknowledgements</semx>
                   </span>
                </fmt-title>
             </acknowledgements>
          </preface>
          <sections>
             <note id="NN1" displayorder="8">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">NOTE</span>
                   </span>
                </fmt-name>
                <p>Initial note</p>
             </note>
             <admonition id="NN2" type="warning" displayorder="9">
                <name id="_">WARNING</name>
                <fmt-name>
                   <span class="fmt-caption-label">
                      <semx element="name" source="_">WARNING</semx>
                   </span>
                </fmt-name>
                <p>Initial admonition</p>
             </admonition>
             <clause id="D" obligation="normative" type="scope" displayorder="10">
                <title id="_">Scope</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Scope</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="12">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="H">3</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="I">3.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Normal Terms</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="I">3.1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="J">3.1.1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="J">3.1.1</semx>
                      </fmt-xref-label>
                      <preferred>
                         <strong>Term2</strong>
                      </preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Symbols</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="K">3.2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Symbols</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="K">3.2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="13">
                <title id="_">Symbols and abbreviated terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Symbols and abbreviated terms</semx>
                   </span>
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
             <clause id="M" inline-header="false" obligation="normative" displayorder="14">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="N">5.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Introduction</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="N">5.1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="O">5.2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Clause 4.2</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="O">5.2</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O1" inline-header="false" obligation="normative">
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="O1">5.3</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="O1">5.3</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="11">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normative References</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="15">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
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
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="Q">A.1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="Q">A.1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="Q1">A.1.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Annex A.1a</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Q1">A.1.1</semx>
                   </fmt-xref-label>
                </clause>
                <references id="Q2" normative="false" autonum="A.1.2">
                   <title id="_">Annex Bibliography</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="Q2">A.1.2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Annex Bibliography</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Q2">A.1.2</semx>
                   </fmt-xref-label>
                </references>
             </clause>
          </annex>
          <annex id="P1" inline-header="false" obligation="normative" autonum="B" displayorder="16">
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P1">B</semx>
                   </strong>
                   <br/>
                   <span class="fmt-obligation">(normative)</span>
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P1">B</semx>
             </fmt-xref-label>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="17">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Bibliography</semx>
                   </span>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Bibliography Subsection</semx>
                      </span>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
          <colophon>
             <clause id="U1" obligation="informative" displayorder="18">
                <title id="_">Postface 1</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Postface 1</semx>
                   </span>
                </fmt-title>
             </clause>
             <clause id="U2" obligation="informative" displayorder="19">
                <title id="_">Postface 2</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Postface 2</semx>
                   </span>
                </fmt-title>
             </clause>
          </colophon>
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
                           <p class="Terms" style="text-align:left;"><b>Term2</b></p>
                         </div><div id="K"><h2>3.2.&#160; Symbols</h2>
                         <div class="figdl">
                           <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
                           </div>
                         </div></div>
                                <div id="L" class="Symbols">
                                  <h1>4.&#160; Symbols and abbreviated terms</h1>
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
                                               <br/>
      <div class="Section3" id="U1">
        <h1 class="IntroTitle">Postface 1</h1>
      </div>
      <div class="Section3" id="U2">
        <h1 class="IntroTitle">Postface 2</h1>
      </div>
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
          <p class="section-break">
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
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
                  <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div>
              <h1 class="AbstractTitle">Abstract</h1>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C"><h2>Introduction Subsection</h2>
            </div>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="B1">
              <h1 class="IntroTitle">Dedication</h1>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="B2">
              <h1 class="IntroTitle">Note to reader</h1>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="">
              <h1 class="IntroTitle">Acknowledgements</h1>
            </div>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
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
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
            </div>
              <div id="K"><h2>3.2.<span style="mso-tab-count:1">&#160; </span>Symbols</h2>
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
            <p class="page-break">
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
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div id="P1" class="Section3">
              <h1 class="Annex"><b>Annex B</b><br/>(normative)</h1>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div><h1 class="Section3">Bibliography</h1>
            <div><h2 class="Section3">Bibliography Subsection</h2>
            </div>
          </div>
                <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
      <div class="Section3" id="U1">
        <h1 class="IntroTitle">Postface 1</h1>
      </div>
      <div class="Section3" id="U2">
        <h1 class="IntroTitle">Postface 2</h1>
      </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes section subtitles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract obligation="informative">
         <title>Abstract</title>
         <variant-title type="sub">Variant 1</variant-title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <variant-title type="sub">Variant 1</variant-title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title>
        <clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
         <variant-title type="sub">Variant 1</variant-title>
       </clause>
       </introduction>
       <clause id="B1"><title>Dedication</title>
         <variant-title type="sub">Variant 1</variant-title>
      </clause>
       <clause id="B2"><title>Note to reader</title>
         <variant-title type="sub">Variant 1</variant-title>
       </clause>
       <acknowledgements obligation="informative">
         <title>Acknowledgements</title>
         <variant-title type="sub">Variant 1</variant-title>
       </acknowledgements>
        </preface><sections>
        <note id="NN1"><p>Initial note</p></note>
        <admonition id="NN2" type="warning"><p>Initial admonition</p></admonition>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <variant-title type="sub">Variant 1</variant-title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <variant-title type="sub">Variant 1</variant-title>
       <terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <variant-title type="sub">Variant 1</variant-title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K">
         <title>Definitions</title>
         <variant-title type="sub">Variant 1</variant-title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L">
       <title>Symbols and abbreviated terms</title>
         <variant-title type="sub">Variant 1</variant-title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative">
        <title>Clause 4</title>
         <variant-title type="sub">Variant 1</variant-title>
        <clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
         <variant-title type="sub">Variant 1</variant-title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
         <variant-title type="sub">Variant 1</variant-title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>
       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <variant-title type="sub">Variant 1</variant-title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <variant-title type="sub">Variant 1</variant-title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         <variant-title type="sub">Variant 1</variant-title>
         </clause>
         <references id="Q2" normative="false">
        <title>Annex Bibliography</title>
         <variant-title type="sub">Variant 1</variant-title>
        </references>
       </clause>
       </annex>
       <annex id="P1" inline-header="false" obligation="normative">
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
         <variant-title type="sub">Variant 1</variant-title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <variant-title type="sub">Variant 1</variant-title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
         <variant-title type="sub">Variant 1</variant-title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
          <html lang='en'>
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
            <br/>
            <div class="TOC" id="_">
            <h1 class="IntroTitle">Table of contents</h1>
          </div>
          <br/>
            <div>
              <h1 class='AbstractTitle'>
                Abstract
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <br/>
            <div>
              <h1 class='ForewordTitle'>
                Foreword
                <br/>
                <br/>
                Variant 1
              </h1>
              <p id='A'>This is a preamble</p>
            </div>
            <br/>
            <div class='Section3' id='B'>
              <h1 class='IntroTitle'>Introduction</h1>
              <div id='C'>
                <h2>
                  Introduction Subsection
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
            </div>
            <br/>
            <div class='Section3' id='B1'>
              <h1 class='IntroTitle'>
                Dedication
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <br/>
            <div class='Section3' id='B2'>
              <h1 class='IntroTitle'>
                Note to reader
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <br/>
            <div class='Section3' id=''>
              <h1 class='IntroTitle'>
                Acknowledgements
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
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
            <div id='D'>
              <h1>
                1.&#160; Scope
                <br/>
                <br/>
                Variant 1
              </h1>
              <p id='E'>Text</p>
            </div>
            <div>
              <h1>
                2.&#160; Normative References
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <div id='H'>
              <h1>
                3.&#160; Terms, Definitions, Symbols and Abbreviated Terms
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='I'>
                <h2>
                  3.1.&#160; Normal Terms
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <p class='TermNum' id='J'>3.1.1.</p>
                <p class='Terms' style='text-align:left;'><b>Term2</b></p>
              </div>
              <div id='K'>
                <h2>
                  3.2.&#160; Definitions
                  <br/>
                  <br/>
                  Variant 1
                </h2>
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
              <h1>
                4.&#160; Symbols and abbreviated terms
                <br/>
                <br/>
                Variant 1
              </h1>
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
              <h1>
                5.&#160; Clause 4
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='N'>
                <h2>
                  5.1.&#160; Introduction
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
              <div id='O'>
                <h2>
                  5.2.&#160; Clause 4.2
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
              <div id='O1'>
                <h2>5.3.</h2>
              </div>
            </div>
            <br/>
            <div id='P' class='Section3'>
              <h1 class='Annex'>
                <b>Annex A</b>
                <br/>
                (normative)
                <br/>
                <br/>
                <b>Annex</b>
                <br/>
                <br/>
                Variant 1
              </h1>
              <p style='display:none;' class='variant-title-sub'>Variant 1</p>
              <div id='Q'>
                <h2>
                  A.1.&#160; Annex A.1
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <div id='Q1'>
                  <h3>
                    A.1.1.&#160; Annex A.1a
                    <br/>
                    <br/>
                    Variant 1
                  </h3>
                </div>
                <div>
                  <h3 class='Section3'>
                    A.1.2.&#160; Annex Bibliography
                    <br/>
                    <br/>
                    Variant 1
                  </h3>
                </div>
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
              <h1 class='Section3'>Bibliography</h1>
              <p style='display:none;' class='variant-title-sub'>Variant 1</p>
              <div>
                <h2 class='Section3'>
                  Bibliography Subsection
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
          <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
        <head>
          <style>
          </style>
        </head>
        <body lang='EN-US' link='blue' vlink='#954F72'>
          <div class='WordSection1'>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
                  <div class="TOC" id="_">
        <p class="zzContents">Table of contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
      <div>
              <h1 class='AbstractTitle'>
                Abstract
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='ForewordTitle'>
                Foreword
                <br/>
                <br/>
                Variant 1
              </h1>
              <p id='A'>This is a preamble</p>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div class='Section3' id='B'>
              <h1 class='IntroTitle'>Introduction</h1>
              <div id='C'>
                <h2>
                  Introduction Subsection
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div class='Section3' id='B1'>
              <h1 class='IntroTitle'>
                Dedication
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div class='Section3' id='B2'>
              <h1 class='IntroTitle'>
                Note to reader
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div class='Section3' id=''>
              <h1 class='IntroTitle'>
                Acknowledgements
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <div id='NN1' class='Note'>
              <p class='Note'>
                <span class='note_label'>NOTE</span>
                <span style='mso-tab-count:1'>&#160; </span>
                Initial note
              </p>
            </div>
            <div id='NN2' class='Admonition'>
              <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
              <p>Initial admonition</p>
            </div>
            <div id='D'>
              <h1>
                1.
                <span style='mso-tab-count:1'>&#160; </span>
                Scope
                <br/>
                <br/>
                Variant 1
              </h1>
              <p id='E'>Text</p>
            </div>
            <div>
              <h1>
                2.
                <span style='mso-tab-count:1'>&#160; </span>
                Normative References
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <div id='H'>
              <h1>
                3.
                <span style='mso-tab-count:1'>&#160; </span>
                Terms, Definitions, Symbols and Abbreviated Terms
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='I'>
                <h2>
                  3.1.
                  <span style='mso-tab-count:1'>&#160; </span>
                  Normal Terms
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <p class='TermNum' id='J'>3.1.1.</p>
                <p class='Terms' style='text-align:left;'><b>Term2</b></p>
              </div>
              <div id='K'>
                <h2>
                  3.2.
                  <span style='mso-tab-count:1'>&#160; </span>
                  Definitions
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <table class='dl'>
                  <tr>
                    <td valign='top' align='left'>
                      <p align='left' style='margin-left:0pt;text-align:left;'>Symbol</p>
                    </td>
                    <td valign='top'>Definition</td>
                  </tr>
                </table>
              </div>
            </div>
            <div id='L' class='Symbols'>
              <h1>
                4.
                <span style='mso-tab-count:1'>&#160; </span>
                Symbols and abbreviated terms
                <br/>
                <br/>
                Variant 1
              </h1>
              <table class='dl'>
                <tr>
                  <td valign='top' align='left'>
                    <p align='left' style='margin-left:0pt;text-align:left;'>Symbol</p>
                  </td>
                  <td valign='top'>Definition</td>
                </tr>
              </table>
            </div>
            <div id='M'>
              <h1>
                5.
                <span style='mso-tab-count:1'>&#160; </span>
                Clause 4
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='N'>
                <h2>
                  5.1.
                  <span style='mso-tab-count:1'>&#160; </span>
                  Introduction
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
              <div id='O'>
                <h2>
                  5.2.
                  <span style='mso-tab-count:1'>&#160; </span>
                  Clause 4.2
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
              <div id='O1'>
                <h2>5.3.</h2>
              </div>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div id='P' class='Section3'>
              <h1 class='Annex'>
                <b>Annex A</b>
                <br/>
                (normative)
                <br/>
                <br/>
                <b>Annex</b>
                <br/>
                <br/>
                Variant 1
              </h1>
              <p style='display:none;' class='variant-title-sub'>Variant 1</p>
              <div id='Q'>
                <h2>
                  A.1.
                  <span style='mso-tab-count:1'>&#160; </span>
                  Annex A.1
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <div id='Q1'>
                  <h3>
                    A.1.1.
                    <span style='mso-tab-count:1'>&#160; </span>
                    Annex A.1a
                    <br/>
                    <br/>
                    Variant 1
                  </h3>
                </div>
                <div>
                  <h3 class='Section3'>
                    A.1.2.
                    <span style='mso-tab-count:1'>&#160; </span>
                    Annex Bibliography
                    <br/>
                    <br/>
                    Variant 1
                  </h3>
                </div>
              </div>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div id='P1' class='Section3'>
              <h1 class='Annex'>
                <b>Annex B</b>
                <br/>
                (normative)
              </h1>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div>
              <h1 class='Section3'>Bibliography</h1>
              <p style='display:none;' class='variant-title-sub'>Variant 1</p>
              <div>
                <h2 class='Section3'>
                  Bibliography Subsection
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    presxml = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes section names suppressing section numbering" do
    input = <<~INPUT
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
    output = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword obligation="informative" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Foreword</semx>
                   </span>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Introduction</semx>
                   </span>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction Subsection</semx>
                      </span>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Scope</semx>
                   </span>
                </fmt-title>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                   </span>
                </fmt-title>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Normal Terms</semx>
                      </span>
                   </fmt-title>
                   <term id="J">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="J">3.1.1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="J">3.1.1</semx>
                      </fmt-xref-label>
                      <preferred>
                         <strong>Term2</strong>
                      </preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Symbols</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Symbols</semx>
                      </span>
                   </fmt-title>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="7">
                <title id="_">Symbols</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Symbols</semx>
                   </span>
                </fmt-title>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Clause 4</semx>
                   </span>
                </fmt-title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction</semx>
                      </span>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Clause 4.2</semx>
                      </span>
                   </fmt-title>
                </clause>
                <clause id="O1" inline-header="false" obligation="normative">
        </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Normative References</semx>
                   </span>
                </fmt-title>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <semx element="title" source="_">
                      <strong>Annex</strong>
                   </semx>
                </span>
             </fmt-title>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Annex A.1</semx>
                   </span>
                </fmt-title>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Annex A.1a</semx>
                      </span>
                   </fmt-title>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Bibliography</semx>
                   </span>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Bibliography Subsection</semx>
                      </span>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes unnumbered section names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <clause id="D" obligation="normative" type="scope" unnumbered="true">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative" unnumbered="true"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K" unnumbered="true">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L" unnumbered="true">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" unnumbered="true"><title>Clause 4</title>
        <clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
        </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause>
        </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
       <clause id="O2" inline-header="false" obligation="normative" unnumbered="true">
       </clause>
       <clause id="O3" inline-header="false" obligation="normative">
       </clause>

       </sections><annex id="P" inline-header="false" obligation="normative" unnumbered="true">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true" unnumbered="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative" unnumbered="true">
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="D" obligation="normative" type="scope" unnumbered="true" displayorder="2">
                <title id="_">Scope</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Scope</semx>
                   </span>
                </fmt-title>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" unnumbered="true" displayorder="4">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                   </span>
                </fmt-title>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Normal Terms</semx>
                      </span>
                   </fmt-title>
                   <term id="J">
                      <preferred>
                         <strong>Term2</strong>
                      </preferred>
                   </term>
                </terms>
                <definitions id="K" unnumbered="true">
                   <title id="_">Symbols</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Symbols</semx>
                      </span>
                   </fmt-title>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" unnumbered="true" displayorder="5">
                <title id="_">Symbols</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Symbols</semx>
                   </span>
                </fmt-title>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" unnumbered="true" displayorder="6">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Clause 4</semx>
                   </span>
                </fmt-title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction</semx>
                      </span>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Clause 4.2</semx>
                      </span>
                   </fmt-title>
                </clause>
             </clause>
             <clause id="O1" inline-header="false" obligation="normative" displayorder="7">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="O1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="O1">1</semx>
                </fmt-xref-label>
             </clause>
             <clause id="O2" inline-header="false" obligation="normative" unnumbered="true" displayorder="8">
        </clause>
             <clause id="O3" inline-header="false" obligation="normative" displayorder="9">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="O3">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="O3">2</semx>
                </fmt-xref-label>
             </clause>
             <references id="R" obligation="informative" normative="true" unnumbered="true" displayorder="3">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Normative References</semx>
                   </span>
                </fmt-title>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" unnumbered="true" displayorder="10">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <semx element="title" source="_">
                      <strong>Annex</strong>
                   </semx>
                </span>
             </fmt-title>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Annex A.1</semx>
                   </span>
                </fmt-title>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Annex A.1a</semx>
                      </span>
                   </fmt-title>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" unnumbered="true" displayorder="11">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Bibliography</semx>
                   </span>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Bibliography Subsection</semx>
                      </span>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes floating titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
        <floating-title depth="1">A0</p>
        <introduction id="B" obligation="informative">
        <title>Introduction</title>
        <floating-title depth="1">A</p>
        <clause id="B1" obligation="informative">
         <title>Introduction Subsection</title>
        <floating-title depth="2">B</p>
        <clause id="B2" obligation="informative">
         <title>Introduction Sub-subsection</title>
        <floating-title depth="1">C</p>
       </clause>
       </clause>
       </introduction>
       </preface>
       <sections>
        <clause id="C" obligation="informative">
        <title>Introduction</title>
        <floating-title depth="1">A</p>
        <clause id="C1" obligation="informative">
         <title>Introduction Subsection</title>
        <floating-title depth="2">B</p>
        <clause id="C2" obligation="informative">
         <title>Introduction Sub-subsection</title>
        <floating-title depth="1">C</p>
       </clause>
       </clause>
       </clause>
        <floating-title depth="1">D</p>
       <clause id="C4"><title>Clause 2</title></clause>
       </sections>
       </iso-standard>
    INPUT

    presxml = <<~PRESXML
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <p depth="1" type="floating-title" displayorder="2">A0</p>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Introduction</semx>
                   </span>
                </fmt-title>
                <p depth="1" type="floating-title">A</p>
                <clause id="B1" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction Subsection</semx>
                      </span>
                   </fmt-title>
                   <p depth="2" type="floating-title">B</p>
                   <clause id="B2" obligation="informative">
                      <title id="_">Introduction Sub-subsection</title>
                      <fmt-title depth="3">
                         <span class="fmt-caption-label">
                            <semx element="title" source="_">Introduction Sub-subsection</semx>
                         </span>
                      </fmt-title>
                      <p depth="1" type="floating-title">C</p>
                   </clause>
                </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="C" obligation="informative" displayorder="4">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">1</semx>
                </fmt-xref-label>
                <p depth="1" type="floating-title">A</p>
                <clause id="C1" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="C1">1.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Introduction Subsection</semx>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="C1">1.1</semx>
                   </fmt-xref-label>
                   <p depth="2" type="floating-title">B</p>
                   <clause id="C2" obligation="informative">
                      <title id="_">Introduction Sub-subsection</title>
                      <fmt-title depth="3">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="C2">1.1.1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <span class="fmt-caption-delim">
                               <tab/>
                            </span>
                            <semx element="title" source="_">Introduction Sub-subsection</semx>
                         </span>
                      </fmt-title>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="C2">1.1.1</semx>
                      </fmt-xref-label>
                      <p depth="1" type="floating-title">C</p>
                   </clause>
                </clause>
             </clause>
             <p depth="1" type="floating-title" displayorder="5">D</p>
             <clause id="C4" displayorder="6">
                <title id="_">Clause 2</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C4">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 2</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C4">2</semx>
                </fmt-xref-label>
             </clause>
          </sections>
       </iso-standard>
    PRESXML

    html = <<~OUTPUT
      #{HTML_HDR}
             <p class='h1'>A0</p>
             <br/>
             <div class='Section3' id='B'>
               <h1 class='IntroTitle'>Introduction</h1>
               <p class='h1'>A</p>
               <div id='B1'>
                 <h2>Introduction Subsection</h2>
                 <p class='h2'>B</p>
                 <div id='B2'>
                   <h3>Introduction Sub-subsection</h3>
                   <p class='h1'>C</p>
                 </div>
               </div>
             </div>
                   <div id='C'>
        <h1>1.&#160; Introduction</h1>
        <p class='h1'>A</p>
        <div id='C1'>
          <h2>1.1.&#160; Introduction Subsection</h2>
          <p class='h2'>B</p>
          <div id='C2'>
            <h3>1.1.1.&#160; Introduction Sub-subsection</h3>
            <p class='h1'>C</p>
          </div>
        </div>
      </div>
      <p class='h1'>D</p>
      <div id='C4'>
        <h1>2.&#160; Clause 2</h1>
      </div>
           </div>
         </body>
       </html>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
              <div class="WordSection2"><p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <p class="h1">A0</p>
              <div class="Section3"><a name="B" id="B"/><h1 class="IntroTitle">Introduction</h1><p class="h1">A</p><div><a name="B1" id="B1"/><h2>Introduction Subsection</h2><p class="h2">B</p><div><a name="B2" id="B2"/><h3>Introduction Sub-subsection</h3><p class="h1">C</p></div></div></div><p class="MsoNormal"> </p></div><p class="MsoNormal"><br clear="all" class="section"/></p><div class="WordSection3"><div><a name="C" id="C"/><h1>
               1.
               <span style="mso-tab-count:1">  </span>
               Introduction
             </h1><p class="h1">A</p><div><a name="C1" id="C1"/><h2>
                 1.1.
                 <span style="mso-tab-count:1">  </span>
                 Introduction Subsection
               </h2><p class="h2">B</p><div><a name="C2" id="C2"/><h3>
                   1.1.1.
                   <span style="mso-tab-count:1">  </span>
                   Introduction Sub-subsection
                 </h3><p class="h1">C</p></div></div></div><p class="h1">D</p><div><a name="C4" id="C4"/><h1>
               2.
               <span style="mso-tab-count:1">  </span>
               Clause 2
             </h1></div></div><div style="mso-element:footnote-list"/>
         </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(Xml::C14n.format(File.read("test.doc")
    .sub(/^.*<body/m, "<body")
    .sub(%r{</body>.*$}m, "")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes section titles without ID" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
       </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <introduction id="B" obligation="informative" displayorder="2">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Introduction</semx>
                   </span>
                </fmt-title>
                <clause obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="1">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction Subsection</semx>
                      </span>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes inline section headers" do
    input = <<~INPUT
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

    presxml = <<~PRESXML
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
        </preface>
        <sections>
          <clause id='M' inline-header='false' obligation='normative' displayorder="2">
                   <title id="_">Clause 4</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="M">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Clause 4</semx>
            </span>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="M">1</semx>
         </fmt-xref-label>
            <clause id='N' inline-header='false' obligation='normative'>
            <title id="_">Introduction</title>
           <fmt-title depth="2">
              <span class="fmt-caption-label">
                 <semx element="autonum" source="N">1.1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <span class="fmt-caption-delim">
                    <tab/>
                 </span>
                 <semx element="title" source="_">Introduction</semx>
              </span>
           </fmt-title>
           <fmt-xref-label>
              <span class="fmt-element-name">Clause</span>
              <semx element="autonum" source="N">1.1</semx>
           </fmt-xref-label>
            </clause>
            <clause id='O' inline-header='true' obligation='normative'>
            <title id="_">Clause 4.2</title>
            <fmt-title depth="2">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="O">1.2</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4.2</semx>
               </span>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="O">1.2</semx>
            </fmt-xref-label>
              <p>ABC</p>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
      #{HTML_HDR}
                   <div id="M">
                     <h1>1.&#160; Clause 4</h1>
                     <div id="N">
              <h2>1.1.&#160; Introduction</h2>
            </div>
                     <div id="O">
              <span class="zzMoveToFollowing inline-header"><b>1.2.&#160; Clause 4.2&#160; </b></span>
              <p>ABC</p>
            </div>
                   </div>
                 </div>
               </body>
           </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes inline section headers with suppressed heading numbering" do
    input = <<~INPUT
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="M" inline-header="false" obligation="normative" displayorder="2">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="title" source="_">Clause 4</semx>
                   </span>
                </fmt-title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Introduction</semx>
                      </span>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="true" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Clause 4.2</semx>
                      </span>
                   </fmt-title>
                </clause>
             </clause>
          </sections>
       </iso-standard>
      OUTPUT
  end

  it "processes sections without titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
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
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <introduction id="M" inline-header="false" obligation="normative" displayorder="2">
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Intro</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="title" source="_">Intro</semx>
                      </span>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="true" obligation="normative">
        </clause>
             </introduction>
          </preface>
          <sections>
             <clause id="M1" inline-header="false" obligation="normative" displayorder="3">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="M1">1</semx>
                </fmt-xref-label>
                <clause id="N1" inline-header="false" obligation="normative">
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="N1">1.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="N1">1.1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O1" inline-header="true" obligation="normative">
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="O1">1.2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="O1">1.2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes disconnected titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <clause id="A1" displayorder="1">
           <clause id="A2">
           <clause id="A3">
           <cross-align>
           <align-cell>
           <title>Title</title>
           <p>Para</p>
           </align-cell>
           <align-cell>
           <title>Iitre</title>
           <p>Alinée</p>
           </align-cell>
           </cross-align>
           </clause>
           </clause>
           </clause>
           </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
           <div class="title-section">
             <p> </p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p> </p>
           </div>
           <br/>
                      <div class="main-section">
             <div id="A1">
               <h1/>
               <div id="A2">
                 <div id="A3">
                   <table>
                     <tbody>
                       <td>
                         <h3>Title</h3>
                         <p>Para</p>
                       </td>
                       <td>
                         <h3>Iitre</h3>
                         <p>Alinée</p>
                       </td>
                     </tbody>
                   </table>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
