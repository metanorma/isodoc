require "spec_helper"

RSpec.describe IsoDoc do
  it "realises subsequences" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N1"/>
        <xref target="N2"/>
        <xref target="N3"/>
        <xref target="N4"/>
        <xref target="N5"/>
        <xref target="N6"/>
        <xref target="N7"/>
        <xref target="N8"/>
        </p>
        </foreword>
            <introduction id="intro">
            <figure id="N1"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N2" subsequence="A"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N3" subsequence="A"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N4" subsequence="B"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N5" subsequence="B"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N6" subsequence="B"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N7"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N8"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
      </introduction>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword id='fwd' displayorder="2">
            <p>
              <xref target='N1'>Figure 1</xref>
      <xref target='N2'>Figure 2a</xref>
      <xref target='N3'>Figure 2b</xref>
      <xref target='N4'>Figure 3a</xref>
      <xref target='N5'>Figure 3b</xref>
      <xref target='N6'>Figure 3c</xref>
      <xref target='N7'>Figure 4</xref>
      <xref target='N8'>Figure 5</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "realises numbering overrides" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N1"/>
        <xref target="N2"/>
        <xref target="N3"/>
        <xref target="N4"/>
        <xref target="N5"/>
        <xref target="N6"/>
        <xref target="N7"/>
        <xref target="N8"/>
        <xref target="N9"/>
        <xref target="N10"/>
        <xref target="N11"/>
        <xref target="N12"/>
        <xref target="N13"/>
        </p>
        <p>
        <xref target="S1"/>
        <xref target="S2"/>
        <xref target="S3"/>
        <xref target="S4"/>
        <xref target="S12"/>
        <xref target="S13"/>
        <xref target="S14"/>
        <xref target="S15"/>
        <xref target="S16"/>
        <xref target="S17"/>
        <xref target="S18"/>
        <xref target="S19"/>
        <xref target="S20"/>
        <xref target="S21"/>
        <xref target="S22"/>
        <xref target="S23"/>
        <xref target="S24"/>
        <xref target="S25"/>
        <xref target="S26"/>
        <xref target="S27"/>
        <xref target="S28"/>
        <xref target="S29"/>
        <xref target="S30"/>
        </p>
        </foreword>
            <introduction id="intro">
            <figure id="N1"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N2" number="A"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N3"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N4" number="7"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N5"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N6" subsequence="B"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N7" subsequence="B" number="c"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N8" subsequence="B"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N9" subsequence="C" number="20f"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N10" subsequence="C"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N11" number="A.1"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N12"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
            <figure id="N13" number="100"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
      </introduction>
      </preface>
      <sections>
      <clause id='S1' number='1bis' type='scope' inline-header='false' obligation='normative'>
                 <title>Scope</title>
                 <p id='_'>Text</p>
               </clause>
               <terms id='S3' number='3bis' obligation='normative'>
                 <title>Terms and definitions</title>
                 <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
                 <term id='S4' number='4bis'>
                   <preferred><expression><name>Term1</name></expression></preferred>
                 </term>
               </terms>
               <definitions id='S12' number='12bis' type='abbreviated_terms' obligation='normative'>
                 <title>Abbreviated terms</title>
               </definitions>
               <clause id='S13' number='13bis' inline-header='false' obligation='normative'>
                 <title>Clause 4</title>
                 <clause id='S14' number='14bis' inline-header='false' obligation='normative'>
                   <title>Introduction</title>
                 </clause>
                 <clause id='S15' inline-header='false' obligation='normative'>
                   <title>Clause A</title>
                 </clause>
                 <clause id='S16' inline-header='false' obligation='normative'>
                   <title>Clause B</title>
                 </clause>
                 <clause id='S17' number='0' inline-header='false' obligation='normative'>
                   <title>Clause C</title>
                 </clause>
                 <clause id='S18' inline-header='false' obligation='normative'>
                   <title>Clause D</title>
                 </clause>
                 <clause id='S19' inline-header='false' obligation='normative'>
                   <title>Clause E</title>
                 </clause>
                 <clause id='S20' number='a' inline-header='false' obligation='normative'>
                   <title>Clause F</title>
                 </clause>
                 <clause id='S21' inline-header='false' obligation='normative'>
                   <title>Clause G</title>
                 </clause>
                 <clause id='S22' number='B' inline-header='false' obligation='normative'>
                   <title>Clause H</title>
                 </clause>
                 <clause id='S23' inline-header='false' obligation='normative'>
                   <title>Clause I</title>
                 </clause>
               </clause>
               <clause id='S24' number='16bis' inline-header='false' obligation='normative'>
                 <title>Terms and Definitions</title>
               </clause>
             </sections>
             <annex id='S25' obligation='normative'>
             <title>First Annex</title>
             </annex>
             <annex id='S26' number='17bis' inline-header='false' obligation='normative'>
               <title>Annex</title>
               <clause id='S27' number='18bis' inline-header='false' obligation='normative'>
                 <title>Annex A.1</title>
               </clause>
             </annex>
             <annex id='S28' inline-header='false' obligation='normative'>
             <title>Another Annex</title>
             </annex>
             <bibliography>
               <references id='S2' number='2bis' normative='true' obligation='informative'>
                 <title>Normative references</title>
                 <p id='_'>There are no normative references in this document.</p>
               </references>
               <clause id='S29' number='19bis' obligation='informative'>
                 <title>Bibliography</title>
                 <references id='S30' number='20bis' normative='false' obligation='informative'>
                   <title>Bibliography Subsection</title>
                 </references>
               </clause>
             </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id='fwd' displayorder='2'>
        <p>
          <xref target='N1'>Figure 1</xref>
          <xref target='N2'>Figure A</xref>
          <xref target='N3'>Figure B</xref>
          <xref target='N4'>Figure 7</xref>
          <xref target='N5'>Figure 8</xref>
          <xref target='N6'>Figure 9a</xref>
          <xref target='N7'>Figure 9c</xref>
          <xref target='N8'>Figure 9d</xref>
          <xref target='N9'>Figure 20f</xref>
          <xref target='N10'>Figure 20g</xref>
          <xref target='N11'>Figure A.1</xref>
          <xref target='N12'>Figure A.2</xref>
          <xref target='N13'>Figure 100</xref>
        </p>
        <p>
          <xref target='S1'>Clause 1bis</xref>
          <xref target='S2'>Clause 2bis</xref>
          <xref target='S3'>Clause 3bis</xref>
          <xref target='S4'>Clause 3bis.4bis</xref>
          <xref target='S12'>Clause 12bis</xref>
          <xref target='S13'>Clause 13bis</xref>
          <xref target='S14'>Clause 13bis.14bis</xref>
          <xref target='S15'>Clause 13bis.14bit</xref>
          <xref target='S16'>Clause 13bis.14biu</xref>
          <xref target='S17'>Clause 13bis.0</xref>
          <xref target='S18'>Clause 13bis.1</xref>
          <xref target='S19'>Clause 13bis.2</xref>
          <xref target='S20'>Clause 13bis.a</xref>
          <xref target='S21'>Clause 13bis.b</xref>
          <xref target='S22'>Clause 13bis.B</xref>
          <xref target='S23'>Clause 13bis.C</xref>
          <xref target='S24'>Clause 16bis</xref>
          <xref target='S25'>Annex A</xref>
          <xref target='S26'>Annex 17bis</xref>
          <xref target='S27'>Annex 17bis.18bis</xref>
          <xref target='S28'>Annex 17bit</xref>
          <xref target='S29'>Bibliography</xref>
          <xref target='S30'>Bibliography Subsection</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "realises branch-numbering overrides" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="S1"/>
        <xref target="S2"/>
        <xref target="S3"/>
        <xref target="S4"/>
        <xref target="S5"/>
        <xref target="S6"/>
        <xref target="S7"/>
        <xref target="S7a"/>
        <xref target="S8"/>
        <xref target="S9"/>
        <xref target="S10"/>
        <xref target="S10a"/>
        <xref target="S11"/>
        <xref target="S12"/>
        <xref target="S13"/>
        <xref target="S14"/>
        <xref target="S15"/>
        <xref target="S16"/>
        <xref target="S17"/>
        <xref target="S18"/>
        <xref target="S19"/>
        <xref target="S20"/>
        <xref target="S21"/>
        <xref target="S22"/>
        <xref target="S23"/>
        <xref target="S24"/>
        </p>
        </foreword>
      </preface>
      <sections>
      <clause id='S1' type='scope' inline-header='false' obligation='normative'>
                 <title>Scope</title>
                 <p id='_'>Text</p>
            <clause id="S2"><title>Subclause 1</title></clause>
            <clause branch-number="123" id="S3"><title>Subclause 2</title></clause>
            <clause id="S4"><title>Subsubclause 1</title></clause>
      </clause>
      <clause id="S5"><title>Subclause 3</title>
               <clause id="S6" branch-number="124"><title>Subclause 2</title>
                  <clause id="S7"><title>Subclause 2</title></clause>
               </clause>
               <clause id="S7a"><title>Subclause 2</title></clause>
      </clause>
      <clause id="S8" branch-number="125"><title>Clause 3</title>
          <clause id="S9" branch-number="126"><title>Subclause 2</title></clause>
          <clause id="S10"><title>Subclause 2</title></clause>
      </clause>
      <clause id="S10a">
               <terms id='S11' branch-number='3bis' obligation='normative'>
                 <title>Terms and definitions</title>
                 <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
                 <term id='S12' branch-number='4bis'>
                   <preferred><expression><name>Term1</name></expression></preferred>
                 </term>
                 <term id='S13' number='4bis'>
                   <preferred><expression><name>Term1</name></expression></preferred>
                 </term>
                 <term id='S14'>
                   <preferred><expression><name>Term1</name></expression></preferred>
                 </term>
               </terms>
               <definitions id='S15' branch-number='12bis' type='abbreviated_terms' obligation='normative'>
                 <title>Abbreviated terms</title>
               </definitions>
               </clause>
             </sections>
             <annex id='S16' obligation='normative'>
             <title>First Annex</title>
            <clause id="S17"><title>Subclause 1</title></clause>
            <clause branch-number="123" id="S18"><title>Subclause 2</title></clause>
            <clause id="S19"><title>Subsubclause 1</title></clause>
             </annex>
             <annex id='S20' branch-number='17bis' inline-header='false' obligation='normative'>
               <title>Annex</title>
            <clause id="S21"><title>Subclause 1</title></clause>
            <clause branch-number="123" id="S22"><title>Subclause 2</title></clause>
            <clause id="S23"><title>Subsubclause 1</title></clause>
             </annex>
             <bibliography>
               <references id='S24' branch-number='2bis' normative='true' obligation='informative'>
                 <title>Normative references</title>
                 <p id='_'>There are no normative references in this document.</p>
               </references>
             </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="fwd" displayorder="2">
         <p>
           <xref target="S1">Clause 1</xref>
           <xref target="S2">Clause 1.1</xref>
           <xref target="S3">Clause 123</xref>
           <xref target="S4">Clause 1.2</xref>
           <xref target="S5">Clause 3</xref>
           <xref target="S6">Clause 124</xref>
           <xref target="S7">Clause 124.1</xref>
           <xref target="S7a">Clause 3.1</xref>
           <xref target="S8">Clause 125</xref>
           <xref target="S9">Clause 126</xref>
           <xref target="S10a">Clause 2</xref>
           <xref target="S10">Clause 125.1</xref>
           <xref target="S11">Clause 3bis</xref>
           <xref target="S12">Clause 4bis</xref>
           <xref target="S13">Clause 3bis.4bis</xref>
           <xref target="S14">Clause 3bis.4bit</xref>
           <xref target="S15">Clause 12bis</xref>
           <xref target="S16">Annex A</xref>
           <xref target="S17">Annex A.1</xref>
           <xref target="S18">Annex 123</xref>
           <xref target="S19">Annex A.2</xref>
           <xref target="S20">Annex B</xref>
           <xref target="S21">Annex B.1</xref>
           <xref target="S22">Annex 123</xref>
           <xref target="S23">Annex B.2</xref>
           <xref target="S24">Clause 2bis</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end


  it "realises roman counter for xrefs" do
    a = IsoDoc::XrefGen::Counter.new(0, numerals: :roman)
    a.increment({})
    expect(a.print).to eq "I"
    a.increment({})
    expect(a.print).to eq "II"
    a.increment({})
    expect(a.print).to eq "III"
    a.increment({})
    expect(a.print).to eq "IV"
    a.increment({})
    expect(a.print).to eq "V"
  end

  it "skips I in counter for xrefs" do
    a = IsoDoc::XrefGen::Counter.new("@", skip_i: true)
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    expect(a.print).to eq "H"
    a.increment({})
    expect(a.print).to eq "J"
    a = IsoDoc::XrefGen::Counter.new("@")
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    a.increment({})
    expect(a.print).to eq "H"
    a.increment({})
    expect(a.print).to eq "I"
  end

  it "increments counter past Z for xrefs" do
    a = IsoDoc::XrefGen::Counter.new("Z")
    a.increment({})
    expect(a.print).to eq "AA"
    a.increment({})
    expect(a.print).to eq "AB"
    a = IsoDoc::XrefGen::Counter.new("BZ")
    a.increment({})
    expect(a.print).to eq "CA"
    a.increment({})
    expect(a.print).to eq "CB"
    a = IsoDoc::XrefGen::Counter.new("z")
    a.increment({})
    expect(a.print).to eq "aa"
    a.increment({})
    expect(a.print).to eq "ab"
    a = IsoDoc::XrefGen::Counter.new("Az")
    a.increment({})
    expect(a.print).to eq "Ba"
    a.increment({})
    expect(a.print).to eq "Bb"
  end

  it "returns initial unincremented value" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword id="fwd">
      <note id="A" unnumbered="true"/>
      <note id="B" unnumbered="false"/>
      <note id="C" unnumbered="true"/>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id='fwd' displayorder='2'>
         <note id='A' unnumbered='true'>
           <name>NOTE </name>
         </note>
         <note id='B' unnumbered='false'>
           <name>NOTE </name>
         </note>
         <note id='C' unnumbered='true'>
           <name>NOTE </name>
         </note>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
