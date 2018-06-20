require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
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
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                <p>A.<a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
                <p>B.<a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
                <p>C.<a rel="footnote" href="#fn:1" epub:type="footnote"><sup>1</sup></a></p>
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

  it "processes IsoXML footnotes (Word)" do
    expect(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
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
       </html>
    OUTPUT
  end

  it "processes IsoXML reviewer notes" do
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p id="A">A.</p>
    <p id="B">B.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711" date="20170101T0000" from="A" to="B"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
<p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review>
    <p id="C">C.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </foreword>
    <introduction>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </introduction>
    </preface>
    </iso-standard>
    INPUT
    html = File.read("test.html").sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")
    expect(html).to be_equivalent_to <<~"OUTPUT"
            <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
            <div class="title-section">
              <p>&#xA0;</p>
            </div>
            <br />
            <div class="prefatory-section">
              <p>&#xA0;</p>
            </div>
            <br />
            <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
              <br />
              <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="B">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_1;mso-comment-date:20170101T0000"><span style="MsoCommentReference" target="3" class="commentLink" from="A" to="C">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_3;mso-comment-date:20170108T0000"><p id="A">A.</p></a>
                     <span style="mso-comment-continuation:3"><span style="mso-special-character:comment" target="3"></span></span>
                   </span>
                 </span></a>
                     <span style="mso-comment-continuation:3"><span style="mso-comment-continuation:1"><span style="mso-special-character:comment" target="1"></span></span></span>
                   </span>
                 </span>
                 <span style="mso-comment-continuation:3"><span style="mso-comment-continuation:1"><p id="B">B.</p></span></span>

                 <span style="MsoCommentReference" target="2" class="commentLink" from="C" to="C">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_2;mso-comment-date:20170108T0000"><span style="mso-comment-continuation:3"><p id="C">C.</p></span></a>
                     <span style="mso-special-character:comment" target="2"></span>
                   </span>
                 </span>

               </div>
               <br />
               <div class="Section3" id="">
                 <h1 class="IntroTitle">Introduction</h1>

               </div>
               <p class="zzSTDTitle1"></p>
               <div style="mso-element:comment-list"><div style="mso-element:comment" id="3">
         <span style="mso-comment-author:&quot;ISO&quot;"></span>

         <p class="MsoCommentText" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08"><span style="MsoCommentReference">
           <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
             <span style="mso-special-character:comment"></span>
           </span>
         </span>Second note.</p>
       </div>
       <div style="mso-element:comment" id="1"><span style="mso-comment-author:&quot;ISO&quot;"></span><p class="MsoCommentText" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07"><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"></span></span></span>A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
       <p class="MsoCommentText" id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b></p></div>
       <div style="mso-element:comment" id="2">
         <span style="mso-comment-author:&quot;ISO&quot;"></span>

         <p class="MsoCommentText" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08"><span style="MsoCommentReference">
           <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
             <span style="mso-special-character:comment"></span>
           </span>
         </span>Second note.</p>
       </div></div>
             </div>
           <script type="text/x-mathjax-config">
         MathJax.Hub.Config({
           asciimath2jax: {
             delimiters: [['(#(', ')#)']]
           }
        });
       </script>
       <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=AM_HTMLorMML"></script>
       </body>
       </html>
    OUTPUT
  end

  it "processes IsoXML reviewer notes (Word)" do
    system "rm -f test.doc"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p id="A">A.</p>
    <p id="B">B.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711" date="20170101T0000" from="A" to="B"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
<p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review>
    <p id="C">C.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </foreword>
    <introduction>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </introduction>
    </preface>
    </iso-standard>
    INPUT
    html = File.read("test.doc").sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")
    expect(html).to be_equivalent_to <<~"OUTPUT"
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
             <div class="WordSection1">
               <p class="MsoNormal">&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="B">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_1;mso-comment-date:20170101T0000"><span style="MsoCommentReference" target="3" class="commentLink" from="A" to="C">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_3;mso-comment-date:20170108T0000"><p class="MsoNormal"><a name="A" id="A"></a>A.</p></a>
                     <span style="mso-comment-continuation:3"><span style="mso-special-character:comment" target="3"></span></span>
                   </span>
                 </span></a>
                     <span style="mso-comment-continuation:3"><span style="mso-comment-continuation:1"><span style="mso-special-character:comment" target="1"></span></span></span>
                   </span>
                 </span>
                 <span style="mso-comment-continuation:3"><span style="mso-comment-continuation:1"><p class="MsoNormal"><a name="B" id="B"></a>B.</p></span></span>

                 <span style="MsoCommentReference" target="2" class="commentLink" from="C" to="C">
                   <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                     <a style="mso-comment-reference:SMC_2;mso-comment-date:20170108T0000"><span style="mso-comment-continuation:3"><p class="MsoNormal"><a name="C" id="C"></a>C.</p></span></a>
                     <span style="mso-special-character:comment" target="2"></span>
                   </span>
                 </span>

               </div>
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div class="Section3" id="">
                 <h1 class="IntroTitle">Introduction</h1>

               </div>
               <p class="MsoNormal">&#xA0;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <div style="mso-element:comment-list"><div style="mso-element:comment"><a name="3" id="3"></a>
         <span style="mso-comment-author:&quot;ISO&quot;"></span>

         <p class="MsoCommentText"><a name="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08"></a><span style="MsoCommentReference">
           <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
             <span style="mso-special-character:comment"></span>
           </span>
         </span>Second note.</p>
       </div>
       <div style="mso-element:comment"><a name="1" id="1"></a><span style="mso-comment-author:&quot;ISO&quot;"></span><p class="MsoCommentText"><a name="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07"></a><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"></span></span></span>A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
       <p class="MsoCommentText"><a name="_f1a8b9da-ca75-458b-96fa-d4af7328975e" id="_f1a8b9da-ca75-458b-96fa-d4af7328975e"></a>For further information on the Foreword, see <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b></p></div>
       <div style="mso-element:comment"><a name="2" id="2"></a>
         <span style="mso-comment-author:&quot;ISO&quot;"></span>

         <p class="MsoCommentText"><a name="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08" id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08"></a><span style="MsoCommentReference">
           <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
             <span style="mso-special-character:comment"></span>
           </span>
         </span>Second note.</p>
       </div></div>
             </div>
           <div style="mso-element:footnote-list"/></body>
    OUTPUT
  end


end
