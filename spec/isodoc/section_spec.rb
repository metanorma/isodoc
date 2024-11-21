require "spec_helper"

RSpec.describe IsoDoc do
  it "processes prefatory blocks" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract id="A" displayorder="1"><fmt-title>abstract</fmt-title></abstract>
      <introduction id="B" displayorder="2"><fmt-title>introduction</fmt-title></introduction>
      <note id="C" displayorder="3">note</note>
      </preface>
      <sections>
       <clause id="M" inline-header="false" obligation="normative" displayorder="4">
        <fmt-title>Clause 4</fmt-title><clause id="N" inline-header="false" obligation="normative">
         <fmt-title>Introduction</fmt-title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative" displayorder="5">
         <fmt-title>Clause 4.2</fmt-title>
       </clause></clause>
       <admonition id="L" type="caution" displayorder="6"><p>admonition</p></admonition>
       </sections>
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
            <div id='A'>
              <h1 class='AbstractTitle'>abstract</h1>
            </div>
            <br/>
            <div class='Section3' id='B'>
              <h1 class='IntroTitle'>introduction</h1>
            </div>
            <div id='C' class='Note'>note</div>
            <div id='M'>
              <h1>Clause 4</h1>
              <div id='N'>
                <h2>Introduction</h2>
              </div>
              <div id='O'>
                <span class='zzMoveToFollowing inline-header'>
                  <b>Clause 4.2&#160; </b>
                </span>
              </div>
            </div>
            <div id='L' class='Admonition'>
              <p>admonition</p>
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
            <div id='A'>
              <h1 class='AbstractTitle'>abstract</h1>
            </div>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
            <div class='Section3' id='B'>
              <h1 class='IntroTitle'>introduction</h1>
            </div>
            <div id="C" class="Note">note</div>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <div id='L' class='Admonition'>
              <p>admonition</p>
            </div>
            <div id='M'>
              <h1>Clause 4</h1>
              <div id='N'>
                <h2>Introduction</h2>
              </div>
              <div id='O'>
                <span class='zzMoveToFollowing inline-header'>
                  <b>
                    Clause 4.2
                    <span style='mso-tab-count:1'>&#160; </span>
                  </b>
                </span>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes indexsect" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <indexsect id='PP' obligation='normative' displayorder="1">
        <fmt-title>Glossary</fmt-title>
        <ul>
        <li>A</li>
        </ul>
      </indexsect>
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
             <div id="PP">
               <h1>Glossary</h1>
               <div class="ul_wrap">
               <ul>
                 <li>A</li>
               </ul>
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

  it "processes annexes containing one, or more than one special sections" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <annex id='PP' obligation='normative'>
        <title>Glossary</title>
        <terms id='PP1' obligation='normative'>
          <term id='term-glossary'>
            <preferred><expression><name>Glossary</name></expression></preferred>
          </term>
        </terms>
      </annex>
            <annex id='QQ' obligation='normative'>
                 <title>Glossary</title>
                   <terms id='QQ1' obligation='normative'>
                     <title>Term Collection</title>
                     <term id='term-term-1'>
                       <preferred><expression><name>Term</name></expression></preferred>
                     </term>
                   </terms>
                   <terms id='QQ2' obligation='normative'>
                     <title>Term Collection 2</title>
                     <term id='term-term-2'>
                       <preferred><expression><name>Term</name></expression></preferred>
                     </term>
                   </terms>
               </annex>
                 <annex id='RR' obligation='normative'>
                 <title>Glossary</title>
                   <terms id='RR1' obligation='normative'>
                     <title>Term Collection</title>
                     <term id='term-term-3'>
                       <preferred><expression><name>Term</name></expression></preferred>
                     </term>
                   </terms>
                   <references id='RR2' obligation='normative'>
                     <title>References</title>
                   </terms>
               </annex>
               <annex id='SS' obligation='normative'>
                   <terms id='SS1' obligation='normative'>
                     <title>Term Collection</title>
                     <term id='term-term-4'>
                       <preferred><expression><name>Term</name></expression></preferred>
                     </term>
                   </terms>
               </annex>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <annex id="PP" obligation="normative" autonum="A" displayorder="2">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="PP">A</semx>
                   </strong>
                   <br/>
                   <span class="fmt-obligation">(normative)</span>
                   <span class="fmt-caption-delim">
                      <br/>
                      <br/>
                   </span>
                   <semx element="title" source="_">
                      <strong>Glossary</strong>
                   </semx>
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="PP">A</semx>
             </fmt-xref-label>
             <terms id="PP1" obligation="normative">
                <term id="term-glossary" autonum="A.1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="term-glossary">A.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="term-glossary">A.1</semx>
                   </fmt-xref-label>
                   <preferred>
                      <strong>Glossary</strong>
                   </preferred>
                </term>
             </terms>
          </annex>
          <annex id="QQ" obligation="normative" autonum="B" displayorder="3">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ">B</semx>
                   </strong>
                   <br/>
                   <span class="fmt-obligation">(normative)</span>
                   <span class="fmt-caption-delim">
                      <br/>
                      <br/>
                   </span>
                   <semx element="title" source="_">
                      <strong>Glossary</strong>
                   </semx>
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="QQ">B</semx>
             </fmt-xref-label>
             <terms id="QQ1" obligation="normative" autonum="B.1">
                <title id="_">Term Collection</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="QQ1">B.1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Term Collection</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="QQ1">B.1</semx>
                </fmt-xref-label>
                <term id="term-term-1" autonum="B.1.1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="term-term-1">B.1.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="term-term-1">B.1.1</semx>
                   </fmt-xref-label>
                   <preferred>
                      <strong>Term</strong>
                   </preferred>
                </term>
             </terms>
             <terms id="QQ2" obligation="normative" autonum="B.2">
                <title id="_">Term Collection 2</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="QQ2">B.2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Term Collection 2</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="QQ2">B.2</semx>
                </fmt-xref-label>
                <term id="term-term-2" autonum="B.2.1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="term-term-2">B.2.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="term-term-2">B.2.1</semx>
                   </fmt-xref-label>
                   <preferred>
                      <strong>Term</strong>
                   </preferred>
                </term>
             </terms>
          </annex>
          <annex id="RR" obligation="normative" autonum="C" displayorder="4">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="RR">C</semx>
                   </strong>
                   <br/>
                   <span class="fmt-obligation">(normative)</span>
                   <span class="fmt-caption-delim">
                      <br/>
                      <br/>
                   </span>
                   <semx element="title" source="_">
                      <strong>Glossary</strong>
                   </semx>
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="RR">C</semx>
             </fmt-xref-label>
             <terms id="RR1" obligation="normative" autonum="C.1">
                <title id="_">Term Collection</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="RR1">C.1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Term Collection</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="RR1">C.1</semx>
                </fmt-xref-label>
                <term id="term-term-3" autonum="C.1.1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="term-term-3">C.1.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="term-term-3">C.1.1</semx>
                   </fmt-xref-label>
                   <preferred>
                      <strong>Term</strong>
                   </preferred>
                </term>
             </terms>
             <references id="RR2" obligation="normative" autonum="C.2">
                <title id="_">References</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="RR2">C.2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">References</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="RR2">C.2</semx>
                </fmt-xref-label>
             </references>
          </annex>
          <annex id="SS" obligation="normative" autonum="D" displayorder="5">
             <title id="_">
                <strong>Term Collection</strong>
             </title>
             <fmt-title>
                <span class="fmt-caption-label">
                   <strong>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="SS">D</semx>
                   </strong>
                   <br/>
                   <span class="fmt-obligation">(normative)</span>
                   <span class="fmt-caption-delim">
                      <br/>
                      <br/>
                   </span>
                   <semx element="title" source="_">
                      <strong>Term Collection</strong>
                   </semx>
                </span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="SS">D</semx>
             </fmt-xref-label>
             <terms id="SS1" obligation="normative">
                <term id="term-term-4" autonum="D.1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="term-term-4">D.1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="term-term-4">D.1</semx>
                   </fmt-xref-label>
                   <preferred>
                      <strong>Term</strong>
                   </preferred>
                </term>
             </terms>
          </annex>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes cross-align" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <cross-align displayorder="1">
           <align-cell>
           <clause id="A1">
           <fmt-title>Title</fmt-title>
           <p>Para</p>
           </clause>
           </align-cell>
           <align-cell>
           <clause id="A2">
           <fmt-title>Iitre</fmt-title>
           <p>Alinée</p>
           </clause>
           </align-cell>
           </cross-align>
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
                        <table>
               <tbody>
                 <td>
                   <div id="A1">
                     <h1>Title</h1>
                     <p>Para</p>
                   </div>
                 </td>
                 <td>
                   <div id="A2">
                     <h1>Iitre</h1>
                     <p>Alinée</p>
                   </div>
                 </td>
               </tbody>
             </table>
           </div>
         </body>
       </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
