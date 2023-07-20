require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references external documents" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="a#b"/>
      </p>
      </foreword>
      </preface>
      </iso-standard
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <title depth="1">Table of contents</title>
          </clause>
          <foreword displayorder='2'>
            <p>
              <xref target='a#b'>a#b</xref>
            </p>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
              #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
      <a href="a.html#b">a#b</a>
      </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
          <div class="WordSection2">
            <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
           <div class="TOC" id="_">
              <p class="zzContents">Table of contents</p>
            </div>
            <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
      <a href="a.doc#b">a#b</a>
      </p>
            </div><p> </p></div>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(Nokogiri::XML(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))
      .at("//div[@class = 'WordSection2']").to_xml))
      .to be_equivalent_to xmlpp(doc)
  end

  it "warns of missing crossreference" do
    i = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      </preface>
      </iso-standard>
    INPUT
    expect do
      IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", i, true)
    end
      .to output(/No label has been processed for ID N1/).to_stderr
  end

  it "does not warn of missing crossreference if text is supplied" do
    i = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1">abc</xref>
      </preface>
      </iso-standard>
    INPUT
    expect { IsoDoc::HtmlConvert.new({}).convert("test", i, true) }
      .not_to output(/No label has been processed for ID N1/).to_stderr
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword displayorder='2'>
            <p>
              <xref target='N1'>Introduction, Note</xref>
      <xref target='N2'>Preparatory, Note</xref>
      <xref target='N'>Clause 1, Note</xref>
      <xref target='note1'>Clause 3.1, Note 1</xref>
      <xref target='note2'>Clause 3.1, Note 2</xref>
      <xref target='AN'>Annex A.1, Note</xref>
      <xref target='Anote1'>Annex A.2, Note 1</xref>
      <xref target='Anote2'>Annex A.2, Note 2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="2">
        <p>
          <xref target="N1">Introduction, Box</xref>
          <xref target="N2">Preparatory, Box</xref>
          <xref target="N3">[N3]</xref>
          <xref target="N">Clause 1, Box</xref>
          <xref target="note1">Clause 3.1, Box  1</xref>
          <xref target="note2">Clause 3.1, Box  2</xref>
          <xref target="AN">Annex A.1, Box</xref>
          <xref target="Anote1">Annex A.2, Box  1</xref>
          <xref target="Anote2">Annex A.2, Box  2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
       .convert("test", input, true))
       .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
    input1 = input.sub(%r{<language>en</language>},
                       "<language>ja</language>")
    output = <<~OUTPUT
      <foreword displayorder="2">
         <p>
           <xref target="N1">IntroductionのBox</xref>
           <xref target="N2">PreparatoryのBox</xref>
           <xref target="N3">[N3]</xref>
           <xref target="N">箇条 1のBox</xref>
           <xref target="note1">箇条 3.1のBox  1</xref>
           <xref target="note2">箇条 3.1のBox  2</xref>
           <xref target="AN">附属書 A.1のBox</xref>
           <xref target="Anote1">附属書 A.2のBox  1</xref>
           <xref target="Anote2">附属書 A.2のBox  2</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
                <foreword id='fwd' displayorder="2">
                  <p>
                     <xref target='N1'>Figure 1</xref>
      <xref target='N2'>Figure (??)</xref>
      <xref target='N'>Figure 2</xref>
      <xref target='note1'>Figure 3</xref>
      <xref target='note3'>Figure 4</xref>
      <xref target='note4'>Figure 5</xref>
      <xref target='note2'>Figure 6</xref>
      <xref target='note51'>[note51]</xref>
      <xref target='AN'>Figure A.1</xref>
      <xref target='Anote1'>Figure (??)</xref>
      <xref target='Anote2'>Figure A.2</xref>
      <xref target='Anote3'>Figure A.3</xref>
                  </p>
                </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword id='fwd' displayorder='2'>
         <p>
           <xref target='N1'>Figure 1</xref>
           <xref target='N2'>Figure (??)</xref>
           <xref target='N'>Diagram 1</xref>
           <xref target='note1'>Plate 1</xref>
           <xref target='note3'>Figure 2</xref>
           <xref target='note4'>Figure 3</xref>
           <xref target='note2'>Diagram 2</xref>
           <xref target='note5'>Figure 4</xref>
           <xref target='AN'>Diagram A.1</xref>
           <xref target='Anote1'>Plate (??)</xref>
           <xref target='Anote2'>Figure A.1</xref>
           <xref target='Anote3'>Figure A.2</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
        </iso-standard>
    INPUT
    output = <<~OUTPUT
                 <foreword id='fwd' displayorder="2">
                   <p>
                     <xref target='N'>Figure 1</xref>
      <xref target='note1'>Figure 1-1</xref>
      <xref target='note2'>Figure 1-2</xref>
      <xref target='AN'>Figure A.1</xref>
      <xref target='Anote1'>Figure A.1-1</xref>
      <xref target='Anote2'>Figure A.1-2</xref>
                   </p>
                 </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT

    output = <<~OUTPUT
          <foreword displayorder='2'>
            <p>
              <xref target='N1'>Introduction, Example</xref>
      <xref target='N2'>Preparatory, Example (??)</xref>
      <xref target='N'>Clause 1, Example</xref>
      <xref target='note1'>Clause 3.1, Example 1</xref>
      <xref target='note2'>Clause 3.1, Example (??)</xref>
      <xref target='AN'>Annex A.1, Example</xref>
      <xref target='Anote1'>Annex A.2, Example (??)</xref>
      <xref target='Anote2'>Annex A.2, Example 1</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)

    output = <<~OUTPUT
      <clause id='widgets1'>
         <title>3.1.</title>
         <example id='note1'>
           <name>EXAMPLE 1</name>
           <p>Hello</p>
         </example>
         <example id='note2' unnumbered='true'>
           <name>EXAMPLE</name>
           <p>
             Hello
             <xref target='note1'>Example 1</xref>
           </p>
         </example>
         <p>
           <xref target='note1'>Example 1</xref>
           <xref target='note2'>Example (??)</xref>
         </p>
       </clause>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id='widgets1']").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          <foreword displayorder='2'>
            <p>
              <xref target='N1'>Introduction, Formula (1)</xref>
      <xref target='N2'>Preparatory, Formula ((??))</xref>
      <xref target='N'>Clause 1, Formula (2)</xref>
      <xref target='note1'>Clause 3.1, Formula (3)</xref>
      <xref target='note2'>Clause 3.1, Formula (4)</xref>
      <xref target='AN'>Formula (A.1)</xref>
      <xref target='Anote1'>Formula ((??))</xref>
      <xref target='Anote2'>Formula (A.2)</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          <foreword displayorder='2'>
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
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
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
          <foreword displayorder='2'>
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
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
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
                 <foreword displayorder='2'>
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
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
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
                <foreword displayorder='2'>
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
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Table 1</xref>
          <xref target='N2'>Table (??)</xref>
          <xref target='N'>Table 2</xref>
          <xref target='note1'>Table 3</xref>
          <xref target='note2'>Table 4</xref>
          <xref target='AN'>Table A.1</xref>
          <xref target='Anote1'>Table (??)</xref>
          <xref target='Anote2'>Table A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <term id="_waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termnote id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote></term>
      <term id="_nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
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
            <p>
              <xref target='note1'>Clause 2.1, Note 1</xref>
      <xref target='note2'>Clause 2.2, Note 1</xref>
      <xref target='note3'>Clause 2.2, Note 2</xref>
      <xref target="note1">Clause 2.1, Note 1</xref> and <xref target="note2">Clause 2.2, Note 1</xref>
      Clause 2.2, <xref target="note2">Note 1</xref> and <xref target="note3">Note 2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <term id="_waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termnote id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <term id="_nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
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
      <foreword displayorder='2'>
        <p>
          <xref target='note1'>Clause 2.1, Note 1</xref>
          <xref target='note2'>Clause 2.1.1, Note 1</xref>
          <xref target='note3'>Clause 2.1.1, Note 2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <term id="_waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termexample id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample></term>
      <term id="_nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
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
            <p>
              <xref target='note1'>Clause 2.1, Example</xref>
      <xref target='note2'>Clause 2.2, Example 1</xref>
      <xref target='note3'>Clause 2.2, Example 2</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <term id="_waxy_rice"><preferred><expression><name>waxy rice</name></expression></preferred>
      <termexample id="note1">
        <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termexample>
      <term id="_nonwaxy_rice"><preferred><expression><name>nonwaxy rice</name></expression></preferred>
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
      <foreword displayorder='2'>
        <p>
          <xref target='note1'>Clause 2.1, Example</xref>
          <xref target='note2'>Clause 2.1.1, Example 1</xref>
          <xref target='note3'>Clause 2.1.1, Example 2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="C"/>
         <xref target="C1"/>
         <xref target="D"/>
         <xref target="H"/>
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
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
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
    output = <<~OUTPUT
      <foreword obligation='informative' displayorder='2'>
        <title>Foreword</title>
        <p id='A'>
          This is a preamble
          <xref target='C'>Introduction Subsection</xref>
          <xref target='C1'>Introduction, 2</xref>
          <xref target='D'>Clause 1</xref>
          <xref target='H'>Clause 3</xref>
          <xref target='I'>Clause 3.1</xref>
          <xref target='J'>Clause 3.1.1</xref>
          <xref target='K'>Clause 3.2</xref>
          <xref target='L'>Clause 4</xref>
          <xref target='M'>Clause 5</xref>
          <xref target='N'>Clause 5.1</xref>
          <xref target='O'>Clause 5.2</xref>
          <xref target='P'>Annex A</xref>
          <xref target='Q'>Annex A.1</xref>
          <xref target='Q1'>Annex A.1.1</xref>
          <xref target='QQ'>Annex B</xref>
          <xref target='QQ1'>Annex B</xref>
          <xref target='QQ2'>Annex B.1</xref>
          <xref target='R'>Clause 2</xref>
          <xref target='S'>Bibliography</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri.XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references lists" do
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
           <ol id="N1">
        <li><p>A</p></li>
      </ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N2">
        <li><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N">
        <li><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          <ol id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          <ol id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </ol>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, List</xref>
          <xref target='N2'>Preparatory, List</xref>
          <xref target='N'>Clause 1, List</xref>
          <xref target='note1'>Clause 3.1, List 1</xref>
          <xref target='note2'>Clause 3.1, List 2</xref>
          <xref target='AN'>Annex A.1, List</xref>
          <xref target='Anote1'>Annex A.2, List 1</xref>
          <xref target='Anote2'>Annex A.2, List 2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references list items in English and Japanese" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N11"/>
          <xref target="N12"/>
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
          <ol id="N01">
        <li id="N1"><p>A</p>
          <ol id="N011">
        <li id="N11"><p>A</p>
          <ol id="N012">
        <li id="N12"><p>A</p>
         </li>
      </ol></li></ol></li></ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N02" type="arabic">
        <li id="N2"><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N0" type="roman">
        <li id="N"><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1l" type="alphabet">
        <li id="note1"><p>A</p></li>
      </ol>
          <ol id="note2l" type="roman_upper">
        <li id="note2"><p>A</p></li>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="ANl" type="alphabet_upper">
        <li id="AN"><p>A</p></li>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1l" type="roman" start="4">
        <li id="Anote1"><p>A</p></li>
      </ol>
          <ol id="Anote2l">
        <li id="Anote2"><p>A</p></li>
      </ol>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, a)</xref>
          <xref target='N11'>Introduction, a) 1)</xref>
          <xref target='N12'>Introduction, a) 1) i)</xref>
          <xref target='N2'>Preparatory, 1)</xref>
          <xref target='N'>Clause 1, i)</xref>
          <xref target='note1'>Clause 3.1, List 1 a)</xref>
          <xref target='note2'>Clause 3.1, List 2 I)</xref>
          <xref target='AN'>Annex A.1, A)</xref>
          <xref target='Anote1'>Annex A.2, List 1 iv)</xref>
          <xref target='Anote2'>Annex A.2, List 2 a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
      <foreword displayorder="2">
         <p>
           <xref target="N1">Introductionのa)</xref>
           <xref target="N11">Introductionのa)の1)</xref>
           <xref target="N12">Introductionのa)の1)のi)</xref>
           <xref target="N2">Preparatoryの1)</xref>
           <xref target="N">箇条 1のi)</xref>
           <xref target="note1">箇条 3.1のリスト  1のa)</xref>
           <xref target="note2">箇条 3.1のリスト  2のI)</xref>
           <xref target="AN">附属書 A.1のA)</xref>
           <xref target="Anote1">附属書 A.2のリスト  1のiv)</xref>
           <xref target="Anote2">附属書 A.2のリスト  2のa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references nested list items in English and Japanese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata><language>en</language></bibdata>
      <preface>
      <foreword>
      <p>
      <xref target="N"/>
      <xref target="note1"/>
      <xref target="note2"/>
      <xref target="AN"/>
      <xref target="Anote1"/>
      <xref target="Anote2"/>
      </p>
      </foreword>
      </preface>
      <sections>
      <clause id="scope" type="scope"><title>Scope</title>
      <ol id="N1">
        <li id="N"><p>A</p>
        <ol>
        <li id="note1"><p>A</p>
        <ol>
        <li id="note2"><p>A</p>
        <ol>
        <li id="AN"><p>A</p>
        <ol>
        <li id="Anote1"><p>A</p>
        <ol>
        <li id="Anote2"><p>A</p></li>
        </ol></li>
        </ol></li>
        </ol></li>
        </ol></li>
        </ol></li>
      </ol>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N'>Clause 1, a)</xref>
          <xref target='note1'>Clause 1, a) 1)</xref>
          <xref target='note2'>Clause 1, a) 1) i)</xref>
          <xref target='AN'>Clause 1, a) 1) i) A)</xref>
          <xref target='Anote1'>Clause 1, a) 1) i) A) I)</xref>
          <xref target='Anote2'>Clause 1, a) 1) i) A) I) a)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
    input1 = input.sub(%r{<language>en</language>}, "<language>ja</language>")
    output = <<~OUTPUT
      <foreword displayorder="2">
         <p>
           <xref target="N">箇条 1のa)</xref>
           <xref target="note1">箇条 1のa)の1)</xref>
           <xref target="note2">箇条 1のa)の1)のi)</xref>
           <xref target="AN">箇条 1のa)の1)のi)のA)</xref>
           <xref target="Anote1">箇条 1のa)の1)のi)のA)のI)</xref>
           <xref target="Anote2">箇条 1のa)の1)のi)のA)のI)のa)</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input1, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references definition lists" do
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
           <dl id="N1">
        <li><p>A</p></li>
      </dl>
        <clause id="xyz"><title>Preparatory</title>
           <dl id="N2">
        <li><p>A</p></li>
      </dl>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <dl id="N">
        <li><p>A</p></li>
      </dl>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <dl id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          <dl id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <dl id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          <clause id="annex1b">
          <dl id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          <dl id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </dl>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction, Definition List</xref>
          <xref target='N2'>Preparatory, Definition List</xref>
          <xref target='N'>Clause 1, Definition List</xref>
          <xref target='note1'>Clause 3.1, Definition List 1</xref>
          <xref target='note2'>Clause 3.1, Definition List 2</xref>
          <xref target='AN'>Annex A.1, Definition List</xref>
          <xref target='Anote1'>Annex A.2, Definition List 1</xref>
          <xref target='Anote2'>Annex A.2, Definition List 2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references definition list terms" do
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
          <dl id="N01">
        <dt id="N1"><p>A</p></dt>
      </dl>
        <clause id="xyz"><title>Preparatory</title>
           <dl id="N02" type="arabic">
        <dt id="N2"><p>A</p></dt>
      </dl>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <dl id="N0" type="roman">
        <dt id="N"><p>A</p></dt>
      </dl>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <dl id="note1l" type="alphabet">
        <dt id="note1"><p>A</p></dt>
      </dl>
          <dl id="note2l" type="roman_upper">
        <dt id="note2"><p>A</p></dt>
      </dl>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <dl id="ANl" type="alphabet_upper">
        <dt id="AN"><p>A</p></dt>
      </dl>
          </clause>
          <clause id="annex1b">
          <dl id="Anote1l" type="roman" start="4">
        <dt id="Anote1"><p>A</p></dt>
      </dl>
          <dl id="Anote2l">
        <dt id="Anote2"><p>A</p></dt>
      </dl>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
        <xref target='N1'>Introduction, Definition List: A</xref>
        <xref target='N2'>Preparatory, Definition List: A</xref>
        <xref target='N'>Clause 1, Definition List: A</xref>
        <xref target='note1'>Clause 3.1, Definition List 1: A</xref>
        <xref target='note2'>Clause 3.1, Definition List 2: A</xref>
        <xref target='AN'>Annex A.1, Definition List: A</xref>
        <xref target='Anote1'>Annex A.2, Definition List 1: A</xref>
        <xref target='Anote2'>Annex A.2, Definition List 2: A</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references definition list terms that are stem expressions" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      </p>
      </foreword>
      <introduction id="intro">
      <dl id="N01">
      <dt id="N1"><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mover accent="true"><mrow><mi>e</mi></mrow><mo>^</mo></mover></mrow><mrow><mi>r</mi></mrow></msub></math></stem>
      <index><primary>
      <stem type="MathML">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <msub>
            <mrow>
              <mover accent="true">
                <mrow>
                  <mi>e</mi>
                </mrow>
                <mo>^</mo>
              </mover>
            </mrow>
            <mrow>
              <mi>r</mi>
            </mrow>
          </msub>
        </math>
      </stem>
      </primary></index></dt><dd>
      <p id="_543e0447-dfc6-477e-00cb-1738d6853190"><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>r</mi></math></stem>-direction</p>
      </dd>
            </dl>
                </clause>
                </annex>
                </iso-standard>
    INPUT
    output = <<~OUTPUT
         <foreword displayorder='2'>
           <p><xref target="N1">Introduction, Definition List: <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mover accent="true"><mrow><mi>e</mi></mrow><mo>^</mo></mover></mrow><mrow><mi>r</mi></mrow></msub></math><asciimath>overset(^)(e)_(r)</asciimath></stem>
      </xref>
           </p>
         </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='2'>
        <p>
          <xref target='N1'>Introduction</xref>
          <xref target='N2'>Preparatory</xref>
          <xref target='N'>Clause 1</xref>
          <xref target='note1'>Note 2</xref>
          <xref target='note2'>Clause 3.1</xref>
          <xref target='AN'>Annex A.1</xref>
          <xref target='Anote1'>Figure A.1</xref>
          <xref target='Anote2'>Annex A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
