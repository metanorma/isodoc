require "spec_helper"

RSpec.describe IsoDoc do
  it "processes sourcecode" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <sourcecode lang="ruby" id="samplecode">
          <name>Ruby <em>code</em></name>
        puts x
      </sourcecode>
      <sourcecode unnumbered="true" linenums="true">Hey
      Que?
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder="1">
            <sourcecode lang='ruby' id='samplecode'>
              <name>
                Figure 1&#xA0;&#x2014; Ruby
                <em>code</em>
              </name>
               puts x
            </sourcecode>
            <sourcecode unnumbered='true' linenums="true">Hey
             Que? </sourcecode>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                         <br/>
                         <div>
                           <h1 class="ForewordTitle">Foreword</h1>
                           <pre id="samplecode" class="sourcecode"><br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160; <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; puts x<br/>&#160;&#160;&#160;&#160;&#160;</pre>
                           <p class="SourceTitle" style="text-align:center;">Figure 1&#160;&#8212; Ruby <i>code</i></p>
                           <pre class="sourcecode">Hey<br/>       Que? </pre>
                         </div>
                         <p class="zzSTDTitle1"/>
                       </div>
                     </body>
                 </html>
    OUTPUT

    doc = <<~OUTPUT
         <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
              <head><style/></head>
              <body lang="EN-US" link="blue" vlink="#954F72">
                <div class="WordSection1">
                  <p>&#160;</p>
                </div>
                <p>
                  <br clear="all" class="section"/>
                </p>
                <div class="WordSection2">
                  <p>
                    <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                  </p>
                    <div>
                      <h1 class="ForewordTitle">Foreword</h1>
                      <p id="samplecode" class="Sourcecode"><br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160; <br/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160; puts x<br/>&#160;&#160;&#160;&#160;&#160; </p><p class="SourceTitle" style="text-align:center;">Figure 1&#160;&#8212; Ruby <i>code</i></p>
                       <p class="Sourcecode">Hey<br/>       Que? </p>
                    </div>
                       <p>&#160;</p>
      </div>
      <p>
        <br clear="all" class="section"/>
      </p>
      <div class="WordSection3">
                    <p class="zzSTDTitle1"/>
                  </div>
                </body>
            </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes sourcecode with sourcecode highlighting" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
          <preface><foreword>
          <sourcecode lang="ruby" id="samplecode">
          <name>Ruby <em>code</em></name>
        puts x
      </sourcecode>
      <sourcecode unnumbered="true" linenums="true" id="A"><name>More</name>Hey
      Que?
      </sourcecode>
      <sourcecode unnumbered="true" linenums="true" id="B"><name>More</name>Hey
      Que?
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata/>
         <metanorma-extension>
           <source-highlighter-css>sourcecode table td { padding: 5px; }
       sourcecode table pre { margin: 0; }
       sourcecode, sourcecode .w {
         color: #444444;
       }
       sourcecode .cp {
         color: #CC00A3;
       }
       sourcecode .cs {
         color: #CC00A3;
       }
       sourcecode .c, sourcecode .ch, sourcecode .cd, sourcecode .cm, sourcecode .cpf, sourcecode .c1 {
         color: #FF0000;
       }
       sourcecode .kc {
         color: #C34E00;
       }
       sourcecode .kd {
         color: #0000FF;
       }
       sourcecode .kr {
         color: #007575;
       }
       sourcecode .k, sourcecode .kn, sourcecode .kp, sourcecode .kt, sourcecode .kv {
         color: #0000FF;
       }
       sourcecode .s, sourcecode .sb, sourcecode .sc, sourcecode .ld, sourcecode .sd, sourcecode .s2, sourcecode .se, sourcecode .sh, sourcecode .si, sourcecode .sx, sourcecode .sr, sourcecode .s1, sourcecode .ss {
         color: #009C00;
       }
       sourcecode .sa {
         color: #0000FF;
       }
       sourcecode .nb, sourcecode .bp {
         color: #C34E00;
       }
       sourcecode .nt {
         color: #0000FF;
       }
       </source-highlighter-css>
         </metanorma-extension>
         <preface>
           <foreword displayorder="1">
             <sourcecode lang="ruby" id="samplecode">
               <name>Figure 1 — Ruby <em>code</em></name>
               <span class="nb">puts</span>
               <span class="n">x</span>
             </sourcecode>
             <sourcecode unnumbered="true" linenums="true" id="A">
               <name>More</name>
               <table class="rouge-line-table">
                 <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>Hey</sourcecode>
                     </td>
                   </tr>
                   <tr id="line-2" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>2</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>Que?</sourcecode>
                     </td>
                   </tr>
                 </tbody>
               </table>
             </sourcecode>
             <sourcecode unnumbered="true" linenums="true" id="B">
               <name>More</name>
               <table class="rouge-line-table">
                 <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>Hey</sourcecode>
                     </td>
                   </tr>
                   <tr id="line-2" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>2</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>Que?</sourcecode>
                     </td>
                   </tr>
                 </tbody>
               </table>
             </sourcecode>
           </foreword>
         </preface>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                                <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <pre id="samplecode" class="sourcecode"><br/>         <br/>         <span class="nb">puts</span><br/>         <span class="n">x</span><br/>       </pre>
               <p class="SourceTitle" style="text-align:center;">Figure 1 — Ruby <i>code</i></p>
               <div id="A" class="sourcecode">
               
                <table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl">
                        <pre>1</pre>
                      </td><td style="" class="rouge-code">
                        <pre class="sourcecode">Hey</pre>
                      </td></tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">Que?</pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">More</p>
               <div id="B" class="sourcecode">
               
                <table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl">
                        <pre>1</pre>
                      </td><td style="" class="rouge-code">
                        <pre class="sourcecode">Hey</pre>
                      </td></tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">Que?</pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">More</p>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT

    doc = <<~OUTPUT
          <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
        <div class="WordSection1">
          <p class="MsoNormal"> </p>
        </div>
        <p class="MsoNormal">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p class="MsoNormal">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="ForewordTitle">Foreword</h1>
            <p class="Sourcecode" style="page-break-after:avoid;"><a name="samplecode" id="samplecode"/><br/>         <br/>         <span class="nb">puts</span><br/>         <span class="n">x</span><br/>       </p>
            <p class="SourceTitle" style="text-align:center;">Figure 1 — Ruby <i>code</i></p>
            <div align="center" class="table_container" style="page-break-after:avoid;">
              <a name="A" id="A"/>
              <table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                 <tbody>
                   <tr>
                     <td style="page-break-after:avoid;" class="rouge-gutter gl">
                        <pre style="page-break-after:avoid">1</pre>
                      </td>
                     <td style="page-break-after:avoid;" class="rouge-code">
                        <p class="Sourcecode" style="page-break-after:avoid">Hey</p>
                      </td>
                   </tr>
                   <tr>
                     <td style="page-break-after:auto;" class="rouge-gutter gl">
                       <pre style="page-break-after:auto">2</pre>
                     </td>
                     <td style="page-break-after:auto;" class="rouge-code">
                       <p class="Sourcecode" style="page-break-after:auto">Que?</p>
                     </td>
                   </tr>
                 </tbody>
               </table>
            </div>
            <p class="SourceTitle" style="text-align:center;">More</p>
            <div align="center" class="table_container" style="page-break-after:avoid;">
              <a name="B" id="B"/>
                 <table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                 <tbody>
                   <tr>
                     <td style="page-break-after:avoid;" class="rouge-gutter gl">
                        <pre style="page-break-after:avoid">1</pre>
                      </td>
                     <td style="page-break-after:avoid;" class="rouge-code">
                        <p class="Sourcecode" style="page-break-after:avoid">Hey</p>
                      </td>
                   </tr>
                   <tr>
                     <td style="page-break-after:auto;" class="rouge-gutter gl">
                       <pre style="page-break-after:auto">2</pre>
                     </td>
                     <td style="page-break-after:auto;" class="rouge-code">
                       <p class="Sourcecode" style="page-break-after:auto">Que?</p>
                     </td>
                   </tr>
                 </tbody>
               </table>
            </div>
            <p class="SourceTitle" style="text-align:center;">More</p>
          </div>
          <p class="MsoNormal"> </p>
        </div>
        <p class="MsoNormal">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
        </div>
        <div style="mso-element:footnote-list"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true })
      .convert("test", input, true))
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    FileUtils.rm_f("test.doc")
    IsoDoc::WordConvert.new({}).convert("test", presxml, false)
    expect(xmlpp(File.read("test.doc")
      .gsub(%r{^.*<body }m, "<body ")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(doc)
  end

  it "processes sourcecode with escapes preserved, and XML sourcecode highlighting" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
          <preface><foreword>
          <sourcecode id="samplecode" lang="xml">
          <name>XML code</name>
        &lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;
      </sourcecode>
          <sourcecode id="samplecode1" lang="xml" linenums="true">
          <name>XML code</name>
        &lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata/>
      <preface><foreword displayorder="1">
      <sourcecode id="samplecode" lang="xml"><name>Figure 1 — XML code</name><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></sourcecode>
                   <sourcecode id="samplecode1" lang="xml" linenums="true">
               <name>Figure 2 — XML code</name>
               <table class="rouge-line-table">
                                <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode/>
                     </td>
                   </tr>
                   <tr id="line-2" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>2</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode/>
                     </td>
                   </tr>
                   <tr id="line-3" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>3</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></sourcecode>
                     </td>
                   </tr>
                 </tbody>
               </table>
             </sourcecode>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                               <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <pre id="samplecode" class="sourcecode"><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></pre>
               <p class="SourceTitle" style="text-align:center;">Figure 1 — XML code</p>
               <div id="samplecode1" class="sourcecode">
               
                <table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl">
                        <pre>1</pre>
                      </td><td style="" class="rouge-code">
                        <pre class="sourcecode"/>
                      </td></tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode"/></td></tr><tr><td style="" class="rouge-gutter gl"><pre>3</pre></td><td style="" class="rouge-code"><pre class="sourcecode"><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">Figure 2 — XML code</p>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert
  .new({ sourcehighlighter: true })
  .convert("test", input, true))
  .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes sourcecode with annotations" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
      <preface><foreword>
      <sourcecode id="_">puts "Hello, world." <callout target="A">1</callout> <callout target="B">2</callout>
         %w{a b c}.each do |x|
           puts x <callout target="C">3</callout>
         end<annotation id="A">
           <p id="_">This is <em>one</em> callout</p>
         </annotation><annotation id="B">
           <p id="_">This is another callout</p>
         </annotation><annotation id="C">
           <p id="_">This is yet another callout</p>
         </annotation></sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata/>
      <preface><foreword displayorder="1">
      <sourcecode id="_"><name>Figure 1</name>puts "Hello, world." <span class="c"><callout target="A">1</callout></span><span class="c"><callout target="B">2</callout></span>
         %w{a b c}.each do |x|
           puts x <span class="c"><callout target="C">3</callout></span>
           end<annotation id="A"><p id="_">This is <em>one</em> callout</p></annotation><annotation id="B"><p id="_">This is another callout</p></annotation><annotation id="C"><p id="_">This is yet another callout</p></annotation></sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                  <br/>
                  <div>
                                 <h1 class="ForewordTitle">Foreword</h1>
               <pre id="_" class="sourcecode">puts "Hello, world." <span class="c">&lt;1&gt;</span> <span class="c">&lt;2&gt;</span><br/>   %w{a b c}.each do |x|<br/>     puts x <span class="c">&lt;3&gt;</span> <br/>     end<div class="annotation"><span class="c">&lt;1&gt;</span> <span class="c">This is one callout</span><br/></div><div class="annotation"><span class="c">&lt;2&gt;</span> <span class="c">This is another callout</span><br/></div><div class="annotation"><span class="c">&lt;3&gt;</span> <span class="c">This is yet another callout</span></div></pre>
               <p class="SourceTitle" style="text-align:center;">Figure 1</p>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
    doc = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
      <head><style/>         </head>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p> </p>
             </div>
             <p>
               <br clear="all" class="section"/>
             </p>
             <div class="WordSection2">
               <p>
                 <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               </p>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_" class="Sourcecode">puts "Hello, world." <span class="c">&lt;1&gt;</span><span class="c">&lt;2&gt;</span><br/>   %w{a b c}.each do |x|<br/>     puts x <span class="c">&lt;3&gt;</span> <br/>     end<div class="annotation"><span class="c">&lt;1&gt;</span><span class="c">This is one callout</span><br/></div><div class="annotation"><span class="c">&lt;2&gt;</span><span class="c">This is another callout</span><br/></div><div class="annotation"><span class="c">&lt;3&gt;</span><span class="c">This is yet another callout</span></div></p>
                 <p class="SourceTitle" style="text-align:center;">Figure 1</p>
               </div>
               <p> </p>
             </div>
             <p>
               <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             </div>
           </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert
  .new({ sourcehighlighter: true })
  .convert("test", input, true))
  .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes sourcecode with annotations and line numbering" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
      <preface><foreword>
      <sourcecode id="_" linenums="true">puts "Hello, world." <callout target="A">1</callout> <callout target="B">2</callout>
         %w{a b c}.each do |x|
           puts x <callout target="C">3</callout>
         end<annotation id="A">
           <p id="_">This is <em>one</em> callout</p>
         </annotation><annotation id="B">
           <p id="_">This is another callout</p>
         </annotation><annotation id="C">
           <p id="_">This is yet another callout</p>
         </annotation></sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata/>
         <preface>
           <foreword displayorder="1">
             <sourcecode id="_" linenums="true">
               <name>Figure 1</name>
               <table class="rouge-line-table">
                 <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>puts "Hello, world." <span class="c"><callout target="A">1</callout></span>  <span class="c"><callout target="B">2</callout></span> </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-2" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>2</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>   %w{a b c}.each do |x|</sourcecode>
                     </td>
                   </tr>
                   <tr id="line-3" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>3</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>     puts x <span class="c"><callout target="C">3</callout></span> </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-4" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>4</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>   end</sourcecode>
                     </td>
                   </tr>
                 </tbody>
               </table>
               <annotation id="A">
                 <p id="_">This is <em>one</em> callout</p>
               </annotation>
               <annotation id="B">
                 <p id="_">This is another callout</p>
               </annotation>
               <annotation id="C">
                 <p id="_">This is yet another callout</p>
               </annotation>
             </sourcecode>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="sourcecode">
               
                <table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl">
                        <pre>1</pre>
                      </td><td style="" class="rouge-code">
                        <pre class="sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span>  <span class="c"> &lt;2&gt;</span> </pre>
                      </td></tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">   %w{a b c}.each do |x|</pre></td></tr><tr><td style="" class="rouge-gutter gl"><pre>3</pre></td><td style="" class="rouge-code"><pre class="sourcecode">     puts x <span class="c"> &lt;3&gt;</span> </pre></td></tr><tr><td style="" class="rouge-gutter gl"><pre>4</pre></td><td style="" class="rouge-code"><pre class="sourcecode">   end</pre></td></tr></tbody></table>
                <div class="annotation"><span class="c">&lt;1&gt;</span><span class="c">This is one callout</span><br/></div>
                <div class="annotation"><span class="c">&lt;2&gt;</span><span class="c">This is another callout</span><br/></div>
                <div class="annotation"><span class="c">&lt;3&gt;</span><span class="c">This is yet another callout</span></div>
              </div>
               <p class="SourceTitle" style="text-align:center;">Figure 1</p>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
    doc = <<~OUTPUT
          <html lang="en">
        <head><style/></head>
                 <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p> </p>
          </div>
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p>
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="_" class="Sourcecode">
              
               <div align="center" class="table_container"><table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;"><tbody><tr><td style="page-break-after:avoid;" class="rouge-gutter gl">
                       <pre>1</pre>
                     </td><td style="page-break-after:avoid;" class="rouge-code">
                       <p class="Sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span>  <span class="c"> &lt;2&gt;</span> </p>
                     </td></tr><tr><td style="page-break-after:avoid;" class="rouge-gutter gl"><pre>2</pre></td><td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode">   %w{a b c}.each do |x|</p></td></tr><tr><td style="page-break-after:avoid;" class="rouge-gutter gl"><pre>3</pre></td><td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode">     puts x <span class="c"> &lt;3&gt;</span> </p></td></tr><tr><td style="page-break-after:auto;" class="rouge-gutter gl"><pre>4</pre></td><td style="page-break-after:auto;" class="rouge-code"><p class="Sourcecode">   end</p></td></tr></tbody></table></div>
               <div class="annotation"><span class="c">&lt;1&gt;</span><span class="c">This is one callout</span><br/></div>
               <div class="annotation"><span class="c">&lt;2&gt;</span><span class="c">This is another callout</span><br/></div>
               <div class="annotation"><span class="c">&lt;3&gt;</span><span class="c">This is yet another callout</span></div>
             </p>
              <p class="SourceTitle" style="text-align:center;">Figure 1</p>
            </div>
            <p> </p>
          </div>
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert
  .new({ sourcehighlighter: true })
  .convert("test", input, true))
  .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(doc)
  end

  it "processes pseudocode" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
              <preface><foreword>
        <figure id="_" class="pseudocode" keep-with-next="true" keep-lines-together="true"><name>Label</name><p id="_">  <strong>A</strong><br/>
              <smallcap>B</smallcap></p>
      <p id="_">  <em>C</em></p></figure>
      </preface></itu-standard>
    INPUT

    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
          <language current="true">en</language>
          </bibdata>
              <preface><foreword displayorder="1">
        <figure id="_" class="pseudocode" keep-with-next="true" keep-lines-together="true"><name>Figure 1&#xA0;&#x2014; Label</name><p id="_">&#xA0;&#xA0;<strong>A</strong><br/>
      &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;<smallcap>B</smallcap></p>
      <p id="_">&#xA0;&#xA0;<em>C</em></p></figure>
      </foreword></preface>
      </itu-standard>

    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                       <div>
                         <h1 class="ForewordTitle">Foreword</h1>
                         <div id="_" class="pseudocode" style='page-break-after: avoid;page-break-inside: avoid;'><p id="_">&#160;&#160;<b>A</b><br/>
                 &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<span style="font-variant:small-caps;">B</span></p>
                 <p id="_">&#160;&#160;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
                       </div>
                       <p class="zzSTDTitle1"/>
                     </div>
                   </body>
          </html>
    OUTPUT

    FileUtils.rm_f "test.doc"
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    IsoDoc::WordConvert.new({}).convert("test", presxml, false)
    expect(xmlpp(File.read("test.doc")
      .gsub(%r{^.*<h1 class="ForewordTitle">Foreword</h1>}m, "")
      .gsub(%r{</div>.*}m, "</div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
             <div class="pseudocode"  style='page-break-after: avoid;page-break-inside: avoid;'><a name="_" id="_"></a><p class="pseudocode"><a name="_" id="_"></a>&#xA0;&#xA0;<b>A</b><br/>
        &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;<span style="font-variant:small-caps;">B</span></p>
        <p class="pseudocode" style="page-break-after:avoid;"><a name="_" id="_"></a>&#xA0;&#xA0;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
      OUTPUT
  end
end
