require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section split HTML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html.yaml"
    FileUtils.rm_rf "test_collection"
    FileUtils.rm_rf "test_files"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title>ISO Title</title>
      <docidentifier type="ISO">ISO 1</docidentifier>
      </bibdata>
      <preface>
      <abstract id="A" displayorder='1'><title>abstract</title></abstract>
      <introduction id="B" displayorder='2'><title>introduction</title></introduction>
      </preface>
      <sections>
       <clause id="M" inline-header="false" obligation="normative" displayorder='4'>
         <title>Clause 4</title>
         <clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
         <p><xref target="A">HE</xref></p>
         <p><eref bibitemid="R1">SHE</xref></p>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
       <admonition id="L" type="caution"><p>admonition</p></admonition>
       </sections>
       <annex id="P" inline-header="false" obligation="normative" displayorder='5'>
         <title><strong>Annex</strong><br/>(informative)</title>
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
       <annex id="P1" inline-header="false" obligation="normative" displayorder='6'>
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true" displayorder='3'>
         <title>Normative References</title>
         <bibitem id="R1"><docidentifier>R1</docidentifier><title>Hello</title></bibitem>
       </references><clause id="S" obligation="informative" displayorder='7'>
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
      </iso-standard>
    INPUT
    IsoDoc::HtmlConvert.new({ sectionsplit: "true" })
      .convert("test", input, true)
    expect(File.exist?("test_collection/index.html")).to be true
    expect(File.exist?("test_collection/test.0.html")).to be true
    expect(File.exist?("test_collection/test.1.html")).to be true
    expect(File.exist?("test_collection/test.2.html")).to be true
    expect(File.exist?("test_collection/test.3.html")).to be false
    expect(File.exist?("test_collection/test.4.html")).to be true
    expect(File.exist?("test_collection/test.5.html")).to be true
    expect(File.exist?("test_collection/test.6.html")).to be true
    expect(File.exist?("test_collection/test.7.html")).to be true
    expect(File.exist?("test_collection/test.8.html")).to be false
    expect(File.exist?("test_files/cover.html")).to be true
    expect(File.exist?("test_files/test.0.xml")).to be true
    expect(File.exist?("test_files/test.1.xml")).to be true
    expect(File.exist?("test_files/test.2.xml")).to be true
    expect(File.exist?("test_files/test.3.xml")).to be true
    expect(File.exist?("test_files/test.4.xml")).to be true
    expect(File.exist?("test_files/test.5.xml")).to be true
    expect(File.exist?("test_files/test.6.xml")).to be true
    expect(File.exist?("test_files/test.7.xml")).to be true
    expect(File.exist?("test_files/test.8.xml")).to be false
    expect(File.exist?("test_files/test.html.yaml")).to be true
    m = /type="([^"]+)"/.match(File.read("test_files/test.0.xml"))
    expect(File.read("test_files/test.2.xml")).to include <<~OUTPUT.strip
      <eref bibitemid="#{m[1]}_A" type="#{m[1]}">HE<localityStack><locality type="anchor"><referenceFrom>A</referenceFrom></locality></localityStack></eref>
    OUTPUT
    expect(File.read("test_files/test.2.xml")).to include <<~OUTPUT.strip
      <eref bibitemid="#{m[1]}_R1" type="#{m[1]}">SHE<localityStack><locality type="anchor"><referenceFrom>#{m[1]}_R1</referenceFrom></locality></localityStack></eref>
    OUTPUT
    expect(File.read("test_files/test.2.xml")).to include <<~OUTPUT
      <bibitem id="#{m[1]}_R1" type="internal">
      <docidentifier type="repository">#{m[1]}/R1</docidentifier>
      </bibitem>
    OUTPUT
    expect(File.read("test_files/test.2.xml")).to include <<~OUTPUT
      <bibitem id="#{m[1]}_A" type="internal">
      <docidentifier type="repository">#{m[1]}/A</docidentifier>
      </bibitem>
    OUTPUT
    expect(File.read("test_files/test.html.yaml")).to be_equivalent_to <<~OUTPUT
      ---
      directives:
      - presentation-xml
      - bare-after-first
      bibdata:
        title:
          type: title-main
          language: en
          content: ISO Title
        type: collection
        docid:
          type: ISO
          id: ISO 1
      manifest:
        level: collection
        title: Collection
        docref:
        - fileref: test.3.xml
          identifier: "[Untitled]"
        - fileref: test.0.xml
          identifier: abstract
        - fileref: test.1.xml
          identifier: introduction
        - fileref: test.6.xml
          identifier: Normative References
        - fileref: test.2.xml
          identifier: Clause 4
        - fileref: test.4.xml
          identifier: Annex (informative)
        - fileref: test.5.xml
          identifier: "[Untitled]"
        - fileref: test.7.xml
          identifier: Bibliography
    OUTPUT
  end
end
