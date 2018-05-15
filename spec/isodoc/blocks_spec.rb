require "spec_helper"

RSpec.describe IsoDoc do
  it "processes unlabelled notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note">
                   <p class="Note"><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes labelled notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="note1" class="Note">
                   <p class="Note"><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes sequences of notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="note1" class="Note">
                   <p class="Note"><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
                 <div id="note2" class="Note">
                   <p class="Note"><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes multi-para notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note">
                   <p class="Note"><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                   <p class="Note" id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes non-para notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
    <dl>
    <dt>A</dt>
    <dd><p>B</p></dd>
    </dl>
    <ul>
    <li>C</li></ul>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note"><p class="Note"><span class="note_label">NOTE</span>&#160; </p>
           <dl><dt><p class="Note">A</p></dt><dd><p class="Note">B</p></dd></dl>
           <ul>
           <li>C</li></ul>
       </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>

    OUTPUT
  end

  it "processes figures" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <figure id="figureA-1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  <dl>
  <dt>A</dt>
  <dd><p>B</p></dd>
  </dl>
</figure>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="figureA-1" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p><b>Key</b></p><dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
       <p class="FigureTitle" align="center">Figure 1&#160;&#8212; Split-it-right sample divider</p></div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes examples" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <table id="samplecode" class="example">
                   <tr>
                     <td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE</td>
                     <td valign="top" class="example">
         <p>Hello</p>
       </td>
                   </tr>
                 </table>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end


  it "processes sequences of examples" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    <example id="samplecode2">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <table id="samplecode" class="example">
                   <tr>
                     <td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  1</td>
                     <td valign="top" class="example">
         <p>Hello</p>
       </td>
                   </tr>
                 </table>
                 <table id="samplecode2" class="example">
                   <tr>
                     <td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  2</td>
                     <td valign="top" class="example">
                 <p>Hello</p>
                 </td>
                   </tr>
                 </table>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes sourcecode" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode id="samplecode">
    <name>Ruby code</name>
  puts x
</sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="samplecode" class="Sourcecode"><br/>&#160;&#160;&#160;&#160;<br/>&#160;&#160;puts&#160;x<br/><p class="FigureTitle" align="center">Ruby code</p></p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes sourcecode with escapes preserved" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode id="samplecode">
    <name>XML code</name>
  &lt;xml&gt;
</sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="samplecode" class="Sourcecode"><br/>&#160;&#160;&#160;&#160;<br/>&#160;&#160;&lt;xml&gt;<br/><p class="FigureTitle" align="center">XML code</p></p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes sourcecode with annotations" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode id="_">puts "Hello, world." <callout target="A">1</callout>
       %w{a b c}.each do |x|
         puts x <callout target="B">2</callout>
       end<annotation id="A">
         <p id="_">This is one callout</p>
       </annotation><annotation id="B">
         <p id="_">This is another callout</p>
       </annotation></sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_" class="Sourcecode">puts&#160;"Hello,&#160;world."&#160; &lt;1&gt;<br/>&#160;&#160;&#160;%w{a&#160;b&#160;c}.each&#160;do&#160;|x|<br/>&#160;&#160;&#160;&#160;&#160;puts&#160;x&#160; &lt;2&gt;<br/>&#160;&#160;&#160;end<span class="zzMoveToFollowing">&lt;1&gt; </span>
            <p class="Sourcecode" id="_">This is one callout</p>
          <span class="zzMoveToFollowing">&lt;2&gt; </span>
            <p class="Sourcecode" id="_">This is another callout</p>
          </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes admonitions" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
</admonition>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="Admonition"><title>CAUTION</title>
         <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes formulae" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
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
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" class="formula"><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</div>
                 <p>where</p>
                 <dl>
                   <dt>
           <span class="stem">(#(r)#)</span>
         </dt>
                   <dd>
           <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
         </dd>
                 </dl>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes paragraph alignments" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8">Vache Equipment<br/>
Fictitious<br/>
World</p>
    <p align="justify">Justify</p>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" align="left" style="text-align:left">Vache Equipment<br/>
       Fictitious<br/>
       World
           </p>
           <p style="text-align:justify">Justify</p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes paragraph alignments (Word)" do
    expect(IsoDoc::WordConvert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8">Vache Equipment<br/>
Fictitious<br/>
World</p>
    <p align="justify">Justify</p>
    </foreword></preface>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
                      </head>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br  clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" align="left" style="text-align:left">Vache Equipment<br/>
       Fictitious<br/>
       World
           </p>
           <p style="text-align:justify">Justify</p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end



  it "processes blockquotes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <quote id="_044bd364-c832-4b78-8fea-92242402a1d1">
  <source type="inline" bibitemid="ISO7301" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality></source>
  <author>ISO</author>
  <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
</quote>

    </foreword></preface>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="Quote" id="_044bd364-c832-4b78-8fea-92242402a1d1">


         <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<i>Oryza sativa</i> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
       <p class="QuoteAttribution">&#8212; ISO, <a href="#ISO7301">ISO 7301: 2011, Clause 1</a></p></div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes term domains" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms>
    <term id="_extraneous_matter"><preferred>extraneous matter</preferred><admitted>EM</admitted>
<domain>rice</domain>
<definition><p id="_318b3939-be09-46c4-a284-93f9826b981e">organic and inorganic components other than whole or broken kernels</p></definition>
</term>
    </terms>
    </sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div><h1>1.&#160; Terms and Definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <p class="TermNum" id="_extraneous_matter">1.1</p><p class="Terms" style="text-align:left;">extraneous matter</p><p class="AltTerms" style="text-align:left;">EM</p>

       <p id="_318b3939-be09-46c4-a284-93f9826b981e">&lt;rice&gt; organic and inorganic components other than whole or broken kernels</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
  end


end
