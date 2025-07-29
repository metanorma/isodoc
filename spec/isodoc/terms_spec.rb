require "spec_helper"

RSpec.describe IsoDoc do
  it "processes simple terms & definitions" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
        <term id="J">
        <preferred><expression><name>Term2</name></expression></preferred>
      </term>
       </terms>
       </sections>
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
            <terms id="H" obligation="normative" displayorder="2">
               <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">1</semx>
               </fmt-xref-label>
               <term id="J">
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                  </fmt-name>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="J">1</semx>
                  </fmt-xref-label>
                  <preferred id="_">
                     <expression>
                        <name>Term2</name>
                     </expression>
                  </preferred>
                  <fmt-preferred>
                     <p>
                        <semx element="preferred" source="_">
                           <strong>Term2</strong>
                        </semx>
                     </p>
                  </fmt-preferred>
               </term>
            </terms>
         </sections>
      </iso-standard>
    OUTPUT

    html = <<~"OUTPUT"
      #{HTML_HDR}
                   <div id="H"><h1>1.\\u00a0 Terms, Definitions, Symbols and Abbreviated Terms</h1>
           <p class="TermNum" id="J">1.1.</p>
             <p class="Terms" style="text-align:left;"><b>Term2</b></p>
           </div>
                 </div>
               </body>
           </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes IsoXML terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression>
      <field-of-application>in agriculture</field-of-application>
      <usage-info>dated</usage-info>
            <source status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </source>
      </preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892"  keep-with-next="true" keep-lines-together="true">
        <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <source status='identical'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'>t1</termref>
          </display-text>
          </origin>
          <modification>
            <p id='_'>comment</p>
          </modification>
        </source>
        <source status='modified'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='adapted'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'>t1</termref>
          </display-text>
          </origin>
          <modification>
            <p id='_'/>
          </modification>
        </source>
      </term>
      <term id="paddy"><preferred><expression><name>paddy</name></expression></preferred>
      <admitted><letter-symbol><name>paddy rice</name></letter-symbol>
      <field-of-application>in agriculture</field-of-application>
      </admitted>
      <admitted><expression><name>rough rice</name></expression></admitted>
      <deprecates><expression><name>cargo rice</name></expression></deprecates>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e"  keep-with-next="true" keep-lines-together="true">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
      <ul><li>A</li></ul>
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <source status="identical">
        <origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
        <origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
      </source></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT

    presxml = <<~PRESXML
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
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
                <p>For the purposes of this document, the following terms and definitions apply.</p>
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
                      <field-of-application id="_">in agriculture</field-of-application>
                      <usage-info id="_">dated</usage-info>
                      <source status="modified" id="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <modification id="_">
                            <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                         </modification>
                      </source>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                            <span class="fmt-designation-field">
                               , &lt;
                               <semx element="field-of-application" source="_">in agriculture</semx>
                               ,
                               <semx element="usage-info" source="_">dated</semx>
                               &gt;
                            </span>
                         </semx>
                         [SOURCE:
                         <semx element="source" source="_">
                            <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                            </origin>
                            <semx element="origin" source="_">
                               <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                                  <locality type="clause">
                                     <referenceFrom>3.1</referenceFrom>
                                  </locality>
                                  ISO\\u00a07301:2011, Clause 3.1
                               </fmt-origin>
                            </semx>
                            , modified —
                            <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                         </semx>
                         ]
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
                   <termexample id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="terms_and_definitions">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termexample id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">2</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy1">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="terms_and_definitions">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy1">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <source status="identical" id="_">
                      <origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </origin>
                      <modification id="_">
                         <p id="_">comment</p>
                      </modification>
                   </source>
                   <source status="modified" id="_">
                      <origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </origin>
                      <modification id="_">
                         <p original-id="_">with adjustments</p>
                      </modification>
                   </source>
                   <source status="adapted" id="_">
                      <origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </origin>
                      <modification id="_">
                         <p original-id="_"/>
                      </modification>
                   </source>
                   <fmt-termsource status="identical">
                      [SOURCE:
                      <semx element="source" source="_">
                         <origin citeas="" id="_">
                            <termref base="IEV" target="xyz">t1</termref>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin citeas="">
                               <termref base="IEV" target="xyz">t1</termref>
                            </fmt-origin>
                         </semx>
                         —
                         <semx element="modification" source="_">comment</semx>
                      </semx>
                      ;
                      <semx element="source" source="_">
                         <origin citeas="" id="_">
                            <termref base="IEV" target="xyz"/>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin citeas="">
                               <termref base="IEV" target="xyz"/>
                            </fmt-origin>
                         </semx>
                         , modified —
                         <semx element="modification" source="_">with adjustments</semx>
                      </semx>
                      ;
                      <semx element="source" source="_">
                         <origin citeas="" id="_">
                            <termref base="IEV" target="xyz">t1</termref>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin citeas="">
                               <termref base="IEV" target="xyz">t1</termref>
                            </fmt-origin>
                         </semx>
                         , adapted
                      </semx>
                      ]
                   </fmt-termsource>
                </term>
                <term id="paddy">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="terms_and_definitions">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="paddy">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="terms_and_definitions">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy">2</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>paddy</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>paddy</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <admitted id="_">
                      <letter-symbol>
                         <name>paddy rice</name>
                      </letter-symbol>
                      <field-of-application id="_">in agriculture</field-of-application>
                   </admitted>
                   <admitted id="_">
                      <expression>
                         <name>rough rice</name>
                      </expression>
                   </admitted>
                   <fmt-admitted>
                      <p>
                         <semx element="admitted" source="_">
                            paddy rice
                            <span class="fmt-designation-field">
                               , &lt;
                               <semx element="field-of-application" source="_">in agriculture</semx>
                               &gt;
                            </span>
                         </semx>
                      </p>
                      <p>
                         <semx element="admitted" source="_">rough rice</semx>
                      </p>
                   </fmt-admitted>
                   <deprecates id="_">
                      <expression>
                         <name>cargo rice</name>
                      </expression>
                   </deprecates>
                   <fmt-deprecates>
                      <p>
                         DEPRECATED:
                         <semx element="deprecates" source="_">cargo rice</semx>
                      </p>
                   </fmt-deprecates>
                   <definition id="_">
                      <verbal-definition>
                         <p original-id="_">rice retaining its husk after threshing</p>
                      </verbal-definition>
                   </definition>
                   <fmt-definition id="_">
                      <semx element="definition" source="_">
                         <p id="_">rice retaining its husk after threshing</p>
                      </semx>
                   </fmt-definition>
                   <termexample id="_" autonum="">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="terms_and_definitions">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Example</span>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                   </termexample>
                   <termnote id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            Note
                            <semx element="autonum" source="_">1</semx>
                            to entry
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="terms_and_definitions">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <termnote id="_" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            Note
                            <semx element="autonum" source="_">2</semx>
                            to entry
                         </span>
                         <span class="fmt-label-delim">: </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="paddy">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="terms_and_definitions">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="paddy">2</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            A
                         </li>
                      </ul>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <source status="identical" id="_">
                      <origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                   </source>
                   <fmt-termsource status="identical">
                      [SOURCE:
                      <semx element="source" source="_">
                         <origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO\\u00a07301:2011, 3.1
                            </fmt-origin>
                         </semx>
                         <origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011" id="_">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                         </origin>
                         <semx element="origin" source="_">
                            <fmt-origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                               ISO\\u00a07301:2011, clause 3.1
                            </fmt-origin>
                         </semx>
                      </semx>
                      ]
                   </fmt-termsource>
                </term>
             </terms>
          </sections>
       </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
      #{HTML_HDR}
                <div id="terms_and_definitions">
                   <h1>1.\\u00a0 Terms and Definitions</h1>
                   <p>For the purposes of this document, the following terms and definitions apply.</p>
                   <p class="TermNum" id="paddy1">1.1.</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                      , &lt;in agriculture, dated&gt; [SOURCE: ISO\\u00a07301:2011, Clause 3.1, modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
                   </p>
                   <p id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                   <div id="_" class="example" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p class="example-title">EXAMPLE 1</p>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="example">
                      <p class="example-title">EXAMPLE 2</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <p>[SOURCE: t1 — comment; Termbase IEV, term ID xyz, modified — with adjustments; t1, adapted]</p>
                   <p class="TermNum" id="paddy">1.2.</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p class="AltTerms" style="text-align:left;">paddy rice, &lt;in agriculture&gt;</p>
                   <p class="AltTerms" style="text-align:left;">rough rice</p>
                   <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                   <p id="_">rice retaining its husk after threshing</p>
                   <div id="_" class="example">
                      <p class="example-title">EXAMPLE</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="Note" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p>
                         <span class="termnote_label">Note 1 to entry: </span>
                         The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                      </p>
                   </div>
                   <div id="_" class="Note">
                      <p>
                         <span class="termnote_label">Note 2 to entry: </span>
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </div>
                   <p>[SOURCE: ISO\\u00a07301:2011, 3.1ISO\\u00a07301:2011, clause 3.1]</p>
                </div>
             </div>
          </body>
       </html>
    OUTPUT

    word = <<~"WORD"
      #{WORD_HDR}
               <p>\\u00a0</p>
      </div>
      <p class="section-break">
         <br clear="all" class="section"/>
      </p>
             <div class="WordSection3">
                <div id="terms_and_definitions">
                   <h1>
                      1.
                      <span style="mso-tab-count:1">\\u00a0 </span>
                      Terms and Definitions
                   </h1>
                   <p>For the purposes of this document, the following terms and definitions apply.</p>
                   <p class="TermNum" id="paddy1">1.1.</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                      , &lt;in agriculture, dated&gt; [SOURCE: ISO\\u00a07301:2011, Clause 3.1, modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
                   </p>
                   <p id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                   <div id="_" class="example" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p class="example-title">EXAMPLE 1</p>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="example">
                      <p class="example-title">EXAMPLE 2</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <p>[SOURCE: t1 — comment; Termbase IEV, term ID xyz, modified — with adjustments; t1, adapted]</p>
                   <p class="TermNum" id="paddy">1.2.</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p class="AltTerms" style="text-align:left;">paddy rice, &lt;in agriculture&gt;</p>
                   <p class="AltTerms" style="text-align:left;">rough rice</p>
                   <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                   <p id="_">rice retaining its husk after threshing</p>
                   <div id="_" class="example">
                      <p class="example-title">EXAMPLE</p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="Note" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p class="Note">
                         <span class="termnote_label">Note 1 to entry: </span>
                         The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                      </p>
                   </div>
                   <div id="_" class="Note">
                      <p class="Note">
                         <span class="termnote_label">Note 2 to entry: </span>
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li id="_">A</li>
                         </ul>
                      </div>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </div>
                   <p>[SOURCE: ISO\\u00a07301:2011, 3.1ISO\\u00a07301:2011, clause 3.1]</p>
                </div>
             </div>
          </body>
       </html>
    WORD
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "processes IsoXML term with multiple definitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747e">rice retaining its husk after threshing, mark 2</p>
      <source status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </source>
      </verbal-definition>
      </definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892"  keep-with-next="true" keep-lines-together="true">
        <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <source status='identical'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'>t1</termref>
          </display-text>
          </origin>
        </source>
        <source status='modified'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
      </term>
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
          <p>For the purposes of this document, the following terms and definitions apply.</p>
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
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>paddy</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <domain id="_">rice</domain>
             <definition id="_">
                <verbal-definition>
                   <p original-id="_">rice retaining its husk after threshing</p>
                </verbal-definition>
             </definition>
             <definition id="_">
                <verbal-definition>
                   <p original-id="_">rice retaining its husk after threshing, mark 2</p>
                   <source status="modified" id="_">
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                      </origin>
                      <modification id="_">
                         <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                      </modification>
                   </source>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <ol id="_">
                   <li id="_">
                      <semx element="definition" source="_">
                         <p id="_">
                            &lt;
                            <semx element="domain" source="_">rice</semx>
                            &gt; rice retaining its husk after threshing
                         </p>
                      </semx>
                   </li>
                   <li id="_">
                      <semx element="definition" source="_">
                         <p id="_">rice retaining its husk after threshing, mark 2</p>
                         [SOURCE:
                         <semx element="source" source="_">
                            <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                               <locality type="clause">
                                  <referenceFrom>3.1</referenceFrom>
                               </locality>
                            </origin>
                            <semx element="origin" source="_">
                               <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                                  <locality type="clause">
                                     <referenceFrom>3.1</referenceFrom>
                                  </locality>
                                  ISO\\u00a07301:2011, Clause 3.1
                               </fmt-origin>
                            </semx>
                            , modified —
                            <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                         </semx>
                         ]
                      </semx>
                   </li>
                </ol>
             </fmt-definition>
             <termexample id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="_">1</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <fmt-xref-label container="paddy1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="terms_and_definitions">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      A
                   </li>
                </ul>
             </termexample>
             <termexample id="_" autonum="2">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="_">2</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">2</semx>
                </fmt-xref-label>
                <fmt-xref-label container="paddy1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="terms_and_definitions">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="paddy1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">2</semx>
                </fmt-xref-label>
                <ul>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      A
                   </li>
                </ul>
             </termexample>
             <source status="identical" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
             </source>
             <source status="modified" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                <modification id="_">
                   <p id="_">with adjustments</p>
                </modification>
             </source>
             <fmt-termsource status="identical">
                [SOURCE:
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz">t1</termref>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </fmt-origin>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , modified —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ]
             </fmt-termsource>
          </term>
       </terms>
    PRESXML
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

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
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
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
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
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
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes IsoXML term with nonverbal definitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <sections>
            <terms id='A' obligation='normative'>
              <title>Terms and definitions</title>
              <p id='B'>For the purposes of this document, the following terms and definitions apply.</p>
              <term id='term-term'>
                <preferred>
                  <expression>
                    <name>Term</name>
                  </expression>
                </preferred>
                <definition>
                  <verbal-definition>
                    <p id='C'>Definition</p>
                    <source status='identical' type='authoritative'>
                      <origin bibitemid='ISO2191' type='inline' citeas=''>
                        <localityStack>
                          <locality type='section'>
                            <referenceFrom>1</referenceFrom>
                          </locality>
                        </localityStack>
                      </origin>
                    </source>
                  </verbal-definition>
                  <non-verbal-representation>
                    <table id='D'>
                      <thead>
                        <tr>
                          <th valign='top' align='left'>A</th>
                          <th valign='top' align='left'>B</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td valign='top' align='left'>C</td>
                          <td valign='top' align='left'>D</td>
                        </tr>
                      </tbody>
                    </table>
                  </non-verbal-representation>
                </definition>
                <source status='identical' type='authoritative'>
                  <origin bibitemid='ISO2191' type='inline' citeas=''>
                    <localityStack>
                      <locality type='section'>
                        <referenceFrom>2</referenceFrom>
                      </locality>
                    </localityStack>
                  </origin>
                </source>
              </term>
              <term id='term-term-2'>
                <preferred>
                  <expression>
                    <name>Term 2</name>
                  </expression>
                </preferred>
                <definition>
                  <non-verbal-representation>
                    <figure id='E'>
                      <pre id='F'>Literal</pre>
                    </figure>
                    <formula id='G'>
                      <stem type='MathML'>
                        <math xmlns='http://www.w3.org/1998/Math/MathML'>
                          <mi>x</mi>
                          <mo>=</mo>
                          <mi>y</mi>
                        </math>
                      </stem>
                    </formula>
                    <source status='identical' type='authoritative'>
                      <origin bibitemid='ISO2191' type='inline' citeas=''>
                        <localityStack>
                          <locality type='section'>
                            <referenceFrom>3</referenceFrom>
                          </locality>
                        </localityStack>
                      </origin>
                    </source>
                  </non-verbal-representation>
                </definition>
              </term>
            </terms>
          </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
      <terms id="A" obligation="normative" displayorder="2">
         <title id="_">Terms and definitions</title>
         <fmt-title id="_" depth="1">
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
         <p id="B">For the purposes of this document, the following terms and definitions apply.</p>
         <term id="term-term">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="A">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="term-term">1</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="term-term">1</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>Term</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>Term</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <definition id="_">
               <verbal-definition>
                  <p original-id="C">Definition</p>
                  <source status="identical" type="authoritative" id="_">
                     <origin bibitemid="ISO2191" type="inline" citeas="">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>1</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                  </source>
               </verbal-definition>
               <non-verbal-representation>
                  <table autonum="1" original-id="D">
                     <thead>
                        <tr>
                           <th valign="top" align="left">A</th>
                           <th valign="top" align="left">B</th>
                        </tr>
                     </thead>
                     <tbody>
                        <tr>
                           <td valign="top" align="left">C</td>
                           <td valign="top" align="left">D</td>
                        </tr>
                     </tbody>
                  </table>
               </non-verbal-representation>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="C">Definition</p>
                  [SOURCE:
                  <semx element="source" source="_">
                     <origin bibitemid="ISO2191" type="inline" citeas="" id="_">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>1</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                     <semx element="origin" source="_">
                        <fmt-origin bibitemid="ISO2191" type="inline" citeas="">
                           <localityStack>
                              <locality type="section">
                                 <referenceFrom>1</referenceFrom>
                              </locality>
                           </localityStack>
                           , Section 1
                        </fmt-origin>
                     </semx>
                  </semx>
                  ]
                  <table id="D" autonum="1">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Table</span>
                           <semx element="autonum" source="D">1</semx>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Table</span>
                        <semx element="autonum" source="D">1</semx>
                     </fmt-xref-label>
                     <thead>
                        <tr>
                           <th valign="top" align="left">A</th>
                           <th valign="top" align="left">B</th>
                        </tr>
                     </thead>
                     <tbody>
                        <tr>
                           <td valign="top" align="left">C</td>
                           <td valign="top" align="left">D</td>
                        </tr>
                     </tbody>
                  </table>
               </semx>
            </fmt-definition>
            <source status="identical" type="authoritative" id="_">
               <origin bibitemid="ISO2191" type="inline" citeas="">
                  <localityStack>
                     <locality type="section">
                        <referenceFrom>2</referenceFrom>
                     </locality>
                  </localityStack>
               </origin>
            </source>
            <fmt-termsource status="identical" type="authoritative">
               [SOURCE:
               <semx element="source" source="_">
                  <origin bibitemid="ISO2191" type="inline" citeas="" id="_">
                     <localityStack>
                        <locality type="section">
                           <referenceFrom>2</referenceFrom>
                        </locality>
                     </localityStack>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin bibitemid="ISO2191" type="inline" citeas="">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>2</referenceFrom>
                           </locality>
                        </localityStack>
                        , Section 2
                     </fmt-origin>
                  </semx>
               </semx>
               ]
            </fmt-termsource>
         </term>
         <term id="term-term-2">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="A">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="term-term-2">2</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="term-term-2">2</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>Term 2</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <p>
                  <semx element="preferred" source="_">
                     <strong>Term 2</strong>
                  </semx>
               </p>
            </fmt-preferred>
            <definition id="_">
               <non-verbal-representation>
                  <figure autonum="1" original-id="E">
                     <pre original-id="F">Literal</pre>
                  </figure>
                  <formula autonum="1" original-id="G">
                     <stem type="MathML">
                        <math xmlns="http://www.w3.org/1998/Math/MathML">
                           <mi>x</mi>
                           <mo>=</mo>
                           <mi>y</mi>
                        </math>
                     </stem>
                  </formula>
                  <source status="identical" type="authoritative" id="_">
                     <origin bibitemid="ISO2191" type="inline" citeas="">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>3</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                  </source>
               </non-verbal-representation>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <figure id="E" autonum="1">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <span class="fmt-element-name">Figure</span>
                           <semx element="autonum" source="E">1</semx>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Figure</span>
                        <semx element="autonum" source="E">1</semx>
                     </fmt-xref-label>
                     <pre id="F">Literal</pre>
                  </figure>
                  <formula id="G" autonum="1">
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
                        <semx element="autonum" source="G">1</semx>
                        <span class="fmt-autonum-delim">)</span>
                     </fmt-xref-label>
                     <fmt-xref-label container="term-term-2">
                        <span class="fmt-xref-container">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="A">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="term-term-2">2</semx>
                        </span>
                        <span class="fmt-comma">,</span>
                        <span class="fmt-element-name">Formula</span>
                        <span class="fmt-autonum-delim">(</span>
                        <semx element="autonum" source="G">1</semx>
                        <span class="fmt-autonum-delim">)</span>
                     </fmt-xref-label>
                     <stem type="MathML" id="_">
                        <math xmlns="http://www.w3.org/1998/Math/MathML">
                           <mi>x</mi>
                           <mo>=</mo>
                           <mi>y</mi>
                        </math>
                     </stem>
                     <fmt-stem type="MathML">
                        <semx element="stem" source="_">
                           <math xmlns="http://www.w3.org/1998/Math/MathML">
                              <mi>x</mi>
                              <mo>=</mo>
                              <mi>y</mi>
                           </math>
                           <asciimath>x = y</asciimath>
                        </semx>
                     </fmt-stem>
                  </formula>
                  [SOURCE:
                  <semx element="source" source="_">
                     <origin bibitemid="ISO2191" type="inline" citeas="" id="_">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>3</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                     <semx element="origin" source="_">
                        <fmt-origin bibitemid="ISO2191" type="inline" citeas="">
                           <localityStack>
                              <locality type="section">
                                 <referenceFrom>3</referenceFrom>
                              </locality>
                           </localityStack>
                           , Section 3
                        </fmt-origin>
                     </semx>
                  </semx>
                  ]
               </semx>
            </fmt-definition>
         </term>
      </terms>
    PRESXML
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
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
        <definition><verbal-definition>Definition 2</verbal-definition></definition>
      </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <terms id="A" obligation="normative" displayorder="2">
          <title id="_">Terms and definitions</title>
          <fmt-title id="_" depth="1">
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
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes IsoXML term with different term source statuses" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
        <source status='identical'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'>t1</termref>
          </display-text>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='adapted'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='modified'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='identical'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'>t1</termref>
          </display-text>
          </origin>
        </source>
        <source status='adapted'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
        </source>
        <source status='modified'>
          <origin citeas=''>
          <display-text>
            <termref base='IEV' target='xyz'/>
          </display-text>
          </origin>
        </source>
      </term></terms>
      </sections></iso-standard>
    INPUT
    output = <<~OUTPUT
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
          <p>For the purposes of this document, the following terms and definitions apply.</p>
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
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>paddy</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <definition id="_">
                <verbal-definition>
                   <p original-id="_">rice retaining its husk after threshing</p>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <semx element="definition" source="_">
                   <p id="_">rice retaining its husk after threshing</p>
                </semx>
             </fmt-definition>
             <source status="identical" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                <modification id="_">
                   <p id="_">with adjustments</p>
                </modification>
             </source>
             <source status="adapted" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                <modification id="_">
                   <p original-id="_">with adjustments</p>
                </modification>
             </source>
             <source status="modified" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                <modification id="_">
                   <p original-id="_">with adjustments</p>
                </modification>
             </source>
             <source status="identical" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
             </source>
             <source status="adapted" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
             </source>
             <source status="modified" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
             </source>
             <fmt-termsource status="identical">
                [SOURCE:
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz">t1</termref>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </fmt-origin>
                   </semx>
                   —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , adapted —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , modified —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz">t1</termref>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </fmt-origin>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , adapted
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , modified
                </semx>
                ]
             </fmt-termsource>
          </term>
       </terms>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
    output = <<~OUTPUT
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
             <span class="fmt-element-name">Klausel</span>
             <semx element="autonum" source="terms_and_definitions">1</semx>
          </fmt-xref-label>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
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
                <span class="fmt-element-name">Klausel</span>
                <semx element="autonum" source="terms_and_definitions">1</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="paddy1">1</semx>
             </fmt-xref-label>
             <preferred id="_">
                <expression>
                   <name>paddy</name>
                </expression>
             </preferred>
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>paddy</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <definition id="_">
                <verbal-definition>
                   <p original-id="_">rice retaining its husk after threshing</p>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <semx element="definition" source="_">
                   <p id="_">rice retaining its husk after threshing</p>
                </semx>
             </fmt-definition>
             <source status="identical" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                <modification id="_">
                   <p id="_">with adjustments</p>
                </modification>
             </source>
             <source status="adapted" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                <modification id="_">
                   <p original-id="_">with adjustments</p>
                </modification>
             </source>
             <source status="modified" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                <modification id="_">
                   <p original-id="_">with adjustments</p>
                </modification>
             </source>
             <source status="identical" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
             </source>
             <source status="adapted" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
             </source>
             <source status="modified" id="_">
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
             </source>
             <fmt-termsource status="identical">
                [QUELLE:
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz">t1</termref>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </fmt-origin>
                   </semx>
                   —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , angepasst —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , geändert —
                   <semx element="modification" source="_">with adjustments</semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz">t1</termref>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </fmt-origin>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , angepasst
                </semx>
                ;
                <semx element="source" source="_">
                   <origin citeas="" id="_">
                      <termref base="IEV" target="xyz"/>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </fmt-origin>
                   </semx>
                   , geändert
                </semx>
                ]
             </fmt-termsource>
          </term>
       </terms>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
          .new(presxml_options)
          .convert("test", input.sub(%r{<language>en</language>},
                                     "<language>de</language>"), true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  # also applies to postprocessing of indexes
  it "preserves bookmarks that are siblings rather than children of designation terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression><bookmark id="b1"/></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
      <term id="muddy"><preferred><expression><name>muddy<bookmark id="b2"/></name></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e7473">rice not retaining its husk after threshing</p></verbal-definition></definition>
      </term>
      </terms>
      </sections></iso-standard>
    INPUT
    output = <<~OUTPUT
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
         <p>For the purposes of this document, the following terms and definitions apply.</p>
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
               <bookmark original-id="b1"/>
            </preferred>
            <fmt-preferred>
            <p>
               <semx element="preferred" source="_">
                  <strong>paddy</strong>
                  <bookmark id="b1"/>
               </semx>
            </p>
            </fmt-preferred>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">rice retaining its husk after threshing</p>
               </semx>
            </fmt-definition>
         </term>
         <term id="muddy">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <semx element="autonum" source="terms_and_definitions">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="muddy">2</semx>
                  <span class="fmt-autonum-delim">.</span>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="terms_and_definitions">1</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="muddy">2</semx>
            </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>
                     muddy
                     <bookmark original-id="b2"/>
                  </name>
               </expression>
            </preferred>
            <fmt-preferred>
            <p>
               <semx element="preferred" source="_">
                  <strong>muddy</strong>
                  <bookmark id="b2"/>
               </semx>
            </p>
            </fmt-preferred>
            <definition id="_">
               <verbal-definition>
                  <p original-id="_">rice not retaining its husk after threshing</p>
               </verbal-definition>
            </definition>
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">rice not retaining its husk after threshing</p>
               </semx>
            </fmt-definition>
         </term>
      </terms>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
