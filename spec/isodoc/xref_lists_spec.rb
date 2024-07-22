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
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, List</xref>
          <xref target='N2'>Preparatory, List</xref>
          <xref target='N'>Clause 1, List</xref>
          <xref target='note1'>Clause 3.1, List 1</xref>
          <xref target='note2'>Clause 3.1, List 2</xref>
          <xref target='AN'>Annex A.1, List</xref>
          <xref target='Anote1'>Annex A.2, List 1</xref>
          <xref target='Anote2'>Annex A.2, List 2</xref>
          <xref target="Anote3">Bibliographical Section, List</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
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
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, a)</xref>
          <xref target='N11'>Introduction, a) 1)</xref>
          <xref target='N12'>Introduction, a) 1) i)</xref>
          <xref target='N2'>Preparatory, 1)</xref>
          <xref target='N'>Clause 1, i)</xref>
          <xref target='note1'>Clause 3.1, List 1 a)</xref>
          <xref target='note2'>Clause 3.1, List 2 I)</xref>
          <xref target='AN'>Annex A.1, A)</xref>
          <xref target='Anote1'>Annex A.2, List 1 iv)</xref>
          <xref target='Anote2'>Annex A.2, List 2 a)</xref>
          <xref target="Anote3">Bibliographical Section, a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
      <foreword displayorder="2">
         <p>
           <xref target="N1">Introductionのa)</xref>
           <xref target="N11">Introductionのa)の1)</xref>
           <xref target="N12">Introductionのa)の1)のi)</xref>
           <xref target="N2">Preparatoryの1)</xref>
           <xref target="N">箇条 1のi)</xref>
           <xref target="note1">箇条 3.1のリスト  1のa)</xref>
           <xref target="note2">箇条 3.1のリスト  2のI)</xref>
           <xref target="AN">附属書 A.1のA)</xref>
           <xref target="Anote1">附属書 A.2のリスト  1のiv)</xref>
           <xref target="Anote2">附属書 A.2のリスト  2のa)</xref>
           <xref target="Anote3">Bibliographical Sectionのa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
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
      <foreword displayorder='2'>
        <p>
          <xref target='N'>Clause 1, a)</xref>
          <xref target='note1'>Clause 1, a) 1)</xref>
          <xref target='note2'>Clause 1, a) 1) i)</xref>
          <xref target='AN'>Clause 1, a) 1) i) A)</xref>
          <xref target='Anote1'>Clause 1, a) 1) i) A) I)</xref>
          <xref target='Anote2'>Clause 1, a) 1) i) A) I) a)</xref>
          <xref target="P">Clause 2, List  1 a)</xref>
          <xref target="Q">Clause 2, List  1 a) 1)</xref>
          <xref target="R">Clause 2, List  1 a) 1) i)</xref>
          <xref target="S">Clause 2, List  1 a) 1) i) A)</xref>
          <xref target="P1">Clause 2, List  2 a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
      <foreword displayorder="2">
         <p>
           <xref target="N">箇条 1のa)</xref>
           <xref target="note1">箇条 1のa)の1)</xref>
           <xref target="note2">箇条 1のa)の1)のi)</xref>
           <xref target="AN">箇条 1のa)の1)のi)のA)</xref>
           <xref target="Anote1">箇条 1のa)の1)のi)のA)のI)</xref>
           <xref target="Anote2">箇条 1のa)の1)のi)のA)のI)のa)</xref>
           <xref target="P">箇条 2のリスト  1のa)</xref>
            <xref target="Q">箇条 2のリスト  1のa)の1)</xref>
            <xref target="R">箇条 2のリスト  1のa)の1)のi)</xref>
            <xref target="S">箇条 2のリスト  1のa)の1)のi)のA)</xref>
            <xref target="P1">箇条 2のリスト  2のa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
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
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, Definition List</xref>
          <xref target='N2'>Preparatory, Definition List</xref>
          <xref target='N'>Clause 1, Definition List</xref>
          <xref target='note1'>Clause 3.1, Definition List 1</xref>
          <xref target='note2'>Clause 3.1, Definition List 2</xref>
          <xref target='AN'>Annex A.1, Definition List</xref>
          <xref target='Anote1'>Annex A.2, Definition List 1</xref>
          <xref target='Anote2'>Annex A.2, Definition List 2</xref>
          <xref target="Anote3">Bibliographical Section, Definition List</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
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
      <foreword displayorder='2'>
        <p>
        <xref target='N1'>Introduction, Definition List: A</xref>
        <xref target='N2'>Preparatory, Definition List: A</xref>
        <xref target='N'>Clause 1, Definition List: A</xref>
        <xref target='note1'>Clause 3.1, Definition List 1: A</xref>
        <xref target='note2'>Clause 3.1, Definition List 2: A</xref>
        <xref target='AN'>Annex A.1, Definition List: A</xref>
        <xref target='Anote1'>Annex A.2, Definition List 1: A</xref>
        <xref target='Anote2'>Annex A.2, Definition List 2: A</xref>
        <xref target="Anote3">Bibliographical Section, Definition List: A</xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
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
         <foreword displayorder='2'>
           <p><xref target="N1">Introduction, Definition List: <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mover accent="true"><mrow><mi>e</mi></mrow><mo>^</mo></mover></mrow><mrow><mi>r</mi></mrow></msub></math><asciimath>hat(e)_(r)</asciimath></stem>
      </xref>
           </p>
         </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
