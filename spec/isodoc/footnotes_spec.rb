require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword><title>Foreword</title>
          <p>A.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>C.<fn reference="1">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
      </fn></p>
          </foreword>
          </preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   A.
                   <fn reference="2">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                   </fn>
                </p>
                <p>
                   B.
                   <fn reference="2">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                   </fn>
                </p>
                <p>
                   C.
                   <fn reference="1">
                      <p id="_">Hello! denoted as 15 % (m/m).</p>
                   </fn>
                </p>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                 <br/>
                 <div>
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
                   A.
                   <a class='FootnoteRef' href='#fn:2'>
                     <sup>2</sup>
                   </a>
                 </p>
                 <p>
                   B.
                   <a class='FootnoteRef' href='#fn:2'>
                     <sup>2</sup>
                   </a>
                 </p>
                 <p>
                   C.
                   <a class='FootnoteRef' href='#fn:1'>
                     <sup>1</sup>
                   </a>
                 </p>
                 </div>
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
    doc = <<~OUTPUT
      #{WORD_HDR}
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <p>
                A.
                <span style='mso-bookmark:_Ref'>
                  <a href='#ftn2' epub:type='footnote'  class='FootnoteRef'>
                    <sup>2</sup>
                  </a>
                </span>
              </p>
              <p>
                B.
                <span style='mso-element:field-begin'/>
                 NOTEREF _Ref \\f \\h
                <span style='mso-element:field-separator'/>
                <span class='MsoFootnoteReference'>2</span>
                <span style='mso-element:field-end'/>
              </p>
              <p>
                C.
                <span style='mso-bookmark:_Ref'>
                  <a href='#ftn1' epub:type='footnote'  class='FootnoteRef'>
                    <sup>1</sup>
                  </a>
                </span>
              </p>
            </div>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <aside id='ftn2'>
              <p id='_'>Formerly denoted as 15 % (m/m).</p>
            </aside>
            <aside id='ftn1'>
              <p id='_'>Hello! denoted as 15 % (m/m).</p>
            </aside>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(html))
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(doc))
  end

  it "processes IsoXML reviewer notes" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword displayorder="1"><title>Foreword</title>
          <p id="A">A.</p>
          <p id="B">B.</p>
          <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711" date="20170101T0000" from="A" to="B"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
      <p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review>
          <p id="C">C.</p>
          <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
          </foreword>
          <introduction displayorder="2"><title>Introduction</title>
          <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
          </introduction>
          </preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="A">A.</p>
                 <p id="B">B.</p>
                 <review reviewer="ISO" id="_" date="20170101T0000" from="A" to="B">
                    <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
                    <p id="_">
                       For further information on the Foreword, see
                       <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                    </p>
                 </review>
                 <p id="C">C.</p>
                 <review reviewer="ISO" id="_" date="20170108T0000" from="C" to="C">
                    <p id="_">Second note.</p>
                 </review>
              </foreword>
              <introduction displayorder="3">
                 <title id="_">Introduction</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Introduction</semx>
                 </fmt-title>
                 <review reviewer="ISO" id="_" date="20170108T0000" from="A" to="C">
                    <p id="_">Second note.</p>
                 </review>
              </introduction>
           </preface>
        </iso-standard>
    INPUT
    html = <<~OUTPUT
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <br />
                   <div id="_" class="TOC">
              <h1 class="IntroTitle">
                 <a class="anchor" href="#_"/>
                 <a class="header" href="#_">Table of contents</a>
              </h1>
           </div>
           <br/>
        <div>
          <h1 class="ForewordTitle">Foreword</h1>
          <p id="A">A.</p>
          <p id="B">B.</p>
          <p id="C">C.</p>
        </div>
        <br />
        <div class="Section3" id="">
          <h1 class="IntroTitle"><a class="anchor" href="#"/> <a class="header" href="#">Introduction</a></h1>
        </div>
      </main>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div>
             <h1 class="ForewordTitle">Foreword</h1>
             <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="B">
               <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                 <a style="mso-comment-reference:SMC_1;mso-comment-date:20170101T0000">
                   <span style="MsoCommentReference" target="3" class="commentLink" from="A" to="C">
                     <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                       <a style="mso-comment-reference:SMC_3;mso-comment-date:20170108T0000">
                         <p class="MsoNormal"><a name="A" id="A"/>A.</p>
                       </a>
                       <span style="mso-comment-continuation:3">
                         <span style="mso-special-character:comment" target="3"/>
                       </span>
                     </span>
                   </span>
                 </a>
                 <span style="mso-comment-continuation:3">
                   <span style="mso-comment-continuation:1">
                     <span style="mso-special-character:comment" target="1"/>
                   </span>
                 </span>
               </span>
             </span>
             <p class="MsoNormal">
               <a name="B" id="B"/>
               <span style="mso-comment-continuation:3">
                 <span style="mso-comment-continuation:1">B.</span>
               </span>
             </p>
             <span style="MsoCommentReference" target="2" class="commentLink" from="C" to="C">
               <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                 <a style="mso-comment-reference:SMC_2;mso-comment-date:20170108T0000">
                   <p class="MsoNormal">
                     <a name="C" id="C"/>
                     <span style="mso-comment-continuation:3">C.</span>
                   </p>
                 </a>
                 <span style="mso-special-character:comment" target="2"/>
               </span>
             </span>
           </div>
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div class="Section3" id="">
             <h1 class="IntroTitle">Introduction</h1>
           </div>
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <div style="mso-element:comment-list">
             <div style="mso-element:comment">
               <a name="3" id="3"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
             <div style="mso-element:comment">
               <a name="1" id="1"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
               <p class="MsoCommentText"><a name="_" id="_"/>For further information on the Foreword, see <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b></p>
             </div>
             <div style="mso-element:comment">
               <a name="2" id="2"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
           </div>
         </div>
         <div style="mso-element:footnote-list"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.html").sub(/^.*<main/m, "<main").sub(
      %r{</main>.*$}m, "</main>"
    )
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.doc").sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m,
                                                              "</body>")
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes IsoXML reviewer notes spanning list" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword displayorder="1"><title>Foreword</title>
      <ol>
      <li id="A"><p>A.</p><p>A1</p></li>
      <li id="B">B.</li>
      <ul>
      <li><p>C.</p><p id="C">C1</p></li>
      <li id="D">D.</li>
      </ul>
      </ol>
      </foreword>
      <introduction displayorder="2"><title>Introduction</title>
      <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
      </introduction>
      </preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <ol type="alphabet">
                    <li id="A" label="">
                       <p>A.</p>
                       <p>A1</p>
                    </li>
                    <li id="B" label="">B.</li>
                    <ul>
                       <li>
                          <p>C.</p>
                          <p id="C">C1</p>
                       </li>
                       <li id="D">D.</li>
                    </ul>
                 </ol>
              </foreword>
              <introduction displayorder="3">
                 <title id="_">Introduction</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Introduction</semx>
                 </fmt-title>
                 <review reviewer="ISO" id="_" date="20170108T0000" from="A" to="C">
                    <p id="_">Second note.</p>
                 </review>
              </introduction>
           </preface>
        </iso-standard>
    INPUT
    html = <<~OUTPUT
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <br />
           <div id="_" class="TOC">
      <h1 class="IntroTitle">
         <a class="anchor" href="#_"/>
         <a class="header" href="#_">Table of contents</a>
      </h1>
      </div>
      <br/>
        <div>
          <h1 class="ForewordTitle">Foreword</h1>
          <div class="ol_wrap">
          <ol type="a">
             <li id="A">
               <p>A.</p>
               <p>A1</p>
             </li>
             <li id="B">B.
             <div class="ul_wrap">
             <ul>
               <li>
                 <p>C.</p>
                 <p id="C">C1</p>
               </li>
               <li id="D">D.</li>
             </ul>
             </div></li>
           </ol>
           </div>
        </div>
        <br />
        <div class="Section3" id="">
          <h1 class="IntroTitle"><a class="anchor" href="#"/><a class="header" href="#">Introduction</a></h1>
        </div>
      </main>
    OUTPUT
    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div>
             <h1 class="ForewordTitle">Foreword</h1>
             <div class="ol_wrap">
               <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="C">
                 <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                   <a style="mso-comment-reference:SMC_1;mso-comment-date:20170108T0000">
                     <li class="MsoNormal">
                       <a name="A" id="A"/>
                       <p class="MsoNormal">A.</p>
                       <div class="ListContLevel1">
                         <p class="MsoNormal">A1</p>
                       </div>
                     </li>
                   </a>
                   <span style="mso-comment-continuation:1">
                     <span style="mso-special-character:comment" target="1"/>
                   </span>
                 </span>
               </span>
               <p class="MsoListParagraphCxSpFirst">
                 <a name="B" id="B"/>
                 <span style="mso-comment-continuation:1">B.</span>
               </p>
               <div class="ul_wrap">
                 <p class="MsoListParagraphCxSpFirst" style="">
                   <span style="mso-comment-continuation:1">C.</span>
                   <p class="MsoListParagraphCxSpMiddle">
                     <a name="C" id="C"/>
                     <span style="mso-comment-continuation:1">C1</span>
                   </p>
                 </p>
                 <p class="MsoListParagraphCxSpLast"><a name="D" id="D"/>D.</p>
               </div>
             </div>
           </div>
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div class="Section3" id="">
             <h1 class="IntroTitle">Introduction</h1>
           </div>
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <div style="mso-element:comment-list">
             <div style="mso-element:comment">
               <a name="1" id="1"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
           </div>
         </div>
         <div style="mso-element:footnote-list"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.html").sub(/^.*<main/m, "<main").sub(
      %r{</main>.*$}m, "</main>"
    )
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.doc")
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
