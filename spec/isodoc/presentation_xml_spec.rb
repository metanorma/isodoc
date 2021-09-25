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
    input = <<~INPUT
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
    output = <<~OUTPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <title language='en'>test</title>
        </bibdata>
        <preface>
          <p displayorder="1">
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
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
            <p displayorder="1">
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
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return(additional_symbols))
    end

    it "Supports twitter_cldr_localiser_symbols fraction options" do
      expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
        .convert("test", input, true))
        .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
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
          <p displayorder="1">
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
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
               <p displayorder="1">
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
  end

  it "resolve address components" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <contributor>
                 <role type='author'/>
                 <person>
                   <name>
                     <completename>Fred Flintstone</completename>
                   </name>
                   <affiliation>
                     <organization>
                       <name>Slate Rock and Gravel Company</name>
                       <address>
                         <street>1 Infinity Loop</street>
                         <city>Cupertino</city>
                         <state>CA</state>
                         <country>USA</country>
                         <postcode>95014</postcode>
                       </address>
                     </organization>
                   </affiliation>
                 </person>
               </contributor>
      </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <contributor>
            <role type='author'/>
            <person>
              <name>
                <completename>Fred Flintstone</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Slate Rock and Gravel Company</name>
                  <address>
                    <formattedAddress>
                      1 Infinity Loop
                      <br/>
                      Cupertino
                      <br/>
                      CA
                      <br/>
                      USA 95014
                    </formattedAddress>
                  </address>
                </organization>
              </affiliation>
            </person>
          </contributor>
        </bibdata>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
  end

  it "strips variant-title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
               <sections>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <p id='_'>Text</p>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Subclause</title>
               <variant-title variant_title='true' type='sub' id='_'>&#8220;A&#8221; &#8216;B&#8217;</variant-title>
               <variant-title variant_title='true' type='toc' id='_'>
                 Clause
                 <em>A</em>
                 <stem type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mi>x</mi>
                   </math>
                 </stem>
               </variant-title>
               <p id='_'>Text</p>
             </clause>
           </clause>
         </sections>
         <annex id='_' inline-header='false' obligation='normative'>
           <title>Clause</title>
           <variant-title variant_title='true' type='toc' id='_'>
             Clause
             <em>A</em>
             <stem type='MathML'>
               <math xmlns='http://www.w3.org/1998/Math/MathML'>
                 <mi>x</mi>
               </math>
             </stem>
           </variant-title>
           <p id='_'>Text</p>
         </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
      <bibdata/>
      <sections>
        <clause id='_' inline-header='false' obligation='normative' displayorder='1'>
          <title depth='1'>
            <strong>Annex A</strong>
            <br/>
            (normative).
            <tab/>
            Clause
          </title>
          <p id='_'>Text</p>
          <clause id='_' inline-header='false' obligation='normative'>
            <title depth='1'>
              <strong>Annex A</strong>
              <br/>
              (normative).
              <tab/>
              Subclause
            </title>
        <variant-title variant_title='true' type='sub' id='_'>&#x201C;A&#x201D; &#x2018;B&#x2019;</variant-title>
            <p id='_'>Text</p>
          </clause>
        </clause>
      </sections>
      <annex id='_' inline-header='false' obligation='normative' displayorder='2'>
        <title>
          <strong>Annex A</strong>
          <br/>
          (normative)
          <br/>
          <br/>
          <strong>Clause</strong>
        </title>
        <p id='_'>Text</p>
      </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
  end

  it "duplicates EMF and SVG files" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <figure id="B">
               <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"/>
               <image src="spec/assets/odf.emf" mimetype="image/x-emf" alt="2"/>
               <image src="data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPjxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz48L3N2Zz4=" mimetype="image/svg+xml" alt="3"/>
               <image src="data:application/x-msmetafile;base64,AQAAAMgAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAJAQAACgAAAACAAAALgAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADAAIAAoADQAMAAzADUAYQA0AGYALAAgADIAMAAyADAALQAwADUALQAwADEAKQAgAAAAbwBkAGYALgBlAG0AZgAAAAAAAAARAAAADAAAAAEAAAAkAAAAJAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAIAAABGAAAALAAAACAAAABTY3JlZW49MTAyMDV4MTMxODFweCwgMjE2eDI3OW1tAEYAAAAwAAAAIwAAAERyYXdpbmc9MTAwLjB4MTAwLjBweCwgMjYuNXgyNi41bW0AABIAAAAMAAAAAQAAABMAAAAMAAAAAgAAABYAAAAMAAAAGAAAABgAAAAMAAAAAAAAABQAAAAMAAAADQAAACcAAAAYAAAAAQAAAAAAAAAAAJkABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACkBAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACkBAAAqAMAAKgDAACkBAAAcQIAAKQEAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAOgEAAKQEAAA/AAAAqAMAAD8AAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAD8AAAA6AQAAOgEAAD8AAABxAgAAPwAAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACoAwAAPwAAAKQEAAA6AQAApAQAAHECAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAAJwAAABgAAAABAAAAAAAAAP///wAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAJ0BAABFAQAANgAAABAAAADPAwAARQEAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABfBAAA7QEAAGQEAADjAgAA2wMAAJEDAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAUgMAAD4EAABhAgAAcwQAAJ0BAAAOBAAANgAAABAAAACdAQAAyQIAADYAAAAQAAAA4gIAAMkCAAA2AAAAEAAAAOICAAAaAgAANgAAABAAAACdAQAAGgIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAOAAAAFAAAAAAAAAAAAAAAJAQAAA==" mimetype="image/x-emf" alt="4"/>
             </figure>
           </clause>
         </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0"?>
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata/>
        <sections>
           <clause id="A" inline-header="false" obligation="normative" displayorder="1">
             <title depth="1">1.<tab/>Clause</title>
             <figure id="B"><name>Figure 1</name>
               <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"><emf src="spec/assets/odf.emf"/></image>
               <image src="" mimetype="image/svg+xml" alt="2">
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
      <g transform="translate(-0.0000, -0.0000)">
      <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
      <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
      <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
      </g>
      </g>
      </svg>
      <emf src="data:application/x-msmetafile;base64"/></image>
      <image src="" mimetype="image/svg+xml" alt="3"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle fill="#009" r="45" cx="50" cy="50"/><path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/></svg><emf src="data:application/x-msmetafile;base64"/></image>
               <image src="" mimetype="image/svg+xml" alt="4">
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
      <g transform="translate(-0.0000, -0.0000)">
      <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
      <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
      <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
      </g>
      </g>
      </svg>
      <emf src="data:application/x-msmetafile;base64"/></image>
             </figure>
           </clause>
         </sections>
      </iso-standard>
    OUTPUT
    expect(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))
      .to be_equivalent_to (output)
  end

  private

  def mock_symbols
    allow_any_instance_of(::IsoDoc::PresentationXMLConvert)
      .to receive(:twitter_cldr_localiser_symbols).and_return(group: "'")
  end
end
