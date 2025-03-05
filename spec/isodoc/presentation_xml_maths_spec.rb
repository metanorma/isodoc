require "spec_helper"
RSpec.describe IsoDoc do
  it "propagates boldface into MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
                <preface><foreword>
                <note>
                <strong><stem type="MathML">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <mfenced open="[" close="]">
            <mrow>
              <mi>a</mi>
              <mo>,</mo>
              <mi>b</mi>
            </mrow>
          </mfenced>
        </math>
        <asciimath>[a,b]</asciimath>
      </stem></strong>
      <stem type="MathML">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <mfenced open="[" close="]">
            <mrow>
              <mi>a</mi>
              <mo>,</mo>
              <mi>b</mi>
            </mrow>
          </mfenced>
        </math>
        <asciimath>[a,b]</asciimath>
      </stem>
            </note>
                </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="_" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <note>
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">NOTE</span>
                       </span>
                       <span class="fmt-label-delim">
                          <tab/>
                       </span>
                    </fmt-name>
                    <strong>
                       <stem type="MathML" id="_">
                          <math xmlns="http://www.w3.org/1998/Math/MathML">
                             <mfenced open="[" close="]">
                                <mrow>
                                   <mi>a</mi>
                                   <mo>,</mo>
                                   <mi>b</mi>
                                </mrow>
                             </mfenced>
                          </math>
                          <asciimath>[a,b]</asciimath>
                       </stem>
                       <fmt-stem type="MathML">
                          <semx element="stem" source="_">
                             <math xmlns="http://www.w3.org/1998/Math/MathML">
                                <mstyle mathvariant="bold">
                                   <mfenced open="[" close="]">
                                      <mrow>
                                         <mi>a</mi>
                                         <mo>,</mo>
                                         <mi>b</mi>
                                      </mrow>
                                   </mfenced>
                                </mstyle>
                             </math>
                             <asciimath>[a,b]</asciimath>
                          </semx>
                       </fmt-stem>
                    </strong>
                    <stem type="MathML" id="_">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                          <mfenced open="[" close="]">
                             <mrow>
                                <mi>a</mi>
                                <mo>,</mo>
                                <mi>b</mi>
                             </mrow>
                          </mfenced>
                       </math>
                       <asciimath>[a,b]</asciimath>
                    </stem>
                    <fmt-stem type="MathML">
                       <semx element="stem" source="_">
                          <math xmlns="http://www.w3.org/1998/Math/MathML">
                             <mfenced open="[" close="]">
                                <mrow>
                                   <mi>a</mi>
                                   <mo>,</mo>
                                   <mi>b</mi>
                                </mrow>
                             </mfenced>
                          </math>
                          <asciimath>[a,b]</asciimath>
                       </semx>
                    </fmt-stem>
                 </note>
              </foreword>
           </preface>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes line breaks in MathML" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections><clause>
      <formula id="_68a2b111-3543-80c0-2547-52e466ca633c"><stem type="MathML" block="true"><math xmlns="http://www.w3.org/1998/Math/MathML">
        <mstyle displaystyle="true">
          <mi>x</mi>
          <mo>=</mo>
          <mo linebreak="newline"/>
          <mi>y</mi>
        </mstyle>
      </math>
      <asciimath>x = \
      y</asciimath></stem></formula>
      </clause></sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="_" displayorder="2">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">1</semx>
                 </fmt-xref-label>
                 <formula id="_" autonum="1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-autonum-delim">(</span>
                          1
                          <span class="fmt-autonum-delim">)</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <fmt-xref-label container="_">
                       <span class="fmt-xref-container">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="_">1</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <stem type="MathML" block="true" id="_">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                          <mstyle displaystyle="true">
                             <mi>x</mi>
                             <mo>=</mo>
                             <mo linebreak="newline"/>
                             <mi>y</mi>
                          </mstyle>
                       </math>
                       <asciimath>x = y</asciimath>
                    </stem>
                    <fmt-stem type="MathML">
                       <semx element="stem" source="_">
                          <math xmlns="http://www.w3.org/1998/Math/MathML">
                             <mstyle displaystyle="true">
                                <mi>x</mi>
                                <mo>=</mo>
                                <mo linebreak="newline"/>
                                <mi>y</mi>
                             </mstyle>
                          </math>
                          <asciimath>x = y</asciimath>
                       </semx>
                    </fmt-stem>
                 </formula>
              </clause>
           </sections>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <div id="_">
               <h1>1.</h1>
               <div id="_">
                 <div class="formula">
                    <p><span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>x</mi><mo>=</mo><mo linebreak="newline"/><mi>y</mi></mstyle></math></span>  (1)</p>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
              <p> </p>
     </div>
     <p class="section-break">
        <br clear="all" class="section"/>
     </p>
     <div class="WordSection3">
             <div id="_">
               <h1>1.</h1>
               <div id="_">
                 <div class="formula">
                 <p><span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>x</mi><mo>=</mo><mo linebreak="newline"/><mi>y</mi></mstyle></math></span><span style="mso-tab-count:1">  </span>(1)</p>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
