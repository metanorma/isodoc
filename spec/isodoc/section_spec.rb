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
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
              <div id='C' class='Note'>
                <p class='Note'>
                  <span class='note_label'/>
                  <span style='mso-tab-count:1'>&#160; </span>
                </p>
                note
              </div>
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
  end

  it "processes indexsect" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <indexsect id='PP' obligation='normative' displayorder="1">
        <title>Glossary</title>
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
         .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <annex id='PP' obligation='normative' displayorder='2'>
          <title>
            <strong>Annex A</strong>
            <br/>
            (normative)
            <br/>
            <br/>
            <strong>Glossary</strong>
          </title>
          <terms id='PP1' obligation='normative'>
            <term id='term-glossary'>
              <name>A.1.</name>
              <preferred><strong>Glossary</strong></preferred>
            </term>
          </terms>
        </annex>
        <annex id='QQ' obligation='normative' displayorder='3'>
          <title>
            <strong>Annex B</strong>
            <br/>
            (normative)
            <br/>
            <br/>
            <strong>Glossary</strong>
          </title>
          <terms id='QQ1' obligation='normative'>
            <title depth='2'>
              B.1.
              <tab/>
              Term Collection
            </title>
            <term id='term-term-1'>
              <name>B.1.1.</name>
              <preferred><strong>Term</strong></preferred>
            </term>
          </terms>
          <terms id='QQ2' obligation='normative'>
            <title depth='2'>
              B.2.
              <tab/>
              Term Collection 2
            </title>
            <term id='term-term-2'>
              <name>B.2.1.</name>
              <preferred><strong>Term</strong></preferred>
            </term>
          </terms>
        </annex>
        <annex id='RR' obligation='normative' displayorder='4'>
          <title>
            <strong>Annex C</strong>
            <br/>
            (normative)
            <br/>
            <br/>
            <strong>Glossary</strong>
          </title>
          <terms id='RR1' obligation='normative'>
            <title depth='2'>
              C.1.
              <tab/>
              Term Collection
            </title>
            <term id='term-term-3'>
              <name>C.1.1.</name>
              <preferred><strong>Term</strong></preferred>
            </term>
          </terms>
          <references id='RR2' obligation='normative'>
            <title depth='2'>
              C.2.
              <tab/>
              References
            </title>
          </references>
        </annex>
          <annex id='SS' obligation='normative' displayorder='5'>
          <title>
            <strong>Annex D</strong>
            <br/>
            (normative)
            <br/>
            <br/>
            <strong>Term Collection</strong>
          </title>
          <terms id='SS1' obligation='normative'>
            <term id='term-term-4'>
              <name>D.1.</name>
              <preferred>
                <strong>Term</strong>
              </preferred>
            </term>
          </terms>
        </annex>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes cross-align" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <cross-align displayorder="1">
           <align-cell>
           <clause id="A1">
           <title>Title</title>
           <p>Para</p>
           </clause>
           </align-cell>
           <align-cell>
           <clause id="A2">
           <title>Iitre</title>
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
         .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
  end
end
