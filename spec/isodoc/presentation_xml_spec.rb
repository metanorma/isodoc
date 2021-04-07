require "spec_helper"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.presentation.xml"
    IsoDoc::PresentationXMLConvert.new({ filename: "test" })
      .convert("test", <<~"INPUT", false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
  end

  it "localises numbers in MathML" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", <<~INPUT, true)).sub(%r{<localized-strings>.*</localized-strings>}m, "")).to be_equivalent_to xmlpp(<<~OUTPUT)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
             <title language="en">test</title>
             </bibdata>
             <preface>
             <p>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>64212149677264515</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>642121496772645.15</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
             </preface>
        </iso-standard>
      INPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
          <bibdata>
            <title language='en'>test</title>
          </bibdata>
          <preface>
            <p>
              64,212,149,677,264,515
              642,121,496,772,645.15 30,000
              <stem type='MathML'>
                <math xmlns='http://www.w3.org/1998/Math/MathML'>
                  <mi>P</mi>
                  <mfenced open='(' close=')'>
                    <mrow>
                      <mi>X</mi>
                      <mo>&#x2265;</mo>
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
                      <mo>&#x2211;</mo>
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
                  <mfenced open='(' close=')'>
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
                      <mfenced open='(' close=')'>
                        <mrow>
                          <mn>1</mn>
                          <mo>&#x2212;</mo>
                          <mi>p</mi>
                        </mrow>
                      </mfenced>
                    </mrow>
                    <mrow>
                      <mrow>
                        <mn>1.003</mn>
                        <mo>&#x2212;</mo>
                        <mi>j</mi>
                      </mrow>
                    </mrow>
                  </msup>
                </math>
              </stem>
            </p>
          </preface>
        </iso-standard>
      OUTPUT
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
            <p>
              30,000
              <stem type='MathML'>
                <math xmlns='http://www.w3.org/1998/Math/MathML'>
                  <mi>P</mi>
                  <mfenced open='(' close=')'>
                    <mrow>
                      <mi>X</mi>
                      <mo>&#x2265;</mo>
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
                      <mo>&#x2211;</mo>
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
                  <mfenced open='(' close=')'>
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
                      <mfenced open='(' close=')'>
                        <mrow>
                          <mn>1</mn>
                          <mo>&#x2212;</mo>
                          <mi>p</mi>
                        </mrow>
                      </mfenced>
                    </mrow>
                    <mrow>
                      <mrow>
                        <mn>1.00'3</mn>
                        <mo>&#x2212;</mo>
                        <mi>j</mi>
                      </mrow>
                    </mrow>
                  </msup>
                  <msup>
                    <mrow>
                      <mfenced open='(' close=')'>
                        <mrow>
                          <mn>1</mn>
                          <mo>&#x2212;</mo>
                          <mi>p</mi>
                        </mrow>
                      </mfenced>
                    </mrow>
                    <mrow>
                      <mrow>
                        <mn>459,384.12'34'56</mn>
                        <mo>&#x2212;</mo>
                        <mi>j</mi>
                      </mrow>
                    </mrow>
                  </msup>
                </math>
              </stem>
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
        .to(receive(:twitter_cldr_localiser_symbols).and_return(additional_symbols))
    end

    it "Supports twitter_cldr_localiser_symbols fraction options" do
      expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
        .convert("test", input, true))
        .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
        .to(be_equivalent_to(xmlpp(output)))
    end
  end

  it "localises numbers in MathML in French" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", <<~INPUT, true)).sub(%r{<localized-strings>.*</localized-strings>}m, "")).to be_equivalent_to xmlpp(<<~OUTPUT)
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
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
          <bibdata>
            <title language='en'>test</title>
            <language current='true'>fr</language>
          </bibdata>
          <preface>
            <p>
              30&#x202F;000
              <stem type='MathML'>
                <math xmlns='http://www.w3.org/1998/Math/MathML'>
                  <mi>P</mi>
                  <mfenced open='(' close=')'>
                    <mrow>
                      <mi>X</mi>
                      <mo>&#x2265;</mo>
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
                      <mo>&#x2211;</mo>
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
                      <mn>1&#x202F;000</mn>
                    </mrow>
                  </munderover>
                  <mfenced open='(' close=')'>
                    <mtable>
                      <mtr>
                        <mtd>
                          <mn>1&#x202F;000</mn>
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
                      <mfenced open='(' close=')'>
                        <mrow>
                          <mn>1</mn>
                          <mo>&#x2212;</mo>
                          <mi>p</mi>
                        </mrow>
                      </mfenced>
                    </mrow>
                    <mrow>
                      <mrow>
                        <mn>1,003</mn>
                        <mo>&#x2212;</mo>
                        <mi>j</mi>
                      </mrow>
                    </mrow>
                  </msup>
                </math>
              </stem>
            </p>
          </preface>
        </iso-standard>
      OUTPUT
  end

  it "customises localisation of numbers" do
    mock_symbols
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", <<~INPUT, true)).sub(%r{<localized-strings>.*</localized-strings>}m, "")).to be_equivalent_to xmlpp(<<~OUTPUT)
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
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
               <bibdata>
                 <title language='en'>test</title>
                 <language current='true'>fr</language>
               </bibdata>

               <preface>
                 <p>
                   30'000
                   <stem type='MathML'>
                     <math xmlns='http://www.w3.org/1998/Math/MathML'>
                       <mi>P</mi>
                       <mfenced open='(' close=')'>
                         <mrow>
                           <mi>X</mi>
                           <mo>&#x2265;</mo>
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
                           <mo>&#x2211;</mo>
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
                           <mn>1'000</mn>
                         </mrow>
                       </munderover>
                       <mfenced open='(' close=')'>
                         <mtable>
                           <mtr>
                             <mtd>
                               <mn>1'000</mn>
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
                           <mfenced open='(' close=')'>
                             <mrow>
                               <mn>0,0000032</mn>
                               <mo>&#x2212;</mo>
                               <mi>p</mi>
                             </mrow>
                           </mfenced>
                         </mrow>
                         <mrow>
                           <mrow>
                             <mn>1,003</mn>
                             <mo>&#x2212;</mo>
                             <mi>j</mi>
                           </mrow>
                         </mrow>
                       </msup>
                     </math>
                   </stem>
                 </p>
               </preface>
             </iso-standard>
      OUTPUT
  end

  private

  def mock_symbols
    allow_any_instance_of(::IsoDoc::PresentationXMLConvert).to receive(:twitter_cldr_localiser_symbols).and_return(group: "'")
  end
end
