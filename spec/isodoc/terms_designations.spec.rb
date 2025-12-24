require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML term with multiple preferred terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1">
      <preferred><expression><name>paddy</name></expression></preferred>
      <preferred><expression><name>muddy rice</name></expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
      <term id="paddy2">
      <preferred><expression><name language="eng">paddy</name></expression></preferred>
      <preferred><expression><name language="eng">muddy rice</name></expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747a">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
      <term id="paddy3">
      <preferred geographic-area="US"><expression><name>paddy</name></expression></preferred>
      <preferred><expression><name>muddy rice</name></expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747b">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
            <term id="paddy4">
      <preferred><expression language="eng"><name>paddy</name></expression></preferred>
      <preferred><expression language="fra"><name>muddy rice</name></expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747c">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
                </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
         <title id="_">Terms and Definitions</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Terms and Definitions</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="terms_and_definitions">1</semx>
         </fmt-xref-label>
         <term id="paddy1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy1">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy1">1</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>paddy</name>
               </expression>
            </preferred>
            <preferred id="_">
               <expression>
                  <name>muddy rice</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>paddy</strong>
                  </semx>
                  ;
                  <semx element="preferred" source="_">
                     <strong>muddy rice</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
         <term id="paddy2">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy2">2</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy2">2</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name language="eng">paddy</name>
               </expression>
            </preferred>
            <preferred id="_">
               <expression>
                  <name language="eng">muddy rice</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>paddy</strong>
                  </semx>
                  ;
                  <semx element="preferred" source="_">
                     <strong>muddy rice</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
         <term id="paddy3">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy3">3</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy3">3</semx>
            </fmt-xref-label>
            <preferred geographic-area="US" id="_">
               <expression>
                  <name>paddy</name>
               </expression>
            </preferred>
            <preferred id="_">
               <expression>
                  <name>muddy rice</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>paddy</strong>
                     , US
                  </semx>
               </p>
               <p>
                  <semx element="preferred" source="_">
                     <strong>muddy rice</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
         <term id="paddy4">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy4">4</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy4">4</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression language="eng">
                  <name>paddy</name>
               </expression>
            </preferred>
            <preferred id="_">
               <expression language="fra">
                  <name>muddy rice</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>paddy</strong>
                     , eng
                  </semx>
               </p>
               <p>
                  <semx element="preferred" source="_">
                     <strong>muddy rice</strong>
                     , fra
                  </semx>
               </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
      </terms>
    PRESXML
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    terms_xml = Nokogiri::XML(pres_output).at("//xmlns:terms").to_xml
    expect(strip_guid(terms_xml)).to be_xml_equivalent_to presxml
  end

  it "processes IsoXML term with grammatical information" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1">
      <preferred geographic-area="US"><expression language="en" script="Latn"><name>paddy</name>
         <pronunciation>pædiː</pronunciation>
                  <grammar>
              <gender>masculine</gender>
              <gender>feminine</gender>
              <number>singular</number>
              <isPreposition>false</isPreposition>
              <isNoun>true</isNoun>
              <grammar-value>irregular declension</grammar-value>
            </grammar>
      </expression></preferred>
      <preferred><expression><name>muddy rice</name>
                        <grammar>
              <gender>neuter</gender>
              <isNoun>true</isNoun>
              <grammar-value>irregular declension</grammar-value>
            </grammar>
      </expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
                </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
         <title id="_">Terms and Definitions</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Terms and Definitions</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="terms_and_definitions">1</semx>
         </fmt-xref-label>
         <term id="paddy1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy1">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy1">1</semx>
            </fmt-xref-label>
            <preferred geographic-area="US" id="_">
               <expression language="en" script="Latn">
                  <name>paddy</name>
                  <pronunciation>pædiː</pronunciation>
                  <grammar>
                     <gender>masculine</gender>
                     <gender>feminine</gender>
                     <number>singular</number>
                     <isPreposition>false</isPreposition>
                     <isNoun>true</isNoun>
                     <grammar-value>irregular declension</grammar-value>
                  </grammar>
               </expression>
            </preferred>
            <preferred id="_">
               <expression>
                  <name>muddy rice</name>
                  <grammar>
                     <gender>neuter</gender>
                     <isNoun>true</isNoun>
                     <grammar-value>irregular declension</grammar-value>
                  </grammar>
               </expression>
            </preferred>
            <fmt-preferred>
            <p>
               <semx element="preferred" source="_">
                  <strong>paddy</strong>
                  , m, f, sg, noun, en Latn US, /pædiː/
               </semx>
            </p>
            <p>
               <semx element="preferred" source="_">
                  <strong>muddy rice</strong>
                  , n, noun
               </semx>
            </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
      </terms>
    PRESXML
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    terms_xml = Nokogiri::XML(pres_output).at("//xmlns:terms").to_xml
    expect(strip_guid(terms_xml)).to be_xml_equivalent_to presxml
  end

  it "processes IsoXML term with empty, mathematical, or graphical designations" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1">
      <preferred><expression><name/></expression></preferred>
      <preferred isInternational='true'><graphical-symbol><figure id='_'><pre id='_'>&lt;LITERAL&gt; FIGURATIVE</pre></figure>
                 </graphical-symbol>
               </preferred>
               <preferred>
                 <letter-symbol>
                   <name>
                     <stem type='MathML'>
                       <math xmlns='http://www.w3.org/1998/Math/MathML'>
                         <msub>
                           <mrow>
                             <mi>x</mi>
                           </mrow>
                           <mrow>
                             <mn>1</mn>
                           </mrow>
                         </msub>
                       </math>
                     </stem>
                   </name>
                 </letter-symbol>
               </preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
                </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
         <title id="_">Terms and Definitions</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Terms and Definitions</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="terms_and_definitions">1</semx>
         </fmt-xref-label>
         <term id="paddy1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="paddy1">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="paddy1">1</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name/>
               </expression>
            </preferred>
            <preferred isInternational="true" id="_">
               <graphical-symbol>
                  <figure autonum="1" original-id="_">
                     <pre original-id="_">&lt;LITERAL&gt; FIGURATIVE</pre>
                  </figure>
               </graphical-symbol>
            </preferred>
            <preferred id="_">
               <letter-symbol>
                  <name>
                     <stem type="MathML">
                        <math xmlns="http://www.w3.org/1998/Math/MathML">
                           <msub>
                              <mrow>
                                 <mi>x</mi>
                              </mrow>
                              <mrow>
                                 <mn>1</mn>
                              </mrow>
                           </msub>
                        </math>
                     </stem>
                  </name>
               </letter-symbol>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong/>
                  </semx>
                  ;
                  <semx element="preferred" source="_">
                     <strong>
                        <stem type="MathML" id="_">
                           <math xmlns="http://www.w3.org/1998/Math/MathML">
                              <msub>
                                 <mrow>
                                    <mi>x</mi>
                                 </mrow>
                                 <mrow>
                                    <mn>1</mn>
                                 </mrow>
                              </msub>
                           </math>
                        </stem>
                        <fmt-stem type="MathML">
                           <semx element="stem" source="_">
                              <math xmlns="http://www.w3.org/1998/Math/MathML">
                                 <mstyle mathvariant="bold">
                                    <msub>
                                       <mrow>
                                          <mi>x</mi>
                                       </mrow>
                                       <mrow>
                                          <mn>1</mn>
                                       </mrow>
                                    </msub>
                                 </mstyle>
                              </math>
                              <asciimath>mathbf(x_(1))</asciimath>
                           </semx>
                        </fmt-stem>
                     </strong>
                  </semx>
               </p>
               <p>
                  <semx element="preferred" source="_">
                     <figure id="_" autonum="1">
                        <fmt-name id="_">
                           <span class="fmt-caption-label">
                              <span class="fmt-element-name">Figure</span>
                              <semx element="autonum" source="_">1</semx>
                           </span>
                        </fmt-name>
                        <fmt-xref-label>
                           <span class="fmt-element-name">Figure</span>
                           <semx element="autonum" source="_">1</semx>
                        </fmt-xref-label>
                        <pre id="_">&lt;LITERAL&gt; FIGURATIVE</pre>
                     </figure>
                  </semx>
               </p>
            </fmt-preferred>
            <domain id="_">rice</domain>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">
                     &lt;
                     <semx element="domain" source="_">rice</semx>
                     &gt; rice retaining its husk after threshing
                  </p>
               </semx>
            </fmt-definition>
         </term>
      </terms>
    PRESXML
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    terms_xml = Nokogiri::XML(pres_output).at("//xmlns:terms").to_xml
    expect(strip_guid(terms_xml)).to be_xml_equivalent_to presxml
  end

  it "processes related terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <terms id='A' obligation='normative'>
            <title>Terms and definitions</title>
            <term id='second'>
        <preferred>
          <expression>
            <name>Second Term</name>
          </expression>
        <field-of-application>Field</field-of-application>
        <usage-info>Usage Info 1</usage-info>
        </preferred>
        <definition><verbal-definition>Definition 1</verbal-definition></definition>
      </term>
      <term id="C">
      <preferred language='fr' script='Latn' type='prefix'>
                <expression>
                  <name>First Designation</name>
                  </expression></preferred>
        <related type='contrast'>
          <preferred>
            <expression>
              <name>Fifth Designation</name>
              <grammar>
                <gender>neuter</gender>
              </grammar>
            </expression>
          </preferred>
          <xref target='second'/>
        </related>
        <related type='see'>
          <preferred>
            <expression>
              <name>Fifth Designation</name>
              <grammar>
                <gender>neuter</gender>
              </grammar>
            </expression>
          </preferred>
        </related>
        <related type='seealso'>
          <xref target='second'/>
        </related>
        <related type='contrast'>
          <preferred>
            <expression>
              <name>Fifth Designation</name>
            </expression>
          </preferred>
          <xref target='second'>Fifth Designation</xref>
        </related>
        <definition><verbal-definition>Definition 2</verbal-definition></definition>
      </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <terms id="A" obligation="normative" displayorder="2">
         <title id="_">Terms and definitions</title>
         <fmt-title depth="1" id="_">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Terms and definitions</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
         <term id="second">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="A">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="second">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="second">1</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>Second Term</name>
               </expression>
               <field-of-application id="_">Field</field-of-application>
               <usage-info id="_">Usage Info 1</usage-info>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>Second Term</strong>
                     <span class="fmt-designation-field">
                        , &lt;
                        <semx element="field-of-application" source="_">Field</semx>
                        ,
                        <semx element="usage-info" source="_">Usage Info 1</semx>
                        &gt;
                     </span>
                  </semx>
               </p>
            </fmt-preferred>
            <definition id="_">
               <verbal-definition>Definition 1</verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">Definition 1</semx>
            </fmt-definition>
         </term>
         <term id="C">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="A">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="C">2</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="C">2</semx>
            </fmt-xref-label>
            <preferred language="fr" script="Latn" type="prefix" id="_">
               <expression>
                  <name>First Designation</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>First Designation</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <related type="contrast" id="_">
               <preferred id="_">
                  <expression>
                     <name>Fifth Designation</name>
                     <grammar>
                        <gender>neuter</gender>
                     </grammar>
                  </expression>
               </preferred>
               <xref target="second"/>
            </related>
            <related type="see" id="_">
               <preferred id="_">
                  <expression>
                     <name>Fifth Designation</name>
                     <grammar>
                        <gender>neuter</gender>
                     </grammar>
                  </expression>
               </preferred>
            </related>
            <related type="seealso" id="_">
               <xref target="second"/>
            </related>
            <related type="contrast" id="_">
               <preferred id="_">
                  <expression>
                     <name>Fifth Designation</name>
                  </expression>
               </preferred>
               <xref target="second">Fifth Designation</xref>
            </related>
            <fmt-related>
               <semx element="related" source="_">
                  <p>
                     <strong>CONTRAST:</strong>
                     <em>
                        <semx element="preferred" source="_">
                           <strong>Fifth Designation</strong>
                           , n
                        </semx>
                     </em>
                     (
                     <xref target="second" id="_"/>
                     <semx element="xref" source="_">
                        <fmt-xref target="second">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="A">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="second">1</semx>
                        </fmt-xref>
                     </semx>
                     )
                  </p>
               </semx>
               <semx element="related" source="_">
                  <p>
                     <strong>SEE:</strong>
                     <strong>**RELATED TERM NOT FOUND**</strong>
                  </p>
               </semx>
               <semx element="related" source="_">
                  <p>
                     <strong>SEE ALSO:</strong>
                     <strong>**RELATED TERM NOT FOUND**</strong>
                  </p>
               </semx>
               <semx element="related" source="_">
                  <p>
                     <strong>CONTRAST:</strong>
                     <em>
                        <xref target="second" id="_">Fifth Designation</xref>
                        <semx element="xref" source="_">
                           <fmt-xref target="second">Fifth Designation</fmt-xref>
                        </semx>
                     </em>
                  </p>
               </semx>
            </fmt-related>
            <definition id="_">
               <verbal-definition>Definition 2</verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">Definition 2</semx>
            </fmt-definition>
         </term>
      </terms>
    OUTPUT
    html = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p>\u00a0</p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p>\u00a0</p>
            </div>
            <br/>
            <div class="main-section">
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <div id="A">
                  <h1>1.\u00a0 Terms and definitions</h1>
                  <p class="TermNum" id="second">1.1.</p>
                  <p class="Terms" style="text-align:left;">
                     <b>Second Term</b>
                     , &lt;Field, Usage Info 1&gt;
                  </p>
                  Definition 1
                  <p class="TermNum" id="C">1.2.</p>
                  <p class="Terms" style="text-align:left;">
                     <b>First Designation</b>
                  </p>
                  <div class="RelatedTerms" style="text-align:left;">
               <p>
                  <b>CONTRAST:</b>
                  <i>
                     <b>Fifth Designation</b>
                     , n
                  </i>
                  (
                  <a href="#second">Clause 1.1</a>
                  )
               </p>
               <p>
                  <b>SEE:</b>
                  <b>**RELATED TERM NOT FOUND**</b>
               </p>
               <p>
                  <b>SEE ALSO:</b>
                  <b>**RELATED TERM NOT FOUND**</b>
               </p>
               <p>
                  <b>CONTRAST:</b>
                  <i>
                     <a href="#second">Fifth Designation</a>
                  </i>
               </p>
            </div>
                  Definition 2
               </div>
            </div>
         </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    terms_xml = Nokogiri::XML(pres_output).at("//xmlns:terms").to_xml
    expect(strip_guid(terms_xml)).to be_xml_equivalent_to presxml

    html_output = IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(strip_guid(html_output)).to be_html5_equivalent_to html
  end
end
