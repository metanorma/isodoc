require "spec_helper"

RSpec.describe IsoDoc do
  it "selects sets of assets to process crossreference for" do
    input = Nokogiri::XML(<<~INPUT)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <clause id="A"><title>Clause</title>
      <note id="B"><p>Note</p></note>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    xrefs = new_xrefs
    xrefs.parse(input)
    expect(xrefs.anchor("A", :xref))
      .to be_equivalent_to "<span class='fmt-element-name'>Clause</span> <semx element='autonum' source='A'>1</semx>"
    expect(xrefs.anchor("B", :xref))
      .to be_equivalent_to "<span class='fmt-element-name'>Note</span>"
    expect(xrefs.anchor("C", :xref))
      .to be_equivalent_to "[C]"

    xrefs = new_xrefs.parse_inclusions(clauses: true)
    xrefs.parse(input)
    expect(xrefs.anchor("A", :xref))
      .to be_equivalent_to "<span class='fmt-element-name'>Clause</span> <semx element='autonum' source='A'>1</semx>"
    expect(xrefs.anchor("B", :xref))
      .to be_equivalent_to "[B]"

    xrefs = new_xrefs.parse_inclusions(assets: true)
    xrefs.parse(input)
    expect(xrefs.anchor("A", :xref))
      .to be_equivalent_to "[A]"
    expect(xrefs.anchor("B", :xref))
      .to be_equivalent_to "<span class='fmt-element-name'>Note</span>"
  end

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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note2">2</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="Anote1">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="N3">[N3]</xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="note2">2</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="Anote1">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input1 = input.sub(%r{<language>en</language>},
                       "<language>ja</language>")
    output = <<~OUTPUT
       <foreword displayorder="2">
           <title id="_">まえがき</title>
           <fmt-title depth="1">
              <semx element="title" source="_">まえがき</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">序文</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="N3">[N3]</xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">箇条</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="note2">2</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="Anote1">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">附属書</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-conn">の</span>
                 <span class="fmt-element-name">Box</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

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
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N1">1</semx>
             </xref>
             <xref target="N2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N2">(??)</semx>
             </xref>
             <xref target="N">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">2</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note1">3</semx>
             </xref>
             <xref target="note3">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note3">4</semx>
             </xref>
             <xref target="note4">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note4">5</semx>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note2">6</semx>
             </xref>
             <xref target="note51">[note51]</xref>
             <xref target="AN">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="Anote1">(??)</semx>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="Anote2">2</semx>
             </xref>
             <xref target="Anote3">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="Anote3">3</semx>
             </xref>
             <xref target="Anote4">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="Anote4">1</semx>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N1">1</semx>
             </xref>
             <xref target="N2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N2">(??)</semx>
             </xref>
             <xref target="N">
                <span class="fmt-element-name">Diagram</span>
                <semx element="autonum" source="N">1</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Plate</span>
                <semx element="autonum" source="note1">1</semx>
             </xref>
             <xref target="note3">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note3">2</semx>
             </xref>
             <xref target="note4">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note4">3</semx>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Diagram</span>
                <semx element="autonum" source="note2">2</semx>
             </xref>
             <xref target="note5">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="note5">4</semx>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Diagram</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Plate</span>
                <semx element="autonum" source="Anote1">(??)</semx>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="Anote2">1</semx>
             </xref>
             <xref target="Anote3">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="Anote3">2</semx>
             </xref>
             <xref target="Anote4">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="Anote4">1</semx>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">1</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note1">1</semx>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note2">2</semx>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote1">1</semx>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote2">2</semx>
             </xref>
             <xref target="AN1">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="AN1">1</semx>
             </xref>
             <xref target="Anote11">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
         <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="AN1">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote11">1</semx>
             </xref>
             <xref target="Anote21">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
         <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="AN1">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote21">2</semx>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">(??)</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="N">(??)</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note1">1</semx>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="Anote1">(??)</semx>
             </xref>
          </p>
       </foreword>
OUTPUT
expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

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
      <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="N2">(??)</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note2">(??)</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1a">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="Anote1">(??)</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="annex1b">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="Anote2">1</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    output = <<~OUTPUT
        <clause id="widgets1">
           <fmt-title depth="2">
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
              <fmt-name>
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
              <fmt-name>
                 <span class="fmt-caption-label">
                    <span class="fmt-element-name">EXAMPLE</span>
                 </span>
              </fmt-name>
              <fmt-xref-label>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note2">(??)</semx>
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
                 <semx element="autonum" source="note2">(??)</semx>
              </fmt-xref-label>
              <p>
                 Hello
                 <xref target="note1">
                    <span class="fmt-element-name">Example</span>
                    <semx element="autonum" source="note1">1</semx>
                 </xref>
              </p>
           </example>
           <p>
              <xref target="note1">
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note2">(??)</semx>
              </xref>
           </p>
        </clause>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id='widgets1']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references formulae" do
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
          <formula id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
        <clause id="xyz"><title>Preparatory</title>
          <formula id="N2" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <formula id="N">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <formula id="note1">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          <formula id="note2">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <formula id="AN">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          </clause>
          <clause id="annex1b">
          <formula id="Anote1" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          <formula id="Anote2">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <formula id="Anote3">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-xref-container">
                    <semx element="introduction" source="intro">Introduction</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N2">
                 <span class="fmt-xref-container">
                    <semx element="clause" source="xyz">Preparatory</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="N2">(??)</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="N">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="scope">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="N">2</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="note1">3</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="note2">4</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="Anote1">(??)</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Anote2">2</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Formula</span>
                 <span class="fmt-autonum-delim">(</span>
                 <semx element="autonum" source="Anote3">1</semx>
                 <span class="fmt-autonum-delim">)</span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references requirements" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="N3"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="note3"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          <xref target="Anote3"/>
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
          <requirement id="N3" model="default" class="provision">
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
          <requirement id="note3" model="default" class="provision">
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
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <requirement id="Anote3" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="N1">1</semx>
             </xref>
             <xref target="N2">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="N2">(??)</semx>
             </xref>
             <xref target="N">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="N">2</semx>
             </xref>
             <xref target="N3">
                <span class="fmt-element-name">provision</span>
                <semx element="autonum" source="N3">1</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="note1">3</semx>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="note2">4</semx>
             </xref>
             <xref target="note3">
                <span class="fmt-element-name">provision</span>
                <semx element="autonum" source="note3">2</semx>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="Anote1">(??)</semx>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="Anote2">2</semx>
             </xref>
             <xref target="Anote3">
                      <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                <span class="fmt-comma">,</span>
                <span class="fmt-element-name">Requirement</span>
                <semx element="autonum" source="Anote3">1</semx>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <xref target="Anote3"/>
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
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <recommendation id="Anote3" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="N1">1</semx>
              </xref>
              <xref target="N2">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="N2">(??)</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="N">2</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="note1">3</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="note2">4</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN">1</semx>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="Anote1">(??)</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                       <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="Anote3">1</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <xref target="Anote3"/>
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
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <permission id="Anote3" model="default">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N1">1</semx>
              </xref>
              <xref target="N2">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N2">(??)</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N">2</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="note1">3</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="note2">4</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN">1</semx>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="Anote1">(??)</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="Anote3">1</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <xref target="BN1"/>
      <xref target="BN2"/>
      <xref target="BN"/>
      <xref target="BQ1"/>
      <xref target="BR1"/>
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
                <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                <permission id="BN1" model="default">
      <permission id="BN2" model="default">
      <permission id="BN" model="default">
      </permission>
      </permission>
      <requirement id="BQ1" model="default">
      </requirement>
      <recommendation id="BR1" model="default">
      </recommendation>
      </permission>
          </references></bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N1">1</semx>
              </xref>
              <xref target="N2">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="N2">1</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="N2">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="N">1</semx>
              </xref>
              <xref target="Q1">
                 <span class="fmt-element-name">Requirement</span>
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="Q1">1</semx>
              </xref>
              <xref target="R1">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="R1">1</semx>
              </xref>
              <xref target="AN1">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="Axyz">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN1">1</semx>
              </xref>
              <xref target="AN2">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="Axyz">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="AN2">1</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="Axyz">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="AN2">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="AN">1</semx>
              </xref>
              <xref target="AQ1">
                 <span class="fmt-element-name">Requirement</span>
                 <semx element="autonum" source="Axyz">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="AQ1">1</semx>
              </xref>
              <xref target="AR1">
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="Axyz">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="AN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="AR1">1</semx>
              </xref>
                           <xref target="BN1">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="BN1">1</semx>
              </xref>
              <xref target="BN2">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="BN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="BN2">1</semx>
              </xref>
              <xref target="BN">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Permission</span>
                 <semx element="autonum" source="BN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="BN2">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="BN">1</semx>
              </xref>
              <xref target="BQ1">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Requirement</span>
                 <semx element="autonum" source="BN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="BQ1">1</semx>
              </xref>
              <xref target="BR1">
                 <span class="fmt-xref-container">
                    <semx element="references" source="biblio">Bibliographical Section</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Recommendation</span>
                 <semx element="autonum" source="BN1">1</semx>
                 <span class="fmt-autonum-delim">-</span>
                 <semx element="autonum" source="BR1">1</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references tables" do
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
          <table id="N1">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
        <clause id="xyz"><title>Preparatory</title>
          <table id="N2" unnumbered="true">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
              <table id="N">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
          <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
              <table id="note1">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
              <table id="note2">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
          <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
              <table id="AN">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
          </clause>
          <clause id="annex1b">
              <table id="Anote1" unnumbered="true">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
              <table id="Anote2">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
          </clause>
          </annex>
                    <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <table id="Anote3">
          <name>Repeatability and reproducibility of husked rice yield</name>
          <tbody>
          <tr>
            <td align="left">Number of laboratories retained after eliminating outliers</td>
            <td align="center">13</td>
            <td align="center">11</td>
          </tr>
          </tbody>
          </table>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="N1">1</semx>
              </xref>
              <xref target="N2">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="N2">(??)</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="N">2</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="note1">3</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="note2">4</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="annex1">A</semx>
         <span class="fmt-autonum-delim">.</span>
         <semx element="autonum" source="AN">1</semx>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="Anote1">(??)</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-element-name">Table</span>
         <semx element="autonum" source="annex1">A</semx>
         <span class="fmt-autonum-delim">.</span>
         <semx element="autonum" source="Anote2">2</semx>
              </xref>
              <xref target="Anote3">
                 <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Table</span>
                 <semx element="autonum" source="Anote3">1</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="waxy_rice">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="nonwaxy_rice">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note2">1</semx>
              </xref>
              <xref target="note3">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="nonwaxy_rice">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note3">2</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="waxy_rice">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <span class="fmt-conn">and</span>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="nonwaxy_rice">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note2">1</semx>
              </xref>
              <span class="fmt-xref-container">
                 <span class="fmt-element-name">Clause</span>
                 <semx element="autonum" source="terms">2</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="nonwaxy_rice">2</semx>
              </span>
              <span class="fmt-comma">,</span>
              <xref target="note2">
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note2">1</semx>
              </xref>
              <span class="fmt-conn">and</span>
              <xref target="note3">
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note3">2</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="waxy_rice">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note1">1</semx>
              </xref>
              <xref target="note2">
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
              </xref>
              <xref target="note3">
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
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="waxy_rice">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
              <xref target="note2">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="nonwaxy_rice">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note2">1</semx>
              </xref>
              <xref target="note3">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="nonwaxy_rice">2</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
                 <semx element="autonum" source="note3">2</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms">2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="waxy_rice">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Example</span>
              </xref>
              <xref target="note2">
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
              </xref>
              <xref target="note3">
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
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri.XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references bookmarks" do
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
          <p id="N01">
        <bookmark id="N1"/>
      </p>
        <clause id="xyz"><title>Preparatory</title>
           <p id="N02" type="arabic">
        <bookmark id="N2"/>
      </p>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <p id="N0" type="roman">
        <bookmark id="N"/>
      </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <note id="note0"/>
          <note id="note1l" type="alphabet">
        <bookmark id="note1"/>
      </note>
          <p id="note2l" type="roman_upper">
        <bookmark id="note2"/>
      </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <p id="ANl" type="alphabet_upper">
        <bookmark id="AN"/>
      </p>
          </clause>
          <clause id="annex1b">
          <figure id="Anote1l" type="roman" start="4">
        <bookmark id="Anote1"/>
      </figure>
          <p id="Anote2l">
        <bookmark id="Anote2"/>
      </p>
          </clause>
          </annex>
          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
          <p id="Anote3l">
        <bookmark id="Anote3"/>
      </p>
          </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <semx element="introduction" source="intro">Introduction</semx>
              </xref>
              <xref target="N2">
                 <semx element="clause" source="xyz">Preparatory</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">Clause</span>
                 <semx element="autonum" source="scope">1</semx>
              </xref>
              <xref target="note1">
                 <span class="fmt-xref-container">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="widgets">3</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="widgets1">1</semx>
                 </span>
                 <span class="fmt-comma">,</span>
                 <span class="fmt-element-name">Note</span>
                 <semx element="autonum" source="note1l">2</semx>
              </xref>
              <xref target="note2">
                 <span class="fmt-element-name">Clause</span>
                 <semx element="autonum" source="widgets">3</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="widgets1">1</semx>
              </xref>
              <xref target="AN">
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="annex1a">1</semx>
              </xref>
              <xref target="Anote1">
                 <span class="fmt-element-name">Figure</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Anote1l">1</semx>
              </xref>
              <xref target="Anote2">
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="annex1">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="annex1b">2</semx>
              </xref>
              <xref target="Anote3">
                 <semx element="references" source="biblio">Bibliographical Section</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
