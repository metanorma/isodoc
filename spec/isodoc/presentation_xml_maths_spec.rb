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
    output = <<~OUTPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <title language='en'>test</title>
        </bibdata>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
          <p displayorder="2">
            64,212,149,677,264,515
            642,121,496,772,645.15 30,000
            <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1,000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1,000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math><asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath></stem></p>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  context "when twitter_cldr_localiser_symbols has additional options" do
    let(:input) do
      <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <title language="en">test</title>
          </bibdata>
          <preface>
            <p>
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
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
                    <mn>459384.123456789</mn>
                    <mo>−</mo>
                    <mi>j</mi>
                  </mrow>
                </mrow>
              </msup>
            </math></stem>
          </p>
          </preface>
        </iso-standard>
      INPUT
    end
    let(:output) do
      <<~OUTPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
          <bibdata>
            <title language='en'>test</title>
          </bibdata>

          <preface>
              <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
            <p displayorder="2">
              30,000
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1,000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1,000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.00'3</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>459,384.12'34'56</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math><asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j) (1 - p)^(459384.123456789 - j)</asciimath></stem>
            </p>
          </preface>
        </iso-standard>
      OUTPUT
    end
    let(:additional_symbols) do
      {
        fraction_group_digits: 2,
        fraction_group: "'",
        precision: 5,
      }
    end

    before do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return(additional_symbols))
    end

    it "Supports twitter_cldr_localiser_symbols fraction options" do
      expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true))
        .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
        .to(be_equivalent_to(xmlpp(output)))
    end
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
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <title language='en'>test</title>
          <language current='true'>fr</language>
        </bibdata>
        <preface>
            <clause type="toc" id="_" displayorder="1">
          <title depth="1">Sommaire</title>
          </clause>
          <p displayorder="2">
            30&#x202F;000
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1 000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1 000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1,003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math><asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath></stem></p>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "customises localisation of numbers" do
    mock_symbols
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
           <title language="en">test</title>
           <language>fr</language>
           </bibdata>
           <preface>
           <p><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>0.0000032</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
           </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
             <bibdata>
               <title language='en'>test</title>
               <language current='true'>fr</language>
             </bibdata>

             <preface>
                 <clause type="toc" id="_" displayorder="1"> <title depth="1">Sommaire</title> </clause>
               <p displayorder="2">
                 30'000
                 <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1'000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1'000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>0,0000032</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1,003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math><asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (0.0000032 - p)^(1.003 - j)</asciimath></stem></p>
             </preface>
           </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  context "overrides localisation of numbers in MathML" do
    it "overrides localisation of numbers in MathML, with no grouping of digits" do
      input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
             <title language="en">test</title>
             <language>de</language>
             </bibdata>
             <preface>
             <p>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>...</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>64212149677264515</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>642121496772.64515</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
             </preface>
        </iso-standard>
      INPUT
      output2 = <<~OUTPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <bibdata>
             <title language='en'>test</title>
             <language current='true'>de</language>
           </bibdata>

           <preface>
              <clause type="toc" id="_" displayorder="1"> <title depth="1">Inhaltsübersicht</title> </clause>
             <p displayorder='2'> ... 64212149677264515 642121496772;64515 30000 </p>
           </preface>
         </iso-standard>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks
      expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
        .new({ localizenumber: "##0;###" }
        .merge(presxml_options))
          .convert("test", input, true))
          .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
        .to be_equivalent_to xmlpp(output2)
    end
  end

  context "overrides localisation of numbers in MathML" do
    it "overrides localisation of numbers in MathML with grouping of digits" do
      input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
             <title language="en">test</title>
             </bibdata>
             <preface>
             <p>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>...</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>64212149677264515</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>642121496772.64515</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
             </preface>
        </iso-standard>
      INPUT
      output1 = <<~OUTPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
           <bibdata>
             <title language='en'>test</title>
           </bibdata>
           <preface>
              <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
             <p displayorder='2'> ... 64=212=149=677=264=515 642=121=496=772;64$51$5 30=000 </p>
           </preface>
         </iso-standard>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks
      expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
    .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
        .to be_equivalent_to xmlpp(output1)
    end
  end

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
              <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
          <foreword displayorder="2">
            <note>
              <name>NOTE</name>
              <strong>
                <stem type="MathML">
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
                </stem>
              </strong>
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
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
             <title depth="1">Table of contents</title>
           </clause>
           </preface>
                    <sections>
           <clause displayorder="2">
             <formula id="_">
               <name>1</name>
               <stem type="MathML" block="true">
                 <math-with-linebreak>
                   <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
                     <mstyle displaystyle="true">
                       <mrow>
                         <mi>x</mi>
                         <mo>=</mo>
                       </mrow>
                     </mstyle>
                   </math>
                   <asciimath>x =</asciimath>
                   <br/>
                   <math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
                     <mstyle displaystyle="true">
                       <mi>y</mi>
                     </mstyle>
                   </math>
                 </math-with-linebreak>
                 <math-no-linebreak>
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mstyle displaystyle="true">
                       <mi>x</mi>
                       <mo>=</mo>
                       <mo linebreak="newline"/>
                       <mi>y</mi>
                     </mstyle>
                   </math>
                   <asciimath>x = \\
         y</asciimath>
                 </math-no-linebreak>
                 <asciimath>x = y</asciimath>
               </stem>
             </formula>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <div>
               <h1/>
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
                 <div>
               <h1/>
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
    expect(xmlpp(strip_guid(output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(strip_guid(IsoDoc::WordConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to xmlpp(word)
  end

  private

  def mock_symbols
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:twitter_cldr_localiser_symbols).and_return(group: "'")
  end
end
