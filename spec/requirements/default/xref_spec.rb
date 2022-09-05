require "spec_helper"

RSpec.describe Metanorma::Requirements::Default do
  it "cross-references requirements" do
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
          </p>
          </foreword>
          <introduction id="intro">
          <requirement id="N1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement id="N2" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement id="N" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement id="note1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement id="note2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement id="AN" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement id="Anote1" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement id="Anote2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword displayorder='1'>
            <p>
              <xref target='N1'>Introduction, Requirement 1</xref>
      <xref target='N2'>Preparatory, Requirement (??)</xref>
      <xref target='N'>Clause 1, Requirement 2</xref>
      <xref target='note1'>Clause 3.1, Requirement 3</xref>
      <xref target='note2'>Clause 3.1, Requirement 4</xref>
      <xref target='AN'>Requirement A.1</xref>
      <xref target='Anote1'>Requirement (??)</xref>
      <xref target='Anote2'>Requirement A.2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirements in French" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <bibdata><language>fr</language></bibdata>
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
          </p>
          </foreword>
          <introduction id="intro">
          <requirement id="N1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement id="N2" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement id="N" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement id="note1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement id="note2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement id="AN" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement id="Anote1" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement id="Anote2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword displayorder='1'>
            <p>
              <xref target='N1'>Introduction, Exigence 1</xref>
      <xref target='N2'>Preparatory, Exigence (??)</xref>
      <xref target='N'>Article 1, Exigence 2</xref>
      <xref target='note1'>Article 3.1, Exigence 3</xref>
      <xref target='note2'>Article 3.1, Exigence 4</xref>
      <xref target='AN'>Exigence A.1</xref>
      <xref target='Anote1'>Exigence (??)</xref>
      <xref target='Anote2'>Exigence A.2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references recommendations" do
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
          </p>
          </foreword>
          <introduction id="intro">
          <recommendation id="N1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <clause id="xyz"><title>Preparatory</title>
          <recommendation id="N2" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <recommendation id="N" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <recommendation id="note1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation id="note2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <recommendation id="AN" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          <clause id="annex1b">
          <recommendation id="Anote1" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation id="Anote2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword displayorder='1'>
            <p>
              <xref target='N1'>Introduction, Recommendation 1</xref>
      <xref target='N2'>Preparatory, Recommendation (??)</xref>
      <xref target='N'>Clause 1, Recommendation 2</xref>
      <xref target='note1'>Clause 3.1, Recommendation 3</xref>
      <xref target='note2'>Clause 3.1, Recommendation 4</xref>
      <xref target='AN'>Recommendation A.1</xref>
      <xref target='Anote1'>Recommendation (??)</xref>
      <xref target='Anote2'>Recommendation A.2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references permissions" do
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
          </p>
          </foreword>
          <introduction id="intro">
          <permission id="N1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <clause id="xyz"><title>Preparatory</title>
          <permission id="N2" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <permission id="N" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <permission id="note1" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission id="note2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <permission id="AN" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          <clause id="annex1b">
          <permission id="Anote1" unnumbered="true" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission id="Anote2" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
                 <foreword displayorder='1'>
                   <p>
                     <xref target='N1'>Introduction, Permission 1</xref>
      <xref target='N2'>Preparatory, Permission (??)</xref>
      <xref target='N'>Clause 1, Permission 2</xref>
      <xref target='note1'>Clause 3.1, Permission 3</xref>
      <xref target='note2'>Clause 3.1, Permission 4</xref>
      <xref target='AN'>Permission A.1</xref>
      <xref target='Anote1'>Permission (??)</xref>
      <xref target='Anote2'>Permission A.2</xref>
                   </p>
                 </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "labels and cross-references nested requirements" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      <xref target="N2"/>
      <xref target="N"/>
      <xref target="Q1"/>
      <xref target="R1"/>
      <xref target="AN1"/>
      <xref target="AN2"/>
      <xref target="AN"/>
      <xref target="AQ1"/>
      <xref target="AR1"/>
      </p>
      </foreword>
      </preface>
      <sections>
      <clause id="xyz"><title>Preparatory</title>
      <permission id="N1" model="default">
      <permission id="N2" model="default">
      <permission id="N" model="default">
      </permission>
      </permission>
      <requirement id="Q1" model="default">
      </requirement>
      <recommendation id="R1" model="default">
      </recommendation>
      </permission>
      </clause>
      </sections>
      <annex id="Axyz"><title>Preparatory</title>
      <permission id="AN1" model="default">
      <permission id="AN2" model="default">
      <permission id="AN" model="default">
      </permission>
      </permission>
      <requirement id="AQ1" model="default">
      </requirement>
      <recommendation id="AR1" model="default">
      </recommendation>
      </permission>
      </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
                <foreword displayorder='1'>
                  <p>
                     <xref target='N1'>Clause 1, Permission 1</xref>
      <xref target='N2'>Clause 1, Permission 1-1</xref>
      <xref target='N'>Clause 1, Permission 1-1-1</xref>
      <xref target='Q1'>Clause 1, Requirement 1-1</xref>
      <xref target='R1'>Clause 1, Recommendation 1-1</xref>
      <xref target='AN1'>Permission A.1</xref>
      <xref target='AN2'>Permission A.1-1</xref>
      <xref target='AN'>Permission A.1-1-1</xref>
      <xref target='AQ1'>Requirement A.1-1</xref>
      <xref target='AR1'>Recommendation A.1-1</xref>
                  </p>
                </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
