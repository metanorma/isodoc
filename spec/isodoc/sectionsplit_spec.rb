require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section split HTML" do
    FileUtils.rm_f "test.xml"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title>ISO Title</title>
      <docidentifier type="ISO">ISO 1</docidentifier>
      </bibdata>
      <preface>
      <abstract id="A"><title>abstract</title></abstract>
      <introduction id="B"><title>introduction</title></introduction>
      <note id="C">note</note>
      </preface>
      <sections>
       <clause id="M" inline-header="false" obligation="normative">
         <title>Clause 4</title>
         <clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
         <p><xref target="A"/></p>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
       <admonition id="L" type="caution"><p>admonition</p></admonition>
       </sections>
       <annex id="P" inline-header="false" obligation="normative">
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
    IsoDoc::HtmlConvert.new({ sectionsplit: "true" }).convert("test", input, true)
  end
end
