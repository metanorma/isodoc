require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references external documents in HTML" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    expect(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">').sub(%r{</div>.*$}m, "</div>")).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="a#b"/>
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
             </div>
    OUTPUT
  end

  it "warns of missing crossreference" do
    expect { IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true) }.to output(/No label has been processed for ID N1/).to_stderr
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N1"/>
    </preface>
    </iso-standard>
    INPUT
  end


  it "cross-references notes" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
    #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
                 <a href="#N1">Introduction, Note</a>
                 <a href="#N2">Preparatory, Note</a>
           <a href="#N">Clause 1, Note</a>
           <a href="#note1">Clause 3.1, Note  1</a>
           <a href="#note2">Clause 3.1, Note  2</a>
           <a href="#AN">Annex A.1, Note</a>
           <a href="#Anote1">Annex A.2, Note  1</a>
           <a href="#Anote2">Annex A.2, Note  2</a>
           </p>
               </div>
                <br/>
                <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="N1" class="Note">
                 <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <div id="xyz"><h2>Preparatory</h2>
           <div id="N2" class="Note"><p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="scope">
               <h1>1.&#160; Scope</h1>
               <div id="N" class="Note">
                 <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <p>
                 <a href="#N">Note</a>
               </p>
             </div>
             <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
             <div id="widgets">
               <h1>3.&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1. </h2>
           <div id="note1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="note2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       <p>    <a href="#note1">Note  1</a> <a href="#note2">Note  2</a> </p>

           </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1. </h2>
           <div id="AN" class="Note"><p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
               <div id="annex1b"><h2>A.2. </h2>
           <div id="Anote1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="Anote2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "cross-references figures" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword id="fwd">
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
    <clause id="scope"><title>Scope</title>
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
    </clause>
    </annex>
    </iso-standard>
    INPUT
    #{HTML_HDR}
    <br/>
               <div id="fwd">
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N1">Figure 1</a>
           <a href="#N2">Figure (??)</a>
           <a href="#N">Figure 2</a>
           <a href="#note1">Figure 3</a>
           <a href="#note2">Figure 4</a>
           <a href="#AN">Figure A.1</a>
           <a href="#Anote1">Figure (??)</a>
           <a href="#Anote2">Figure A.2</a>
           </p>
               </div>
               <br/>
             <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="N1" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="xyz"><h2>Preparatory</h2>
               <div id="N2" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
       </div>
             </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <div id="N" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 2&#160;&#8212; Split-it-right sample divider</p></div>
                 <p>
                   <a href="#N">Figure 2</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1"><h2>3.1. </h2>
               <div id="note1" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 3&#160;&#8212; Split-it-right sample divider</p></div>
           <div id="note2" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 4&#160;&#8212; Split-it-right sample divider</p></div>
         <p>    <a href="#note1">Figure 3</a> <a href="#note2">Figure 4</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a"><h2>A.1. </h2>
               <div id="AN" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure A.1&#160;&#8212; Split-it-right sample divider</p></div>
           </div>
                 <div id="annex1b"><h2>A.2. </h2>
               <div id="Anote1" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
           <div id="Anote2" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure A.2&#160;&#8212; Split-it-right sample divider</p></div>
           </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references subfigures" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
    <br/>
               <div id="fwd">
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
         <a href="#N">Figure 1</a>
         <a href="#note1">Figure 1-1</a>
         <a href="#note2">Figure 1-2</a>
         <a href="#AN">Figure A.1</a>
         <a href="#Anote1">Figure A.1-1</a>
         <a href="#Anote2">Figure A.1-2</a>
         </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1"><h2>3.1. </h2>
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-1&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-2&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
       <p>    <a href="#note1">Figure 1-1</a> <a href="#note2">Figure 1-2</a> </p>
         </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a"><h2>A.1. </h2>
         </div>
                 <div id="annex1b"><h2>A.2. </h2>
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A.1-1&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A.1-2&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
         </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references examples" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N1">Introduction, Example</a>
           <a href="#N2">Preparatory, Example (??)</a>
           <a href="#N">Clause 1, Example</a>
           <a href="#note1">Clause 3.1, Example  1</a>
           <a href="#note2">Clause 3.1, Example (??)</a>
           <a href="#AN">Annex A.1, Example</a>
           <a href="#Anote1">Annex A.2, Example (??)</a>
           <a href="#Anote2">Annex A.2, Example  1</a>
           </p>
               </div>
               <br/>
             <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="N1" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
       </div>
               <div id="xyz"><h2>Preparatory</h2>
               <div id="N2" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
       </div>
       </div>
             </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
               <div id="N" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
                 </div>
                 <p>
                   <a href="#N">Example</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1"><h2>3.1. </h2>
               <div id="note1" class="example"><p class="example-title">EXAMPLE  1</p>
         <p>Hello</p>
       </div>
               <div id="note2" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
       </div>
       <p>    <a href="#note1">Example  1</a> <a href="#note2">Example (??)</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a"><h2>A.1. </h2>
               <div id="AN" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
       </div>
           </div>
                 <div id="annex1b"><h2>A.2. </h2>
               <div id="Anote1" class="example"><p class="example-title">EXAMPLE</p>
         <p>Hello</p>
       </div>
               <div id="Anote2" class="example"><p class="example-title">EXAMPLE  1</p>
         <p>Hello</p>
       </div>
           </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references formulae" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N1">Introduction, Formula (1)</a>
           <a href="#N2">Preparatory, Formula ((??))</a>
           <a href="#N">Clause 1, Formula (2)</a>
           <a href="#note1">Clause 3.1, Formula (3)</a>
           <a href="#note2">Clause 3.1, Formula (4)</a>
           <a href="#AN">Annex A.1, Formula (A.1)</a>
           <a href="#Anote1">Annex A.2, Formula ((??))</a>
           <a href="#Anote2">Annex A.2, Formula (A.2)</a>
           </p>
               </div>
                            <br/>
             <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="N1" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div>
                       <div id="xyz"><h2>Preparatory</h2>
    <div id="N2" class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div>
                </div>
             </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <div id="N" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (2)</p></div>
                 <p>
                   <a href="#N">Formula (2)</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1"><h2>3.1. </h2>
           <div id="note1" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (3)</p></div>
           <div id="note2" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (4)</p></div>
         <p>    <a href="#note1">Formula (3)</a> <a href="#note2">Formula (4)</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a"><h2>A.1. </h2>
           <div id="AN" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (A.1)</p></div>
           </div>
                 <div id="annex1b"><h2>A.2. </h2>
           <div id="Anote1" class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div>
           <div id="Anote2" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (A.2)</p></div>
           </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "cross-references requirements" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
#{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
    <a href="#N1">Introduction, Requirement 1</a>
    <a href="#N2">Preparatory, Requirement (??)</a>
    <a href="#N">Clause 1, Requirement 2</a>
    <a href="#note1">Clause 3.1, Requirement 3</a>
    <a href="#note2">Clause 3.1, Requirement 4</a>
    <a href="#AN">Annex A.1, Requirement A.1</a>
    <a href="#Anote1">Annex A.2, Requirement (??)</a>
    <a href="#Anote2">Annex A.2, Requirement A.2</a>
    </p>
      </div>
      <br/>
      <div class="Section3" id="intro">
        <h1 class="IntroTitle">Introduction</h1>
        <div class="require"><p class="AdmonitionTitle">Requirement 1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <div id="xyz"><h2>Preparatory</h2>
    <div class="require"><p class="AdmonitionTitle">Requirement:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
</div>
      </div>
      <p class="zzSTDTitle1"/>
      <div id="scope">
        <h1>1.&#160; Scope</h1>
        <div class="require"><p class="AdmonitionTitle">Requirement 2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <p>
          <a href="#N">Requirement 2</a>
        </p>
      </div>
      <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
</div>
      <div id="widgets">
        <h1>3.&#160; Widgets</h1>
        <div id="widgets1"><h2>3.1. </h2>
    <div class="require"><p class="AdmonitionTitle">Requirement 3:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="require"><p class="AdmonitionTitle">Requirement 4:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
  <p>    <a href="#note1">Requirement 3</a> <a href="#note2">Requirement 4</a> </p>
    </div>
      </div>
      <br/>
      <div id="annex1" class="Section3">
        <div id="annex1a"><h2>A.1. </h2>
    <div class="require"><p class="AdmonitionTitle">Requirement A.1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
        <div id="annex1b"><h2>A.2. </h2>
    <div class="require"><p class="AdmonitionTitle">Requirement:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="require"><p class="AdmonitionTitle">Requirement A.2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
      </div>
    </div>
  </body>
</html>
OUTPUT
    end

        it "cross-references recommendations" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
#{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
    <a href="#N1">Introduction, Recommendation 1</a>
    <a href="#N2">Preparatory, Recommendation (??)</a>
    <a href="#N">Clause 1, Recommendation 2</a>
    <a href="#note1">Clause 3.1, Recommendation 3</a>
    <a href="#note2">Clause 3.1, Recommendation 4</a>
    <a href="#AN">Annex A.1, Recommendation A.1</a>
    <a href="#Anote1">Annex A.2, Recommendation (??)</a>
    <a href="#Anote2">Annex A.2, Recommendation A.2</a>
    </p>
      </div>
      <br/>
      <div class="Section3" id="intro">
        <h1 class="IntroTitle">Introduction</h1>
        <div class="recommend"><p class="AdmonitionTitle">Recommendation 1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <div id="xyz"><h2>Preparatory</h2>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
</div>
      </div>
      <p class="zzSTDTitle1"/>
      <div id="scope">
        <h1>1.&#160; Scope</h1>
        <div class="recommend"><p class="AdmonitionTitle">Recommendation 2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <p>
          <a href="#N">Recommendation 2</a>
        </p>
      </div>
      <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
</div>
      <div id="widgets">
        <h1>3.&#160; Widgets</h1>
        <div id="widgets1"><h2>3.1. </h2>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation 3:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation 4:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
  <p>    <a href="#note1">Recommendation 3</a> <a href="#note2">Recommendation 4</a> </p>
    </div>
      </div>
      <br/>
      <div id="annex1" class="Section3">
        <div id="annex1a"><h2>A.1. </h2>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation A.1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
        <div id="annex1b"><h2>A.2. </h2>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="recommend"><p class="AdmonitionTitle">Recommendation A.2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
      </div>
    </div>
  </body>
</html>
OUTPUT
    end

        it "cross-references permissions" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
#{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
    <a href="#N1">Introduction, Permission 1</a>
    <a href="#N2">Preparatory, Permission (??)</a>
    <a href="#N">Clause 1, Permission 2</a>
    <a href="#note1">Clause 3.1, Permission 3</a>
    <a href="#note2">Clause 3.1, Permission 4</a>
    <a href="#AN">Annex A.1, Permission A.1</a>
    <a href="#Anote1">Annex A.2, Permission (??)</a>
    <a href="#Anote2">Annex A.2, Permission A.2</a>
    </p>
      </div>
      <br/>
      <div class="Section3" id="intro">
        <h1 class="IntroTitle">Introduction</h1>
        <div class="permission"><p class="AdmonitionTitle">Permission 1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <div id="xyz"><h2>Preparatory</h2>
    <div class="permission"><p class="AdmonitionTitle">Permission:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
</div>
      </div>
      <p class="zzSTDTitle1"/>
      <div id="scope">
        <h1>1.&#160; Scope</h1>
        <div class="permission"><p class="AdmonitionTitle">Permission 2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
        <p>
          <a href="#N">Permission 2</a>
        </p>
      </div>
      <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
</div>
      <div id="widgets">
        <h1>3.&#160; Widgets</h1>
        <div id="widgets1"><h2>3.1. </h2>
    <div class="permission"><p class="AdmonitionTitle">Permission 3:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="permission"><p class="AdmonitionTitle">Permission 4:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
  <p>    <a href="#note1">Permission 3</a> <a href="#note2">Permission 4</a> </p>
    </div>
      </div>
      <br/>
      <div id="annex1" class="Section3">
        <div id="annex1a"><h2>A.1. </h2>
    <div class="permission"><p class="AdmonitionTitle">Permission A.1:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
        <div id="annex1b"><h2>A.2. </h2>
    <div class="permission"><p class="AdmonitionTitle">Permission:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    <div class="permission"><p class="AdmonitionTitle">Permission A.2:</p>
  <span class="stem">(#(r = 1 %)#)</span>
  </div>
    </div>
      </div>
    </div>
  </body>
</html>
OUTPUT
    end

        it "labels and cross-references nested requirements" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
     #{HTML_HDR}
      <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <p>
<a href="#N1">Clause 1, Permission 1</a>
<a href="#N2">Clause 1, Permission 1-1</a>
<a href="#N">Clause 1, Permission 1-1-1</a>
<a href="#Q1">Clause 1, Requirement 1-1</a>
<a href="#R1">Clause 1, Recommendation 1-1</a>
<a href="#AN1">Annex A, Permission A.1</a>
<a href="#AN2">Annex A, Permission A.1-1</a>
<a href="#AN">Annex A, Permission A.1-1-1</a>
<a href="#AQ1">Annex A, Requirement A.1-1</a>
<a href="#AR1">Annex A, Recommendation A.1-1</a>
</p>
      </div>
      <p class="zzSTDTitle1"/>
      <div id="xyz">
        <h1>1.&#160; Preparatory</h1>
        <div class="permission"><p class="AdmonitionTitle">Permission 1:</p>
<div class="permission"><p class="AdmonitionTitle">Permission 1-1:</p>
<div class="permission"><p class="AdmonitionTitle">Permission 1-1-1:</p>
</div>
</div>
<div class="require"><p class="AdmonitionTitle">Requirement 1-1:</p>
</div>
<div class="recommend"><p class="AdmonitionTitle">Recommendation 1-1:</p>
</div>
</div>
      </div>
      <br/>
      <div id="Axyz" class="Section3">
        <h1 class="Annex"><b>Annex A</b><br/>(informative)<br/><br/><b>Preparatory</b></h1>
        <div class="permission"><p class="AdmonitionTitle">Permission A.1:</p>
<div class="permission"><p class="AdmonitionTitle">Permission A.1-1:</p>
<div class="permission"><p class="AdmonitionTitle">Permission A.1-1-1:</p>
</div>
</div>
<div class="require"><p class="AdmonitionTitle">Requirement A.1-1:</p>
</div>
<div class="recommend"><p class="AdmonitionTitle">Recommendation A.1-1:</p>
</div>
</div>
      </div>
    </div>
  </body>
</html>
    OUTPUT
        end


  it "cross-references tables" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <a href="#N1">Table 1</a>
       <a href="#N2">Table (??)</a>
       <a href="#N">Table 2</a>
       <a href="#note1">Table 3</a>
       <a href="#note2">Table 4</a>
       <a href="#AN">Table A.1</a>
       <a href="#Anote1">Table (??)</a>
       <a href="#Anote2">Table A.2</a>
       </p>
               </div>
                            <br/>
             <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <p class="TableTitle" style="text-align:center;">Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p>
               <table id="N1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                 <tbody>
                   <tr>
                     <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td>
                   </tr>
                 </tbody>
               </table>
                      <div id="xyz"><h2>Preparatory</h2>
       <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of husked rice yield</p><table id="N2" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
             </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <p class="TableTitle" style="text-align:center;">
                   Table 2&#160;&#8212; Repeatability and reproducibility of husked rice yield
                 </p>
                 <table id="N" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <tbody>
                     <tr>
                       <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td>
                       <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td>
                       <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td>
                     </tr>
                   </tbody>
                 </table>
                 <p>
                   <a href="#N">Table 2</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1"><h2>3.1. </h2>
           <p class="TableTitle" style="text-align:center;">Table 3&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
           <p class="TableTitle" style="text-align:center;">Table 4&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note2" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       <p>    <a href="#note1">Table 3</a> <a href="#note2">Table 4</a> </p>
       </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a"><h2>A.1. </h2>
                 <p class="TableTitle" style="text-align:center;">Table A.1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="AN" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
                 <div id="annex1b"><h2>A.2. </h2>
                 <p class="TableTitle" style="text-align:center;">Repeatability and reproducibility of husked rice yield</p><table id="Anote1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
                 <p class="TableTitle" style="text-align:center;">Table A.2&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="Anote2" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references term notes" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
            #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#note1">Clause 2.1, Note 1</a>
           <a href="#note2">Clause 2.2, Note 1</a>
           <a href="#note3">Clause 2.2, Note 2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="_waxy_rice">2.1.</p><p class="Terms" style="text-align:left;">waxy rice</p>
       <div class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div><p class="TermNum" id="_nonwaxy_rice">2.2.</p><p class="Terms" style="text-align:left;">nonwaxy rice</p>
       <div class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div class="Note"><p>Note 2 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div></div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references sections" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
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
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
    <div>
    <h1 class="ForewordTitle">Foreword</h1>
    <p id="A">This is a preamble
    <a href="#C">Introduction Subsection</a>
    <a href="#C1">Introduction, 2</a>
    <a href="#D">Clause 1</a>
    <a href="#H">Clause 3</a>
    <a href="#I">Clause 3.1</a>
    <a href="#J">Clause 3.1.1</a>
    <a href="#K">Clause 3.2</a>
    <a href="#L">Clause 4</a>
    <a href="#M">Clause 5</a>
    <a href="#N">Clause 5.1</a>
    <a href="#O">Clause 5.2</a>
    <a href="#P">Annex A</a>
    <a href="#Q">Annex A.1</a>
    <a href="#Q1">Annex A.1.1</a>
    <a href="#R">Clause 2</a>
    <a href="#S">Bibliography</a>
    </p>
    </div>
    <br/>
                 <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C">
          <h2>Introduction Subsection</h2>
        </div>
               <div id="C1"><h2/>Text</div>
             </div>
    <p class="zzSTDTitle1"/>
    <div id="D">
    <h1>1.&#160; Scope</h1>
      <p id="E">Text</p>
    </div>
    <div>
    <h1>2.&#160; Normative references</h1>
      <p>There are no normative references in this document.</p>
    </div>
    <div id="H"><h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1><p>For the purposes of this document,
      the following terms and definitions apply.</p>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1.</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and abbreviated terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4.&#160; Symbols and abbreviated terms</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
               <div id="M">
                 <h1>5.&#160; Clause 4</h1>
                 <div id="N">
          <h2>5.1. Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
          </div>
        </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">Bibliography</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references lists" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N1">Introduction, List</a>
           <a href="#N2">Preparatory, List</a>
           <a href="#N">Clause 1, List</a>
           <a href="#note1">Clause 3.1, List  1</a>
           <a href="#note2">Clause 3.1, List  2</a>
           <a href="#AN">Annex A.1, List</a>
           <a href="#Anote1">Annex A.2, List  1</a>
           <a href="#Anote2">Annex A.2, List  2</a>
           </p>
               </div>
                            <br/>
                                         <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <ol type="a" id="N1">
         <li><p>A</p></li>
       </ol>
               <div id="xyz"><h2>Preparatory</h2>
            <ol type="a" id="N2">
         <li><p>A</p></li>
       </ol>
       </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="scope">
               <h1>1.&#160; Scope</h1>
               <ol type="a" id="N">
         <li><p>A</p></li>
       </ol>
             </div>
             <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
             <div id="widgets">
               <h1>3.&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1. </h2>
           <ol type="a" id="note1">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a" id="note2">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1. </h2>
           <ol type="a" id="AN">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
               <div id="annex1b"><h2>A.2. </h2>
           <ol type="a" id="Anote1">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a" id="Anote2">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "cross-references list items" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
     <ol id="N02">
  <li id="N2"><p>A</p></li>
</ol>
</clause>
    </introduction>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <ol id="N0">
  <li id="N"><p>A</p></li>
</ol>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <ol id="note1l">
  <li id="note1"><p>A</p></li>
</ol>
    <ol id="note2l">
  <li id="note2"><p>A</p></li>
</ol>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <ol id="ANl">
  <li id="AN"><p>A</p></li>
</ol>
    </clause>
    <clause id="annex1b">
    <ol id="Anote1l">
  <li id="Anote1"><p>A</p></li>
</ol>
    <ol id="Anote2l">
  <li id="Anote2"><p>A</p></li>
</ol>
    </clause>
    </annex>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N1">Introduction, a)</a>
           <a href="#N2">Preparatory, a)</a>
           <a href="#N">Clause 1, a)</a>
           <a href="#note1">Clause 3.1, List  1 a)</a>
           <a href="#note2">Clause 3.1, List  2 a)</a>
           <a href="#AN">Annex A.1, a)</a>
           <a href="#Anote1">Annex A.2, List  1 a)</a>
           <a href="#Anote2">Annex A.2, List  2 a)</a>
           </p>
               </div>
                            <br/>
                                         <div class="Section3" id="intro">
               <h1 class="IntroTitle">Introduction</h1>
               <ol type="a" id="N01">
         <li id="N1"><p>A</p></li>
       </ol>
               <div id="xyz"><h2>Preparatory</h2>
            <ol type="a" id="N02">
         <li id="N2"><p>A</p></li>
       </ol>
       </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="scope">
               <h1>1.&#160; Scope</h1>
               <ol type="a" id="N0">
         <li id="N"><p>A</p></li>
       </ol>
             </div>
             <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
             <div id="widgets">
               <h1>3.&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1. </h2>
           <ol type="a" id="note1l">
         <li id="note1"><p>A</p></li>
       </ol>
           <ol type="a" id="note2l">
         <li id="note2"><p>A</p></li>
       </ol>
           </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1. </h2>
           <ol type="a" id="ANl">
         <li id="AN"><p>A</p></li>
       </ol>
           </div>
               <div id="annex1b"><h2>A.2. </h2>
           <ol type="a" id="Anote1l">
         <li id="Anote1"><p>A</p></li>
       </ol>
           <ol type="a" id="Anote2l">
         <li id="Anote2"><p>A</p></li>
       </ol>
           </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "cross-references nested list items" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
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
    <clause id="scope"><title>Scope</title>
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
        #{HTML_HDR}
                     <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p>
       <a href="#N">Clause 1, a)</a>
       <a href="#note1">Clause 1, a.1)</a>
       <a href="#note2">Clause 1, a.1.i)</a>
       <a href="#AN">Clause 1, a.1.i.A)</a>
       <a href="#Anote1">Clause 1, a.1.i.A.I)</a>
       <a href="#Anote2">Clause 1, a.1.i.A.I.a)</a>
       </p>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="scope">
               <h1>1.&#160; Scope</h1>
               <ol type="a" id="N1">
         <li id="N"><p>A</p>
         <ol type="1">
         <li id="note1"><p>A</p>
         <ol type="i">
         <li id="note2"><p>A</p>
         <ol type="A">
         <li id="AN"><p>A</p>
         <ol type="I">
         <li id="Anote1"><p>A</p>
         <ol type="a">
         <li id="Anote2"><p>A</p></li>
         </ol></li>
         </ol></li>
         </ol></li>
         </ol></li>
         </ol></li>
       </ol>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

end
