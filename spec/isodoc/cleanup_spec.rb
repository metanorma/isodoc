require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "cleans up admonitions" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html xmlns:epub="http://www.idpf.org/2007/ops">
      <body>
        <div class="figure">
          <p>Warning</p>
          <a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#160; </span>
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
        <p><b>Key</b></p><dl><dt><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#xA0; </span></dt><dd><p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></dd></dl></div>
      </body>
      </html>
    OUTPUT
  end

  it "cleans up figures (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html xmlns:epub="http://www.idpf.org/2007/ops">
      <body>
        <div class="figure">
          <p>Warning</p>
          <a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#160; </span></span>
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
         <p><b>Key</b></p><table class="dl"><tr><td valign="top" align="left"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#xA0; </span></span></td><td valign="top"><p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></td></tr></table></div>
      </body>
      </html>
    OUTPUT
  end

  it "cleans up inline headers" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
      <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                  <p>A.<a class="FootnoteRef" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
                  <p>B.<a class="FootnoteRef" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
                  <p>C.<a class="FootnoteRef" href="#fn:1" epub:type="footnote"><sup>1</sup></a></p>
                 </div>
                 <p class="zzSTDTitle1"/>
                               <aside id="fn:2" class="footnote">
            <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
          </aside>
                <aside id="fn:1" class="footnote">
            <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
          </aside>
               </div>
             </body>
         </html>
    INPUT
      #{HTML_HDR}
      <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                  <p>A.<a class="FootnoteRef" href="#fn:2" epub:type="footnote"><sup>1</sup></a></p>
                  <p>B.<a class="FootnoteRef" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
                  <p>C.<a class="FootnoteRef" href="#fn:1" epub:type="footnote"><sup>3</sup></a></p>
                 </div>
                 <p class="zzSTDTitle1"/>
                               <aside id="fn:2" class="footnote">
            <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
          </aside>
                <aside id="fn:1" class="footnote">
            <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
          </aside>
               </div>
             </body>
         </html>
    OUTPUT
  end

  it "cleans up footnotes (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
          <head/>
            <body lang="EN-US" link="blue" vlink="#954F72">
              <div class="WordSection1">
                <p>&#160;</p>
              </div>
              <p><br clear="all" class="section"/></p>
              <div class="WordSection2">
                <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p>A.<a href="#ftn1" epub:type="footnote"><sup>1</sup></a></p>
                  <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                  <p>C.<a href="#ftn3" epub:type="footnote"><sup>3</sup></a></p>
                </div>
                <p>&#160;</p>
              </div>
              <p><br clear="all" class="section"/></p>
              <div class="WordSection3">
                <p class="zzSTDTitle1"/>
                <aside id="ftn1">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
        </aside>
                <aside id="ftn2">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
        </aside>
                <aside id="ftn3">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
        </aside>
              </div>
            </body>
        </html>
    INPUT
      <?xml version="1.0"?>
          <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
              <head/>
                <body lang="EN-US" link="blue" vlink="#954F72">
                  <div class="WordSection1">
                    <p>&#xA0;</p>
                  </div>
                  <p><br clear="all" class="section"/></p>
                  <div class="WordSection2">
                    <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                    <div>
                      <h1 class="ForewordTitle">Foreword</h1>
                      <p>A.<a href="#ftn1" epub:type="footnote"><sup>1</sup></a></p>
                      <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                      <p>C.<a href="#ftn3" epub:type="footnote"><sup>3</sup></a></p>
                    </div>
                    <p>&#xA0;</p>
                  </div>
                  <p><br clear="all" class="section"/></p>
                  <div class="WordSection3">
                    <p class="zzSTDTitle1"/>
                    <aside id="ftn1">
              <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
            </aside>
                    <aside id="ftn2">
              <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
            </aside>
                    <aside id="ftn3">
              <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
            </aside>
                  </div>
                </body>
            </html>
    OUTPUT
  end

  it "cleans up tables with tfoot" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                      <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#160; </span>
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
        <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#xA0; </span>Parboiled rice.</p>
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
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                      <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#160; </span></span>
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
                  <tr><td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;"><div id="" class="Note">
                    <p class="Note">NOTE<span style="mso-tab-count:1">&#xA0; </span>This is a table about rice</p>
                  </div><div class="TableFootnote"><div id="ftntableD-1a">
        <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#xA0; </span></span>Parboiled rice.</p>
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
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                      <td align="center" style="border-top:none;border-bottom:solid windowtext 1.5pt;">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#160; </span>
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
        <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55" class="TableFootnote"><span><span id="tableD-1a" class="TableFootnoteRef">a</span>&#xA0; </span>Parboiled rice.</p>
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

  it "does not break up very long strings in tables by default" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                  </tr>
                  </thead>
                  <tbody>
                  <tr>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                  </tr>
                  </tbody>
                  </table>
                  </div>
                  </div>
                  </body>
                  </html>
    INPUT
                           <?xml version='1.0'?>
      <html xmlns:epub='http://www.idpf.org/2007/ops'>
        <head>
          <title>test</title>
          <body lang='EN-US' link='blue' vlink='#954F72'>
            <div class='WordSection1'>
              <p>&#xA0;</p>
            </div>
            <br clear='all' class='section'/>
            <div class='WordSection2'>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
              <div>
                <h1 class='ForewordTitle'>Foreword</h1>
                <p class='TableTitle' align='center'>
                  <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                </p>
                <table id='tableD-1' class='MsoISOTable' border='1' cellspacing='0' cellpadding='0'>
                  <thead>
                    <tr>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>Rice sample</td>
                    </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB </td>
                        <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>
                        www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                      </tr>
                    </tbody>
                </table>
              </div>
            </div>
          </body>
        </head>
      </html>
    OUTPUT
  end

  it "does not break up very long strings in tables on request in HTML" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({ break_up_urls_in_tables: "true" }).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                  </tr>
                  </thead>
                  <tbody>
                  <tr>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                  </tr>
                  </tbody>
                  </table>
                  </div>
                  </div>
                  </body>
                  </html>
    INPUT
                           <?xml version='1.0'?>
      <html xmlns:epub='http://www.idpf.org/2007/ops'>
        <head>
          <title>test</title>
          <body lang='EN-US' link='blue' vlink='#954F72'>
            <div class='WordSection1'>
              <p>&#xA0;</p>
            </div>
            <br clear='all' class='section'/>
            <div class='WordSection2'>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
              <div>
                <h1 class='ForewordTitle'>Foreword</h1>
                <p class='TableTitle' align='center'>
                  <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                </p>
                <table id='tableD-1' class='MsoISOTable' border='1' cellspacing='0' cellpadding='0'>
                  <thead>
                    <tr>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>Rice sample</td>
                    </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                        <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>
                        www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                      </tr>
                    </tbody>
                </table>
              </div>
            </div>
          </body>
        </head>
      </html>
    OUTPUT
  end

  it "does not break up very long strings in tables by default (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                  </tr>
                  </thead>
                  <tbody>
                  <tr>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/&amp;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB
                      </td>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                        http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                      </td>
                      <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>
                        www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                      </td>
                  </tr>
                  </tbody>
                  </table>
                  </div>
                  </div>
                  </body>
                  </html>
    INPUT
                           <?xml version='1.0'?>
      <html xmlns:epub='http://www.idpf.org/2007/ops'>
        <head>
          <title>test</title>
          <body lang='EN-US' link='blue' vlink='#954F72'>
            <div class='WordSection1'>
              <p>&#xA0;</p>
            </div>
            <br clear='all' class='section'/>
            <div class='WordSection2'>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
              <div>
                <h1 class='ForewordTitle'>Foreword</h1>
                <p class='TableTitle' align='center'>
                  <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                </p>
                <table id='tableD-1' class='MsoISOTable' border='1' cellspacing='0' cellpadding='0'>
                  <thead>
                    <tr>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>Rice sample</td>
                    </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                          http://www.example.com/&amp;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                          http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                        <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>
                          www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                      </tr>
                    </tbody>
                </table>
              </div>
            </div>
          </body>
        </head>
      </html>
    OUTPUT
  end

  it "breaks up very long strings in tables on request (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({ break_up_urls_in_tables: "true" }).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Description</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">Rice sample</td>
                  </tr>
                  </thead>
                  <tbody>
                  <tr>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">http://www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                    <td align="center" style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">www.example.com/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBB</td>
                  </tr>
                  </tbody>
                  </table>
                  </div>
                  </div>
                  </body>
                  </html>
    INPUT
                           <?xml version='1.0'?>
      <html xmlns:epub='http://www.idpf.org/2007/ops'>
        <head>
          <title>test</title>
          <body lang='EN-US' link='blue' vlink='#954F72'>
            <div class='WordSection1'>
              <p>&#xA0;</p>
            </div>
            <br clear='all' class='section'/>
            <div class='WordSection2'>
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
              <div>
                <h1 class='ForewordTitle'>Foreword</h1>
                <p class='TableTitle' align='center'>
                  <b>Table 1&#xA0;&#x2014; Repeatability and reproducibility of husked rice yield</b>
                </p>
                <table id='tableD-1' class='MsoISOTable' border='1' cellspacing='0' cellpadding='0'>
                  <thead>
                    <tr>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Description</td>
                      <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>Rice sample</td>
                    </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                          http://www.example.com/ AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAA/ BBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                        <td align='left' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
                          http://www.example.com/ AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAABBBBBBBBBBBBBBBBBBBBBB BBBBBB
                        </td>
                        <td align='center' style='border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;'>
                          www.example.com/ AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ABBBBBBBBBBBBBBBBBBBBBBBBBBBB
                        </td>
                      </tr>
                    </tbody>
                </table>
              </div>
            </div>
          </body>
        </head>
      </html>
    OUTPUT
  end

  it "cleans up term sources" do
    c = IsoDoc::HtmlConvert.new({ i18nyaml: "spec/assets/i18n.yaml" })
    c.i18n_init("en", "Latn")
    expect(xmlpp(c.textcleanup(<<~"INPUT").to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
               #{HTML_HDR}
                     <p class="zzSTDTitle1"/>
                     <div id="_terms_and_definitions"><h1>1.&#160; Terms and Definitions</h1><p>For the purposes of this document,
                 the following terms and definitions apply.</p>
             <p class="TermNum" id="paddy1">1.1.</p><p class="Terms" style="text-align:left;">paddy</p>
             <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
             <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example"><p class="example-title">EXAMPLE 1</p>
               <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
               <ul>
               <li>A</li>
               </ul>
             </div>
             <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example"><p class="example-title">EXAMPLE 2</p>
               <ul>
               <li>A</li>
               </ul>
             </div>
             <p>[TERMREF]
               <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
                 [MODIFICATION]The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here
             [/TERMREF]</p>
             <p>[TERMREF] Termbase IEV, term ID xyz [/TERMREF]</p>
      <p>[TERMREF] Termbase IEV, term ID xyz [MODIFICATION] [/TERMREF]</p>
      <p>[TERMREF] Termbase IEV, term ID xyz [MODIFICATION]with adjustments [/TERMREF]</p>
      <p class="TermNum" id="paddy">1.2.</p><p class="Terms" style="text-align:left;">paddy</p><p class="AltTerms" style="text-align:left;">paddy rice</p>
             <p class="AltTerms" style="text-align:left;">rough rice</p>
             <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
             <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
             <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example"><p class="example-title">EXAMPLE</p>
               <ul>
               <li>A</li>
               </ul>
             </div>
             <div class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
             <div class="Note"><p>Note 2 to entry: <ul><li>A</li></ul><p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
             <p>[TERMREF]
               <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
             [/TERMREF]</p></div>
                   </div>
                 </body>
             </html>
    INPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
        <head/>
        <body lang='en'>
          <div class='title-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='main-section'>
            <p class='zzSTDTitle1'/>
            <div id='_terms_and_definitions'>
              <h1>1.&#160; Terms and Definitions</h1>
              <p>For the purposes of this document, the following terms and definitions apply.</p>
              <p class='TermNum' id='paddy1'>1.1.</p>
              <p class='Terms' style='text-align:left;'>paddy</p>
              <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>&lt;rice&gt; rice retaining its husk after threshing</p>
              <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f892' class='example'>
                <p class='example-title'>EXAMPLE 1</p>
                <p id='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f894' class='example'>
                <p class='example-title'>EXAMPLE 2</p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <p>
                [SOURCE:
                <a href='#ISO7301'>ISO 7301:2011, Clause 3.1</a>
                , modified &mdash; The term "cargo rice" is shown as deprecated, and
                Note 1 to entry is not included here; Termbase IEV, term ID xyz;
                Termbase IEV, term ID xyz, modified; Termbase IEV, term ID xyz,
      modified &mdash; with adjustments]
              </p>
              <p class='TermNum' id='paddy'>1.2.</p>
              <p class='Terms' style='text-align:left;'>paddy</p>
              <p class='AltTerms' style='text-align:left;'>paddy rice</p>
              <p class='AltTerms' style='text-align:left;'>rough rice</p>
              <p class='DeprecatedTerms' style='text-align:left;'>DEPRECATED: cargo rice</p>
              <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
              <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f893' class='example'>
                <p class='example-title'>EXAMPLE</p>
                <ul>
                  <li>A</li>
                </ul>
              </div>
              <div class='Note'>
                <p>
                  Note 1 to entry: The starch of waxy rice consists almost entirely of
                  amylopectin. The kernels have a tendency to stick together after
                  cooking.
                </p>
              </div>
              <div class='Note'>
                <p>
                  Note 2 to entry:
                  <ul>
                    <li>A</li>
                  </ul>
                  <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                    The starch of waxy rice consists almost entirely of amylopectin.
                    The kernels have a tendency to stick together after cooking.
                  </p>
                </p>
              </div>
              <p>
                [SOURCE:
                <a href='#ISO7301'>ISO 7301:2011, Clause 3.1</a>
                ]
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end
end
