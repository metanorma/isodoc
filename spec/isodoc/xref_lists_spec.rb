require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          </p>
          </foreword>
          <introduction id="intro">
           <ol id="N1">
        <li><p>A</p></li>
      </ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N2">
        <li><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N">
        <li><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          <ol id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          <ol id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <ol id="Anote3">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="note2">2</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="Anote1">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references list items in English and Japanese" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N11"/>
          <xref target="N12"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          </p>
          </foreword>
          <introduction id="intro">
          <ol id="N01">
        <li id="N1"><p>A</p>
          <ol id="N011">
        <li id="N11"><p>A</p>
          <ol id="N012">
        <li id="N12"><p>A</p>
         </li>
      </ol></li></ol></li></ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N02" type="arabic">
        <li id="N2"><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N0" type="roman">
        <li id="N"><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1l" type="alphabet">
        <li id="note1"><p>A</p></li>
      </ol>
          <ol id="note2l" type="roman_upper">
        <li id="note2"><p>A</p></li>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="ANl" type="alphabet_upper">
        <li id="AN"><p>A</p></li>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1l" type="roman" start="4">
        <li id="Anote1"><p>A</p></li>
      </ol>
          <ol id="Anote2l">
        <li id="Anote2"><p>A</p></li>
      </ol>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <ol id="Anote31">
        <li id="Anote3"><p>A</p></li>
      </ol>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N11">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N11">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N12">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N11">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N12">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N2">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="note1l">1</semx>
                 <semx element="autonum" source="note1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="note2l">2</semx>
                 <semx element="autonum" source="note2">I</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="Anote1l">1</semx>
                 <semx element="autonum" source="Anote1">iv</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="Anote2l">2</semx>
                 <semx element="autonum" source="Anote2">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="Anote3">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">まえがき</title>
           <fmt-title depth="1">
              <semx element="title" source="_">まえがき</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">序文</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N11">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">序文</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N11">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N12">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">序文</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N11">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N12">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N2">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="note1l">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="note2l">2</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note2">I</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="Anote1l">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote1">iv</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="Anote2l">2</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote2">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote3">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references nested list items in English and Japanese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>en</language></bibdata>
      <preface>
      <foreword>
      <p>
      <xref target="N"/>
      <xref target="note1"/>
      <xref target="note2"/>
      <xref target="AN"/>
      <xref target="Anote1"/>
      <xref target="Anote2"/>
                    <xref target="P"/>
         <xref target="Q"/>
         <xref target="R"/>
         <xref target="S"/>
         <xref target="P1"/>
      </p>
      </foreword>
      </preface>
      <sections>
      <clause id="scope" type="scope"><title>Scope</title>
      <ol id="N1">
        <li id="N"><p>A</p>
        <ol>
        <li id="note1"><p>A</p>
        <ol>
        <li id="note2"><p>A</p>
        <ol>
        <li id="AN"><p>A</p>
        <ol>
        <li id="Anote1"><p>A</p>
        <ol>
        <li id="Anote2"><p>A</p></li>
        </ol></li>
        </ol></li>
        </ol></li>
        </ol></li>
        </ol></li>
      </ol>
      </clause>
      <clause id="A"><title>Clause</title>
       <ol id="L">
       <li id="P">
       <ol id="L11">
       <li id="Q">
       <ol id="L12">
       <li id="R">
       <ol id="L13">
       <li id="S">
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       <ol id="L1">
       <li id="P1">A</li>
       </ol>
       </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Anote1">I</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Anote1">I</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Anote2">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="P">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="L">1</semx>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Q">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="L">1</semx>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="R">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="L">1</semx>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="R">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="S">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="L">1</semx>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="R">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="S">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="P1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">List</span>
                 <semx element="autonum" source="L1">2</semx>
                 <semx element="autonum" source="P1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
       <foreword displayorder="2">
           <title id="_">まえがき</title>
           <fmt-title depth="1">
              <semx element="title" source="_">まえがき</semx>
           </fmt-title>
           <p>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote1">I</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="N">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="note2">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="AN">A</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote1">I</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Anote2">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="P">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="L">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Q">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="L">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="R">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="L">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="R">i</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="S">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="L">1</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="P">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="R">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="S">A</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="P1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="A">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">リスト</span>
                 <semx element="autonum" source="L1">2</semx>
                 <span class="fmt-conn">の</span>
                 <semx element="autonum" source="P1">a</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references definition lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          </p>
          </foreword>
          <introduction id="intro">
           <dl id="N1">
        <li><p>A</p></li>
      </dl>
        <clause id="xyz"><title>Preparatory</title>
           <dl id="N2">
        <li><p>A</p></li>
      </dl>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <dl id="N">
        <li><p>A</p></li>
      </dl>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <dl id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          <dl id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <dl id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          <clause id="annex1b">
          <dl id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          <dl id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
      <dl id="Anote3">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="note2">2</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="Anote1">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references definition list terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          </p>
          </foreword>
          <introduction id="intro">
          <dl id="N01">
        <dt id="N1"><p>A</p></dt>
      </dl>
        <clause id="xyz"><title>Preparatory</title>
           <dl id="N02" type="arabic">
        <dt id="N2"><p>A</p></dt>
      </dl>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <dl id="N0" type="roman">
        <dt id="N"><p>A</p></dt>
      </dl>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <dl id="note1l" type="alphabet">
        <dt id="note1"><p>A</p></dt>
      </dl>
          <dl id="note2l" type="roman_upper">
        <dt id="note2"><p>A</p></dt>
      </dl>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <dl id="ANl" type="alphabet_upper">
        <dt id="AN"><p>A</p></dt>
      </dl>
          </clause>
          <clause id="annex1b">
          <dl id="Anote1l" type="roman" start="4">
        <dt id="Anote1"><p>A</p></dt>
      </dl>
          <dl id="Anote2l">
        <dt id="Anote2"><p>A</p></dt>
      </dl>
          </clause>
          </annex>
                    <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <dl id="Anote3l">
        <dt id="Anote3"><p>A</p></dt>
      </dl>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="N1">A</semx>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="N2">A</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="N">A</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="note1l">1</semx>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="note1">A</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="note2l">2</semx>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="note2">A</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="AN">A</semx>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="Anote1l">1</semx>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="Anote1">A</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <semx element="autonum" source="Anote2l">2</semx>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="Anote2">A</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="Anote3">A</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references definition list terms that are stem expressions" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      </p>
      </foreword>
      <introduction id="intro">
      <dl id="N01">
      <dt id="N1"><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mover accent="true"><mrow><mi>e</mi></mrow><mo>^</mo></mover></mrow><mrow><mi>r</mi></mrow></msub></math></stem>
      <index><primary>
      <stem type="MathML">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <msub>
            <mrow>
              <mover accent="true">
                <mrow>
                  <mi>e</mi>
                </mrow>
                <mo>^</mo>
              </mover>
            </mrow>
            <mrow>
              <mi>r</mi>
            </mrow>
          </msub>
        </math>
      </stem>
      </primary></index></dt><dd>
      <p id="_543e0447-dfc6-477e-00cb-1738d6853190"><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>r</mi></math></stem>-direction</p>
      </dd>
            </dl>
                </clause>
                </annex>
                </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
            <semx element="introduction" source="intro">Introduction</semx>
         </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Definition List</span>
                 <span class="fmt-autonum-delim">:</span>
                 <semx element="autonum" source="N1">
                    <stem type="MathML">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                          <msub>
                             <mrow>
                                <mover accent="true">
                                   <mrow>
                                      <mi>e</mi>
                                   </mrow>
                                   <mo>^</mo>
                                </mover>
                             </mrow>
                             <mrow>
                                <mi>r</mi>
                             </mrow>
                          </msub>
                       </math>
                       <asciimath>hat(e)_(r)</asciimath>
                    </stem>
                 </semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
