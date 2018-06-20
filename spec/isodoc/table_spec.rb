require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1">
  <name>Repeatability and reproducibility of husked rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    <tr>
      <td align="left">Arborio</td>
      <td align="center">Drago<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Balilla<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Thaibonnet</td>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>
</foreword>
</preface>
</iso-standard>
    INPUT
    #{HTML_HDR}
                 <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" align="center">Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p>
               <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                 <thead>
                   <tr>
                     <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                     <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                   </tr>
                   <tr>
                     <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:tableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a&#160; </a>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside></td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Thaibonnet</td>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Number of laboratories retained after eliminating outliers</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                   </tr>
                   <tr>
                     <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                     <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
                   </tr>
                 </tbody>
                 <tfoot>
                   <tr>
                     <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,89</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">0,57</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,26</td>
                     <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">6,06</td>
                   </tr>
                 </tfoot>
                 <dl>
                   <dt>
                     <p>Drago</p>
                   </dt>
                   <dd>A type of rice</dd>
                 </dl>
                 <div id="" class="Note">
                   <p class="Note"><span class="note_label">NOTE</span>&#160; This is a table about rice</p>
                 </div>
               </table>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "processes IsoXML tables (Word)" do
    expect(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1">
  <name>Repeatability and reproducibility of husked rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    <tr>
      <td align="left">Arborio</td>
      <td align="center">Drago<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Balilla<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Thaibonnet</td>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>
</foreword>
</preface>
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
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p class="TableTitle" align="center">Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p>
                 <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Thaibonnet</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">Number of laboratories retained after eliminating outliers</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">11</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">81,2</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">82,0</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">81,8</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">77,7</td>
                     </tr>
                   </tbody>
                   <tfoot>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">2,89</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">0,57</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">2,26</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">6,06</td>
                     </tr>
                   </tfoot>
                   <table class="dl">
                     <tr>
                       <td valign="top" align="left">
                         <p align="left" style="margin-left:0pt;text-align:left;">Drago</p>
                       </td>
                       <td valign="top">A type of rice</td>
                     </tr>
                   </table>
                   <div id="" class="Note">
                     <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
                   </div>
                 </table>
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
end
