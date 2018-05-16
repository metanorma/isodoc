require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "cleans up admonitions" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
    <html>
    <body>
      <div class="Admonition">
        <title>Warning</title>
        <p>Text</p>
      </div>
    </body>
    </html>
    INPUT
           <?xml version="1.0"?>
       <html>
       <body>
         <div class="Admonition">

           <p>Warning&#x2014;Text</p>
         </div>
       </body>
       </html>
    OUTPUT
  end

  it "cleans up figures" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
    <html xmlns:epub="http://www.idpf.org/2007/ops">
    <body>
      <div class="figure">
        <p>Warning</p>
        <a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside>
      </div>
    </body>
    </html>
    INPUT
              <?xml version="1.0"?>
       <html xmlns:epub="http://www.idpf.org/2007/ops">
       <body>
         <div class="figure">
           <p>Warning</p>
           <aside><div id="ftntableD-1a">

          </div></aside>
         <p><b/></p><dl><dt><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#xA0; </span></a></dt><dd><p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></dd></dl></div>
       </body>
       </html>
    OUTPUT
  end

    it "cleans up figures (Word)" do
    expect(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
    <html xmlns:epub="http://www.idpf.org/2007/ops">
    <body>
      <div class="figure">
        <p>Warning</p>
        <a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside>
      </div>
    </body>
    </html>
    INPUT
              <?xml version="1.0"?>
       <html xmlns:epub="http://www.idpf.org/2007/ops">
       <body>
         <div class="figure">
           <p>Warning</p>
           <aside><div id="ftntableD-1a">

          </div></aside>
          <p><b/></p><table class="dl"><tr><td valign="top" align="left"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#xA0; </span></a></td><td valign="top"><p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></td></tr></table></div>
       </body>
       </html>
    OUTPUT
  end

  it "cleans up inline headers" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
             <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>4.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
                 <div id="N">
          <h2>4.1. Introduction</h2>
        </div>
                 <div id="O">
          <span class="zzMoveToFollowing"><b>4.2. Clause 4.2 </b></span>
        </div>
                 <div id="P">
          <span class="zzMoveToFollowing"><b>4.3. Clause 4.3 </b></span>
          <p>text</p>
        </div>
               </div>
             </div>
           </body>
         </head>
       </html>
       INPUT
              <?xml version="1.0"?>
       <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <p>&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>4.<span style="mso-tab-count:1">&#xA0; </span>Clause 4</h1>
                 <div id="N">
          <h2>4.1. Introduction</h2>
        </div>
                 <div id="O">
          <p><b>4.2. Clause 4.2 </b></p>
        </div>
         <div id="P">

          <p><span><b>4.3. Clause 4.3 </b></span>text</p>
        </div>
               </div>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "cleans up footnotes" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
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
                 <p>A.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                 <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                 <p>C.<a href="#ftn1" epub:type="footnote"><sup>1</sup></a></p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
               <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
             </div>
           </body>
         </head>
       </html>
       INPUT
             <?xml version="1.0"?>
       <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>A.<a href="#ftn2" epub:type="footnote"><sup>1</sup></a></p>
                 <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                 <p>C.<a href="#ftn1" epub:type="footnote"><sup>3</sup></a></p>
               </div>
               <p>&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
               <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
  end

  it "cleans up tables with tfoot" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
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
                 <p class="TableTitle" align="center">
                   <b>Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</b>
                 </p>
                 <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
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
                     <p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
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
         </head>
       </html>
INPUT
        <?xml version="1.0"?>
        <html xmlns:epub="http://www.idpf.org/2007/ops">
          <head>
            <title>test</title>
            <body lang="EN-US" link="blue" vlink="#954F72">
              <div class="WordSection1">
                <p>&#xA0;</p>
              </div>
              <br clear="all" class="section"/>
              <div class="WordSection2">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p class="TableTitle" align="center">
                    <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                  </p>
                  <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                      <tr>
                        <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                        <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                      </tr>
                      <tr>
                        <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                        <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
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
                        <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,89</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">0,57</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,26</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">6,06</td>
                      </tr>
                    <tr><td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;"><div id="" class="Note">
                      <p class="Note">NOTE<span style="mso-tab-count:1">&#xA0; </span>This is a table about rice</p>
                    </div><div class="TableFootnote"><div id="ftntableD-1a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#xA0; </span></a>Parboiled rice.</p>
        </div></div></td></tr></tfoot>
                    <dl>
                      <dt>
                        <p>Drago</p>
                      </dt>
                      <dd>A type of rice</dd>
                    </dl>

                  </table>
                </div>
                <p>&#xA0;</p>
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

  it "cleans up tables with tfoot (Word)" do
    expect(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
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
                 <p class="TableTitle" align="center">
                   <b>Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</b>
                 </p>
                 <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
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
                     <p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
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
         </head>
       </html>
INPUT
        <?xml version="1.0"?>
        <html xmlns:epub="http://www.idpf.org/2007/ops">
          <head>
            <title>test</title>
            <body lang="EN-US" link="blue" vlink="#954F72">
              <div class="WordSection1">
                <p>&#xA0;</p>
              </div>
              <br clear="all" class="section"/>
              <div class="WordSection2">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p class="TableTitle" align="center">
                    <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                  </p>
                  <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                    <thead>
                      <tr>
                        <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                        <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                      </tr>
                      <tr>
                        <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                        <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
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
                        <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,89</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">0,57</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,26</td>
                        <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:0pt;">6,06</td>
                      </tr>
                    <tr><td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;       border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;"><div id="" class="Note">
                      <p class="Note">NOTE<span style="mso-tab-count:1">&#xA0; </span>This is a table about rice</p>
                    </div><div class="TableFootnote"><div id="ftntableD-1a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#xA0; </span></a>Parboiled rice.</p>
        </div></div></td></tr></tfoot>
                    <dl>
                      <dt>
                        <p>Drago</p>
                      </dt>
                      <dd>A type of rice</dd>
                    </dl>

                  </table>
                </div>
                <p>&#xA0;</p>
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


  it "cleans up tables without tfoot" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
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
                 <p class="TableTitle" align="center">
                   <b>Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield</b>
                 </p>
                 <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#160; </span></a>
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
                   <dl>
                     <dt>
                       <p>Drago</p>
                     </dt>
                     <dd>A type of rice</dd>
                   </dl>
                   <div id="" class="Note">
                     <p class="Note">NOTE<span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
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
         </head>
       </html>
INPUT
       <?xml version="1.0"?>
       <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p class="TableTitle" align="center">
                   <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                 </p>
                 <table id="tableD-1" class="MsoISOTable" border="1" cellspacing="0" cellpadding="0">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                       <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
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
                   <dl>
                     <dt>
                       <p>Drago</p>
                     </dt>
                     <dd>A type of rice</dd>
                   </dl>

                 <tfoot><tr><td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;"><div id="" class="Note">
                     <p class="Note">NOTE<span style="mso-tab-count:1">&#xA0; </span>This is a table about rice</p>
                   </div><div class="TableFootnote"><div id="ftntableD-1a">
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><a id="tableD-1a" class="TableFootnoteRef">a<span style="mso-tab-count:1">&#xA0; </span></a>Parboiled rice.</p>
       </div></div></td></tr></tfoot></table>
               </div>
               <p>&#xA0;</p>
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

  it "cleans up symbols lists" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
  <div id="L" class="Symbols">
                 <h1>4.<span style="mso-tab-count:1">&#160; </span>Symbols and Abbreviated Terms</h1>
                 <dl>
                   <dt><p><span class="stem">(#(&#x3b1;)#)</span></p></dt><dd>Definition 1</dd>
                   <dt><p><span class="stem">(#(xa)#)</span></p></dt><dd>Definition 2</dd>
                   <dt><p><span class="stem">(#(x_1)#)</span></p></dt><dd>Definition 3</dd>
                   <dt><p><span class="stem">(#(x_m)#)</span></p></dt><dd>Definition 4</dd>
                   <dt><p><span class="stem">(#(x)#)</span></p></dt><dd>Definition 5</dd>
                 </dl>
               </div>
               INPUT
                      <?xml version="1.0"?>
       <div id="L" class="Symbols">
                      <h1>4.<span style="mso-tab-count:1">&#xA0; </span>Symbols and Abbreviated Terms</h1>
                      <dt>
         <p>
           <span class="stem">(#(x)#)</span>
         </p>
       </dt><dd>Definition 5</dd>
       <dt>
         <p>
           <span class="stem">(#(x_m)#)</span>
         </p>
       </dt><dd>Definition 4</dd>
       <dt>
         <p>
           <span class="stem">(#(x_1)#)</span>
         </p>
       </dt><dd>Definition 3</dd>
       <dt>
         <p>
           <span class="stem">(#(xa)#)</span>
         </p>
       </dt><dd>Definition 2</dd>
       <dt>
         <p>
           <span class="stem">(#(&#x3B1;)#)</span>
         </p>
       </dt><dd>Definition 1</dd>
                    </div>

    OUTPUT
  end

end
