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
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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

    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)

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
                      \\u2005
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
                      \\u2005
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
                      \\u2005
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
                      \\u2005
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
                      \\u2005
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
                      \\u2005
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
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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
                     ISO\\u00a0712
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
                     ISO\\u00a0712
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
                     ISO\\u00a0713
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
