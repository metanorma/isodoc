require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative" id="C0">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="C0"/>
         <xref target="B"/>
         <xref target="C"/>
         <xref target="C1"/>
         <xref target="C2"/>
         <xref target="C3"/>
         <xref target="C4"/>
         <xref target="D"/>
         <xref target="H"/>
         <xref target="D"><location target="D" connective="and"/><location target="H" connective="and"/></xref>
         <xref target="I"/>
         <xref target="J"/>
         <xref target="K"/>
         <xref target="L"/>
         <xref target="M"/>
         <xref target="N"/>
         <xref target="O"/>
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="QQ"/>
         <xref target="QQ1"/>
         <xref target="QQ2"/>
         <xref target="P"><location target="P" connective="and"/><location target="QQ" connective="and"/></xref>
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title></title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction>
       <acknowledgements id="C2"><p>Ack</p>
       <clause id="C3" inline-header="false" obligation="informative">Text</clause>
        </acknowledgements>
       <executivesummary id="C4"/>
        </preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </terms>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex>
       <annex id="QQ">
       <terms id="QQ1">
       <term id="QQ2"/>
       </terms>
       </annex>
        <bibliography><references normative="false" id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references normative="false" id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword obligation="informative" id="C0" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="C0" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C0">
                  <semx element="foreword" source="C0">Foreword</semx>
               </fmt-xref>
            </semx>
            <xref target="B" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="B">
                  <semx element="introduction" source="B">Introduction</semx>
               </fmt-xref>
            </semx>
            <xref target="C" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C">
                  <semx element="clause" source="C">Introduction Subsection</semx>
               </fmt-xref>
            </semx>
            <xref target="C1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C1">
                  <semx element="introduction" source="B">Introduction</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="C1">2</semx>
               </fmt-xref>
            </semx>
            <xref target="C2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C2">
                  <semx element="acknowledgements" source="C2">Acknowledgements</semx>
               </fmt-xref>
            </semx>
            <xref target="C3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C3">
                  <semx element="acknowledgements" source="C2">Acknowledgements</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="C3">1</semx>
               </fmt-xref>
            </semx>
            <xref target="C4" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C4">
                  <semx element="executivesummary" source="C4">Executive summary</semx>
               </fmt-xref>
            </semx>
            <xref target="D" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref>
            </semx>
            <xref target="H" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="H">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref>
            </semx>
            <xref target="D" id="_">
               <location target="D" connective="and"/>
               <location target="H" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  Clauses
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref>
               <span class="fmt-conn">and</span>
               <fmt-xref target="H">
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="J">1</semx>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="K">2</semx>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">4</semx>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="N">1</semx>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="O">2</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
               </fmt-xref>
            </semx>
            <xref target="Q" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q1">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="QQ">B</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ1">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="QQ1">B</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ2">
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="QQ1">B</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="QQ2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_">
               <location target="P" connective="and"/>
               <location target="QQ" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  Annexes
                  <semx element="autonum" source="P">A</semx>
               </fmt-xref>
               <span class="fmt-conn">and</span>
               <fmt-xref target="QQ">
                  <semx element="autonum" source="QQ">B</semx>
               </fmt-xref>
            </semx>
            <xref target="R" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="R">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref>
            </semx>
            <xref target="S" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="S">
                  <semx element="clause" source="S">Bibliography</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    foreword_xml = Nokogiri.XML(pres_output)
      .at("//xmlns:foreword").to_xml
    expect(strip_guid(foreword_xml)).to be_xml_equivalent_to output
    output = <<~OUTPUT
      <foreword obligation="informative" id="C0" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="C0" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C0">
                  <semx element="foreword" source="C0">Foreword</semx>
               </fmt-xref>
            </semx>
            <xref target="B" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="B">
                  <semx element="introduction" source="B">Введение</semx>
               </fmt-xref>
            </semx>
            <xref target="C" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C">
                  <semx element="clause" source="C">Introduction Subsection</semx>
               </fmt-xref>
            </semx>
            <xref target="C1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C1">
                  <semx element="introduction" source="B">Введение</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="C1">2</semx>
               </fmt-xref>
            </semx>
            <xref target="C2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C2">
                  <semx element="acknowledgements" source="C2">Подтверждения</semx>
               </fmt-xref>
            </semx>
            <xref target="C3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C3">
                  <semx element="acknowledgements" source="C2">Подтверждения</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="C3">1</semx>
               </fmt-xref>
            </semx>
            <xref target="C4" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="C4">
                  <semx element="executivesummary" source="C4">Управляющее резюме</semx>
               </fmt-xref>
            </semx>
            <xref target="D" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref>
            </semx>
            <xref target="H" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="H">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref>
            </semx>
            <xref target="D" id="_">
               <location target="D" connective="and"/>
               <location target="H" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  Пункты
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref>
               <span class="fmt-conn">и</span>
               <fmt-xref target="H">
                  <semx element="autonum" source="H">3</semx>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="I">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="J">1</semx>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="H">3</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="K">2</semx>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="L">4</semx>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="N">1</semx>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="M">5</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="O">2</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="P">A</semx>
               </fmt-xref>
            </semx>
            <xref target="Q" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q1">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="QQ">B</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ1">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="QQ1">B</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ2">
                  <span class="fmt-element-name">Дополнение</span>
                  <semx element="autonum" source="QQ1">B</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="QQ2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_">
               <location target="P" connective="and"/>
               <location target="QQ" connective="and"/>
            </xref>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  Дополнения
                  <semx element="autonum" source="P">A</semx>
               </fmt-xref>
               <span class="fmt-conn">и</span>
               <fmt-xref target="QQ">
                  <semx element="autonum" source="QQ">B</semx>
               </fmt-xref>
            </semx>
            <xref target="R" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="R">
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref>
            </semx>
            <xref target="S" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="S">
                  <semx element="clause" source="S">Bibliography</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test",
               input.sub("<preface>",
                         "<bibdata><language>ru</language></bibdata><preface>"),
               true)
    foreword_xml = Nokogiri.XML(pres_output)
      .at("//xmlns:foreword").to_xml
    expect(strip_guid(foreword_xml)).to be_xml_equivalent_to output
  end

  it "cross-references unnumbered sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="D"/>
         <xref target="H"/>
         <xref target="I"/>
         <xref target="J"/>
         <xref target="K"/>
         <xref target="L"/>
         <xref target="M"/>
         <xref target="N"/>
         <xref target="O"/>
         <xref target="O1"/>
         <xref target="O2"/>
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="QQ"/>
         <xref target="QQ1"/>
         <xref target="QQ2"/>
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
       </preface><sections>
       <clause id="D" obligation="normative" type="scope" unnumbered="true">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="H" obligation="normative" unnumbered="true"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K" unnumbered="true">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </terms>
       <definitions id="L" unnumbered="true">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" unnumbered="true"><title>Clause A</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause B</title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative" unnumbered="true">
         <title>Clause B</title>
       </clause>
       <clause id="O2" inline-header="false" obligation="normative" unnumbered="false">
         <title>Clause C</title>
       </clause>

       </sections><annex id="P" inline-header="false" obligation="normative" unnumbered="true">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex1a</title>
         </clause>
       </clause>
       </annex>
       <annex id="QQ" unnumbered="true">
       <terms id="QQ1">
       <term id="QQ2"/>
       </terms>
       </annex>
        <bibliography><references normative="false" id="R" obligation="informative" normative="true" unnumbered="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative" unnumbered="true">
         <title>Bibliography</title>
         <references normative="false" id="T" obligation="informative" normative="false" unnumbered="true">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="_" obligation="informative" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="D" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  <semx element="clause" source="D">Scope</semx>
               </fmt-xref>
            </semx>
            <xref target="H" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="H">
                  <semx element="terms" source="H">Terms, definitions, symbols and abbreviated terms</semx>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <semx element="terms" source="I">Normal Terms</semx>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <semx element="terms" source="I">Normal Terms</semx>
                  <semx element="autonum" source="J">1</semx>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <semx element="definitions" source="K">Symbols</semx>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <semx element="definitions" source="L">Symbols</semx>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <semx element="clause" source="M">Clause A</semx>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <semx element="clause" source="N">Introduction</semx>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="O">1</semx>
               </fmt-xref>
            </semx>
            <xref target="O1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O1">
                  <semx element="clause" source="O1">Clause B</semx>
               </fmt-xref>
            </semx>
            <xref target="O2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O2">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="O2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="P" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="P">
                  <semx element="annex" source="P">Annex</semx>
               </fmt-xref>
            </semx>
            <xref target="Q" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q">
                  <semx element="clause" source="Q">Annex1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q1">
                  <semx element="clause" source="Q1">Annex1a</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ">
                  <semx element="annex" source="QQ">Annex</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ1">
                  <semx element="annex" source="QQ">Annex</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="QQ1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ2">
                  <semx element="annex" source="QQ">Annex</semx>
                  <span class="fmt-comma">,</span>
                  <semx element="autonum" source="QQ1">1</semx>
                  <semx element="autonum" source="QQ2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="R" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="R">
                  <semx element="references" source="R">Normative References</semx>
               </fmt-xref>
            </semx>
            <xref target="S" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="S">
                  <semx element="clause" source="S">Bibliography</semx>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    foreword_xml = Nokogiri.XML(pres_output)
      .at("//xmlns:foreword").to_xml
    expect(strip_guid(foreword_xml)).to be_xml_equivalent_to output
  end
end
