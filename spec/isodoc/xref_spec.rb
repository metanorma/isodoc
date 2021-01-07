require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references external documents in Presentation XML" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
      <p>
        <xref target='a#b'>a#b</xref>
      </p>
    </foreword>
  </preface>
</iso-standard>
    OUTPUT
  end

  it "cross-references external documents in HTML" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
        <xref target='a#b'>a#b</xref>
    </p>
    </foreword>
    </preface>
    </iso-standard
    INPUT
        #{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
<a href="a.html#b">a#b</a>
</p>
      </div>
      <p class="zzSTDTitle1"/>
    </div>
  </body>
</html>
    OUTPUT
  end

  it "cross-references external documents in DOC" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">').sub(%r{</div>.*$}m, "</div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
        <xref target='a#b'>a#b</xref>
    </p>
    </foreword>
    </preface>
    </iso-standard>
    INPUT
           <div class="WordSection2">
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p>
       <a href="a.doc#b">a#b</a>
       </p>
             </div></div>
    OUTPUT
  end

  it "warns of missing crossreference" do
    expect { IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true) }.to output(/No label has been processed for ID N1/).to_stderr
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N1"/>
    </preface>
    </iso-standard>
    INPUT
  end

  it "does not warn of missing crossreference if text is supplied" do
    expect { IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true) }.not_to output(/No label has been processed for ID N1/).to_stderr
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N1">abc</xref>
    </preface>
    </iso-standard>
    INPUT
  end

  it "cross-references notes" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
     <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <note id='N1'>
        <name>NOTE</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <note id='N2'>
          <name>NOTE</name>
          <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d'>
            These results are based on a study carried out on three different
            types of kernel.
          </p>
        </note>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <note id='N'>
        <name>NOTE</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
      <p>
      <xref target='N'>Note</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
      <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <note id='note1'>
          <name>NOTE 1</name>
          <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
            These results are based on a study carried out on three different
            types of kernel.
          </p>
        </note>
        <note id='note2'>
          <name>NOTE 2</name>
          <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
            These results are based on a study carried out on three different
            types of kernel.
          </p>
        </note>
        <p>
          <xref target='note1'>Note 1</xref>
<xref target='note2'>Note 2</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <note id='AN'>
        <name>NOTE</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <note id='Anote1'>
        <name>NOTE 1</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
      <note id='Anote2'>
        <name>NOTE 2</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references figures" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
     <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword id='fwd'>
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
           <introduction id='intro'>
             <figure id='N1'>
               <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
               <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
             </figure>
             <clause id='xyz'>
               <title depth='2'>Preparatory</title>
               <figure id='N2' unnumbered='true'>
                 <name>Split-it-right sample divider</name>
                 <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
               </figure>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='scope' type="scope">
             <title depth='1'>
  1.
  <tab/>
  Scope
</title>
             <figure id='N'>
               <name>Figure 2&#xA0;&#x2014; Split-it-right sample divider</name>
               <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
             </figure>
             <p>
             <xref target='N'>Figure 2</xref>
             </p>
           </clause>
           <terms id='terms'>
  <title>2.</title>
</terms>
           <clause id='widgets'>
             <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
             <clause id='widgets1'><title>3.1.</title>
               <figure id='note1'>
                 <name>Figure 3&#xA0;&#x2014; Split-it-right sample divider</name>
                 <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
               </figure>
               <figure id='note3' class='pseudocode'>
                 <name>Figure 4</name>
                 <p>pseudocode</p>
               </figure>
               <sourcecode id='note4'>
                 <name>Figure 5&#xA0;&#x2014; Source! Code!</name>
                  A B C
               </sourcecode>
               <example id='note5'>
               <name>EXAMPLE</name>
                 <sourcecode id='note51'> A B C </sourcecode>
               </example>
               <figure id='note2'>
                 <name>Figure 6&#xA0;&#x2014; Split-it-right sample divider</name>
                 <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
               </figure>
               <p>
                 <xref target='note1'>Figure 3</xref>
<xref target='note2'>Figure 6</xref>
               </p>
             </clause>
           </clause>
         </sections>
         <annex id='annex1'>
         <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
           <clause id='annex1a'><title>A.1.</title>
             <figure id='AN'>
               <name>Figure A.1&#xA0;&#x2014; Split-it-right sample divider</name>
               <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
             </figure>
           </clause>
           <clause id='annex1b'><title>A.2.</title>
             <figure id='Anote1' unnumbered='true'>
               <name>Split-it-right sample divider</name>
               <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
             </figure>
             <figure id='Anote2'>
               <name>Figure A.2&#xA0;&#x2014; Split-it-right sample divider</name>
               <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
             </figure>
             <sourcecode id='Anote3'>
               <name>Figure A.3&#xA0;&#x2014; Source! Code!</name>
                A B C
             </sourcecode>
           </clause>
         </annex>
       </iso-standard>
    OUTPUT
  end

  it "cross-references subfigures" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword id='fwd'>
             <p>
               <xref target='N'>Figure 1</xref>
<xref target='note1'>Figure 1-1</xref>
<xref target='note2'>Figure 1-2</xref>
<xref target='AN'>Figure A.1</xref>
<xref target='Anote1'>Figure A.1-1</xref>
<xref target='Anote2'>Figure A.1-2</xref>
             </p>
           </foreword>
         </preface>
         <sections>
           <clause id='scope' type="scope">
           <title depth='1'>
  1.
  <tab/>
  Scope
</title>
           </clause>
           <terms id='terms'>
  <title>2.</title>
</terms>
           <clause id='widgets'>
             <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
             <clause id='widgets1'><title>3.1.</title>
               <figure id='N'>
                 <figure id='note1'>
                   <name>Figure 1-1&#xA0;&#x2014; Split-it-right sample divider</name>
                   <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                 </figure>
                 <figure id='note2'>
                   <name>Figure 1-2&#xA0;&#x2014; Split-it-right sample divider</name>
                   <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                 </figure>
               </figure>
               <p>
                 <xref target='note1'>Figure 1-1</xref>
<xref target='note2'>Figure 1-2</xref>
               </p>
             </clause>
           </clause>
         </sections>
         <annex id='annex1'>
         <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
           <clause id='annex1a'>     <title>A.1.</title>
  </clause>
           <clause id='annex1b'><title>A.2.</title>
             <figure id='AN'>
               <figure id='Anote1'>
                 <name>Figure A.1-1&#xA0;&#x2014; Split-it-right sample divider</name>
                 <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
               </figure>
               <figure id='Anote2'>
                 <name>Figure A.1-2&#xA0;&#x2014; Split-it-right sample divider</name>
                 <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
               </figure>
             </figure>
           </clause>
         </annex>
       </iso-standard>
    OUTPUT
  end

  it "cross-references examples" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
  <p>Hello</p>
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
           <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <example id='N1'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <example id='N2' unnumbered='true'>
          <name>EXAMPLE</name>
          <p>Hello</p>
        </example>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <example id='N'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
      <p>
      <xref target='N'>Example</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
      <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <example id='note1'>
          <name>EXAMPLE 1</name>
          <p>Hello</p>
        </example>
        <example id='note2' unnumbered='true'>
          <name>EXAMPLE</name>
          <p>Hello</p>
        </example>
        <p>
        <xref target='note1'>Example 1</xref>
<xref target='note2'>Example (??)</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <example id='AN'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <example id='Anote1' unnumbered='true'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
      <example id='Anote2'>
        <name>EXAMPLE 1</name>
        <p>Hello</p>
      </example>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references formulae" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
           <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <formula id='N1'>
        <name>1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <formula id='N2' unnumbered='true'>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
    <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <formula id='N'>
        <name>2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <p>
      <xref target='N'>Formula (2)</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
      <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <formula id='note1'>
          <name>3</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
        <formula id='note2'>
          <name>4</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
        <p>
          <xref target='note1'>Formula (3)</xref>
<xref target='note2'>Formula (4)</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <formula id='AN'>
        <name>A.1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <formula id='Anote1' unnumbered='true'>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <formula id='Anote2'>
        <name>A.2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

    it "cross-references requirements" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <requirement id="N1">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
  <clause id="xyz"><title>Preparatory</title>
    <requirement id="N2" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
</clause>
    </introduction>
    </preface>
    <sections>
    <clause id="scope" type="scope"><title>Scope</title>
    <requirement id="N">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
  <p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <requirement id="note1">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
    <requirement id="note2">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <requirement id="AN">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
    </clause>
    <clause id="annex1b">
    <requirement id="Anote1" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
    <requirement id="Anote2">
  <stem type="AsciiMath">r = 1 %</stem>
  </requirement>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <requirement id='N1'>
        <name>Requirement 1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </requirement>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <requirement id='N2' unnumbered='true'>
          <name>Requirement</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </requirement>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <requirement id='N'>
        <name>Requirement 2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </requirement>
      <p>
        <xref target='N'>Requirement 2</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
    <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <requirement id='note1'>
          <name>Requirement 3</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </requirement>
        <requirement id='note2'>
          <name>Requirement 4</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </requirement>
        <p>
          <xref target='note1'>Requirement 3</xref>
<xref target='note2'>Requirement 4</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <requirement id='AN'>
        <name>Requirement A.1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </requirement>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <requirement id='Anote1' unnumbered='true'>
        <name>Requirement</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </requirement>
      <requirement id='Anote2'>
        <name>Requirement A.2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </requirement>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
    end

        it "cross-references recommendations" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <recommendation id="N1">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
  <clause id="xyz"><title>Preparatory</title>
    <recommendation id="N2" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
</clause>
    </introduction>
    </preface>
    <sections>
    <clause id="scope" type="scope"><title>Scope</title>
    <recommendation id="N">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
  <p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <recommendation id="note1">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
    <recommendation id="note2">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <recommendation id="AN">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
    </clause>
    <clause id="annex1b">
    <recommendation id="Anote1" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
    <recommendation id="Anote2">
  <stem type="AsciiMath">r = 1 %</stem>
  </recommendation>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <recommendation id='N1'>
        <name>Recommendation 1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </recommendation>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <recommendation id='N2' unnumbered='true'>
          <name>Recommendation</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </recommendation>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <recommendation id='N'>
        <name>Recommendation 2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </recommendation>
      <p>
      <xref target='N'>Recommendation 2</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
    <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <recommendation id='note1'>
          <name>Recommendation 3</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </recommendation>
        <recommendation id='note2'>
          <name>Recommendation 4</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </recommendation>
        <p>
           <xref target='note1'>Recommendation 3</xref>
 <xref target='note2'>Recommendation 4</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <recommendation id='AN'>
        <name>Recommendation A.1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </recommendation>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <recommendation id='Anote1' unnumbered='true'>
        <name>Recommendation</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </recommendation>
      <recommendation id='Anote2'>
        <name>Recommendation A.2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </recommendation>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
    end

        it "cross-references permissions" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <permission id="N1">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
  <clause id="xyz"><title>Preparatory</title>
    <permission id="N2" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
</clause>
    </introduction>
    </preface>
    <sections>
    <clause id="scope" type="scope"><title>Scope</title>
    <permission id="N">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
  <p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <permission id="note1">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
    <permission id="note2">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <permission id="AN">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
    </clause>
    <clause id="annex1b">
    <permission id="Anote1" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
    <permission id="Anote2">
  <stem type="AsciiMath">r = 1 %</stem>
  </permission>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword>
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
           <introduction id='intro'>
             <permission id='N1'>
               <name>Permission 1</name>
               <stem type='AsciiMath'>r = 1 %</stem>
             </permission>
             <clause id='xyz'>
               <title depth='2'>Preparatory</title>
               <permission id='N2' unnumbered='true'>
                 <name>Permission</name>
                 <stem type='AsciiMath'>r = 1 %</stem>
               </permission>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='scope' type="scope">
             <title depth='1'>
  1.
  <tab/>
  Scope
</title>
             <permission id='N'>
               <name>Permission 2</name>
               <stem type='AsciiMath'>r = 1 %</stem>
             </permission>
             <p>
               <xref target='N'>Permission 2</xref>
             </p>
           </clause>
           <terms id='terms'>
  <title>2.</title>
</terms>
           <clause id='widgets'>
           <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
             <clause id='widgets1'><title>3.1.</title>
               <permission id='note1'>
                 <name>Permission 3</name>
                 <stem type='AsciiMath'>r = 1 %</stem>
               </permission>
               <permission id='note2'>
                 <name>Permission 4</name>
                 <stem type='AsciiMath'>r = 1 %</stem>
               </permission>
               <p>
               <xref target='note1'>Permission 3</xref>
<xref target='note2'>Permission 4</xref>
               </p>
             </clause>
           </clause>
         </sections>
         <annex id='annex1'>
         <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
           <clause id='annex1a'><title>A.1.</title>
             <permission id='AN'>
               <name>Permission A.1</name>
               <stem type='AsciiMath'>r = 1 %</stem>
             </permission>
           </clause>
           <clause id='annex1b'><title>A.2.</title>
             <permission id='Anote1' unnumbered='true'>
               <name>Permission</name>
               <stem type='AsciiMath'>r = 1 %</stem>
             </permission>
             <permission id='Anote2'>
               <name>Permission A.2</name>
               <stem type='AsciiMath'>r = 1 %</stem>
             </permission>
           </clause>
         </annex>
       </iso-standard>
OUTPUT
    end

        it "labels and cross-references nested requirements" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <permission id="N1">
    <permission id="N2">
    <permission id="N">
    </permission>
    </permission>
    <requirement id="Q1">
    </requirement>
    <recommendation id="R1">
    </recommendation>
    </permission>
    </clause>
    </sections>
    <annex id="Axyz"><title>Preparatory</title>
    <permission id="AN1">
    <permission id="AN2">
    <permission id="AN">
    </permission>
    </permission>
    <requirement id="AQ1">
    </requirement>
    <recommendation id="AR1">
    </recommendation>
    </permission>
    </annex>
    </iso-standard>
    INPUT
<?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword>
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
         </preface>
         <sections>
           <clause id='xyz'>
           <title depth='1'>
  1.
  <tab/>
  Preparatory
</title>
             <permission id='N1'>
               <name>Permission 1</name>
               <permission id='N2'>
                 <name>Permission 1-1</name>
                 <permission id='N'>
                   <name>Permission 1-1-1</name>
                 </permission>
               </permission>
               <requirement id='Q1'>
                 <name>Requirement 1-1</name>
               </requirement>
               <recommendation id='R1'>
                 <name>Recommendation 1-1</name>
               </recommendation>
             </permission>
           </clause>
         </sections>
         <annex id='Axyz'>
         <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
  <br/>
  <br/>
           <strong>Preparatory</strong></title>
           <permission id='AN1'>
             <name>Permission A.1</name>
             <permission id='AN2'>
               <name>Permission A.1-1</name>
               <permission id='AN'>
                 <name>Permission A.1-1-1</name>
               </permission>
             </permission>
             <requirement id='AQ1'>
               <name>Requirement A.1-1</name>
             </requirement>
             <recommendation id='AR1'>
               <name>Recommendation A.1-1</name>
             </recommendation>
           </permission>
         </annex>
       </iso-standard>
    OUTPUT
        end


  it "cross-references tables" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
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
    <introduction id='intro'>
      <table id='N1'>
        <name>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
        <tbody>
          <tr>
            <td align='left'>Number of laboratories retained after eliminating outliers</td>
            <td align='center'>13</td>
            <td align='center'>11</td>
          </tr>
        </tbody>
      </table>
      <clause id='xyz'>
        <title depth='2'>Preparatory</title>
        <table id='N2' unnumbered='true'>
          <name>Table &#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
          <tbody>
            <tr>
              <td align='left'>Number of laboratories retained after eliminating outliers</td>
              <td align='center'>13</td>
              <td align='center'>11</td>
            </tr>
          </tbody>
        </table>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <table id='N'>
        <name>Table 2&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
        <tbody>
          <tr>
            <td align='left'>Number of laboratories retained after eliminating outliers</td>
            <td align='center'>13</td>
            <td align='center'>11</td>
          </tr>
        </tbody>
      </table>
      <p>
        <xref target='N'>Table 2</xref>
      </p>
    </clause>
    <terms id='terms'>
  <title>2.</title>
</terms>
    <clause id='widgets'>
    <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
      <clause id='widgets1'><title>3.1.</title>
        <table id='note1'>
          <name>Table 3&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
          <tbody>
            <tr>
              <td align='left'>Number of laboratories retained after eliminating outliers</td>
              <td align='center'>13</td>
              <td align='center'>11</td>
            </tr>
          </tbody>
        </table>
        <table id='note2'>
          <name>Table 4&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
          <tbody>
            <tr>
              <td align='left'>Number of laboratories retained after eliminating outliers</td>
              <td align='center'>13</td>
              <td align='center'>11</td>
            </tr>
          </tbody>
        </table>
        <p>
          <xref target='note1'>Table 3</xref>
<xref target='note2'>Table 4</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
    <clause id='annex1a'><title>A.1.</title>
      <table id='AN'>
        <name>Table A.1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
        <tbody>
          <tr>
            <td align='left'>Number of laboratories retained after eliminating outliers</td>
            <td align='center'>13</td>
            <td align='center'>11</td>
          </tr>
        </tbody>
      </table>
    </clause>
    <clause id='annex1b'><title>A.2.</title>
      <table id='Anote1' unnumbered='true'>
        <name>Table &#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
        <tbody>
          <tr>
            <td align='left'>Number of laboratories retained after eliminating outliers</td>
            <td align='center'>13</td>
            <td align='center'>11</td>
          </tr>
        </tbody>
      </table>
      <table id='Anote2'>
        <name>Table A.2&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</name>
        <tbody>
          <tr>
            <td align='left'>Number of laboratories retained after eliminating outliers</td>
            <td align='center'>13</td>
            <td align='center'>11</td>
          </tr>
        </tbody>
      </table>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references term notes" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<term id="_waxy_rice"><preferred>waxy rice</preferred>
<termnote id="note1">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote></term>
<term id="_nonwaxy_rice"><preferred>nonwaxy rice</preferred>
<termnote id="note2">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="note3">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote></term>
</terms>

    </iso-standard>
    INPUT
           <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
      <p>
        <xref target='note1'>Clause 2.1, Note 1</xref>
<xref target='note2'>Clause 2.2, Note 1</xref>
<xref target='note3'>Clause 2.2, Note 2</xref>
      </p>
    </foreword>
  </preface>
  <sections>
    <clause id='scope' type="scope">
      <title depth='1'>
  1.
  <tab/>
  Scope
</title>
    </clause>
    <terms id='terms'>
  <title>2.</title>
      <term id='_waxy_rice'>
       <name>2.1.</name>
        <preferred>waxy rice</preferred>
        <termnote id='note1'>
          <name>Note 1 to entry</name>
          <p id='_b0cb3dfd-78fc-47dd-a339-84070d947463'>
            The starch of waxy rice consists almost entirely of amylopectin. The
            kernels have a tendency to stick together after cooking.
          </p>
        </termnote>
      </term>
      <term id='_nonwaxy_rice'>
       <name>2.2.</name>
        <preferred>nonwaxy rice</preferred>
        <termnote id='note2'>
          <name>Note 1 to entry</name>
          <p id='_b0cb3dfd-78fc-47dd-a339-84070d947463'>
            The starch of waxy rice consists almost entirely of amylopectin. The
            kernels have a tendency to stick together after cooking.
          </p>
        </termnote>
        <termnote id='note3'>
          <name>Note 2 to entry</name>
          <p id='_b0cb3dfd-78fc-47dd-a339-84070d947463'>
            The starch of waxy rice consists almost entirely of amylopectin. The
            kernels have a tendency to stick together after cooking.
          </p>
        </termnote>
      </term>
    </terms>
  </sections>
</iso-standard>
    OUTPUT
  end

  it "cross-references sections" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
         <preferred>Term2</preferred>
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
    <?xml version='1.0'?>
        <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword obligation='informative'>
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
            <introduction id='B' obligation='informative'>
              <title>Introduction</title>
              <clause id='C' inline-header='false' obligation='informative'>
                <title depth="2">Introduction Subsection</title>
              </clause>
              <clause id='C1' inline-header='false' obligation='informative'>Text</clause>
            </introduction>
          </preface>
          <sections>
            <clause id='D' obligation='normative' type="scope">
              <title depth='1'>
  1.
  <tab/>
  Scope
</title>
              <p id='E'>Text</p>
            </clause>
            <terms id='H' obligation='normative'>
            <title depth='1'>
  3.
  <tab/>
  Terms, definitions, symbols and abbreviated terms
</title>
              <terms id='I' obligation='normative'>
              <title depth='2'>
  3.1.
  <tab/>
  Normal Terms
</title>
                <term id='J'><name>3.1.1.</name>
                  <preferred>Term2</preferred>
                </term>
              </terms>
              <definitions id='K'>
              <title>3.2.</title>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </terms>
            <definitions id='L'>
            <title>4.</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id='M' inline-header='false' obligation='normative'>
              <title depth='1'>
  5.
  <tab/>
  Clause 4
</title>
              <clause id='N' inline-header='false' obligation='normative'>
               <title depth='2'>
   5.1.
   <tab/>
   Introduction
 </title>
              </clause>
              <clause id='O' inline-header='false' obligation='normative'>
               <title depth='2'>
   5.2.
   <tab/>
   Clause 4.2
 </title>
              </clause>
            </clause>
          </sections>
          <annex id='P' inline-header='false' obligation='normative'>
          <title>
  <strong>Annex A</strong>
  <br/>
  (normative)
  <br/>
  <br/>
            <strong>Annex</strong></title>
            <clause id='Q' inline-header='false' obligation='normative'>
            <title depth='2'>
  A.1.
  <tab/>
  Annex A.1
</title>
              <clause id='Q1' inline-header='false' obligation='normative'>
               <title depth='3'>
   A.1.1.
   <tab/>
   Annex A.1a
 </title>
              </clause>
            </clause>
          </annex>
          <annex id='QQ'>
          <title>
  <strong>Annex B</strong>
  <br/>
  (informative)
</title>
            <terms id='QQ1'>
            <title>B.</title>
              <term id='QQ2'>
               <name>B.1.</name>
               </term>
            </terms>
          </annex>
          <bibliography>
            <references id='R' obligation='informative' normative='true'>
            <title depth='1'>
  2.
  <tab/>
  Normative References
</title>
            </references>
            <clause id='S' obligation='informative'>
              <title depth="1">Bibliography</title>
              <references id='T' obligation='informative' normative='false'>
                <title depth="2">Bibliography Subsection</title>
              </references>
            </clause>
          </bibliography>
        </iso-standard>
    OUTPUT
  end

  it "cross-references lists" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
        <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword>
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
            <introduction id='intro'>
              <ol id='N1'>
                <li>
                  <p>A</p>
                </li>
              </ol>
              <clause id='xyz'>
                <title depth='2'>Preparatory</title>
                <ol id='N2'>
                  <li>
                    <p>A</p>
                  </li>
                </ol>
              </clause>
            </introduction>
          </preface>
          <sections>
            <clause id='scope' type="scope">
              <title depth='1'>
  1.
  <tab/>
  Scope
</title>
              <ol id='N'>
                <li>
                  <p>A</p>
                </li>
              </ol>
            </clause>
            <terms id='terms'>
  <title>2.</title>
</terms>
            <clause id='widgets'>
            <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
              <clause id='widgets1'><title>3.1.</title>
                <ol id='note1'>
                  <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                    These results are based on a study carried out on three different
                    types of kernel.
                  </p>
                </ol>
                <ol id='note2'>
                  <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
                    These results are based on a study carried out on three different
                    types of kernel.
                  </p>
                </ol>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
          <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
            <clause id='annex1a'><title>A.1.</title>
              <ol id='AN'>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </ol>
            </clause>
            <clause id='annex1b'><title>A.2.</title>
              <ol id='Anote1'>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </ol>
              <ol id='Anote2'>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </ol>
            </clause>
          </annex>
        </iso-standard>
    OUTPUT
  end

  it "cross-references list items" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <ol id="N01">
  <li id="N1"><p>A</p></li>
</ol>
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
 <?xml version='1.0'?>
        <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword>
              <p>
                <xref target='N1'>Introduction, a)</xref>
                <xref target='N2'>Preparatory, 1)</xref>
                <xref target='N'>Clause 1, i)</xref>
                <xref target='note1'>Clause 3.1, List 1 a)</xref>
                <xref target='note2'>Clause 3.1, List 2 I)</xref>
                <xref target='AN'>Annex A.1, A)</xref>
                <xref target='Anote1'>Annex A.2, List 1 iv)</xref>
                <xref target='Anote2'>Annex A.2, List 2 a)</xref>
              </p>
            </foreword>
            <introduction id='intro'>
              <ol id='N01'>
                <li id='N1'>
                  <p>A</p>
                </li>
              </ol>
              <clause id='xyz'>
                <title depth='2'>Preparatory</title>
                <ol id='N02' type="arabic">
                  <li id='N2'>
                    <p>A</p>
                  </li>
                </ol>
              </clause>
            </introduction>
          </preface>
          <sections>
            <clause id='scope' type="scope">
              <title depth='1'>
  1.
  <tab/>
  Scope
</title>
              <ol id='N0' type="roman">
                <li id='N'>
                  <p>A</p>
                </li>
              </ol>
            </clause>
            <terms id='terms'>
  <title>2.</title>
</terms>
            <clause id='widgets'>
            <title depth='1'>
  3.
  <tab/>
  Widgets
</title>
              <clause id='widgets1'><title>3.1.</title>
                <ol id='note1l' type="alphabet">
                  <li id='note1'>
                    <p>A</p>
                  </li>
                </ol>
                <ol id='note2l' type="roman_upper">
                  <li id='note2'>
                    <p>A</p>
                  </li>
                </ol>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
          <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
            <clause id='annex1a'><title>A.1.</title>
              <ol id='ANl' type="alphabet_upper">
                <li id='AN'>
                  <p>A</p>
                </li>
              </ol>
            </clause>
            <clause id='annex1b'><title>A.2.</title>
              <ol id='Anote1l' type="roman" start="4">
                <li id='Anote1'>
                  <p>A</p>
                </li>
              </ol>
              <ol id='Anote2l'>
                <li id='Anote2'>
                  <p>A</p>
                </li>
              </ol>
            </clause>
          </annex>
        </iso-standard>
    OUTPUT
  end

  it "cross-references nested list items" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
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
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
      <p>
        <xref target='N'>Clause 1, a)</xref>
        <xref target='note1'>Clause 1, a.1)</xref>
        <xref target='note2'>Clause 1, a.1.i)</xref>
        <xref target='AN'>Clause 1, a.1.i.A)</xref>
        <xref target='Anote1'>Clause 1, a.1.i.A.I)</xref>
        <xref target='Anote2'>Clause 1, a.1.i.A.I.a)</xref>
      </p>
    </foreword>
  </preface>
  <sections>
    <clause id='scope' type="scope">
    <title depth='1'>
  1.
  <tab/>
  Scope
</title>
      <ol id='N1'>
        <li id='N'>
          <p>A</p>
          <ol>
            <li id='note1'>
              <p>A</p>
              <ol>
                <li id='note2'>
                  <p>A</p>
                  <ol>
                    <li id='AN'>
                      <p>A</p>
                      <ol>
                        <li id='Anote1'>
                          <p>A</p>
                          <ol>
                            <li id='Anote2'>
                              <p>A</p>
                            </li>
                          </ol>
                        </li>
                      </ol>
                    </li>
                  </ol>
                </li>
              </ol>
            </li>
          </ol>
        </li>
      </ol>
    </clause>
  </sections>
</iso-standard>
    OUTPUT
  end

  it "cross-references bookmarks" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <p id="note1l" type="alphabet">
  <bookmark id="note1"/>
</p>
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
    <p id="Anote1l" type="roman" start="4">
  <bookmark id="Anote1"/>
</p>
    <p id="Anote2l">
  <bookmark id="Anote2"/>
</p>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <preface>
           <foreword>
             <p>
               <xref target='N1'>Introduction</xref>
               <xref target='N2'>Preparatory</xref>
               <xref target='N'>Clause 1</xref>
               <xref target='note1'>Clause 3.1</xref>
               <xref target='note2'>Clause 3.1</xref>
               <xref target='AN'>Annex A.1</xref>
               <xref target='Anote1'>Annex A.2</xref>
               <xref target='Anote2'>Annex A.2</xref>
             </p>
           </foreword>
           <introduction id='intro'>
             <p id='N01'>
               <bookmark id='N1'/>
             </p>
             <clause id='xyz'>
               <title depth='2'>Preparatory</title>
               <p id='N02' type='arabic'>
                 <bookmark id='N2'/>
               </p>
             </clause>
           </introduction>
         </preface>
         <sections>
           <clause id='scope' type='scope'>
             <title depth='1'>
               1.
               <tab/>
               Scope
             </title>
             <p id='N0' type='roman'>
               <bookmark id='N'/>
             </p>
           </clause>
           <terms id='terms'>
             <title>2.</title>
           </terms>
           <clause id='widgets'>
             <title depth='1'>
               3.
               <tab/>
               Widgets
             </title>
             <clause id='widgets1'>
               <title>3.1.</title>
               <p id='note1l' type='alphabet'>
                 <bookmark id='note1'/>
               </p>
               <p id='note2l' type='roman_upper'>
                 <bookmark id='note2'/>
               </p>
             </clause>
           </clause>
         </sections>
         <annex id='annex1'>
           <title>
             <strong>Annex A</strong>
             <br/>
             (informative)
           </title>
           <clause id='annex1a'>
             <title>A.1.</title>
             <p id='ANl' type='alphabet_upper'>
               <bookmark id='AN'/>
             </p>
           </clause>
           <clause id='annex1b'>
             <title>A.2.</title>
             <p id='Anote1l' type='roman' start='4'>
               <bookmark id='Anote1'/>
             </p>
             <p id='Anote2l'>
               <bookmark id='Anote2'/>
             </p>
           </clause>
         </annex>
       </iso-standard>
OUTPUT
end

   it "realises subsequences" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword id='fwd'>
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
    <introduction id='intro'>
      <figure id='N1'>
        <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N2' subsequence='A'>
        <name>Figure 2a&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N3' subsequence='A'>
        <name>Figure 2b&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N4' subsequence='B'>
        <name>Figure 3a&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N5' subsequence='B'>
        <name>Figure 3b&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N6' subsequence='B'>
        <name>Figure 3c&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N7'>
        <name>Figure 4&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N8'>
        <name>Figure 5&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
    </introduction>
  </preface>
</iso-standard>
    OUTPUT
   end

      it "realises numbering overrides" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
               <preferred>Term1</preferred>
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
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword id='fwd'>
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
    <introduction id='intro'>
      <figure id='N1'>
        <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N2' number='A'>
        <name>Figure A&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N3'>
        <name>Figure B&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N4' number='7'>
        <name>Figure 7&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N5'>
        <name>Figure 8&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N6' subsequence='B'>
        <name>Figure 9a&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N7' subsequence='B' number='c'>
        <name>Figure 9c&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N8' subsequence='B'>
        <name>Figure 9d&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N9' subsequence='C' number='20f'>
        <name>Figure 20f&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
      <figure id='N10' subsequence='C'>
        <name>Figure 20g&#xA0;&#x2014; Split-it-right sample divider</name>
        <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
      </figure>
       <figure id='N11' number='A.1'>
   <name>Figure A.1&#xA0;&#x2014; Split-it-right sample divider</name>
   <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
 </figure>
 <figure id='N12'>
   <name>Figure A.2&#xA0;&#x2014; Split-it-right sample divider</name>
   <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
 </figure>
 <figure id='N13' number='100'>
   <name>Figure 100&#xA0;&#x2014; Split-it-right sample divider</name>
   <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
 </figure>

    </introduction>
  </preface>
  <sections>
           <clause id='S1' number='1bis' type='scope' inline-header='false' obligation='normative'>
             <title depth='1'>
               1bis.
               <tab/>
               Scope
             </title>
             <p id='_'>Text</p>
           </clause>
           <terms id='S3' number='3bis' obligation='normative'>
             <title depth='1'>
               3bis.
               <tab/>
               Terms and definitions
             </title>
             <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
             <term id='S4' number='4bis'>
               <name>3bis.4bis.</name>
               <preferred>Term1</preferred>
             </term>
           </terms>
           <definitions id='S12' number='12bis' type='abbreviated_terms' obligation='normative'>
             <title depth='1'>
               12bis.
               <tab/>
               Abbreviated terms
             </title>
           </definitions>
           <clause id='S13' number='13bis' inline-header='false' obligation='normative'>
             <title depth='1'>
               13bis.
               <tab/>
               Clause 4
             </title>
             <clause id='S14' number='14bis' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.14bis.
                 <tab/>
                 Introduction
               </title>
             </clause>
             <clause id='S15' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.14bit.
                 <tab/>
                 Clause A
               </title>
             </clause>
             <clause id='S16' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.14biu.
                 <tab/>
                 Clause B
               </title>
             </clause>
             <clause id='S17' number='0' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.0.
                 <tab/>
                 Clause C
               </title>
             </clause>
             <clause id='S18' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.1.
                 <tab/>
                 Clause D
               </title>
             </clause>
             <clause id='S19' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.2.
                 <tab/>
                 Clause E
               </title>
             </clause>
             <clause id='S20' number='a' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.a.
                 <tab/>
                 Clause F
               </title>
             </clause>
             <clause id='S21' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.b.
                 <tab/>
                 Clause G
               </title>
             </clause>
             <clause id='S22' number='B' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.B.
                 <tab/>
                 Clause H
               </title>
             </clause>
             <clause id='S23' inline-header='false' obligation='normative'>
               <title depth='2'>
                 13bis.C.
                 <tab/>
                 Clause I
               </title>
             </clause>
           </clause>
           <clause id='S24' number='16bis' inline-header='false' obligation='normative'>
             <title depth='1'>
               16bis.
               <tab/>
               Terms and Definitions
             </title>
           </clause>
         </sections>
         <annex id='S25' obligation='normative'>
           <title>
             <strong>Annex A</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>First Annex</strong>
           </title>
         </annex>
         <annex id='S26' number='17bis' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex 17bis</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id='S27' number='18bis' inline-header='false' obligation='normative'>
             <title depth='2'>
               17bis.18bis.
               <tab/>
               Annex A.1
             </title>
           </clause>
         </annex>
         <annex id='S28' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex 17bit</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Another Annex</strong>
           </title>
         </annex>
         <bibliography>
           <references id='S2' number='2bis' normative='true' obligation='informative'>
             <title depth='1'>
               2bis.
               <tab/>
               Normative references
             </title>
             <p id='_'>There are no normative references in this document.</p>
           </references>
           <clause id='S29' number='19bis' obligation='informative'>
             <title depth='1'>Bibliography</title>
             <references id='S30' number='20bis' normative='false' obligation='informative'>
               <title depth='2'>Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
</iso-standard>
OUTPUT
      end

end
