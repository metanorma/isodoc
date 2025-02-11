require "spec_helper"

RSpec.describe IsoDoc do
  it "processes sourcecode" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <sourcecode lang="ruby" id="samplecode"><name>Ruby <em>code</em></name>puts x</sourcecode>
      <sourcecode unnumbered="true" linenums="true">Hey
      Que?
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <sourcecode lang="ruby" id="samplecode" autonum="1">
                   <name id="_">
                      Ruby
                      <em>code</em>
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="samplecode">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Ruby
                         <em>code</em>
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="samplecode">1</semx>
                   </fmt-xref-label>
                   puts x
                   <fmt-sourcecode lang="ruby" autonum="1">puts x</fmt-sourcecode>
                </sourcecode>
                <sourcecode unnumbered="true" linenums="true" id="_">
                   Hey Que?
                   <fmt-sourcecode unnumbered="true" linenums="true">Hey
       Que?
       </fmt-sourcecode>
                </sourcecode>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                         <br/>
                                         <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <pre id="samplecode" class="sourcecode">puts x</pre>
                   <p class="SourceTitle" style="text-align:center;">
                      Figure 1 — Ruby
                      <i>code</i>
                   </p>
                   <pre id="_" class="sourcecode">
                      Hey
                      <br/>
                      Que?
                      <br/>
                   </pre>
                </div>
             </div>
          </body>
       </html>
    OUTPUT

    doc = <<~OUTPUT
      #{WORD_HDR}
               <p class="page-break">
                  <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               </p>
               <div id="fwd">
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p id="samplecode" class="Sourcecode">puts x</p>
                  <p class="SourceTitle" style="text-align:center;">
                     Figure 1 — Ruby
                     <i>code</i>
                  </p>
                  <p id="_" class="Sourcecode">
                     Hey
                     <br/>
                     Que?
                     <br/>
                  </p>
               </div>
               <p> </p>
            </div>
            <p class="section-break">
               <br clear="all" class="section"/>
            </p>
            <div class="WordSection3"/>
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
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "processes sourcecode with sourcecode highlighting" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
          <preface><foreword>
          <sourcecode lang="ruby" id="samplecode"><name>Ruby <em>code</em></name>puts x</sourcecode>
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
             <clause type="toc" id="_" displayorder="1">
             <fmt-title depth="1">Table of contents</fmt-title>
        </clause>
        <foreword displayorder="2">
                 <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <sourcecode lang="ruby" id="samplecode" autonum="1">
            <name id="_">
               Ruby
               <em>code</em>
            </name>
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="samplecode">1</semx>
                  </span>
                  <span class="fmt-caption-delim"> — </span>
                  <semx element="name" source="_">
                     Ruby
                     <em>code</em>
                  </semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="samplecode">1</semx>
            </fmt-xref-label>puts x<fmt-sourcecode lang="ruby" autonum="1">
               <span class="nb">puts</span>
               <span class="n">x</span>
               </fmt-sourcecode>
             </sourcecode>
             <sourcecode unnumbered="true" linenums="true" id="A">
            <name id="_">More</name>
            <fmt-name>
                  <semx element="name" source="_">More</semx>
            </fmt-name>Hey
      Que?<fmt-sourcecode unnumbered="true" linenums="true">
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
               </fmt-sourcecode>
             </sourcecode>
             <sourcecode unnumbered="true" linenums="true" id="B">
               <name id="_">More</name>
            <fmt-name>
                  <semx element="name" source="_">More</semx>
            </fmt-name>Hey
      Que?<fmt-sourcecode unnumbered="true" linenums="true">
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
               </fmt-sourcecode>
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
               <pre id="samplecode" class="sourcecode"><span class="nb">puts</span><span class="n">x</span></pre>
               <p class="SourceTitle" style="text-align:center;">Figure 1 — Ruby <i>code</i></p>
               <div id="A" class="sourcecode"><table class="rouge-line-table" style=""><tbody><tr>
                  <td style="" class="rouge-gutter gl"><pre>1</pre></td>
                  <td style="" class="rouge-code"><pre class="sourcecode">Hey</pre></td>
                </tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">Que?</pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">More</p>
               <div id="B" class="sourcecode"><table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl"><pre>1</pre></td>
                    <td style="" class="rouge-code"><pre class="sourcecode">Hey</pre></td>
                  </tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">Que?</pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">More</p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT

    doc = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div>
             <h1 class="ForewordTitle">Foreword</h1>
             <p class="Sourcecode" style="page-break-after:avoid;"><a name="samplecode" id="samplecode"/><span class="nb">puts</span><span class="n">x</span></p>
             <p class="SourceTitle" style="text-align:center;">Figure 1 — Ruby <i>code</i></p>
             <div align="center" class="table_container" style="page-break-after:avoid;">
               <a name="A" id="A"/>
               <table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                 <tbody>
                   <tr>
                     <td style="page-break-after:avoid;" class="rouge-gutter gl"><pre style="page-break-after:avoid">1</pre></td>
                     <td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode" style="page-break-after:avoid">Hey</p></td>
                   </tr>
                   <tr>
                     <td style="page-break-after:auto;" class="rouge-gutter gl"><pre style="page-break-after:auto">2</pre></td>
                     <td style="page-break-after:auto;" class="rouge-code"><p class="Sourcecode" style="page-break-after:auto">Que?</p></td>
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
                     <td style="page-break-after:avoid;" class="rouge-gutter gl"><pre style="page-break-after:avoid">1</pre></td>
                     <td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode" style="page-break-after:avoid">Hey</p></td>
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
         <div class="WordSection3"/>
         <div style="mso-element:footnote-list"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f("test.doc")
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(Xml::C14n.format(strip_guid(File.read("test.doc")
      .gsub(%r{^.*<body }m, "<body ")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "combines sourcecode highlighting stylesheet with user-css" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
      <metanorma-extension><clause id="_user_css" inline-header="false" obligation="normative">
      <title>user-css</title>
      <sourcecode id="_2d494494-0538-c337-37ca-6d083d748646">.green { background-color: green }</sourcecode>
      </clause>
      </metanorma-extension>
      <preface><foreword>
      <sourcecode lang="ruby" id="samplecode">
          puts x
      </sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <metanorma-extension>
              <clause id="_" inline-header="false" obligation="normative">
      <title id="_">user-css</title>
      <fmt-title depth="1">
            <semx element="title" source="_">user-css</semx>
      </fmt-title>
             <sourcecode id="_">.green { background-color: green }</sourcecode>
           </clause>
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


       .green { background-color: green }</source-highlighter-css>
         </metanorma-extension>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true))
      .at("//xmlns:metanorma-extension")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes sourcecode with escapes preserved, and XML sourcecode highlighting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
      <preface><foreword>
      <sourcecode id="samplecode" lang="xml"><name>XML code</name>&lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;</sourcecode>
      <sourcecode id="samplecode1" lang="xml" linenums="true"><name>XML code</name>&lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;</sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata/>
      <preface>    <clause type="toc" id="_" displayorder="1">
      <fmt-title depth="1">Table of contents</fmt-title>
      </clause>
      <foreword displayorder="2">
               <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
                  <sourcecode id="samplecode" lang="xml" autonum="1"><name id="_">XML code</name><fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="samplecode">1</semx>
                  </span>
                  <span class="fmt-caption-delim"> — </span>
                  <semx element="name" source="_">XML code</semx>
            </fmt-name><fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="samplecode">1</semx>
            </fmt-xref-label>&lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;<fmt-sourcecode lang="xml" autonum="1"><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></fmt-sourcecode></sourcecode>
                     <sourcecode id="samplecode1" lang="xml" linenums="true" autonum="2">
            <name id="_">XML code</name>
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="samplecode1">2</semx>
                  </span>
                  <span class="fmt-caption-delim"> — </span>
                  <semx element="name" source="_">XML code</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="samplecode1">2</semx>
            </fmt-xref-label>&lt;xml&gt;A&lt;b&gt;C&lt;/b&gt;&lt;/xml&gt;
               <fmt-sourcecode lang="xml" linenums="true" autonum="2"><table class="rouge-line-table">
                                <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></sourcecode>
                     </td>
                   </tr>
                 </tbody>
               </table></fmt-sourcecode>
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
               <div id="samplecode1" class="sourcecode"><table class="rouge-line-table" style=""><tbody><tr>
                <td style="" class="rouge-gutter gl"><pre>1</pre></td><td style="" class="rouge-code"><pre class="sourcecode"><span class="nt">&lt;xml&gt;</span>A<span class="nt">&lt;b&gt;</span>C<span class="nt">&lt;/b&gt;&lt;/xml&gt;</span></pre></td></tr></tbody></table>
              </div>
               <p class="SourceTitle" style="text-align:center;">Figure 2 — XML code</p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
     .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
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
          
          
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <sourcecode id="_" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="_">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="_">1</semx>
                   </fmt-xref-label>
                   puts "Hello, world."
                   <callout target="A">1</callout>
                   <callout target="B">2</callout>
                   %w{a b c}.each do |x| puts x
                   <callout target="C">3</callout>
                   end
                   <annotation original-id="A" id="_">
                      <p original-id="_">
                         This is
                         <em>one</em>
                         callout
                      </p>
                   </annotation>
                   <annotation original-id="B" id="_">
                      <p original-id="_">This is another callout</p>
                   </annotation>
                   <annotation original-id="C" id="_">
                      <p original-id="_">This is yet another callout</p>
                   </annotation>
                   <fmt-sourcecode autonum="1">
                         puts "Hello, world."
                         <span class="c">
                            <callout target="A">1</callout>
                         </span>
                         <span class="c">
                            <callout target="B">2</callout>
                         </span>
                         %w{a b c}.each do |x| puts x
                         <span class="c">
                            <callout target="C">3</callout>
                         </span>
                         end
                         <dl>
                            <name id="_">Key</name>
                            <fmt-name>
                               <semx element="name" source="_">Key</semx>
                            </fmt-name>
                            <dt id="A">
                               <span class="c">1</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">
                                     This is
                                     <em>one</em>
                                     callout
                                  </p>
                               </semx>
                            </dd>
                            <dt id="B">
                               <span class="c">2</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">This is another callout</p>
                               </semx>
                            </dd>
                            <dt id="C">
                               <span class="c">3</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">This is yet another callout</p>
                               </semx>
                            </dd>
                         </dl>
                   </fmt-sourcecode>
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
               <pre id="_" class="sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span><span class="c"> &lt;2&gt;</span> <br/>   %w{a b c}.each do |x|<br/>     puts x <span class="c"> &lt;3&gt;</span><br/>   end</pre>
                       <div class="annotation">
                       <div class="figdl">
          <p class="ListTitle">Key</p>
          <dl>
            <dt id="A">
              <span class="c">1</span>
            </dt>
            <dd>
              <p>This is <i>one</i> callout</p>
            </dd>
            <dt id="B">
              <span class="c">2</span>
            </dt>
            <dd>
              <p>This is another callout</p>
            </dd>
            <dt id="C">
              <span class="c">3</span>
            </dt>
            <dd>
              <p>This is yet another callout</p>
            </dd>
          </dl>
          </div>
        </div>
               <p class="SourceTitle" style="text-align:center;">Figure 1</p>
             </div>
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
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_" class="Sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span><span class="c"> &lt;2&gt;</span> <br/>   %w{a b c}.each do |x|<br/>     puts x <span class="c"> &lt;3&gt;</span><br/>   end</p>
                 <div class="annotation">
          <p class="ListTitle">Key</p>
          <table class="dl">
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">1</span>
                </p>
              </td>
              <td valign="top">
                <p>This is <i>one</i> callout</p>
              </td>
            </tr>
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">2</span>
                </p>
              </td>
              <td valign="top">
                <p>This is another callout</p>
              </td>
            </tr>
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">3</span>
                </p>
              </td>
              <td valign="top">
                <p>This is yet another callout</p>
              </td>
            </tr>
                  <tr>
                     <td colspan="2"/>
                  </tr>
          </table>
        </div>
                 <p class="SourceTitle" style="text-align:center;">Figure 1</p>
               </div>
               <p> </p>
             </div>
             <p class="section-break">
               <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
             </div>
           </body>
         </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
     .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(doc)
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
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
             <foreword displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <sourcecode id="_" linenums="true" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="_">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="_">1</semx>
                   </fmt-xref-label>
                   puts "Hello, world."
                   <callout target="A">1</callout>
                   <callout target="B">2</callout>
                   %w{a b c}.each do |x| puts x
                   <callout target="C">3</callout>
                   end
                   <annotation original-id="A" id="_">
                      <p original-id="_">
                         This is
                         <em>one</em>
                         callout
                      </p>
                   </annotation>
                   <annotation original-id="B" id="_">
                      <p original-id="_">This is another callout</p>
                   </annotation>
                   <annotation original-id="C" id="_">
                      <p original-id="_">This is yet another callout</p>
                   </annotation>
                   <fmt-sourcecode linenums="true" autonum="1">
                         <table class="rouge-line-table">
                            <tbody>
                               <tr id="line-1" class="lineno">
                                  <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                                     <pre>1</pre>
                                  </td>
                                  <td class="rouge-code">
                                     <sourcecode>
                                        puts "Hello, world."
                                        <span class="c">
                                           <callout target="A">1</callout>
                                        </span>
                                        <span class="c">
                                           <callout target="B">2</callout>
                                        </span>
                                     </sourcecode>
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
                                     <sourcecode>
                                        puts x
                                        <span class="c">
                                           <callout target="C">3</callout>
                                        </span>
                                     </sourcecode>
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
                         <dl>
                            <name id="_">Key</name>
                            <fmt-name>
                               <semx element="name" source="_">Key</semx>
                            </fmt-name>
                            <dt id="A">
                               <span class="c">1</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">
                                     This is
                                     <em>one</em>
                                     callout
                                  </p>
                               </semx>
                            </dd>
                            <dt id="B">
                               <span class="c">2</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">This is another callout</p>
                               </semx>
                            </dd>
                            <dt id="C">
                               <span class="c">3</span>
                            </dt>
                            <dd>
                               <semx element="annotation" source="_">
                                  <p original-id="_">This is yet another callout</p>
                               </semx>
                            </dd>
                         </dl>
                   </fmt-sourcecode>
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
               <div id="_" class="sourcecode"><table class="rouge-line-table" style=""><tbody><tr><td style="" class="rouge-gutter gl"><pre>1</pre></td><td style="" class="rouge-code"><pre class="sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span>  <span class="c"> &lt;2&gt;</span> </pre>
                      </td></tr><tr><td style="" class="rouge-gutter gl"><pre>2</pre></td><td style="" class="rouge-code"><pre class="sourcecode">   %w{a b c}.each do |x|</pre></td></tr><tr><td style="" class="rouge-gutter gl"><pre>3</pre></td><td style="" class="rouge-code"><pre class="sourcecode">     puts x <span class="c"> &lt;3&gt;</span> </pre></td></tr><tr><td style="" class="rouge-gutter gl"><pre>4</pre></td><td style="" class="rouge-code"><pre class="sourcecode">   end</pre></td></tr></tbody></table></div>
                              <div class="annotation">
                              <div class="figdl">
          <p class="ListTitle">Key</p>
          <dl>
            <dt id="A">
              <span class="c">1</span>
            </dt>
            <dd>
              <p>This is <i>one</i> callout</p>
            </dd>
            <dt id="B">
              <span class="c">2</span>
            </dt>
            <dd>
              <p>This is another callout</p>
            </dd>
            <dt id="C">
              <span class="c">3</span>
            </dt>
            <dd>
              <p>This is yet another callout</p>
            </dd>
          </dl>
          </div>
        </div>
               <p class="SourceTitle" style="text-align:center;">Figure 1</p>
             </div>
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
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="_" class="Sourcecode"><div align="center" class="table_container"><table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;"><tbody><tr><td style="page-break-after:avoid;" class="rouge-gutter gl"><pre>1</pre></td>
                <td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode">puts "Hello, world." <span class="c"> &lt;1&gt;</span>  <span class="c"> &lt;2&gt;</span> </p>
                     </td></tr><tr><td style="page-break-after:avoid;" class="rouge-gutter gl"><pre>2</pre></td><td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode">   %w{a b c}.each do |x|</p></td></tr><tr><td style="page-break-after:avoid;" class="rouge-gutter gl"><pre>3</pre></td><td style="page-break-after:avoid;" class="rouge-code"><p class="Sourcecode">     puts x <span class="c"> &lt;3&gt;</span> </p></td></tr><tr><td style="page-break-after:auto;" class="rouge-gutter gl"><pre>4</pre></td><td style="page-break-after:auto;" class="rouge-code"><p class="Sourcecode">   end</p></td></tr></tbody></table></div>
             </p>
                     <div class="annotation">
          <p class="ListTitle">Key</p>
          <table class="dl">
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">1</span>
                </p>
              </td>
              <td valign="top">
                <p>This is <i>one</i> callout</p>
              </td>
            </tr>
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">2</span>
                </p>
              </td>
              <td valign="top">
                <p>This is another callout</p>
              </td>
            </tr>
            <tr>
              <td valign="top" align="left">
                <p align="left" style="margin-left:0pt;text-align:left;">
                  <span class="c">3</span>
                </p>
              </td>
              <td valign="top">
                <p>This is yet another callout</p>
              </td>
            </tr>
          <tr>
                    <td colspan="2"/>
                 </tr>
          </table>
        </div>
              <p class="SourceTitle" style="text-align:center;">Figure 1</p>
            </div>
            <p> </p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
     .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
     .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "processes sourcecode with xml formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata/>
      <preface><foreword id="X">
      <sourcecode id="_" lang="ruby" linenums="true">puts "Hello, world." <callout target="A">1</callout> <callout target="B">2</callout>
         %w{a b c}.each do |x|
           <strong>puts</strong> <xref target="X">x</xref> <callout target="C">3</callout>
         end<annotation id="A">
           <p id="A1">This is <em>one</em> callout</p>
         </annotation>
         </sourcecode>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata/>
         <preface>    <clause type="toc" id="_" displayorder="1">
         <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
           <foreword id="X" displayorder="2">
                    <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
                  <sourcecode id="_" lang="ruby" linenums="true" autonum="1">
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="_">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="_">1</semx>
            </fmt-xref-label>puts "Hello, world." <callout target="A">1</callout> <callout target="B">2</callout>
         %w{a b c}.each do |x|
           <strong>puts</strong> <xref target="X">x</xref> <callout target="C">3</callout>
         end<annotation original-id="A" id="_">
           <p original-id="A1">This is <em>one</em> callout</p>
         </annotation>
         <fmt-sourcecode lang="ruby" linenums="true" autonum="1">
               <table class="rouge-line-table">
                 <tbody>
                   <tr id="line-1" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>1</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>
                         <span class="nb">puts</span>
                         <span class="s2">"Hello, world."</span>
                                           <span class="c">
                    <callout target="A">1</callout>
                  </span>
                  <span class="c">
                    <callout target="B">2</callout>
                  </span>
                       </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-2" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>2</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>
                         <span class="sx">%w{a b c}</span>
                         <span class="p">.</span>
                         <span class="nf">each</span>
                         <span class="k">do</span>
                         <span class="o">|</span>
                         <span class="n">x</span>
                         <span class="o">|</span>
                       </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-3" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>3</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>
                         <strong>
                           <span class="nb">puts</span>
                         </strong>
                         <xref target="X">
                           <span class="n">x</span>
                         </xref>
                                           <span class="c">
                    <callout target="C">3</callout>
                  </span>
                       </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-4" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>4</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode>
                         <span class="k">end</span>
                       </sourcecode>
                     </td>
                   </tr>
                   <tr id="line-5" class="lineno">
                     <td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;">
                       <pre>5</pre>
                     </td>
                     <td class="rouge-code">
                       <sourcecode/>
                     </td>
                   </tr>
                 </tbody>
               </table>
                       <dl>
                 <name id="_">Key</name>
               <fmt-name>
                     <semx element="name" source="_">Key</semx>
               </fmt-name>
          <dt id="A"><span class="c">1</span></dt>
          <dd>
                       <semx element="annotation" source="_">
                           <p original-id="A1">
                              This is
                              <em>one</em>
                              callout
                           </p>
                        </semx>
          </dd>
        </dl>
        </fmt-sourcecode>
             </sourcecode>
           </foreword>
         </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)))
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes pseudocode" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
              <preface><foreword id="fwd">
        <figure id="fig" class="pseudocode" keep-with-next="true" keep-lines-together="true"><name>Label</name><p id="_">  <strong>A</strong><br/>
              <smallcap>B</smallcap></p>
      <p id="_">  <em>C</em></p></figure>
      </preface></itu-standard>
    INPUT

    presxml = <<~OUTPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata>
              <language current="true">en</language>
           </bibdata>
           
           
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="fwd" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <figure id="fig" class="pseudocode" keep-with-next="true" keep-lines-together="true" autonum="1">
                    <name id="_">Label</name>
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Figure</span>
                          <semx element="autonum" source="fig">1</semx>
                       </span>
                       <span class="fmt-caption-delim"> — </span>
                       <semx element="name" source="_">Label</semx>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="fig">1</semx>
                    </fmt-xref-label>
                    <p original-id="_">
                         
                       <strong>A</strong>
                       <br/>
                               
                       <smallcap>B</smallcap>
                    </p>
                    <p original-id="_">
                         
                       <em>C</em>
                    </p>
                    <fmt-figure class="pseudocode" keep-with-next="true" keep-lines-together="true" autonum="1">
                          <p id="_">
                               
                             <strong>A</strong>
                             <br/>
                                     
                             <smallcap>B</smallcap>
                          </p>
                          <p id="_">
                               
                             <em>C</em>
                          </p>
                    </fmt-figure>
                 </figure>
              </foreword>
           </preface>
        </itu-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                       <div id="fwd">
                         <h1 class="ForewordTitle">Foreword</h1>
                         <div id="fig" class="pseudocode" style='page-break-after: avoid;page-break-inside: avoid;'><p id="_">&#160;&#160;<b>A</b><br/>
                 &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<span style="font-variant:small-caps;">B</span></p>
                 <p id="_">&#160;&#160;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
                       </div>
                     </div>
                   </body>
          </html>
    OUTPUT

    FileUtils.rm_f "test.doc"
    pres_output = IsoDoc::PresentationXMLConvert
      .new({ sourcehighlighter: true }
      .merge(presxml_options))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(Xml::C14n.format(File.read("test.doc")
      .gsub(%r{^.*<h1 class="ForewordTitle">Foreword</h1>}m, "")
      .gsub(%r{</div>.*}m, "</div>")))
      .to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
             <div class="pseudocode"  style='page-break-after: avoid;page-break-inside: avoid;'><a name="fig" id="fig"></a><p class="pseudocode"><a name="_" id="_"></a>&#xA0;&#xA0;<b>A</b><br/>
        &#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;<span style="font-variant:small-caps;">B</span></p>
        <p class="pseudocode" style="page-break-after:avoid;"><a name="_" id="_"></a>&#xA0;&#xA0;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Label</p></div>
      OUTPUT
  end
end
