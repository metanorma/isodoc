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
       <executivesummary obligation="informative">
         <title>Executive Summary</title>
       </executivesummary>
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
               <clause id="_">
                  <title id="_">Copyright</title>
                  <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Copyright</semx>
                  </fmt-title>
               </clause>
            </copyright-statement>
            <license-statement>
               <clause id="_">
                  <title id="_">License</title>
                  <fmt-title id="_" depth="1">
                     <semx element="title" source="_">License</semx>
                  </fmt-title>
               </clause>
            </license-statement>
            <legal-statement>
               <clause id="_">
                  <title id="_">Legal</title>
                  <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Legal</semx>
                  </fmt-title>
               </clause>
            </legal-statement>
            <feedback-statement>
               <clause id="_">
                  <title id="_">Feedback</title>
                  <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Feedback</semx>
                  </fmt-title>
               </clause>
            </feedback-statement>
         </boilerplate>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <abstract obligation="informative" id="_" displayorder="2">
               <title id="_">Abstract</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Abstract</semx>
               </fmt-title>
            </abstract>
            <foreword obligation="informative" id="_" displayorder="3">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="4">
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
            <clause id="B1" displayorder="5">
               <title id="_">Dedication</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Dedication</semx>
               </fmt-title>
            </clause>
            <clause id="B2" displayorder="6">
               <title id="_">Note to reader</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Note to reader</semx>
               </fmt-title>
            </clause>
            <acknowledgements obligation="informative" id="_" displayorder="7">
               <title id="_">Acknowledgements</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Acknowledgements</semx>
               </fmt-title>
            </acknowledgements>
            <executivesummary obligation="informative" id="_" displayorder="8">
               <title id="_">Executive Summary</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Executive Summary</semx>
               </fmt-title>
            </executivesummary>
         </preface>
         <sections>
            <note id="NN1" displayorder="9">
               <fmt-name id="_">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">NOTE</span>
                  </span>
                  <span class="fmt-label-delim">
                     <tab/>
                  </span>
               </fmt-name>
               <p>Initial note</p>
            </note>
            <admonition id="NN2" type="warning" displayorder="10">
               <name id="_">WARNING</name>
               <fmt-name id="_">
                  <semx element="name" source="_">WARNING</semx>
               </fmt-name>
               <p>Initial admonition</p>
            </admonition>
            <clause id="D" obligation="normative" type="scope" displayorder="11">
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
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="13">
               <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
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
            <definitions id="L" displayorder="14">
               <title id="_">Symbols and abbreviated terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symbols and abbreviated terms</semx>
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
            <clause id="M" inline-header="false" obligation="normative" displayorder="15">
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
               <clause id="O1" inline-header="false" obligation="normative">
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O1">3</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O1">3</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" obligation="informative" normative="true" displayorder="12">
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
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="16">
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
               <references id="Q2" normative="false" autonum="A.1.2">
                  <title id="_">Annex Bibliography</title>
                  <fmt-title id="_" depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="P">A</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q2">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex Bibliography</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q2">2</semx>
                  </fmt-xref-label>
               </references>
            </clause>
         </annex>
         <annex id="P1" inline-header="false" obligation="normative" autonum="B" displayorder="17">
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P1">B</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(normative)</span>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P1">B</semx>
            </fmt-xref-label>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="18">
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
         <colophon>
            <clause id="U1" obligation="informative" displayorder="19">
               <title id="_">Postface 1</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Postface 1</semx>
               </fmt-title>
            </clause>
            <clause id="U2" obligation="informative" displayorder="20">
               <title id="_">Postface 2</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Postface 2</semx>
               </fmt-title>
            </clause>
         </colophon>
      </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
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
               <div class="authority">
                  <div class="boilerplate-copyright">
                     <div id="_">
                        <h1>Copyright</h1>
                     </div>
                  </div>
                  <div class="boilerplate-license">
                     <div id="_">
                        <h1>License</h1>
                     </div>
                  </div>
                  <div class="boilerplate-legal">
                     <div id="_">
                        <h1>Legal</h1>
                     </div>
                  </div>
                  <div class="boilerplate-feedback">
                     <div id="_">
                        <h1>Feedback</h1>
                     </div>
                  </div>
               </div>
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <br/>
               <div id="_">
                  <h1 class="AbstractTitle">Abstract</h1>
               </div>
               <br/>
               <div id="_">
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
               <div id="B1" class="Section3">
                  <h1 class="IntroTitle">Dedication</h1>
               </div>
               <br/>
               <div id="B2" class="Section3">
                  <h1 class="IntroTitle">Note to reader</h1>
               </div>
               <br/>
               <div class="Section3" id="_">
                  <h1 class="IntroTitle">Acknowledgements</h1>
               </div>
               <br/>
               <div class="Section3" id="_">
                  <h1 class="IntroTitle">Executive Summary</h1>
               </div>
               <div id="NN1" class="Note">
                  <p>
                     <span class="note_label">NOTE\u00a0 </span>
                     Initial note
                  </p>
               </div>
               <div id="NN2" class="Admonition">
                  <p class="AdmonitionTitle" style="text-align:center;">WARNING</p>
                  <p>Initial admonition</p>
               </div>
               <div id="D">
                  <h1>1.\u00a0 Scope</h1>
                  <p id="E">Text</p>
               </div>
               <div>
                  <h1>2.\u00a0 Normative References</h1>
               </div>
               <div id="H">
                  <h1>3.\u00a0 Terms, Definitions, Symbols and Abbreviated Terms</h1>
                  <div id="I">
                     <h2>3.1.\u00a0 Normal Terms</h2>
                     <p class="TermNum" id="J">3.1.1.</p>
                     <p class="Terms" style="text-align:left;">
                        <b>Term2</b>
                     </p>
                  </div>
                  <div id="K">
                     <h2>3.2.\u00a0 Symbols</h2>
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
               <div id="L" class="Symbols">
                  <h1>4.\u00a0 Symbols and abbreviated terms</h1>
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
                  </div>
                  <div id="O">
                     <h2>5.2.\u00a0 Clause 4.2</h2>
                  </div>
                  <div id="O1">
                     <h2>5.3.</h2>
                  </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                  <h1 class="Annex">
                     <b>Annex A</b>
                     <br/>
                     (normative)
                     <br/>
                     <br/>
                     <b>Annex</b>
                  </h1>
                  <div id="Q">
                     <h2>A.1.\u00a0 Annex A.1</h2>
                     <div id="Q1">
                        <h3>A.1.1.\u00a0 Annex A.1a</h3>
                     </div>
                     <div>
                        <h3 class="Section3">A.1.2.\u00a0 Annex Bibliography</h3>
                     </div>
                  </div>
               </div>
               <br/>
               <div id="P1" class="Section3">
                  <h1 class="Annex">
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
         </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
         <head><style/></head>
         <body lang="EN-US" link="blue" vlink="#954F72">
            <div class="WordSection1">
               <p>\u00a0</p>
            </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection2">
                <div class="authority">
                   <div class="boilerplate-copyright">
                      <div id="_">
                         <h1>Copyright</h1>
                      </div>
                   </div>
                   <div class="boilerplate-license">
                      <div id="_">
                         <h1>License</h1>
                      </div>
                   </div>
                   <div class="boilerplate-legal">
                      <div id="_">
                         <h1>Legal</h1>
                      </div>
                   </div>
                   <div class="boilerplate-feedback">
                      <div id="_">
                         <h1>Feedback</h1>
                      </div>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_" class="TOC">
                   <p class="zzContents">Table of contents</p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_">
                   <h1 class="AbstractTitle">Abstract</h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p id="A">This is a preamble</p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <div id="C">
                      <h2>Introduction Subsection</h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="B1" class="Section3">
                   <h1 class="IntroTitle">Dedication</h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="B2" class="Section3">
                   <h1 class="IntroTitle">Note to reader</h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="_">
                   <h1 class="IntroTitle">Acknowledgements</h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="_">
                   <h1 class="IntroTitle">Executive Summary</h1>
                </div>
                <p>\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
                <div id="NN1" class="Note">
                   <p class="Note">
                      <span class="note_label">
                         NOTE
                         <span style="mso-tab-count:1">\u00a0 </span>
                      </span>
                      Initial note
                   </p>
                </div>
                <div id="NN2" class="Admonition">
                   <p class="AdmonitionTitle" style="text-align:center;">WARNING</p>
                   <p>Initial admonition</p>
                </div>
                <div id="D">
                   <h1>
                      1.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Scope
                   </h1>
                   <p id="E">Text</p>
                </div>
                <div>
                   <h1>
                      2.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Normative References
                   </h1>
                </div>
                <div id="H">
                   <h1>
                      3.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Terms, Definitions, Symbols and Abbreviated Terms
                   </h1>
                   <div id="I">
                      <h2>
                         3.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Normal Terms
                      </h2>
                      <p class="TermNum" id="J">3.1.1.</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>
                         3.2.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Symbols
                      </h2>
                      <div align="left">
                         <table class="dl">
                            <tr>
                               <td valign="top" align="left">
                                  <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                               </td>
                               <td valign="top">Definition</td>
                            </tr>
                         </table>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                   <h1>
                      4.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Symbols and abbreviated terms
                   </h1>
                   <div align="left">
                      <table class="dl">
                         <tr>
                            <td valign="top" align="left">
                               <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                            </td>
                            <td valign="top">Definition</td>
                         </tr>
                      </table>
                   </div>
                </div>
                <div id="M">
                   <h1>
                      5.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Clause 4
                   </h1>
                   <div id="N">
                      <h2>
                         5.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Introduction
                      </h2>
                   </div>
                   <div id="O">
                      <h2>
                         5.2.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Clause 4.2
                      </h2>
                   </div>
                   <div id="O1">
                      <h2>5.3.</h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="P" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (normative)
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>
                         A.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Annex A.1
                      </h2>
                      <div id="Q1">
                         <h3>
                            A.1.1.
                            <span style="mso-tab-count:1">\u00a0 </span>
                            Annex A.1a
                         </h3>
                      </div>
                      <div>
                         <h3 class="Section3">
                            A.1.2.
                            <span style="mso-tab-count:1">\u00a0 </span>
                            Annex Bibliography
                         </h3>
                      </div>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="P1" class="Section3">
                   <h1 class="Annex">
                      <b>Annex B</b>
                      <br/>
                      (normative)
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <div>
                      <h2 class="Section3">Bibliography Subsection</h2>
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
    expect(strip_guid(pres_output)).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to html

    word_output = IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(word_output)).to be_html4_equivalent_to word
  end

  it "customises annex titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
         <metanorma-extension>
            <presentation-metadata>
               <annex-delim><br/><tab/><br/>&#x993;<br/></annex-delim>
            </presentation-metadata>
         </metanorma-extension>
         <annex id="P" inline-header="false" obligation="normative">
            <title>Annex</title>
            <clause id="Q" inline-header="false" obligation="normative">
            </clause>
         </annex>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <metanorma-extension>
            <presentation-metadata>
               <annex-delim>
                  <br/>
                  <tab/>
                  <br/>
                  ও
                  <br/>
               </annex-delim>
            </presentation-metadata>
         </metanorma-extension>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title depth="1" id="_">Table of contents</fmt-title>
            </clause>
         </preface>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="2">
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
                  <tab/>
                  <br/>
                  ও
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
               <fmt-title depth="2" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref-label>
            </clause>
         </annex>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to presxml
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
       <executivesummary obligation="informative">
         <title>Executive Summary</title>
         <variant-title type="sub">Variant 1</variant-title>
       </executivesummary>
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
            <p>\u00a0</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>\u00a0</p>
          </div>
          <br/>
          <div class='main-section'>
            <br/>
            <div class="TOC" id="_">
            <h1 class="IntroTitle">Table of contents</h1>
          </div>
          <br/>
            <div id="_">
              <h1 class='AbstractTitle'>
                Abstract
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <br/>
            <div id="_">
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
            <div class='Section3' id='_'>
              <h1 class='IntroTitle'>
                Acknowledgements
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
                <br/>
                <div class="Section3" id="_">
                   <h1 class="IntroTitle">
                      Executive Summary
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
            <div id='NN1' class='Note'>
              <p>
                <span class='note_label'>NOTE\u00a0 </span>
                Initial note
              </p>
            </div>
            <div id='NN2' class='Admonition'>
              <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
              <p>Initial admonition</p>
            </div>
            <div id='D'>
              <h1>
                1.\u00a0 Scope
                <br/>
                <br/>
                Variant 1
              </h1>
              <p id='E'>Text</p>
            </div>
            <div>
              <h1>
                2.\u00a0 Normative References
                <br/>
                <br/>
                Variant 1
              </h1>
            </div>
            <div id='H'>
              <h1>
                3.\u00a0 Terms, Definitions, Symbols and Abbreviated Terms
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='I'>
                <h2>
                  3.1.\u00a0 Normal Terms
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <p class='TermNum' id='J'>3.1.1.</p>
                <p class='Terms' style='text-align:left;'><b>Term2</b></p>
              </div>
              <div id='K'>
                <h2>
                  3.2.\u00a0 Definitions
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
                4.\u00a0 Symbols and abbreviated terms
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
                5.\u00a0 Clause 4
                <br/>
                <br/>
                Variant 1
              </h1>
              <div id='N'>
                <h2>
                  5.1.\u00a0 Introduction
                  <br/>
                  <br/>
                  Variant 1
                </h2>
              </div>
              <div id='O'>
                <h2>
                  5.2.\u00a0 Clause 4.2
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
                  A.1.\u00a0 Annex A.1
                  <br/>
                  <br/>
                  Variant 1
                </h2>
                <div id='Q1'>
                  <h3>
                    A.1.1.\u00a0 Annex A.1a
                    <br/>
                    <br/>
                    Variant 1
                  </h3>
                </div>
                <div>
                  <h3 class='Section3'>
                    A.1.2.\u00a0 Annex Bibliography
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
      #{WORD_HDR}
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
                <div id="_">
                   <h1 class="AbstractTitle">
                      Abstract
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_">
                   <h1 class="ForewordTitle">
                      Foreword
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                   <p id="A">This is a preamble</p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <div id="C">
                      <h2>
                         Introduction Subsection
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="B1" class="Section3">
                   <h1 class="IntroTitle">
                      Dedication
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="B2" class="Section3">
                   <h1 class="IntroTitle">
                      Note to reader
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="_">
                   <h1 class="IntroTitle">
                      Acknowledgements
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="_">
                   <h1 class="IntroTitle">
                      Executive Summary
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <p>\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
                <div id="NN1" class="Note">
                   <p class="Note">
                      <span class="note_label">
                         NOTE
                         <span style="mso-tab-count:1">\u00a0 </span>
                      </span>
                      Initial note
                   </p>
                </div>
                <div id="NN2" class="Admonition">
                   <p class="AdmonitionTitle" style="text-align:center;">WARNING</p>
                   <p>Initial admonition</p>
                </div>
                <div id="D">
                   <h1>
                      1.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Scope
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                   <p id="E">Text</p>
                </div>
                <div>
                   <h1>
                      2.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Normative References
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                </div>
                <div id="H">
                   <h1>
                      3.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Terms, Definitions, Symbols and Abbreviated Terms
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                   <div id="I">
                      <h2>
                         3.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Normal Terms
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                      <p class="TermNum" id="J">3.1.1.</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>
                         3.2.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Definitions
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                      <div align="left">
                         <table class="dl">
                            <tr>
                               <td valign="top" align="left">
                                  <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                               </td>
                               <td valign="top">Definition</td>
                            </tr>
                         </table>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                   <h1>
                      4.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Symbols and abbreviated terms
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                   <div align="left">
                      <table class="dl">
                         <tr>
                            <td valign="top" align="left">
                               <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                            </td>
                            <td valign="top">Definition</td>
                         </tr>
                      </table>
                   </div>
                </div>
                <div id="M">
                   <h1>
                      5.
                      <span style="mso-tab-count:1">\u00a0 </span>
                      Clause 4
                      <br/>
                      <br/>
                      Variant 1
                   </h1>
                   <div id="N">
                      <h2>
                         5.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Introduction
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                   </div>
                   <div id="O">
                      <h2>
                         5.2.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Clause 4.2
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                   </div>
                   <div id="O1">
                      <h2>5.3.</h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="P" class="Section3">
                   <h1 class="Annex">
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
                   <p style="display:none;" class="variant-title-sub">Variant 1</p>
                   <div id="Q">
                      <h2>
                         A.1.
                         <span style="mso-tab-count:1">\u00a0 </span>
                         Annex A.1
                         <br/>
                         <br/>
                         Variant 1
                      </h2>
                      <div id="Q1">
                         <h3>
                            A.1.1.
                            <span style="mso-tab-count:1">\u00a0 </span>
                            Annex A.1a
                            <br/>
                            <br/>
                            Variant 1
                         </h3>
                      </div>
                      <div>
                         <h3 class="Section3">
                            A.1.2.
                            <span style="mso-tab-count:1">\u00a0 </span>
                            Annex Bibliography
                            <br/>
                            <br/>
                            Variant 1
                         </h3>
                      </div>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="P1" class="Section3">
                   <h1 class="Annex">
                      <b>Annex B</b>
                      <br/>
                      (normative)
                   </h1>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <p style="display:none;" class="variant-title-sub">Variant 1</p>
                   <div>
                      <h2 class="Section3">
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

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to html

    word_output = IsoDoc::WordConvert.new({})
      .convert("test", presxml, true)
    expect(strip_guid(word_output)).to be_html4_equivalent_to word
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
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword obligation="informative" displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
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
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="6">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                </fmt-title>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
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
                      <semx element="title" source="_">Symbols</semx>
                   </fmt-title>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="7">
                <title id="_">Symbols</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Symbols</semx>
                </fmt-title>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                </clause>
                <clause id="O1" inline-header="false" obligation="normative">
        </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
                <title id="_">Annex A.1</title>
                <fmt-title id="_" depth="2">
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                   <title id="_">Annex A.1a</title>
                   <fmt-title id="_" depth="3">
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to output
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="D" obligation="normative" type="scope" unnumbered="true" displayorder="2">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" unnumbered="true" displayorder="4">
               <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
               </fmt-title>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <term id="J">
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
               <definitions id="K" unnumbered="true">
                  <title id="_">Symbols</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Symbols</semx>
                  </fmt-title>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" unnumbered="true" displayorder="5">
               <title id="_">Symbols</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Symbols</semx>
               </fmt-title>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" unnumbered="true" displayorder="6">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
               </clause>
            </clause>
            <clause id="O1" inline-header="false" obligation="normative" displayorder="7">
               <fmt-title id="_" depth="1">
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
               <fmt-title id="_" depth="1">
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
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" unnumbered="true" displayorder="10">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title id="_">
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <clause id="Q" inline-header="false" obligation="normative">
               <title id="_">Annex A.1</title>
               <fmt-title id="_" depth="2">
                  <semx element="title" source="_">Annex A.1</semx>
               </fmt-title>
               <clause id="Q1" inline-header="false" obligation="normative">
                  <title id="_">Annex A.1a</title>
                  <fmt-title id="_" depth="3">
                     <semx element="title" source="_">Annex A.1a</semx>
                  </fmt-title>
               </clause>
            </clause>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" unnumbered="true" displayorder="11">
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to output
  end

  it "processes floating titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
        <floating-title depth="1" id="F1">A0</p>
        <introduction id="B" obligation="informative">
        <title>Introduction</title>
        <floating-title depth="1" id="F2">A</p>
        <clause id="B1" obligation="informative">
         <title>Introduction Subsection</title>
        <floating-title depth="2" id="F3">B</p>
        <clause id="B2" obligation="informative">
         <title>Introduction Sub-subsection</title>
        <floating-title depth="1" id="F4">C</p>
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <floating-title depth="1" original-id="F1">A0</floating-title>
            <p depth="1" id="F1" type="floating-title" displayorder="2">
               <semx element="floating-title" source="F1">A0</semx>
            </p>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <floating-title depth="1" original-id="F2">A</floating-title>
               <p depth="1" id="F2" type="floating-title">
                  <semx element="floating-title" source="F2">A</semx>
               </p>
               <clause id="B1" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <floating-title depth="2" original-id="F3">B</floating-title>
                  <p depth="2" id="F3" type="floating-title">
                     <semx element="floating-title" source="F3">B</semx>
                  </p>
                  <clause id="B2" obligation="informative">
                     <title id="_">Introduction Sub-subsection</title>
                     <fmt-title id="_" depth="3">
                        <semx element="title" source="_">Introduction Sub-subsection</semx>
                     </fmt-title>
                     <floating-title depth="1" original-id="F4">C</floating-title>
                     <p depth="1" id="F4" type="floating-title">
                        <semx element="floating-title" source="F4">C</semx>
                     </p>
                  </clause>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="C" obligation="informative" displayorder="4">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="C">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="C">1</semx>
               </fmt-xref-label>
               <floating-title depth="1" original-id="_">A</floating-title>
               <p depth="1" id="_" type="floating-title">
                  <semx element="floating-title" source="_">A</semx>
               </p>
               <clause id="C1" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="C">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="C">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="C1">1</semx>
                  </fmt-xref-label>
                  <floating-title depth="2" original-id="_">B</floating-title>
                  <p depth="2" id="_" type="floating-title">
                     <semx element="floating-title" source="_">B</semx>
                  </p>
                  <clause id="C2" obligation="informative">
                     <title id="_">Introduction Sub-subsection</title>
                     <fmt-title id="_" depth="3">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="C">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="C1">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="C2">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Introduction Sub-subsection</semx>
                     </fmt-title>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="C">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C2">1</semx>
                     </fmt-xref-label>
                     <floating-title depth="1" original-id="_">C</floating-title>
                     <p depth="1" id="_" type="floating-title">
                        <semx element="floating-title" source="_">C</semx>
                     </p>
                  </clause>
               </clause>
            </clause>
            <floating-title depth="1" original-id="_">D</floating-title>
            <p depth="1" id="_" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_">D</semx>
            </p>
            <clause id="C4" displayorder="6">
               <title id="_">Clause 2</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="C4">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 2</semx>
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
                <p class="h1" id="F1">A0</p>
                <br/>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <p class="h1" id="F2">A</p>
                   <div id="B1">
                      <h2>Introduction Subsection</h2>
                      <p class="h2" id="F3">B</p>
                      <div id="B2">
                         <h3>Introduction Sub-subsection</h3>
                         <p class="h1" id="F4">C</p>
                      </div>
                   </div>
                </div>
                <div id="C">
                   <h1>1.\u00a0 Introduction</h1>
                   <p class="h1" id="_">A</p>
                   <div id="C1">
                      <h2>1.1.\u00a0 Introduction Subsection</h2>
                      <p class="h2" id="_">B</p>
                      <div id="C2">
                         <h3>1.1.1.\u00a0 Introduction Sub-subsection</h3>
                         <p class="h1" id="_">C</p>
                      </div>
                   </div>
                </div>
                <p class="h1" id="_">D</p>
                <div id="C4">
                   <h1>2.\u00a0 Clause 2</h1>
                </div>
             </div>
          </body>
       </html>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
            <p class="MsoNormal">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <p class="h1">
               <a name="F1" id="F1"/>
               A0
            </p>
            <div class="Section3">
               <a name="B" id="B"/>
               <h1 class="IntroTitle">Introduction</h1>
               <p class="h1">
                  <a name="F2" id="F2"/>
                  A
               </p>
               <div>
                  <a name="B1" id="B1"/>
                  <h2>Introduction Subsection</h2>
                  <p class="h2">
                     <a name="F3" id="F3"/>
                     B
                  </p>
                  <div>
                     <a name="B2" id="B2"/>
                     <h3>Introduction Sub-subsection</h3>
                     <p class="h1">
                        <a name="F4" id="F4"/>
                        C
                     </p>
                  </div>
               </div>
            </div>
            <p class="MsoNormal">\u00a0</p>
         </div>
         <p class="MsoNormal">
            <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
            <div>
               <a name="C" id="C"/>
               <h1>
                  1.
                  <span style="mso-tab-count:1">\u00a0 </span>
                  Introduction
               </h1>
               <p class="h1">
                  <a name="_" id="_"/>
                  A
               </p>
               <div>
                  <a name="C1" id="C1"/>
                  <h2>
                     1.1.
                     <span style="mso-tab-count:1">\u00a0 </span>
                     Introduction Subsection
                  </h2>
                  <p class="h2">
                     <a name="_" id="_"/>
                     B
                  </p>
                  <div>
                     <a name="C2" id="C2"/>
                     <h3>
                        1.1.1.
                        <span style="mso-tab-count:1">\u00a0 </span>
                        Introduction Sub-subsection
                     </h3>
                     <p class="h1">
                        <a name="_" id="_"/>
                        C
                     </p>
                  </div>
               </div>
            </div>
            <p class="h1">
               <a name="_" id="_"/>
               D
            </p>
            <div>
               <a name="C4" id="C4"/>
               <h1>
                  2.
                  <span style="mso-tab-count:1">\u00a0 </span>
                  Clause 2
               </h1>
            </div>
         </div>
         <div style="mso-element:footnote-list"/>
      </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to html

    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    word_content = File.read("test.doc")
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "")
    expect(strip_guid(word_content)).to be_html4_equivalent_to word
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
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <introduction id="B" obligation="informative" displayorder="2">
                <title id="_">Introduction</title>
                <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause obligation="informative" id="_">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title id="_" depth="2">
                         <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
       </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to output
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
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="M" inline-header="false" obligation="normative" displayorder="2">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                      </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">1</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">1</semx>
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
                     <semx element="autonum" source="M">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O" inline-header="true" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">1</semx>
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
                     <semx element="autonum" source="M">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
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
                     <h1>1.\u00a0 Clause 4</h1>
                     <div id="N">
              <h2>1.1.\u00a0 Introduction</h2>
            </div>
                     <div id="O">
              <span class="zzMoveToFollowing inline-header"><b>1.2.\u00a0 Clause 4.2\u00a0 </b></span>
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
    expect(strip_guid(pres_output)).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to html
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
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ suppressheadingnumbers: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to(<<~OUTPUT)
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="M" inline-header="false" obligation="normative" displayorder="2">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                        <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
               </clause>
               <clause id="O" inline-header="true" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                        <semx element="title" source="_">Clause 4.2</semx>
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <introduction id="M" inline-header="false" obligation="normative" displayorder="2">
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Intro</title>
                  <fmt-title id="_" depth="2">
                        <semx element="title" source="_">Intro</semx>
                  </fmt-title>
               </clause>
               <clause id="O" inline-header="true" obligation="normative">
       </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="M1" inline-header="false" obligation="normative" displayorder="3">
               <fmt-title id="_" depth="1">
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
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M1">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N1">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O1" inline-header="true" obligation="normative">
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O1">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M1">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O1">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </sections>
      </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to output
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
             <p>\u00a0</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>\u00a0</p>
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
    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to output
  end

  it "processes duplicate ids between Semantic and Presentation XML titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <clause id="A1">
           <title>Title <bookmark id="A2"/> <index><primary>title</primary></index></title>
           </clause>
           </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="A1" displayorder="2">
                <title id="_">
                   Title
                   <bookmark original-id="A2"/>
                </title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">
                      Title
                      <bookmark id="A2"/>
                   </semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A1">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output)).to be_xml_equivalent_to output
  end
end
