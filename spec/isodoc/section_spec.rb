require "spec_helper"

RSpec.describe IsoDoc do
  it "processes prefatory blocks" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract id="A" displayorder="1"><fmt-title id="_">abstract</fmt-title></abstract>
      <introduction id="B" displayorder="2"><fmt-title id="_">introduction</fmt-title></introduction>
      <note id="C" displayorder="3">note</note>
      </preface>
      <sections>
       <clause id="M" inline-header="false" obligation="normative" displayorder="4">
        <fmt-title id="_">Clause 4</fmt-title><clause id="N" inline-header="false" obligation="normative">
         <fmt-title id="_">Introduction</fmt-title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative" displayorder="5">
         <fmt-title id="_">Clause 4.2</fmt-title>
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
            <p>\\u00a0</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>\\u00a0</p>
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
                  <b>Clause 4.2\\u00a0 </b>
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
            <p>\\u00a0</p>
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
            <p>\\u00a0</p>
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
                    <span style='mso-tab-count:1'>\\u00a0 </span>
                  </b>
                </span>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes indexsect" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <indexsect id='PP' obligation='normative' displayorder="1">
        <fmt-title id="_">Glossary</fmt-title>
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
             <p>\\u00a0</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>\\u00a0</p>
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
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
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <annex id="PP" obligation="normative" autonum="A" displayorder="2">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="PP">A</semx>
                   </span>
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
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="PP">A</semx>
             </fmt-xref-label>
             <terms id="PP1" obligation="normative">
                <term id="term-glossary" autonum="A.1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="PP1">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="term-glossary">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="PP1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="term-glossary">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Glossary</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>Glossary</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                </term>
             </terms>
          </annex>
          <annex id="QQ" obligation="normative" autonum="B" displayorder="3">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ">B</semx>
                   </span>
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
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="QQ">B</semx>
             </fmt-xref-label>
             <terms id="QQ1" obligation="normative" autonum="B.1">
                <title id="_">Term Collection</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="QQ">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="QQ1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Term Collection</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="QQ">B</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="QQ1">1</semx>
                </fmt-xref-label>
                <term id="term-term-1" autonum="B.1.1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="QQ">B</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="QQ1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="term-term-1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="QQ1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="term-term-1">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Term</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>Term</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                </term>
             </terms>
             <terms id="QQ2" obligation="normative" autonum="B.2">
                <title id="_">Term Collection 2</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="QQ">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="QQ2">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Term Collection 2</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="QQ">B</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="QQ2">2</semx>
                </fmt-xref-label>
                <term id="term-term-2" autonum="B.2.1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="QQ">B</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="QQ2">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="term-term-2">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="QQ2">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="term-term-2">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Term</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>Term</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                </term>
             </terms>
          </annex>
          <annex id="RR" obligation="normative" autonum="C" displayorder="4">
             <title id="_">
                <strong>Glossary</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="RR">C</semx>
                   </span>
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
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="RR">C</semx>
             </fmt-xref-label>
             <terms id="RR1" obligation="normative" autonum="C.1">
                <title id="_">Term Collection</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="RR">C</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="RR1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Term Collection</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="RR">C</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="RR1">1</semx>
                </fmt-xref-label>
                <term id="term-term-3" autonum="C.1.1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="RR">C</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="RR1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="term-term-3">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="RR">C</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="RR1">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="term-term-3">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Term</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>Term</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                </term>
             </terms>
             <references id="RR2" obligation="normative" autonum="C.2">
                <title id="_">References</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="RR">C</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="RR2">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="RR">C</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="RR2">2</semx>
                </fmt-xref-label>
             </references>
          </annex>
          <annex id="SS" obligation="normative" autonum="D" displayorder="5">
             <title id="_">
                <strong>Term Collection</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="SS">D</semx>
                   </span>
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
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="SS">D</semx>
             </fmt-xref-label>
             <terms id="SS1" obligation="normative">
                <term id="term-term-4" autonum="D.1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="SS1">D</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="term-term-4">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="SS1">D</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="term-term-4">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>Term</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>Term</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                </term>
             </terms>
          </annex>
       </iso-standard>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
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
           <fmt-title id="_">Title</fmt-title>
           <p>Para</p>
           </clause>
           </align-cell>
           <align-cell>
           <clause id="A2">
           <fmt-title id="_">Iitre</fmt-title>
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
             <p>\\u00a0</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>\\u00a0</p>
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "ignores index entries" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p id="A"><index primary="A" secondary="B" tertiary="C"/></p>
      </foreword></preface>
      <sections/>
      <indexsect>
        <title>Index</title>
      </indexsect>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <p id="A"/>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    mock_indexsect(true)
    output = <<~OUTPUT
      <p id="A">
         <bookmark primary="A" secondary="B" tertiary="C" id="_"/>
      </p>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "generates an index in English" do
    mock_indexsect(true)
    input = <<~INPUT
      <iso-standard xmlns="https://open.ribose.com/standards/bipm">
        <bibdata>
          <language>en</language>
          <script>Latn</script>
        </bibdata>
        <sections>
          <clause id="A">
            <p>A</p>
            <index><primary>&#xE9;long&#xE9;</primary></index>
            <index><primary>&#xEA;tre</primary><secondary>Husserl</secondary><tertiary>en allemand</tertiary></index>
            <index><primary><em>Eman</em>cipation</primary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>en Bretagne</tertiary></index>
            <clause id="B">
              <p>B</p>
              <index><primary><em>Eman</em>cipation</primary></index>
              <index><primary>zebra</primary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans les &#xC9;tats-Unis</secondary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>&#xE0; Paris</tertiary></index>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target><em>Eman</em>cipation</target></index-xref>
              <index-xref also="false"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target>&#xEA;tre</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target><em>Eman</em>cipation</target></index-xref>
            </clause>
          </clause>
        </sections>
      </bipm-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="https://open.ribose.com/standards/bipm" type="presentation">
           <bibdata>
              <language current="true">en</language>
              <script current="true">Latn</script>
           </bibdata>
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title id="_" depth="1">Table of contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="A" displayorder="2">
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <p>A</p>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <clause id="B">
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="B">1</semx>
                    </fmt-xref-label>
                    <p>B</p>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                 </clause>
              </clause>
           </sections>
           <indexsect id="_" displayorder="3">
              <title>Index</title>
              <ul>
                 <li>
                    <fmt-name id="_">
                       <semx element="autonum" source="">—</semx>
                    </fmt-name>
                    <em>Dasein</em>
                    , see
                    <em>Eman</em>
                    cipation, être
                 </li>
                 <li>
                    <fmt-name id="_">
                       <semx element="autonum" source="">—</semx>
                    </fmt-name>
                    élongé,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref>
                    </semx>
                 </li>
                 <li>
                    <fmt-name id="_">
                       <semx element="autonum" source="">—</semx>
                    </fmt-name>
                    <em>Eman</em>
                    cipation,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref>
                    </semx>
                    ,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </fmt-xref>
                    </semx>
                    <ul>
                       <li>
                          <fmt-name id="_">
                             <semx element="autonum" source="">—</semx>
                          </fmt-name>
                          dans la France,
                          <xref target="_" pagenumber="true" id="_"/>
                          <semx element="xref" source="_">
                             <fmt-xref target="_" pagenumber="true">
                                <span class="fmt-element-name">Clause</span>
                                <semx element="autonum" source="A">1</semx>
                             </fmt-xref>
                          </semx>
                          <ul>
                             <li>
                                <fmt-name id="_">
                                   <semx element="autonum" source="">—</semx>
                                </fmt-name>
                                à Paris,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <span class="fmt-element-name">Clause</span>
                                      <semx element="autonum" source="A">1</semx>
                                      <span class="fmt-autonum-delim">.</span>
                                      <semx element="autonum" source="B">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                             <li>
                                <fmt-name id="_">
                                   <semx element="autonum" source="">—</semx>
                                </fmt-name>
                                en Bretagne,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <span class="fmt-element-name">Clause</span>
                                      <semx element="autonum" source="A">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                          </ul>
                       </li>
                       <li>
                          <fmt-name id="_">
                             <semx element="autonum" source="">—</semx>
                          </fmt-name>
                          dans les États-Unis,
                          <xref target="_" pagenumber="true" id="_"/>
                          <semx element="xref" source="_">
                             <fmt-xref target="_" pagenumber="true">
                                <span class="fmt-element-name">Clause</span>
                                <semx element="autonum" source="A">1</semx>
                                <span class="fmt-autonum-delim">.</span>
                                <semx element="autonum" source="B">1</semx>
                             </fmt-xref>
                          </semx>
                       </li>
                    </ul>
                 </li>
                 <li>
                    <fmt-name id="_">
                       <semx element="autonum" source="">—</semx>
                    </fmt-name>
                    être
                    <ul>
                       <li>
                          <fmt-name id="_">
                             <semx element="autonum" source="">—</semx>
                          </fmt-name>
                          Husserl, see zebra, see also
                          <em>Eman</em>
                          cipation, zebra
                          <ul>
                             <li>
                                <fmt-name id="_">
                                   <semx element="autonum" source="">—</semx>
                                </fmt-name>
                                en allemand,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <span class="fmt-element-name">Clause</span>
                                      <semx element="autonum" source="A">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                          </ul>
                       </li>
                    </ul>
                 </li>
                 <li>
                    <fmt-name id="_">
                       <semx element="autonum" source="">—</semx>
                    </fmt-name>
                    zebra,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </fmt-xref>
                    </semx>
                 </li>
              </ul>
           </indexsect>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="main-section">
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <div id="A">
                  <h1>1.</h1>
                  <p>A</p>
                  <a id="_"/>
                  <a id="_"/>
                  <a id="_"/>
                  <a id="_"/>
                  <a id="_"/>
                  <div id="B">
                     <h2>1.1.</h2>
                     <p>B</p>
                     <a id="_"/>
                     <a id="_"/>
                     <a id="_"/>
                     <a id="_"/>
                  </div>
               </div>
               <div id="_">
                  <h1>Index</h1>
                  <div class="ul_wrap">
                     <ul>
                        <li>
                           <i>Dasein</i>
                           , see
                           <i>Eman</i>
                           cipation, être
                        </li>
                        <li>
                           élongé,
                           <a href="#_">Clause 1</a>
                        </li>
                        <li>
                           <i>Eman</i>
                           cipation,
                           <a href="#_">Clause 1</a>
                           ,
                           <a href="#_">Clause 1.1</a>
                           <div class="ul_wrap">
                              <ul>
                                 <li>
                                    dans la France,
                                    <a href="#_">Clause 1</a>
                                    <div class="ul_wrap">
                                       <ul>
                                          <li>
                                             à Paris,
                                             <a href="#_">Clause 1.1</a>
                                          </li>
                                          <li>
                                             en Bretagne,
                                             <a href="#_">Clause 1</a>
                                          </li>
                                       </ul>
                                    </div>
                                 </li>
                                 <li>
                                    dans les États-Unis,
                                    <a href="#_">Clause 1.1</a>
                                 </li>
                              </ul>
                           </div>
                        </li>
                        <li>
                           être
                           <div class="ul_wrap">
                              <ul>
                                 <li>
                                    Husserl, see zebra, see also
                                    <i>Eman</i>
                                    cipation, zebra
                                    <div class="ul_wrap">
                                       <ul>
                                          <li>
                                             en allemand,
                                             <a href="#_">Clause 1</a>
                                          </li>
                                       </ul>
                                    </div>
                                 </li>
                              </ul>
                           </div>
                        </li>
                        <li>
                           zebra,
                           <a href="#_">Clause 1.1</a>
                        </li>
                     </ul>
                  </div>
               </div>
            </div>
         </body>
      </html>
    OUTPUT
    doc = <<~DOC
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection3">
            <div>
               <a name="A" id="A"/>
               <h1>1.</h1>
               <p class="MsoNormal">A</p>
               <a>
                  <a name="_" id="_"/>
               </a>
               <a>
                  <a name="_" id="_"/>
               </a>
               <a>
                  <a name="_" id="_"/>
               </a>
               <a>
                  <a name="_" id="_"/>
               </a>
               <a>
                  <a name="_" id="_"/>
               </a>
               <div>
                  <a name="B" id="B"/>
                  <h2>1.1.</h2>
                  <p class="MsoNormal">B</p>
                  <a>
                     <a name="_" id="_"/>
                  </a>
                  <a>
                     <a name="_" id="_"/>
                  </a>
                  <a>
                     <a name="_" id="_"/>
                  </a>
                  <a>
                     <a name="_" id="_"/>
                  </a>
               </div>
            </div>
            <div>
               <a name="_" id="_"/>
               <h1>Index</h1>
               <div class="ul_wrap">
                  <p class="MsoListParagraphCxSpFirst">
                     <i>Dasein</i>
                     , see
                     <i>Eman</i>
                     cipation, être
                  </p>
                  <p class="MsoListParagraphCxSpMiddle">
                     élongé,
                     <a href="#_">Clause 1</a>
                  </p>
                  <p class="MsoListParagraphCxSpMiddle">
                     <i>Eman</i>
                     cipation,
                     <a href="#_">Clause 1</a>
                     ,
                     <a href="#_">Clause 1.1</a>
                     <div class="ul_wrap">
                        <p class="MsoListParagraphCxSpFirst">
                           dans la France,
                           <a href="#_">Clause 1</a>
                           <div class="ul_wrap">
                              <p class="MsoListParagraphCxSpFirst">
                                 à Paris,
                                 <a href="#_">Clause 1.1</a>
                              </p>
                              <p class="MsoListParagraphCxSpLast">
                                 en Bretagne,
                                 <a href="#_">Clause 1</a>
                              </p>
                           </div>
                        </p>
                        <p class="MsoListParagraphCxSpLast">
                           dans les États-Unis,
                           <a href="#_">Clause 1.1</a>
                        </p>
                     </div>
                  </p>
                  <p class="MsoListParagraphCxSpMiddle">
                     être
                     <div class="ul_wrap">
                        <p class="MsoListParagraphCxSpFirst">
                           Husserl, see zebra, see also
                           <i>Eman</i>
                           cipation, zebra
                           <div class="ul_wrap">
                              <p class="MsoListParagraphCxSpFirst">
                                 en allemand,
                                 <a href="#_">Clause 1</a>
                              </p>
                           </div>
                        </p>
                     </div>
                  </p>
                  <p class="MsoListParagraphCxSpLast">
                     zebra,
                     <a href="#_">Clause 1.1</a>
                  </p>
               </div>
            </div>
         </div>
         <div style="mso-element:footnote-list"/>
      </body>
    DOC
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f("test.doc")
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")
    wordxml = Nokogiri::XML(word)
    expect(strip_guid(Xml::C14n.format(wordxml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  private

  def mock_indexsect(value)
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:enable_indexsect).and_return(value)
  end
end
