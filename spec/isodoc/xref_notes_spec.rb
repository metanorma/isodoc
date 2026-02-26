require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes" do
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
          <note id="N1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <clause id="xyz"><title>Preparatory</title>
          <note id="N2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <note id="N">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <note id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <note id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          <clause id="annex1b">
          <note id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <note id="Anote3">
            <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
          </note>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="_" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-xref-container">
                      <semx element="introduction" source="intro">Introduction</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-xref-container">
                      <semx element="clause" source="xyz">Preparatory</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote3">
                   <span class="fmt-xref-container">
                      <semx element="references" source="biblio">Bibliographical Section</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output
  end

  it "cross-references box admonitions in English and Japanese" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N3"/>
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
          <admonition type="box" id="N1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
      <clause id="xyz"><title>Preparatory</title>
          <admonition type="box" id="N2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
      <admonition type="tip" id="N3">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <admonition type="box" id="N">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <admonition type="box" id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
          <admonition type="box" id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <admonition type="box" id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
          </clause>
          <clause id="annex1b">
          <admonition type="box" id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
          <admonition type="box" id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </admonition>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <admonition type="box" id="Anote3">
            <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
          </admonition>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="N1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N1">
                  <span class="fmt-xref-container">
                     <semx element="introduction" source="intro">Introduction</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
               </fmt-xref>
            </semx>
            <xref target="N2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N2">
                  <span class="fmt-xref-container">
                     <semx element="clause" source="xyz">Preparatory</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
               </fmt-xref>
            </semx>
            <xref target="N3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N3">[N3]</fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="scope">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
               </fmt-xref>
            </semx>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="widgets">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="widgets1">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="widgets">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="widgets1">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
                  <semx element="autonum" source="note2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="AN" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="AN">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="annex1">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="annex1a">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
               </fmt-xref>
            </semx>
            <xref target="Anote1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote1">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="annex1">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="annex1b">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
                  <semx element="autonum" source="Anote1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="annex1">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="annex1b">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
                  <semx element="autonum" source="Anote2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote3">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Box</span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT

    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output

    input1 = input.sub(%r{<language>en</language>},
                       "<language>ja</language>")
    output = <<~OUTPUT
      <foreword id="_" displayorder="2">
          <title id="_">まえがき</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">まえがき</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-xref-container">
                      <semx element="introduction" source="intro">序文</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-xref-container">
                      <semx element="clause" source="xyz">Preparatory</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                </fmt-xref>
             </semx>
             <xref target="N3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N3">[N3]</fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">箇条</span>
                      \u2005
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">箇条</span>
                      \u2005
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">箇条</span>
                      \u2005
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                   <semx element="autonum" source="note2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">附属書</span>
                      \u2005
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">附属書</span>
                      \u2005
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                   <semx element="autonum" source="Anote1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">附属書</span>
                      \u2005
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote3">
                   <span class="fmt-xref-container">
                      <semx element="references" source="biblio">Bibliographical Section</semx>
                   </span>
                   <span class="fmt-conn">の</span>
                   <span class="fmt-element-name">Box</span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output
  end

  it "cross-references term notes" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="note3"/>
          <xref target="note1"><location target="note1" connective="and"/><location target="note2" connective="and"/></xref>
          <xref target="note2"><location target="note2" connective="and"/><location target="note3" connective="and"/></xref>
          </p>
          </foreword>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          </clause>
          <terms id="terms">
      <term id="waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termnote id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote></term>
      <term id="nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
      <termnote id="note2">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="note3">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote></term>
      </terms>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="waxy_rice">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="nonwaxy_rice">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note3">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="nonwaxy_rice">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note3">2</semx>
               </fmt-xref>
            </semx>
            <xref target="note1" id="_">
               <location target="note1" connective="and"/>
               <location target="note2" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="waxy_rice">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
               <span class="fmt-conn">and</span>
               <fmt-xref target="note2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="nonwaxy_rice">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_">
               <location target="note2" connective="and"/>
               <location target="note3" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="terms">2</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="nonwaxy_rice">2</semx>
               </span>
               <span class="fmt-comma">,</span>
               <fmt-xref target="note2">
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">1</semx>
               </fmt-xref>
               <span class="fmt-conn">and</span>
               <fmt-xref target="note3">
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note3">2</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output
  end

  it "cross-references nested term notes" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="note3"/>
          </p>
          </foreword>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          </clause>
          <terms id="terms">
      <term id="waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termnote id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <term id="nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
      <termnote id="note2">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="note3">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote></term></term>
      </terms>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="waxy_rice">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="waxy_rice">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="nonwaxy_rice">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note3">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="terms">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="waxy_rice">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="nonwaxy_rice">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note3">2</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output
  end

  it "cross-references bibliographic notes" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="note3"/>
          </p>
          </foreword>
          </preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <note id="note1">Note</note>
      <note id="note2">Note</note>
      </references></bibliography>
      <bibliography><references id="_bibliography" obligation="informative" normative="false"><title>Bibliography</title>
      <bibitem id="ISO713" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <note id="note3">Note</note>
      </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title depth="1" id="_">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-xref-container">
                     <span class="fmt-xref-container">
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="_normative_references">1</semx>
                     </span>
                     <span class="fmt-comma">,</span>
                     ISO\u00a0712
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-xref-container">
                     <span class="fmt-xref-container">
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="_normative_references">1</semx>
                     </span>
                     <span class="fmt-comma">,</span>
                     ISO\u00a0712
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="note3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note3">
                  <span class="fmt-xref-container">
                     <span class="fmt-xref-container">
                        <semx element="references" source="_bibliography">Bibliography</semx>
                     </span>
                     <span class="fmt-comma">,</span>
                     ISO\u00a0713
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output
  end

  it "cross-references notes nested in assets" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="scopeTN1"/>
        <xref target="scopeTN2"/>
        <xref target="scopeFN1"/>
        <xref target="scopeFN2"/>
        <xref target="scopeRN1"/>
        <xref target="scopeRN2"/>
        <xref target="scope2TN1"/>
        <xref target="scope2TN2"/>
        <xref target="scope2FN1"/>
        <xref target="scope2FN2"/>
        <xref target="scope2RN1"/>
        <xref target="scope2RN2"/>
        <xref target="annexTN1"/>
        <xref target="annexTN2"/>
        <xref target="annexFN1"/>
        <xref target="annexFN2"/>
        <xref target="annexRN1"/>
        <xref target="annexRN2"/>
        <xref target="annex2TN1"/>
        <xref target="annex2TN2"/>
        <xref target="annex2FN1"/>
        <xref target="annex2FN2"/>
        <xref target="annex2RN1"/>
        <xref target="annex2RN2"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
        <table id="scopeT">
        <tbody><td/></table>
        <note id="scopeTN1">Note <xref target="scopeTN2"/></note>
        <note id="scopeTN2">Note <xref target="scopeFN2"/></note>
        <note id="scopeTN3">Note <xref target="scope2TN2"/></note>
        </table>
        <figure id="scopeF">
        <literal>...</literal>
        <note id="scopeFN1">Note</note>
        <note id="scopeFN2">Note</note>
        </figure>
        <requirement id="scopeR" model="default">
        <note id="scopeRN1">Note</note>
        <note id="scopeRN2">Note</note>
        </requirement>
      </clause>
      <clause id="scope2"><title>Scope</title>
        <table id="scope2T">
        <tbody><td/></table>
        <note id="scope2TN1">Note</note>
        <note id="scope2TN2">Note</note>
        </table>
        <figure id="scope2F">
        <literal>...</literal>
        <note id="scope2FN1">Note</note>
        <note id="scope2FN2">Note</note>
        </figure>
        <requirement id="scopeR" model="default">
        <note id="scope2RN1">Note</note>
        <note id="scope2RN2">Note</note>
        </requirement>
      </clause>
      </sections>
      <annex id="annex">
        <table id="annexT">
        <tbody><td/></table>
        <note id="annexTN1">Note</note>
        <note id="annexTN2">Note</note>
        </table>
        <figure id="annexF">
        <literal>...</literal>
        <note id="annexFN1">Note</note>
        <note id="annexFN2">Note</note>
        </figure>
        <recommendation id="scopeR" model="default">
        <note id="annexRN1">Note</note>
        <note id="annexRN2">Note</note>
        </recommendation>
      </annex>
      <annex id="annex2">
        <table id="annex2T">
        <tbody><td/></table>
        <note id="annex2TN1">Note</note>
        <note id="annex2TN2">Note</note>
        </table>
        <figure id="annex2F">
        <literal>...</literal>
        <note id="annex2FN1">Note</note>
        <note id="annex2FN2">Note</note>
        </figure>
        <recommendation id="scopeR" model="default">
        <note id="annex2RN1">Note</note>
        <note id="annex2RN2">Note</note>
        </recommendation>
      </annex>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1" id="_">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="scopeTN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeTN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="scopeT">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeTN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeTN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeTN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="scopeT">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeTN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeFN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeFN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="scopeF">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeFN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeFN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeFN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="scopeF">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeFN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeRN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeRN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeRN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeRN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeRN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scopeRN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2TN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2TN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="scope2T">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2TN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2TN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2TN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="scope2T">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2TN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2FN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2FN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="scope2F">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2FN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2FN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2FN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="scope2F">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2FN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2RN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2RN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2RN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2RN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2RN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="scope2RN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annexTN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexTN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annexT">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexTN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annexTN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexTN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annexT">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexTN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annexFN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexFN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annexF">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexFN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annexFN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexFN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annexF">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexFN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annexRN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexRN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexRN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annexRN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexRN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annexRN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2TN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2TN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex2T">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2TN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2TN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2TN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex2T">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2TN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2FN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2FN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex2F">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2FN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2FN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2FN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex2F">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2FN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2RN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2RN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2RN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2RN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2RN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="annex2">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="scopeR">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="annex2RN2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_xml_equivalent_to output

    # test container_container scope references
    output = <<~OUTPUT
          <table id="scopeT" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Table</span>
               <semx element="autonum" source="scopeT">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Table</span>
            <semx element="autonum" source="scopeT">1</semx>
         </fmt-xref-label>
         <tbody>
            <td/>
         </tbody>
         <note id="scopeTN1" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">NOTE</span>
                  <semx element="autonum" source="scopeTN1">1</semx>
               </span>
               <span class="fmt-label-delim">
                  <tab/>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN1">1</semx>
            </fmt-xref-label>
            <fmt-xref-label container="scopeT">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Table</span>
                  <semx element="autonum" source="scopeT">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN1">1</semx>
            </fmt-xref-label>
            Note
            <xref target="scopeTN2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="scopeTN2">
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="scopeTN2">2</semx>
               </fmt-xref>
            </semx>
         </note>
         <note id="scopeTN2" autonum="2">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">NOTE</span>
                  <semx element="autonum" source="scopeTN2">2</semx>
               </span>
               <span class="fmt-label-delim">
                  <tab/>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN2">2</semx>
            </fmt-xref-label>
            <fmt-xref-label container="scopeT">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Table</span>
                  <semx element="autonum" source="scopeT">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN2">2</semx>
            </fmt-xref-label>
            Note
            <xref target="scopeFN2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="scopeFN2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Figure</span>
                     <semx element="autonum" source="scopeF">1</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="scopeFN2">2</semx>
               </fmt-xref>
            </semx>
         </note>
         <note id="scopeTN3" autonum="3">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">NOTE</span>
                  <semx element="autonum" source="scopeTN3">3</semx>
               </span>
               <span class="fmt-label-delim">
                  <tab/>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN3">3</semx>
            </fmt-xref-label>
            <fmt-xref-label container="scopeT">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Table</span>
                  <semx element="autonum" source="scopeT">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="scopeTN3">3</semx>
            </fmt-xref-label>
            Note
            <xref target="scope2TN2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="scope2TN2">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Table</span>
                     <semx element="autonum" source="scope2T">2</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="scope2TN2">2</semx>
               </fmt-xref>
            </semx>
         </note>
      </table>
    OUTPUT
    expect(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
     .new(presxml_options)
     .convert("test", input, true))
     .at("//xmlns:table[@id = 'scopeT']").to_xml))
      .to be_xml_equivalent_to output
  end
end
