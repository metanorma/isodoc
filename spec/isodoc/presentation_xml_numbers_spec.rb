require "spec_helper"
RSpec.describe IsoDoc do
  it "localises numbers in MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
           <title language="en">test</title>
           </bibdata>
           <preface>
           <p>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle><mn>64212149677264515</mn></mstyle></math></stem>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mn>642121496772645.15</mn></mrow></math></stem>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
           </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <title language="en">test</title>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <p displayorder="2">
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mstyle>
                        <mn>64212149677264515</mn>
                     </mstyle>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">64,212,149,677,264,515</semx>
               </fmt-stem>
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mrow>
                        <mn>642121496772645.15</mn>
                     </mrow>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">642,121,496,772,645.15</semx>
               </fmt-stem>
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mn>30000</mn>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">30,000</semx>
               </fmt-stem>
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mi>P</mi>
                     <mfenced open="(" close=")">
                        <mrow>
                           <mi>X</mi>
                           <mo>≥</mo>
                           <msub>
                              <mrow>
                                 <mi>X</mi>
                              </mrow>
                              <mrow>
                                 <mo>max</mo>
                              </mrow>
                           </msub>
                        </mrow>
                     </mfenced>
                     <mo>=</mo>
                     <munderover>
                        <mrow>
                           <mo>∑</mo>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mi>j</mi>
                              <mo>=</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mrow>
                        <mrow>
                           <mn>1000</mn>
                        </mrow>
                     </munderover>
                     <mfenced open="(" close=")">
                        <mtable>
                           <mtr>
                              <mtd>
                                 <mn>1000</mn>
                              </mtd>
                           </mtr>
                           <mtr>
                              <mtd>
                                 <mi>j</mi>
                              </mtd>
                           </mtr>
                        </mtable>
                     </mfenced>
                     <msup>
                        <mrow>
                           <mi>p</mi>
                        </mrow>
                        <mrow>
                           <mi>j</mi>
                        </mrow>
                     </msup>
                     <msup>
                        <mrow>
                           <mfenced open="(" close=")">
                              <mrow>
                                 <mn>1</mn>
                                 <mo>−</mo>
                                 <mi>p</mi>
                              </mrow>
                           </mfenced>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mn>1.003</mn>
                              <mo>−</mo>
                              <mi>j</mi>
                           </mrow>
                        </mrow>
                     </msup>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mi>P</mi>
                        <mfenced open="(" close=")">
                           <mrow>
                              <mi>X</mi>
                              <mo>≥</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mfenced>
                        <mo>=</mo>
                        <munderover>
                           <mrow>
                              <mo>∑</mo>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mi>j</mi>
                                 <mo>=</mo>
                                 <msub>
                                    <mrow>
                                       <mi>X</mi>
                                    </mrow>
                                    <mrow>
                                       <mo>max</mo>
                                    </mrow>
                                 </msub>
                              </mrow>
                           </mrow>
                           <mrow>
                              <mn>1,000</mn>
                           </mrow>
                        </munderover>
                        <mfenced open="(" close=")">
                           <mtable>
                              <mtr>
                                 <mtd>
                                    <mn>1,000</mn>
                                 </mtd>
                              </mtr>
                              <mtr>
                                 <mtd>
                                    <mi>j</mi>
                                 </mtd>
                              </mtr>
                           </mtable>
                        </mfenced>
                        <msup>
                           <mrow>
                              <mi>p</mi>
                           </mrow>
                           <mrow>
                              <mi>j</mi>
                           </mrow>
                        </msup>
                        <msup>
                           <mrow>
                              <mfenced open="(" close=")">
                                 <mrow>
                                    <mn>1</mn>
                                    <mo>−</mo>
                                    <mi>p</mi>
                                 </mrow>
                              </mfenced>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mn>1.003</mn>
                                 <mo>−</mo>
                                 <mi>j</mi>
                              </mrow>
                           </mrow>
                        </msup>
                     </math>
                     <asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath>
                  </semx>
               </fmt-stem>
            </p>
         </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="main-section">
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <p>
          <span>64,212,149,677,264,515</span>
          <span>642,121,496,772,645.15</span>
          <span>30,000</span>
                  <span class="stem">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mi>P</mi>
                        <mfenced open="(" close=")">
                           <mrow>
                              <mi>X</mi>
                              <mo>≥</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mfenced>
                        <mo>=</mo>
                        <munderover>
                           <mrow>
                              <mo>∑</mo>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mi>j</mi>
                                 <mo>=</mo>
                                 <msub>
                                    <mrow>
                                       <mi>X</mi>
                                    </mrow>
                                    <mrow>
                                       <mo>max</mo>
                                    </mrow>
                                 </msub>
                              </mrow>
                           </mrow>
                           <mrow>
                              <mn>1,000</mn>
                           </mrow>
                        </munderover>
                        <mfenced open="(" close=")">
                           <mtable>
                              <mtr>
                                 <mtd>
                                    <mn>1,000</mn>
                                 </mtd>
                              </mtr>
                              <mtr>
                                 <mtd>
                                    <mi>j</mi>
                                 </mtd>
                              </mtr>
                           </mtable>
                        </mfenced>
                        <msup>
                           <mrow>
                              <mi>p</mi>
                           </mrow>
                           <mrow>
                              <mi>j</mi>
                           </mrow>
                        </msup>
                        <msup>
                           <mrow>
                              <mfenced open="(" close=")">
                                 <mrow>
                                    <mn>1</mn>
                                    <mo>−</mo>
                                    <mi>p</mi>
                                 </mrow>
                              </mfenced>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mn>1.003</mn>
                                 <mo>−</mo>
                                 <mi>j</mi>
                              </mrow>
                           </mrow>
                        </msup>
                     </math>
                  </span>
               </p>
            </div>
         </body>
      </html>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "localises numbers in MathML in French" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
           <title language="en">test</title>
           <language>fr</language>
           </bibdata>
           <preface>
           <p><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
           </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <title language="en">test</title>
            <language current="true">fr</language>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Sommaire</fmt-title>
            </clause>
            <p displayorder="2">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn>30000</mn>
               </math>
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mi>P</mi>
                     <mfenced open="(" close=")">
                        <mrow>
                           <mi>X</mi>
                           <mo>≥</mo>
                           <msub>
                              <mrow>
                                 <mi>X</mi>
                              </mrow>
                              <mrow>
                                 <mo>max</mo>
                              </mrow>
                           </msub>
                        </mrow>
                     </mfenced>
                     <mo>=</mo>
                     <munderover>
                        <mrow>
                           <mo>∑</mo>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mi>j</mi>
                              <mo>=</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mrow>
                        <mrow>
                           <mn>1000</mn>
                        </mrow>
                     </munderover>
                     <mfenced open="(" close=")">
                        <mtable>
                           <mtr>
                              <mtd>
                                 <mn>1000</mn>
                              </mtd>
                           </mtr>
                           <mtr>
                              <mtd>
                                 <mi>j</mi>
                              </mtd>
                           </mtr>
                        </mtable>
                     </mfenced>
                     <msup>
                        <mrow>
                           <mi>p</mi>
                        </mrow>
                        <mrow>
                           <mi>j</mi>
                        </mrow>
                     </msup>
                     <msup>
                        <mrow>
                           <mfenced open="(" close=")">
                              <mrow>
                                 <mn>1</mn>
                                 <mo>−</mo>
                                 <mi>p</mi>
                              </mrow>
                           </mfenced>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mn>1.003</mn>
                              <mo>−</mo>
                              <mi>j</mi>
                           </mrow>
                        </mrow>
                     </msup>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mi>P</mi>
                        <mfenced open="(" close=")">
                           <mrow>
                              <mi>X</mi>
                              <mo>≥</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mfenced>
                        <mo>=</mo>
                        <munderover>
                           <mrow>
                              <mo>∑</mo>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mi>j</mi>
                                 <mo>=</mo>
                                 <msub>
                                    <mrow>
                                       <mi>X</mi>
                                    </mrow>
                                    <mrow>
                                       <mo>max</mo>
                                    </mrow>
                                 </msub>
                              </mrow>
                           </mrow>
                           <mrow>
                              <mn>1\\u202f000</mn>
                           </mrow>
                        </munderover>
                        <mfenced open="(" close=")">
                           <mtable>
                              <mtr>
                                 <mtd>
                                    <mn>1\\u202f000</mn>
                                 </mtd>
                              </mtr>
                              <mtr>
                                 <mtd>
                                    <mi>j</mi>
                                 </mtd>
                              </mtr>
                           </mtable>
                        </mfenced>
                        <msup>
                           <mrow>
                             <mi>p</mi>
                           </mrow>
                           <mrow>
                              <mi>j</mi>
                           </mrow>
                        </msup>
                        <msup>
                           <mrow>
                              <mfenced open="(" close=")">
                                 <mrow>
                                    <mn>1</mn>
                                    <mo>−</mo>
                                    <mi>p</mi>
                                 </mrow>
                              </mfenced>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mn>1,003</mn>
                                 <mo>−</mo>
                                 <mi>j</mi>
                              </mrow>
                           </mrow>
                        </msup>
                     </math>
                     <asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath>
                  </semx>
               </fmt-stem>
            </p>
         </preface>
      </iso-standard>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
