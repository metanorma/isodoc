require "spec_helper"

RSpec.describe IsoDoc do
  it "processes unlabelled notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note">
                   <p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span>These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "processes labelled notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
INPUT
       <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="note1" class="Note">
                   <p class="Note">NOTE  1<span style="mso-tab-count:1">&#160; </span>These results are based on a study carried out on three different types of kernel.</p>
                 </div>
                 <div id="note2" class="Note">
                   <p class="Note">NOTE  2<span style="mso-tab-count:1">&#160; </span>These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "processes multi-para notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note">
                   <p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span>These results are based on a study carried out on three different types of kernel.</p>
                   <p class="Note" id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "processes non-para notes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
    <dl>
    <dt>A</dt>
    <dd><p>B</p></dd>
    </dl>
    <ul>
    <li>C</li></ul>
</note>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="" class="Note"><p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span></p>
           <dl><dt><p class="Note">A</p></dt><dd><p class="Note">B</p></dd></dl>
           <ul>
           <li>C</li></ul>
       </div>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>

    OUTPUT
  end

  it "processes figures" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <figure id="figureA-1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" imagetype="PNG"/>
  <dl>
  <dt>A</dt>
  <dd><p>B</p></dd>
  </dl>
</figure>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="figureA-1" class="figure">

         <img src="rice_images/rice_image1.png"/>
         <p><b>Key</b></p><dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
       <p class="FigureTitle" align="center"><b>Figure 1&#160;&#8212; Split-it-right sample divider</b></p></div>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "processes examples" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <table id="samplecode" class="example">
                   <tr>
                     <td width="110pt" valign="top" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE</td>
                     <td valign="top">
         <p>Hello</p>
       </td>
                   </tr>
                 </table>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end


  it "processes sequences of examples" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    <example id="samplecode2>
  <p>Hello</p>
</example>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <table id="samplecode" class="example">
                   <tr>
                     <td width="110pt" valign="top" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  1</td>
                     <td valign="top">
         <p>Hello</p>
       </td>
                   </tr>
                 </table>
                 <table id="samplecode2&gt;   " class="example">
                   <tr>
                     <td width="110pt" valign="top" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE  2</td>
                     <td valign="top"/>
                   </tr>
                 </table>
                 <p>Hello</p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

    it "processes sourcecode" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <sourcecode id="samplecode">
    <name>Ruby code</name>
  puts x
</sourcecode>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="samplecode" class="Sourcecode"><br/>&#160;&#160;&#160;&#160;<br/>&#160;&#160;puts&#160;x<br/><p class="FigureTitle" align="center"><b>Ruby code</b></p></p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
OUTPUT
    end

        it "processes sourcecode with annotations" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <sourcecode id="_">puts "Hello, world." <callout target="A">1</callout>
       %w{a b c}.each do |x|
         puts x <callout target="B">2</callout>
       end<annotation id="A">
         <p id="_">This is one callout</p>
       </annotation><annotation id="B">
         <p id="_">This is another callout</p>
       </annotation></sourcecode>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_" class="Sourcecode">puts&#160;"Hello,&#160;world."&#160; &lt;1&gt;<br/>&#160;&#160;&#160;%w{a&#160;b&#160;c}.each&#160;do&#160;|x|<br/>&#160;&#160;&#160;&#160;&#160;puts&#160;x&#160; &lt;2&gt;<br/>&#160;&#160;&#160;end<span class="zzMoveToFollowing">&lt;1&gt; </span>
            <p class="Sourcecode" id="_">This is one callout</p>
          <span class="zzMoveToFollowing">&lt;2&gt; </span>
            <p class="Sourcecode" id="_">This is another callout</p>
          </p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
        end


end
