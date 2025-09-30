require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references figures" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
          <foreword id="fwd">
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note3"/>
          <xref target="note4"/>
          <xref target="note2"/>
          <xref target="note51"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          <xref target="Anote4"/>
          </p>
          </foreword>
              <introduction id="intro">
              <figure id="N1">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <clause id="xyz"><title>Preparatory</title>
              <figure id="N2" unnumbered="true">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
              <figure id="N">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
              <figure id="note1">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <figure id="note3" class="pseudocode">
        <p>pseudocode</p>
        </figure>
        <sourcecode id="note4"><name>Source! Code!</name>
        A B C
        </sourcecode>
        <example id="note5">
        <sourcecode id="note51">
        A B C
        </sourcecode>
        </example>
          <figure id="note2">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
              <figure id="AN">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          </clause>
          <clause id="annex1b">
              <figure id="Anote1" unnumbered="true">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          <figure id="Anote2">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <sourcecode id="Anote3"><name>Source! Code!</name>
        A B C
        </sourcecode>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <figure id="Anote4">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N2">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N">2</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="note1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="note3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note3">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="note3">4</semx>
                </fmt-xref>
             </semx>
             <xref target="note4" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note4">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="note4">5</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="note2">6</semx>
                </fmt-xref>
             </semx>
             <xref target="note51" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note51">[note51]</fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote3">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote3">3</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote4" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote4">
                   <span class="fmt-xref-container">
                      <semx element="references" source="biblio">Bibliographical Section</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="Anote4">1</semx>
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

  it "cross-references figure classes" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
          <foreword id="fwd">
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note3"/>
          <xref target="note4"/>
          <xref target="note2"/>
          <xref target="note5"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
          <xref target="Anote4"/>
          </p>
          </foreword>
              <introduction id="intro">
              <figure id="N1">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <clause id="xyz"><title>Preparatory</title>
              <figure id="N2" unnumbered="true">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
              <figure id="N" class="diagram">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
              <figure id="note1" class="plate">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <figure id="note3" class="pseudocode">
        <p>pseudocode</p>
        </figure>
        <sourcecode id="note4" class="diagram"><name>Source! Code!</name>
        A B C
        </sourcecode>
        <figure id="note5">
        <sourcecode id="note51">
        A B C
        </sourcecode>
        </figure>
          <figure id="note2" class="diagram">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
              <figure id="AN" class="diagram">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          </clause>
          <clause id="annex1b">
              <figure id="Anote1" unnumbered="true" class="plate">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          <figure id="Anote2">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
        <sourcecode id="Anote3"><name>Source! Code!</name>
        A B C
        </sourcecode>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <figure id="Anote4">
        <name>Split-it-right sample divider</name>
        <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
        </figure>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="fwd" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="N1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N1">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="N2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N2">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N2">(??)</semx>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-element-name">Diagram</span>
                  <semx element="autonum" source="N">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-element-name">Plate</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note3">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="note3">2</semx>
               </fmt-xref>
            </semx>
            <xref target="note4" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note4">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="note4">3</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-element-name">Diagram</span>
                  <semx element="autonum" source="note2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="note5" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note5">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="note5">4</semx>
               </fmt-xref>
            </semx>
            <xref target="AN" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="AN">
                  <span class="fmt-element-name">Diagram</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="AN">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote1">
                  <span class="fmt-element-name">Plate</span>
                  <semx element="autonum" source="Anote1">(??)</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote2">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Anote2">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote3">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Anote3">2</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote4" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote4">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="Anote4">1</semx>
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

  it "cross-references subfigures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N"/>
        <xref target="note1"/>
        <xref target="note2"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        <xref target="Anote2"/>
        <xref target="AN1"/>
        <xref target="Anote11"/>
        <xref target="Anote21"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
        </clause>
        <terms id="terms"/>
        <clause id="widgets"><title>Widgets</title>
        <clause id="widgets1">
        <figure id="N">
            <figure id="note1">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="note2">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
        </clause>
        </clause>
        </sections>
        <annex id="annex1">
        <clause id="annex1a">
        </clause>
        <clause id="annex1b">
        <figure id="AN">
            <figure id="Anote1">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote2">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
        </clause>
        </annex>
                  <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                  <figure id="AN1">
            <figure id="Anote11">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote21">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
          </references></bibliography>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="fwd" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="note2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note2">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="note2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="AN" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="AN">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="AN">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote1">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="AN">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="Anote1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote2">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="annex1">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="AN">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="Anote2">2</semx>
               </fmt-xref>
            </semx>
            <xref target="AN1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="AN1">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="AN1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote11" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote11">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="AN1">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="Anote11">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote21" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote21">
                  <span class="fmt-xref-container">
                     <semx element="references" source="biblio">Bibliographical Section</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="AN1">1</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="Anote21">2</semx>
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

  it "cross-references unnumbered subfigures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N"/>
        <xref target="note1"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
        <figure id="N" unnumbered="true">
            <figure id="note1">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
        <figure id="AN">
            <figure id="Anote1" unnumbered="true">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote2">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
      </clause>
      </sections>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id="fwd" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N">(??)</semx>
               </fmt-xref>
            </semx>
            <xref target="note1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="note1">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="N">(??)</semx>
                  <span class="fmt-autonum-delim">-</span>
                  <semx element="autonum" source="note1">1</semx>
               </fmt-xref>
            </semx>
            <xref target="AN" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="AN">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="AN">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Anote1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Anote1">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="Anote1">(??)</semx>
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
 
  it "cross-references tabular subfigures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="N"/>
        <xref target="note1"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
                     <figure id="N">
                <name id="_">Stages of gelatinization</name>
                <table id="T1" plain="true">
                   <colgroup>
                      <col width="25%"/>
                      <col width="75%"/>
                   </colgroup>
                   <tbody>
                      <tr id="_">
                         <td id="_" valign="bottom" align="center">
                            <figure id="note1">
                               <name id="_">Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_1.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_1.png"/>
                            </figure>
                         </td>
                         <td id="_" valign="bottom" align="center">
                            <figure id="AN">
                               <name id="_">Intermediate stages: Some fully gelatinized kernels are visible</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_2.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_2.png"/>
                            </figure>
                         </td>
                      </tr>
                      <tr id="_">
                         <td id="_" colspan="2" valign="bottom" align="center">
                            <figure id="Anote1">
                               <name id="_">Final stages: All kernels are fully gelatinized</name>
                               <image id="_" src="spec/examples/rice_images/rice_image3_3.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image3_3.png"/>
                            </figure>
                         </td>
                      </tr>
                   </tbody>
                </table>
             </figure>
      </clause>
      </sections>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1" id="_">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N">1</semx>
                   <span class="fmt-autonum-delim">-</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N">1</semx>
                   <span class="fmt-autonum-delim">-</span>
                   <semx element="autonum" source="AN">2</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Figure</span>
                   <semx element="autonum" source="N">1</semx>
                   <span class="fmt-autonum-delim">-</span>
                   <semx element="autonum" source="Anote1">3</semx>
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
