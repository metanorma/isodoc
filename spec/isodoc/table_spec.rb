require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
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
      <th align="left">Number of laboratories retained after eliminating outliers</th>
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
<note><name>NOTE</name><p>This is a table about rice</p></note>
</table>

<table id="tableD-2" unnumbered="true">
<tbody><tr><td>A</td></tr></tbody>
</table>
</foreword>
</preface>
</iso-standard>
    INPUT
    #{HTML_HDR}
                 <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p class="TableTitle" style="text-align:center;">Table 1&#160;&#8212; Repeatability and reproducibility of <i>husked</i> rice yield
               <a class='FootnoteRef' href='#fn:1'>
  <sup>1</sup>
</a>
                </p>
               <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;width:70%;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" >
               <caption>
               <span style="display:none">long desc</span>
               </caption>
                 <thead>
                   <tr>
                     <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                     <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="colgroup">Rice sample</td>
                   </tr>
                   <tr>
                     <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Arborio</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:tableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#160; </span>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside></td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Thaibonnet</td>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                   </tr>
                   <tr>
                     <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                     <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
                   </tr>
                 </tbody>
                 <tfoot>
                   <tr>
                     <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,89</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">0,57</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,26</td>
                     <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">6,06</td>
                   </tr>
                 </tfoot>
                 <dl>
                   <dt>
                     <p>Drago</p>
                   </dt>
                   <dd>A type of rice</dd>
                 </dl>
                 <div class="Note">
                   <p><span class="note_label">NOTE</span>&#160; This is a table about rice</p>
                 </div>
               </table>
               <table id="tableD-2" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                 <tbody>
                   <tr>
                     <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                   </tr>
                 </tbody>
               </table>
             </div>
             <p class="zzSTDTitle1"/>
              <aside id='fn:1' class='footnote'>
   <p>X</p>
 </aside>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "processes IsoXML tables (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-0">
      <tbody><tr><td>A</td></tr></tbody>
      </table>
      <table id="tableD-1" alt="tool tip" summary="long desc" width="70%">
  <name>Repeatability and reproducibility of husked rice yield<fn reference="1"><p>X</p></fn></name>
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
<note><name>NOTE</name><p>This is a table about rice</p></note>
</table>
</foreword>
</preface>
</iso-standard>
    INPUT
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
         <head><style/></head>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection2">
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p class="TableTitle" style="text-align:center;">Table 1</p>
                 <div align="center" class="table_container">
                 <table id="tableD-0" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                   <tbody>
                     <tr>
                       <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">A</td>
                     </tr>
                   </tbody>
                 </table>
                 </div>
                 <p class="TableTitle" style="text-align:center;">Table 2&#160;&#8212; Repeatability and reproducibility of husked rice yield
                 <span style='mso-bookmark:_Ref'>
   <a href='#ftn1' epub:type='footnote' class='FootnoteRef'>
     <sup>1</sup>
   </a>
 </span>
        </p>
                  <div align="center" class="table_container">
                 <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc" width="70%">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#160; </span></span>
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
                   <div class="Note">
                     <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
                   </div>
                 </table>
                 </div>
               </div>
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <aside id='ftn1'>
  <p>X</p>
</aside>
             </div>
           </body>
       </html>
    OUTPUT
  end
end
