require "spec_helper"
RSpec.describe IsoDoc do
  context "overrides localisation of numbers in MathML" do
    it "with no grouping of digits" do
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
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
            <bibdata>
               <title language="en">test</title>
               <language current="true">de</language>
            </bibdata>
            <preface>
               <clause type="toc" id="_" displayorder="1">
                  <fmt-title id="_" depth="1">Inhaltsübersicht</fmt-title>
               </clause>
               <p displayorder="2">
                  <stem type="MathML" id="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mn>...</mn>
                     </math>
                  </stem>
                  <fmt-stem type="MathML">
                     <semx element="stem" source="_">...</semx>
                  </fmt-stem>
                  <stem type="MathML" id="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mn>64212149677264515</mn>
                     </math>
                  </stem>
                  <fmt-stem type="MathML">
                     <semx element="stem" source="_">64212149677264515</semx>
                  </fmt-stem>
                  <stem type="MathML" id="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mn>642121496772.64515</mn>
                     </math>
                  </stem>
                  <fmt-stem type="MathML">
                     <semx element="stem" source="_">642121496772;64515</semx>
                  </fmt-stem>
                  <stem type="MathML" id="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mn>30000</mn>
                     </math>
                  </stem>
                  <fmt-stem type="MathML">
                     <semx element="stem" source="_">30000</semx>
                  </fmt-stem>
               </p>
            </preface>
         </iso-standard>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks
      expect(strip_guid(IsoDoc::PresentationXMLConvert
        .new({ localizenumber: "##0;###" }
        .merge(presxml_options))
          .convert("test", input, true))
          .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
        .to be_xml_equivalent_to output2
    end

    it "with grouping of digits" do
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
                       <mn>...</mn>
                    </math>
                 </stem>
                 <fmt-stem type="MathML">
                    <semx element="stem" source="_">...</semx>
                 </fmt-stem>
                 <stem type="MathML" id="_">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mn>64212149677264515</mn>
                    </math>
                 </stem>
                 <fmt-stem type="MathML">
                    <semx element="stem" source="_">6=42=12=14=96=77=26=45=15</semx>
                 </fmt-stem>
                 <stem type="MathML" id="_">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mn>642121496772.64515</mn>
                    </math>
                 </stem>
                 <fmt-stem type="MathML">
                    <semx element="stem" source="_">64=21=21=49=67=72;64$51$5</semx>
                 </fmt-stem>
                 <stem type="MathML" id="_">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mn>30000</mn>
                    </math>
                 </stem>
                 <fmt-stem type="MathML">
                    <semx element="stem" source="_">3=00=00</semx>
                 </fmt-stem>
              </p>
           </preface>
        </iso-standard>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks
      expect(strip_guid(IsoDoc::PresentationXMLConvert
    .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
        .to be_xml_equivalent_to output1
    end
  end

  context "overrides localisation of numbers in MathML" do
    let(:input) do
      <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
             <title language="en">test</title>
             </bibdata>
             <preface>
             <p id="A">
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="notation='basic'">0.0</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="notation='basic'">0.31e2</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="notation='basic'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal='.'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="digit_count='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="digit_count='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="significant='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="significant='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="precision='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal='.',notation='basic',digit_count='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',digit_count='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal='.',notation='basic',significant='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',significant='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',precision='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.11e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1100e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e22</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e20</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e-18</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal='.',notation='e',digit_count='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',digit_count='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal='.',notation='e',significant='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',significant='9'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',precision='3'">0.3274287432878432992e6</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.11e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1100e1</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e22</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e20</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
               <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e-18</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>...</mn></math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e18</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',e='EE'">0.6421214967726451564515e18</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='plus',e='EE'">0.6421214967726451564515e18</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',large_notation='nil',exponent_sign='true',e='EE'">0.6421214967726451564515e18</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e18</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e-19</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
              <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e-19</mn>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
             <msqrt>
              <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=',',notation='engineering'">0.6421214967726451564515e-19</mn>
             </msqrt>
             </math></stem>
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn data-metanorma-numberformat="locale='fr'">30000</mn></math></stem>
             </p>
        </iso-standard>
      INPUT
    end

    it "with data-metanorma-numberformat attributes and default precision" do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return({
                      fraction_group_digits: 2,
                      fraction_group: "'",
                      precision: 2,
                    }))

      output1 = <<~OUTPUT
        <p id="A" displayorder="2">
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.0</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0.00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.31e2</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">31.00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,429</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,429</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74'0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,10</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,10</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1 000 000 000 000 000 000 000,00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">10 000 000 000 000 000 000,00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3.27e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27'00'00'00e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3.27e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27'4e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,00e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,10e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,10e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,00e21</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,00e19</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,00e-19</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn>...</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">...</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">642x121x496x772x645x156</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='plus',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>+17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',large_notation='nil',exponent_sign='true',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 642,1214y967 × 10
                 <sup>15</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">642x121x496x800x000x000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,0000y0000y0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 64,2121y4960 × 10
                 <sup>-21</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,00</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <msqrt>
                    <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=',',notation='engineering'">0.6421214967726451564515e-19</mn>
                 </msqrt>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msqrt>
                       <msup>
                          <mn>64,21 × 10</mn>
                          <mn>-21</mn>
                       </msup>
                    </msqrt>
                 </math>
                 <asciimath>sqrt(0.6421214967726451564515e-19)</asciimath>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='fr'">30000</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">30\u202f000,00</semx>
           </fmt-stem>
        </p>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks

      expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
    .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
      .convert("test", input, true))
        .at("//xmlns:p[@id = 'A']").to_xml))
        .to be_xml_equivalent_to output1
    end

    it "with data-metanorma-numberformat attributes and no default precision" do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return({
                      fraction_group_digits: 2,
                      fraction_group: "'",
                    }))

      output1 = <<~OUTPUT
        <p id="A" displayorder="2">
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.0</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0.0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.31e2</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">31</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'32'87'84'32'99'2</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'32'87'84'32'99'2</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,429</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,428.74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,429</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327,000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">327 428,74'3</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1 000 000 000 000 000 000 000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">10 000 000 000 000 000 000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,00'00'00'00'00'00'00'00'00'1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3.27e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27'42'87'43e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3.27e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27'42'87'43e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">3,27'4e5</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1e21</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,0e19</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,0e-19</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn>...</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">...</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">642x121x496x772x645x156</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='plus',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>+17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',large_notation='nil',exponent_sign='true',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 642,1214y967 × 10
                 <sup>15</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">642x121x496x800x000x000</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,0000y0000y0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 64,2121y4960 × 10
                 <sup>-21</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0,00'00'00'00'00'00'00'00'00'06'42'12'14'96'8</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <msqrt>
                    <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=',',notation='engineering'">0.6421214967726451564515e-19</mn>
                 </msqrt>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msqrt>
                       <msup>
                          <mn>64,21'21'49'68 × 10</mn>
                          <mn>-21</mn>
                       </msup>
                    </msqrt>
                 </math>
                 <asciimath>sqrt(0.6421214967726451564515e-19)</asciimath>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='fr'">30000</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">30\u202f000</semx>
           </fmt-stem>
        </p>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks

      expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
    .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
            .convert("test", input, true))
        .at("//xmlns:p[@id = 'A']").to_xml))
        .to be_xml_equivalent_to output1
    end

    it "with large-notation attribute and implicit minimum and maximum" do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return({
                      fraction_group_digits: 2,
                      fraction_group: "'",
                      large_notation: "scientific",
                    }))

      output1 = <<~OUTPUT
        <p id="A" displayorder="2">
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="notation='basic'">0.0</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">0.0</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="notation='basic'">0.31e2</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">31</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="notation='basic'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,428.74'32'87'84'32'99'2</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal='.'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,428.74'32'87'84'32'99'2</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="digit_count='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,429</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="digit_count='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,428.74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="significant='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,000</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="significant='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,428.74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,428.74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal='.',notation='basic',digit_count='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,429</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',digit_count='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327 428,74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal='.',notation='basic',significant='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327,000</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',significant='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327 428,74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',precision='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">327 428,74'3</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.11e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1,1</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1100e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1,1</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e22</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1 × 10
                  <sup>21</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e20</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1,0 × 10
                  <sup>19</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e-18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1,0 × 10
                  <sup>-19</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal='.',notation='e',digit_count='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">3.27e5</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',digit_count='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">3,27'42'87'43e5</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal='.',notation='e',significant='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">3.27e5</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',significant='9'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">3,27'42'87'43e5</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',precision='3'">0.3274287432878432992e6</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">3,27'4e5</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1e0</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.11e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1,1e0</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1100e1</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">1,1e0</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e22</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1 × 10
                  <sup>21</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e20</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1,0 × 10
                  <sup>19</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e-18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  1,0 × 10
                  <sup>-19</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn>...</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">...</semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>17</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',e='EE'">0.6421214967726451564515e18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>17</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='plus',e='EE'">0.6421214967726451564515e18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>+17</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',large_notation='nil',exponent_sign='true',e='EE'">0.6421214967726451564515e18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  642,1214y967 × 10
                  <sup>15</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e18</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,42'12'14'96'8 × 10
                  <sup>17</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e-19</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>-20</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>-20</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,4212y1490y0 × 10
                  <sup>-20</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e-19</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  6,42'12'14'96'8 × 10
                  <sup>-20</sup>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <msqrt>
                     <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=',',notation='engineering'">0.6421214967726451564515e-19</mn>
                  </msqrt>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <msqrt>
                        <msup>
                           <mn>6,42'12'14'96'8 × 10</mn>
                           <mn>-20</mn>
                        </msup>
                     </msqrt>
                  </math>
                  <asciimath>sqrt(0.6421214967726451564515e-19)</asciimath>
               </semx>
            </fmt-stem>
            <stem type="MathML" id="_">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mn data-metanorma-numberformat="locale='fr'">30000</mn>
               </math>
            </stem>
            <fmt-stem type="MathML">
               <semx element="stem" source="_">30\u202f000</semx>
            </fmt-stem>
         </p>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks

      expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
        .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
        .convert("test", input, true))
        .at("//xmlns:p[@id = 'A']").to_xml))
        .to be_xml_equivalent_to output1
    end

    it "with large-notation attribute and explicit minimum and maximum" do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return({
                      fraction_group_digits: 2,
                      fraction_group: "'",
                      large_notation: "scientific",
                      large_notation_min: "1e-3",
                      large_notation_max: "1e3",
                    }))

      output1 = <<~OUTPUT
        <p id="A" displayorder="2">
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.0</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">0.0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.31e2</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">31</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="notation='basic'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27'42'87'43'28'78'43'29'92 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27'42'87'43'28'78'43'29'92 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27'4 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='basic',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'4 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1 × 10
                 <sup>21</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1,0 × 10
                 <sup>19</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='basic'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1,0 × 10
                 <sup>-19</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',digit_count='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',digit_count='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal='.',notation='e',significant='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3.27 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',significant='9'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'42'87'43 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e',precision='3'">0.3274287432878432992e6</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,27'4 × 10
                 <sup>5</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.11e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1100e1</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">1,1e0</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.1e22</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1 × 10
                 <sup>21</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e20</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1,0 × 10
                 <sup>19</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="decimal=',',group=' ',notation='e'">0.10e-18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 1,0 × 10
                 <sup>-19</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn>...</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">...</semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='plus',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>+17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',large_notation='nil',exponent_sign='true',e='EE'">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 642,1214y967 × 10
                 <sup>15</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e18</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,42'12'14'96'8 × 10
                 <sup>17</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='scientific',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="precision='7',digit_count='10',group='x',group_digits='3',decimal=',',fraction_group='y',fraction_group_digits='4',notation='engineering',exponent_sign='true',e='EE'">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,4212y1490y0 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=','">0.6421214967726451564515e-19</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 6,42'12'14'96'8 × 10
                 <sup>-20</sup>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <msqrt>
                    <mn data-metanorma-numberformat="locale='de',significant='10',group='x',group_digits='3',decimal=',',notation='engineering'">0.6421214967726451564515e-19</mn>
                 </msqrt>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msqrt>
                       <msup>
                          <mn>6,42'12'14'96'8 × 10</mn>
                          <mn>-20</mn>
                       </msup>
                    </msqrt>
                 </math>
                 <asciimath>sqrt(0.6421214967726451564515e-19)</asciimath>
              </semx>
           </fmt-stem>
           <stem type="MathML" id="_">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mn data-metanorma-numberformat="locale='fr'">30000</mn>
              </math>
           </stem>
           <fmt-stem type="MathML">
              <semx element="stem" source="_">
                 3,00'00 × 10
                 <sup>4</sup>
              </semx>
           </fmt-stem>
        </p>
      OUTPUT
      TwitterCldr.reset_locale_fallbacks

      expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
    .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
      .convert("test", input, true))
        .at("//xmlns:p[@id = 'A']").to_xml))
        .to be_xml_equivalent_to output1
    end

    it "with numbers within formulas" do
      allow_any_instance_of(IsoDoc::PresentationXMLConvert)
        .to(receive(:twitter_cldr_localiser_symbols)
        .and_return({
                      fraction_group_digits: 2,
                      fraction_group: "'",
                      precision: 2,
                    }))

      input = <<~INPUT
         <standard-document xmlns="http://riboseinc.com/isoxml">
         <bibdata>
              <title language="en">test</title>
              </bibdata>
             <sections>
             <p id="A">
              <formula id="_">
                 <stem block="true" type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mstyle displaystyle="true">
                          <mn>1</mn>
                          <mo>+</mo>
                          <mi>x</mi>
                       </mstyle>
                    </math>
                    <asciimath>1 + x</asciimath>
                 </stem>
              </formula>
              <formula id="_">
                 <stem block="true" type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mstyle displaystyle="true">
                          <mn data-metanorma-numberformat="notation='basic',exponent_sign='plus',precision='4'">2</mn>
                          <mo>+</mo>
                          <mi>x</mi>
                       </mstyle>
                    </math>
                    <asciimath>2 + x</asciimath>
                 </stem>
              </formula>
              <formula id="_">
                 <stem block="true" type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                       <mstyle displaystyle="true">
                          <mn data-metanorma-numberformat="notation='basic'">3</mn>
                          <mo>+</mo>
                          <mi>x</mi>
                       </mstyle>
                    </math>
                    <asciimath>3 + x</asciimath>
                 </stem>
              </formula>
              </p>
           </sections>
        </standard-document>
      INPUT
      output = <<~OUTPUT
        <p id="A">
            <formula id="_">
               <stem block="true" type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mstyle displaystyle="true">
                        <mn>1</mn>
                        <mo>+</mo>
                        <mi>x</mi>
                     </mstyle>
                  </math>
                  <asciimath>1 + x</asciimath>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mstyle displaystyle="true">
                           <mn>1</mn>
                           <mo>+</mo>
                           <mi>x</mi>
                        </mstyle>
                     </math>
                     <asciimath>1 + x</asciimath>
                  </semx>
               </fmt-stem>
            </formula>
            <formula id="_">
               <stem block="true" type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mstyle displaystyle="true">
                        <mn data-metanorma-numberformat="notation='basic',exponent_sign='plus',precision='4'">2</mn>
                        <mo>+</mo>
                        <mi>x</mi>
                     </mstyle>
                  </math>
                  <asciimath>2 + x</asciimath>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mstyle displaystyle="true">
                           <mn>2.00'00</mn>
                           <mo>+</mo>
                           <mi>x</mi>
                        </mstyle>
                     </math>
                     <asciimath>2 + x</asciimath>
                  </semx>
               </fmt-stem>
            </formula>
            <formula id="_">
               <stem block="true" type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mstyle displaystyle="true">
                        <mn data-metanorma-numberformat="notation='basic'">3</mn>
                        <mo>+</mo>
                        <mi>x</mi>
                     </mstyle>
                  </math>
                  <asciimath>3 + x</asciimath>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mstyle displaystyle="true">
                           <mn>3.00</mn>
                           <mo>+</mo>
                           <mi>x</mi>
                        </mstyle>
                     </math>
                     <asciimath>3 + x</asciimath>
                  </semx>
               </fmt-stem>
            </formula>
         </p>
      OUTPUT
      expect(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
        .new({ localizenumber: "#=#0;##$#" }
        .merge(presxml_options))
        .convert("test", input, true))
        .at("//xmlns:p[@id = 'A']").to_xml))
        .to be_xml_equivalent_to output
    end
  end
end
