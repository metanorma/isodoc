require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)). to be_equivalent_to <<~"OUTPUT"
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
           <a href="#N">Clause 1, Note</a>
           <a href="#note1">3.1, Note  1</a>
           <a href="#note2">3.1, Note  2</a>
           <a href="#AN">A.1, Note</a>
           <a href="#Anote1">A.2, Note  1</a>
           <a href="#Anote2">A.2, Note  2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <div id="N" class="Note">
                   <p class="Note"><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
                 <p>
                   <a href="#N">Note</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
           <div id="note1" class="Note"><p class="Note"><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="note2" class="Note"><p class="Note"><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       <p>    <a href="#note1">Note  1</a> <a href="#note2">Note  2</a> </p>

           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
           <div id="AN" class="Note"><p class="Note"><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
                 <div id="annex1b">
           <div id="Anote1" class="Note"><p class="Note"><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="Anote2" class="Note"><p class="Note"><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
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
        <figure id="N">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
<p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
        <figure id="note1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
        <figure id="AN">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
    </clause>
    <clause id="annex1b">
        <figure id="Anote1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
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
           <a href="#note1">Figure 2</a>
           <a href="#note2">Figure 3</a>
           <a href="#AN">Figure A.1</a>
           <a href="#Anote1">Figure A.2</a>
           <a href="#Anote2">Figure A.3</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <div id="N" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure 1&#160;&#8212; Split-it-right sample divider</p></div>
                 <p>
                   <a href="#N">Figure 1</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
               <div id="note1" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure 2&#160;&#8212; Split-it-right sample divider</p></div>
           <div id="note2" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure 3&#160;&#8212; Split-it-right sample divider</p></div>
         <p>    <a href="#note1">Figure 2</a> <a href="#note2">Figure 3</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
               <div id="AN" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure A.1&#160;&#8212; Split-it-right sample divider</p></div>
           </div>
                 <div id="annex1b">
               <div id="Anote1" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure A.2&#160;&#8212; Split-it-right sample divider</p></div>
           <div id="Anote2" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p class="FigureTitle" align="center">Figure A.3&#160;&#8212; Split-it-right sample divider</p></div>
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
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
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
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
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
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png"/>
       <p class="FigureTitle" align="center">Figure 1-1&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png"/>
       <p class="FigureTitle" align="center">Figure 1-2&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
       <p>    <a href="#note1">Figure 1-1</a> <a href="#note2">Figure 1-2</a> </p>
         </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
         </div>
                 <div id="annex1b">
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png"/>
       <p class="FigureTitle" align="center">Figure A.1-1&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png"/>
       <p class="FigureTitle" align="center">Figure A.1-2&#160;&#8212; Split-it-right sample divider</p></div>
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
        <example id="note2">
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
        <example id="Anote1">
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
           <a href="#N">Clause 1, Example</a>
           <a href="#note1">3.1, Example  1</a>
           <a href="#note2">3.1, Example  2</a>
           <a href="#AN">A.1, Example</a>
           <a href="#Anote1">A.2, Example  1</a>
           <a href="#Anote2">A.2, Example  2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <table id="N" class="example">
                   <tr>
                     <td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE</td>
                     <td valign="top" class="example">
         <p>Hello</p>
       </td>
                   </tr>
                 </table>
                 <p>
                   <a href="#N">Example</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
               <table id="note1" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  1</td><td valign="top" class="example">
         <p>Hello</p>
       </td></tr></table>
               <table id="note2" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  2</td><td valign="top" class="example">
         <p>Hello</p>
       </td></tr></table>
       <p>    <a href="#note1">Example  1</a> <a href="#note2">Example  2</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
               <table id="AN" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE</td><td valign="top" class="example">
         <p>Hello</p>
       </td></tr></table>
           </div>
                 <div id="annex1b">
               <table id="Anote1" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  1</td><td valign="top" class="example">
         <p>Hello</p>
       </td></tr></table>
               <table id="Anote2" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  2</td><td valign="top" class="example">
         <p>Hello</p>
       </td></tr></table>
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
    <formula id="Anote1">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    <formula id="Anote2">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </clause>
    </annex>
    </iso-standard>

    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
</dl></formula>
    </foreword>
    </preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N">Clause 1, Formula (1)</a>
           <a href="#note1">3.1, Formula (2)</a>
           <a href="#note2">3.1, Formula (3)</a>
           <a href="#AN">A.1, Formula (A.1)</a>
           <a href="#Anote1">A.2, Formula (A.2)</a>
           <a href="#Anote2">A.2, Formula (A.3)</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <div id="N" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</div>
                 <p>
                   <a href="#N">Formula (1)</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
           <div id="note1" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (2)</div>
           <div id="note2" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (3)</div>
         <p>    <a href="#note1">Formula (2)</a> <a href="#note2">Formula (3)</a> </p>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
           <div id="AN" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (A.1)</div>
           </div>
                 <div id="annex1b">
           <div id="Anote1" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (A.2)</div>
           <div id="Anote2" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (A.3)</div>
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
        <table id="Anote1">
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
       <a href="#N">Table 1</a>
       <a href="#note1">Table 2</a>
       <a href="#note2">Table 3</a>
       <a href="#AN">Table A.1</a>
       <a href="#Anote1">Table A.2</a>
       <a href="#Anote2">Table A.3</a>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <p class="TableTitle" align="center">
                   Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield
                 </p>
                 <table id="N" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <tbody>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td>
                     </tr>
                   </tbody>
                 </table>
                 <p>
                   <a href="#N">Table 1</a>
                 </p>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
           <p class="TableTitle" align="center">Table 2&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
           <p class="TableTitle" align="center">Table 3&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note2" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       <p>    <a href="#note1">Table 2</a> <a href="#note2">Table 3</a> </p>
       </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
           <p class="TableTitle" align="center">Table A.1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="AN" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
                 <div id="annex1b">
           <p class="TableTitle" align="center">Table A.2&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="Anote1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
           <p class="TableTitle" align="center">Table A.3&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="Anote2" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
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
           <a href="#note1">2.1, Note 1</a>
           <a href="#note2">2.2, Note 1</a>
           <a href="#note3">2.2, Note 2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <p class="TermNum" id="_waxy_rice">2.1</p><p class="Terms" style="text-align:left;">waxy rice</p>
       <div class="Note"><p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div><p class="TermNum" id="_nonwaxy_rice">2.2</p><p class="Terms" style="text-align:left;">nonwaxy rice</p>
       <div class="Note"><p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div class="Note"><p class="Note">Note 2 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div></div>
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
         <xref target="Q2"/>
         <xref target="R"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
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
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </terms>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
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
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
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
    <a href="#C">0.1</a>
    <a href="#D">Clause 1</a>
    <a href="#H">Clause 3</a>
    <a href="#I">3.1</a>
    <a href="#J">3.1.1</a>
    <a href="#K">3.2</a>
    <a href="#L">Clause 4</a>
    <a href="#M">Clause 5</a>
    <a href="#N">5.1</a>
    <a href="#O">5.2</a>
    <a href="#P">Annex A</a>
    <a href="#Q">A.1</a>
    <a href="#Q1">A.1.1</a>
    <a href="#Q2">Annex A, Appendix 1</a>
    <a href="#R">Clause 2</a>
    </p>
    </div>
    <br/>
    <div class="Section3" id="B">
    <h1 class="IntroTitle">0.&#160; Introduction</h1>
      <div id="C">
    <h2>0.1. Introduction Subsection</h2>
    </div>
    <p>This is patent boilerplate</p>
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
    <div id="H"><h1>3.&#160; Terms and definitions</h1><p>For the purposes of this document,
      the following terms and definitions apply.</p>
    <p>ISO and IEC maintain terminological databases for use in
    standardization at the following addresses:</p>

    <ul>
    <li> <p>ISO Online browsing platform: available at
    <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
    <li> <p>IEC Electropedia: available at
    <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
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
       <div id="Q2">
        <h2>Appendix 1. An Appendix</h2>
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
           <a href="#N">Clause 1, List</a>
           <a href="#note1">3.1, List  1</a>
           <a href="#note2">3.1, List  2</a>
           <a href="#AN">A.1, List</a>
           <a href="#Anote1">A.2, List  1</a>
           <a href="#Anote2">A.2, List  2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <ol type="a">
         <li><p>A</p></li>
       </ol>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
           <ol type="a">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
           <ol type="a">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
                 <div id="annex1b">
           <ol type="a">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a">
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
           <a href="#N">Clause 1, a)</a>
           <a href="#note1">3.1, List  1 a)</a>
           <a href="#note2">3.1, List  2 a)</a>
           <a href="#AN">A.1, a)</a>
           <a href="#Anote1">A.2, List  1 a)</a>
           <a href="#Anote2">A.2, List  2 a)</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1.&#160; Scope</h1>
                 <ol type="a">
         <li><p>A</p></li>
       </ol>
               </div>
               <div id="terms"><h1>2.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       </div>
               <div id="widgets">
                 <h1>3.&#160; Widgets</h1>
                 <div id="widgets1">
           <ol type="a">
         <li><p>A</p></li>
       </ol>
           <ol type="a">
         <li><p>A</p></li>
       </ol>
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
                 <div id="annex1a">
           <ol type="a">
         <li><p>A</p></li>
       </ol>
           </div>
                 <div id="annex1b">
           <ol type="a">
         <li><p>A</p></li>
       </ol>
           <ol type="a">
         <li><p>A</p></li>
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
                  <ol type="a">
          <li><p>A</p>
          <ol type="1">
          <li><p>A</p>
          <ol type="i">
          <li><p>A</p>
          <ol type="A">
          <li><p>A</p>
          <ol type="I">
          <li><p>A</p>
          <ol type="a">
          <li><p>A</p></li>
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
