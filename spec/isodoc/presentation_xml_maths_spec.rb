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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <note>
                  <fmt-name id="_">
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
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert.new(presxml_options)
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
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <clause id="_" displayorder="2">
               <fmt-title id="_" depth="1">
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
                  <fmt-name id="_">
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
                    <p><span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>x</mi><mo>=</mo><mo linebreak="newline"/><mi>y</mi></mstyle></math></span>\\u00a0 (1)</p>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
       #{WORD_HDR}
               <p>\\u00a0</p>
      </div>
      <p class="section-break">
         <br clear="all" class="section"/>
      </p>
      <div class="WordSection3">
              <div id="_">
                <h1>1.</h1>
                <div id="_">
                  <div class="formula">
                  <p><span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>x</mi><mo>=</mo><mo linebreak="newline"/><mi>y</mi></mstyle></math></span><span style="mso-tab-count:1">\\u00a0 </span>(1)</p>
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
    expect(strip_guid(Xml::C14n.format(output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "correctly parses options with commas inside values" do
    converter = IsoDoc::PresentationXMLConvert.new({})
    options = "'group_digits=3','fraction_group_digits=3','decimal=,','group= ','fraction_group= ','notation=general'"
    result = converter.numberformat_extract(options)

    expect(result).to eq({
                           group_digits: "3",
                           fraction_group_digits: "3",
                           decimal: ",",
                           group: " ",
                           fraction_group: " ",
                           notation: "general",
                         })
  end

  it "processes AsciiMath and MathML" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m="http://www.w3.org/1998/Math/MathML">
        <preface>    <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
       <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
        <p id="A">
        <stem type="AsciiMath">&lt;A&gt;</stem>
        <stem type="AsciiMath"><m:math><m:mrow>X</m:mrow></m:math><asciimath>&lt;A&gt;</asciimath></stem>
        <stem type="MathML"><m:math><m:mrow>X</m:mrow></m:math></stem>
        <stem type="LaTeX">Latex?</stem>
        <stem type="LaTeX"><asciimath>&lt;A&gt;</asciimath><latexmath>Latex?</latexmath></stem>
        <stem type="None">Latex?</stem>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
         <stem type="AsciiMath" id="_">&lt;A&gt;</stem>
         <fmt-stem type="AsciiMath">
            <semx element="stem" source="_">&lt;A&gt;</semx>
         </fmt-stem>
         <stem type="AsciiMath" id="_">
            <m:math>
               <m:mrow>X</m:mrow>
            </m:math>
            <asciimath>&lt;A&gt;</asciimath>
         </stem>
         <fmt-stem type="AsciiMath">
            <semx element="stem" source="_">
               <m:math>
                  <m:mrow>X</m:mrow>
               </m:math>
               <asciimath>&lt;A&gt;</asciimath>
            </semx>
         </fmt-stem>
         <stem type="MathML" id="_">
            <m:math>
               <m:mrow>X</m:mrow>
            </m:math>
         </stem>
         <fmt-stem type="MathML">
            <semx element="stem" source="_">
               <m:math>
                  <m:mrow>X</m:mrow>
               </m:math>
               <asciimath>X</asciimath>
            </semx>
         </fmt-stem>
         <stem type="LaTeX" id="_">Latex?</stem>
         <fmt-stem type="LaTeX">
            <semx element="stem" source="_">Latex?</semx>
         </fmt-stem>
         <stem type="LaTeX" id="_">
            <asciimath>&lt;A&gt;</asciimath>
            <latexmath>Latex?</latexmath>
         </stem>
         <fmt-stem type="LaTeX">
            <semx element="stem" source="_">
               <asciimath>&lt;A&gt;</asciimath>
               <latexmath>Latex?</latexmath>
            </semx>
         </fmt-stem>
         <stem type="None" id="_">Latex?</stem>
         <fmt-stem type="None">
            <semx element="stem" source="_">Latex?</semx>
         </fmt-stem>
      </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A">
         <span class="stem">(#(&lt;A&gt;)#)</span>
         <span class="stem">(#(&lt;A&gt;)#)</span>
         <span class="stem"><m:math xmlns:m="http://www.w3.org/1998/Math/MathML">
           <m:mrow>X</m:mrow>
         </m:math></span>
         <span class="stem">Latex?</span>
         <span class="stem">Latex?</span>
         <span class="stem">Latex?</span>
         </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "overrides AsciiMath delimiters" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
            <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
        <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
        <p id="A">
        <stem type="AsciiMath">A</stem>
        (#((Hello))#)
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
         <stem type="AsciiMath" id="_">A</stem>
         <fmt-stem type="AsciiMath">
            <semx element="stem" source="_">A</semx>
         </fmt-stem>
         (#((Hello))#)
      </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A">
      <span class="stem">(#(((A)#)))</span>
      (#((Hello))#)
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "duplicates MathML with AsciiMath" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m='http://www.w3.org/1998/Math/MathML'>
      <preface><foreword>
      <p>
      <stem type="MathML"><m:math>
        <m:msup> <m:mrow> <m:mo>(</m:mo> <m:mrow> <m:mi>x</m:mi> <m:mo>+</m:mo> <m:mi>y</m:mi> </m:mrow> <m:mo>)</m:mo> </m:mrow> <m:mn>2</m:mn> </m:msup>
      </m:math></stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' xmlns:m='http://www.w3.org/1998/Math/MathML' type='presentation'>
        <preface>
                      <clause type="toc" id="_" displayorder="1">
                 <fmt-title id="_" depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="_" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title id="_" depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
            <p>
              <stem type='MathML' id="_">
                 <m:math>
                   <m:msup>
                     <m:mrow>
                       <m:mo>(</m:mo>
                       <m:mrow>
                         <m:mi>x</m:mi>
                         <m:mo>+</m:mo>
                         <m:mi>y</m:mi>
                       </m:mrow>
                       <m:mo>)</m:mo>
                     </m:mrow>
                     <m:mn>2</m:mn>
                   </m:msup>
                   </m:math>
              </stem>
              <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 <m:math>
                    <m:msup>
                       <m:mrow>
                          <m:mo>(</m:mo>
                          <m:mrow>
                             <m:mi>x</m:mi>
                             <m:mo>+</m:mo>
                             <m:mi>y</m:mi>
                          </m:mrow>
                          <m:mo>)</m:mo>
                       </m:mrow>
                       <m:mn>2</m:mn>
                    </m:msup>
                 </m:math>
                 <asciimath>(x + y)^(2)</asciimath>
              </semx>
           </fmt-stem>
            </p>
          </foreword>
        </preface>
        <sections> </sections>
      </iso-standard>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
    .new(presxml_options)
      .convert("test", input, true)
      .gsub("<!--", "<comment>")
      .gsub("-->", "</comment>"))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "overrides duplication of MathML with AsciiMath" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml"  xmlns:m='http://www.w3.org/1998/Math/MathML'>
      <preface><foreword>
      <p>
      <stem type="MathML"><m:math>
        <m:msup> <m:mrow> <m:mo>(</m:mo> <m:mrow> <m:mi>x</m:mi> <m:mo>+</m:mo> <m:mi>y</m:mi> </m:mrow> <m:mo>)</m:mo> </m:mrow> <m:mn>2</m:mn> </m:msup>
      </m:math></stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' xmlns:m='http://www.w3.org/1998/Math/MathML' type='presentation'>
            <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                     <semx element="title" source="_">Foreword</semx>
               </fmt-title>
            <p>
              <stem type='MathML' id="_">
                 <m:math>
                   <m:msup>
                     <m:mrow>
                       <m:mo>(</m:mo>
                       <m:mrow>
                         <m:mi>x</m:mi>
                        <m:mo>+</m:mo>
                         <m:mi>y</m:mi>
                       </m:mrow>
                       <m:mo>)</m:mo>
                     </m:mrow>
                     <m:mn>2</m:mn>
                   </m:msup>
                 </m:math>
              </stem>
                     <fmt-stem type="MathML">
                      <semx element="stem" source="_">
                         <m:math>
                            <m:msup>
                               <m:mrow>
                                  <m:mo>(</m:mo>
                                  <m:mrow>
                                     <m:mi>x</m:mi>
                                     <m:mo>+</m:mo>
                                     <m:mi>y</m:mi>
                                  </m:mrow>
                                  <m:mo>)</m:mo>
                               </m:mrow>
                               <m:mn>2</m:mn>
                            </m:msup>
                         </m:math>
                      </semx>
                   </fmt-stem>
            </p>
          </foreword>
        </preface>
        <sections> </sections>
      </iso-standard>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::PresentationXMLConvert
      .new({ suppressasciimathdup: true }
      .merge(presxml_options))
      .convert("test", input, true)
      .gsub("<!--", "<comment>")
      .gsub("-->", "</comment>"))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
