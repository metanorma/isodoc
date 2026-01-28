require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references examples" do
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
              <example id="N1">
        <p>Hello</p>
      </example>
      <clause id="xyz"><title>Preparatory</title>
              <example id="N2" unnumbered="true">
        <p>Hello</p>
      </example>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
              <example id="N">
        <p>Hello</p>
      </example>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
              <example id="note1">
        <p>Hello</p>
      </example>
              <example id="note2" unnumbered="true">
        <p>Hello <xref target="note1"/></p>
      </example>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
              <example id="AN">
        <p>Hello</p>
      </example>
          </clause>
          <clause id="annex1b">
              <example id="Anote1" unnumbered="true">
        <p>Hello</p>
      </example>
              <example id="Anote2">
        <p>Hello</p>
      </example>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <example id="Anote3">
        <p>Hello</p>
      </example>
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
                  <span class="fmt-element-name">Example</span>
               </fmt-xref>
            </semx>
            <xref target="N2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N2">
                  <span class="fmt-xref-container">
                     <semx element="clause" source="xyz">Preparatory</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Example</span>
                  <semx element="autonum" source="N2">(??)</semx>
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
                  <span class="fmt-element-name">Example</span>
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
                  <span class="fmt-element-name">Example</span>
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
                  <span class="fmt-element-name">Example</span>
                  <semx element="autonum" source="note2">(??)</semx>
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
                  <span class="fmt-element-name">Example</span>
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
                  <span class="fmt-element-name">Example</span>
                  <semx element="autonum" source="Anote1">(??)</semx>
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
                  <span class="fmt-element-name">Example</span>
                  <semx element="autonum" source="Anote2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote3">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Example</span>
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

    output = <<~OUTPUT
      <clause id="widgets1">
          <fmt-title id="_" depth="2">
             <span class="fmt-caption-label">
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="widgets1">1</semx>
                <span class="fmt-autonum-delim">.</span>
             </span>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">Clause</span>
             <semx element="autonum" source="widgets">3</semx>
             <span class="fmt-autonum-delim">.</span>
             <semx element="autonum" source="widgets1">1</semx>
          </fmt-xref-label>
          <example id="note1" autonum="1">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">EXAMPLE</span>
                   <semx element="autonum" source="note1">1</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="note1">1</semx>
             </fmt-xref-label>
             <fmt-xref-label container="widgets1">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="widgets">3</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="widgets1">1</semx>
                </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="note1">1</semx>
             </fmt-xref-label>
             <p>Hello</p>
          </example>
          <example id="note2" unnumbered="true">
             <p>
                Hello
                <xref target="note1" id="_"/>
                <semx element="xref" source="_">
                   <fmt-xref target="note1">
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="note1">1</semx>
                   </fmt-xref>
                </semx>
             </p>
          </example>
          <p>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="note2">(??)</semx>
                </fmt-xref>
             </semx>
          </p>
       </clause>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id='widgets1']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references term examples" do
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
      <termexample id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample></term>
      <term id="nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
      <termexample id="note2">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample>
      <termexample id="note3">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample></term>
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
                  <span class="fmt-element-name">Example</span>
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
                  <span class="fmt-element-name">Example</span>
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
                  <span class="fmt-element-name">Example</span>
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

  it "cross-references nested term examples" do
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
      <termexample id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample>
      <term id="nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
      <termexample id="note2">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample>
      <termexample id="note3">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample></term></term>
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
                   <span class="fmt-element-name">Example</span>
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
                   <span class="fmt-element-name">Example</span>
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
                   <span class="fmt-element-name">Example</span>
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

  it "cross-references examples nested in assets" do
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
        <example id="scopeTN1">Note <xref target="scopeTN2"/></example>
        <example id="scopeTN2">Note <xref target="scopeFN2"/></example>
        <example id="scopeTN3">Note <xref target="scope2TN2"/></example>
        </table>
        <figure id="scopeF">
        <literal>...</literal>
        <example id="scopeFN1">Note</example>
        <example id="scopeFN2">Note</example>
        </figure>
        <requirement id="scopeR" model="default">
        <example id="scopeRN1">Note</example>
        <example id="scopeRN2">Note</example>
        </requirement>
      </clause>
      <clause id="scope2"><title>Scope</title>
        <table id="scope2T">
        <tbody><td/></table>
        <example id="scope2TN1">Note</example>
        <example id="scope2TN2">Note</example>
        </table>
        <figure id="scope2F">
        <literal>...</literal>
        <example id="scope2FN1">Note</example>
        <example id="scope2FN2">Note</example>
        </figure>
        <requirement id="scopeR" model="default">
        <example id="scope2RN1">Note</example>
        <example id="scope2RN2">Note</example>
        </requirement>
      </clause>
      </sections>
      <annex id="annex">
        <table id="annexT">
        <tbody><td/></table>
        <example id="annexTN1">Note</example>
        <example id="annexTN2">Note</example>
        </table>
        <figure id="annexF">
        <literal>...</literal>
        <example id="annexFN1">Note</example>
        <example id="annexFN2">Note</example>
        </figure>
        <recommendation id="scopeR" model="default">
        <example id="annexRN1">Note</example>
        <example id="annexRN2">Note</example>
        </recommendation>
      </annex>
      <annex id="annex2">
        <table id="annex2T">
        <tbody><td/></table>
        <example id="annex2TN1">Note</example>
        <example id="annex2TN2">Note</example>
        </table>
        <figure id="annex2F">
        <literal>...</literal>
        <example id="annex2FN1">Note</example>
        <example id="annex2FN2">Note</example>
        </figure>
        <recommendation id="scopeR" model="default">
        <example id="annex2RN1">Note</example>
        <example id="annex2RN2">Note</example>
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
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeTN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeTN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeTN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeTN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeFN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeFN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeFN1">4</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeFN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeFN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeFN2">5</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeRN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeRN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeRN1">6</semx>
                </fmt-xref>
             </semx>
             <xref target="scopeRN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeRN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeRN2">7</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2TN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2TN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2TN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2TN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2TN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2TN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2FN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2FN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2FN1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2FN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2FN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2FN2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2RN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2RN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2RN1">5</semx>
                </fmt-xref>
             </semx>
             <xref target="scope2RN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2RN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2RN2">6</semx>
                </fmt-xref>
             </semx>
             <xref target="annexTN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexTN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexTN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annexTN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexTN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexTN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annexFN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexFN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexFN1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="annexFN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexFN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexFN2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="annexRN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexRN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexRN1">5</semx>
                </fmt-xref>
             </semx>
             <xref target="annexRN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annexRN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annexRN2">6</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2TN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2TN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2TN1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2TN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2TN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2TN2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2FN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2FN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2FN1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2FN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2FN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2FN2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2RN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2RN1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2RN1">5</semx>
                </fmt-xref>
             </semx>
             <xref target="annex2RN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="annex2RN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="annex2">B</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="annex2RN2">6</semx>
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
          <example id="scopeTN1" autonum="1">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">EXAMPLE</span>
                   <semx element="autonum" source="scopeTN1">1</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN1">1</semx>
             </fmt-xref-label>
             <fmt-xref-label container="scope">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="scope">1</semx>
                </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN1">1</semx>
             </fmt-xref-label>
             Note
             <xref target="scopeTN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeTN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeTN2">2</semx>
                </fmt-xref>
             </semx>
          </example>
          <example id="scopeTN2" autonum="2">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">EXAMPLE</span>
                   <semx element="autonum" source="scopeTN2">2</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN2">2</semx>
             </fmt-xref-label>
             <fmt-xref-label container="scope">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="scope">1</semx>
                </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN2">2</semx>
             </fmt-xref-label>
             Note
             <xref target="scopeFN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scopeFN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scopeFN2">5</semx>
                </fmt-xref>
             </semx>
          </example>
          <example id="scopeTN3" autonum="3">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">EXAMPLE</span>
                   <semx element="autonum" source="scopeTN3">3</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN3">3</semx>
             </fmt-xref-label>
             <fmt-xref-label container="scope">
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="scope">1</semx>
                </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Example</span>
                <semx element="autonum" source="scopeTN3">3</semx>
             </fmt-xref-label>
             Note
             <xref target="scope2TN2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="scope2TN2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope2">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="scope2TN2">2</semx>
                </fmt-xref>
             </semx>
          </example>
       </table>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri.XML(IsoDoc::PresentationXMLConvert
     .new(presxml_options)
     .convert("test", input, true))
     .at("//xmlns:table[@id = 'scopeT']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
