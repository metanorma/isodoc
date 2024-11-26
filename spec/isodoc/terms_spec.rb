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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
           <fmt-title depth="1">Table of contents</fmt-title>
          </clause>
        </preface>
                  <sections>
             <terms id="H" obligation="normative" displayorder="2">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
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
                   <fmt-name>
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
                   <preferred>
                      <strong>Term2</strong>
                   </preferred>
                </term>
             </terms>
          </sections>
       </iso-standard>
    OUTPUT

    html = <<~"OUTPUT"
      #{HTML_HDR}
                   <div id="H"><h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
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
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
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
            <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource>
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
      <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
          <modification>
            <p id='_'>comment</p>
          </modification>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
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
      <termsource status="identical">
        <origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
        <origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT

    presxml = <<~PRESXML
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <terms id="terms_and_definitions" obligation="normative" displayorder="2">
                <title id="_">Terms and Definitions</title>
                <fmt-title depth="1">
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
                   <fmt-name>
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
                   <preferred>
                      <strong>paddy</strong>
                      , &lt;in agriculture, dated&gt;
                   </preferred>
                   <termsource status="modified">
                      [SOURCE:
                      <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                         ISO 7301:2011, Clause 3.1
                      </origin>
                      , modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
                   </termsource>
                   <domain hidden="true">rice</domain>
                   <definition>
                      <p id="_">
                         &lt;
                         <domain>rice</domain>
                         &gt; rice retaining its husk after threshing
                      </p>
                   </definition>
                   <termexample id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">1</semx>
                      </fmt-xref-label>
                      <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                      <ul>
                         <li>A</li>
                      </ul>
                   </termexample>
                   <termexample id="_" autonum="2">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                            <semx element="autonum" source="_">2</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                         <semx element="autonum" source="_">2</semx>
                      </fmt-xref-label>
                      <ul>
                         <li>A</li>
                      </ul>
                   </termexample>
                   <termsource status="identical">
                      [SOURCE:
                      <origin citeas="">
                         <termref base="IEV" target="xyz">t1</termref>
                      </origin>
                      — comment ;
                      <origin citeas="">
                         <termref base="IEV" target="xyz"/>
                      </origin>
                      , modified — with adjustments]
                   </termsource>
                </term>
                <term id="paddy">
                   <fmt-name>
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
                   <preferred>
                      <strong>paddy</strong>
                   </preferred>
                   <admitted>paddy rice, &lt;in agriculture&gt;</admitted>
                   <admitted>rough rice</admitted>
                   <deprecates>DEPRECATED: cargo rice</deprecates>
                   <definition>
                      <p id="_">rice retaining its husk after threshing</p>
                   </definition>
                   <termexample id="_" autonum="">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">EXAMPLE</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Example</span>
                      </fmt-xref-label>
                      <ul>
                         <li>A</li>
                      </ul>
                   </termexample>
                   <termnote id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                      <fmt-name>
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
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <termnote id="_" autonum="2">
                      <fmt-name>
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
                      <ul>
                         <li>A</li>
                      </ul>
                      <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                   </termnote>
                   <termsource status="identical">
                      [SOURCE:
                      <origin bibitemid="ISO7301" type="inline" droploc="true" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                         ISO 7301:2011, 3.1
                      </origin>
                      <origin bibitemid="ISO7301" type="inline" case="lowercase" citeas="ISO 7301:2011">
                         <locality type="clause">
                            <referenceFrom>3.1</referenceFrom>
                         </locality>
                         ISO 7301:2011, clause 3.1
                      </origin>
                      ]
                   </termsource>
                </term>
             </terms>
          </sections>
       </iso-standard>
    PRESXML

    html = <<~"OUTPUT"
      #{HTML_HDR}
             <div id="terms_and_definitions"><h1>1.&#160; Terms and Definitions</h1><p>For the purposes of this document, the following terms and definitions apply.</p><p class="TermNum" id="paddy1">1.1.</p><p class="Terms" style="text-align:left;"><b>paddy</b>, &lt;in agriculture, dated&gt;</p><p>[SOURCE: ISO&#xa0;7301:2011, Clause 3.1, modified
             &#x2014;
            The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>

        <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
        <div id="_" class="example" style="page-break-after: avoid;page-break-inside: avoid;"><p class="example-title">EXAMPLE  1</p>
          <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
          <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
          </div>
        </div>
        <div id="_" class="example"><p class="example-title">EXAMPLE  2</p>
        <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
          </div>
        </div>
        <p>[SOURCE: t1
            &#x2014;
             comment

         ;
          Termbase IEV, term ID xyz, modified
             &#x2014;
              with adjustments]</p>
        <p class="TermNum" id="paddy">1.2.</p><p class="Terms" style="text-align:left;"><b>paddy</b></p>
        <p class="AltTerms" style="text-align:left;">paddy rice, &lt;in agriculture&gt;</p>
        <p class="AltTerms" style="text-align:left;">rough rice</p>
        <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
        <p id="_">rice retaining its husk after threshing</p>
        <div id="_" class="example"><p class="example-title">EXAMPLE</p>
        <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
        </div>
        </div>
        <div id="_" class="Note" style="page-break-after: avoid;page-break-inside: avoid;"><p><span class="termnote_label">Note 1 to entry: </span> The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
        <div id="_" class="Note"><p><span class="termnote_label">Note 2 to entry: </span></p>
        <div class="ul_wrap"><ul><li>A</li></ul></div>
        <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
        <p>[SOURCE: ISO&#xa0;7301:2011, 3.1
          ISO&#xa0;7301:2011, clause 3.1]</p></div>
           </div>
         </body>
       </html>
    OUTPUT

    word = <<~"WORD"
      #{WORD_HDR}
             <div id="terms_and_definitions"><h1>1.<span style="mso-tab-count:1">&#160; </span>Terms and Definitions</h1><p>For the purposes of this document, the following terms and definitions apply.</p><p class="TermNum" id="paddy1">1.1.</p><p class="Terms" style="text-align:left;"><b>paddy</b>, &lt;in agriculture, dated&gt;</p><p>[SOURCE: ISO&#xa0;7301:2011, Clause 3.1, modified
             &#x2014;
            The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>

        <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
        <div id="_" class="example" style="page-break-after: avoid;page-break-inside: avoid;"><p class="example-title">EXAMPLE  1</p>
          <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
          <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
          </div>
        </div>
        <div id="_" class="example"><p class="example-title">EXAMPLE  2</p>
        <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
          </div>
        </div>
        <p>[SOURCE: t1
            &#x2014;
             comment

         ;
          Termbase IEV, term ID xyz, modified
             &#x2014;
              with adjustments]</p>
        <p class="TermNum" id="paddy">1.2.</p><p class="Terms" style="text-align:left;"><b>paddy</b></p>
        <p class="AltTerms" style="text-align:left;">paddy rice, &lt;in agriculture&gt;</p>
        <p class="AltTerms" style="text-align:left;">rough rice</p>
        <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
        <p id="_">rice retaining its husk after threshing</p>
        <div id="_" class="example"><p class="example-title">EXAMPLE</p>
        <div class="ul_wrap">
          <ul>
          <li>A</li>
          </ul>
        </div>
        </div>
        <div id="_" class="Note" style="page-break-after: avoid;page-break-inside: avoid;"><p class="Note"><span class="termnote_label">Note 1 to entry: </span> The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
        <div id="_" class="Note"><p class="Note"><span class="termnote_label">Note 2 to entry: </span></p>
        <div class="ul_wrap"><ul><li>A</li></ul></div>
        <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
        <p>[SOURCE: ISO&#xa0;7301:2011, 3.1
          ISO&#xa0;7301:2011, clause 3.1]</p></div>
           </div>
         </body>
       </html>
    WORD
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
      .to be_equivalent_to Xml::C14n.format(word)
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
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource>
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
      <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
      </term>
    INPUT
    presxml = <<~PRESXML
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
          <title id="_">Terms and Definitions</title>
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong>paddy</strong>
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <ol>
                   <li>
                      <p id="_">
                         &lt;
                         <domain>rice</domain>
                         &gt; rice retaining its husk after threshing
                      </p>
                   </li>
                   <li>
                      <p id="_">rice retaining its husk after threshing, mark 2</p>
                      <termsource status="modified">
                         [SOURCE:
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                            ISO 7301:2011, Clause 3.1
                         </origin>
                         , modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
                      </termsource>
                   </li>
                </ol>
             </definition>
             <termexample id="_" keep-with-next="true" keep-lines-together="true" autonum="1">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="_">1</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                   <li>A</li>
                </ul>
             </termexample>
             <termexample id="_" autonum="2">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="_">2</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">2</semx>
                </fmt-xref-label>
                <ul>
                   <li>A</li>
                </ul>
             </termexample>
             <termsource status="identical">
                [SOURCE:
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , modified — with adjustments]
             </termsource>
          </term>
       </terms>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong>paddy; muddy rice</strong>
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
          <term id="paddy2">
             <fmt-name>
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
             <preferred>
                <strong>paddy; muddy rice</strong>
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
          <term id="paddy3">
             <fmt-name>
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
             <preferred geographic-area="US">
                <strong>paddy</strong>
                , US
             </preferred>
             <preferred>
                <strong>muddy rice</strong>
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
          <term id="paddy4">
             <fmt-name>
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
             <preferred>
                <strong>paddy</strong>
                , eng
             </preferred>
             <preferred>
                <strong>muddy rice</strong>
                , fra
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
       </terms>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred geographic-area="US">
                <strong>paddy</strong>
                , m, f, sg, noun, en Latn US, /pædiː/
             </preferred>
             <preferred>
                <strong>muddy rice</strong>
                , n, noun
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
       </terms>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes IsoXML term with empty or graphical designations" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1">
      <preferred><expression><name/></expression></preferred>
      <preferred isInternational='true'><graphical-symbol><figure id='_'><pre id='_'>&lt;LITERAL&gt; FIGURATIVE</pre></figure>
                 </graphical-symbol>
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
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong/>
             </preferred>
             <preferred isInternational="true">
                <figure id="_" autonum="1">
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
                   <pre id="_">&lt;LITERAL&gt; FIGURATIVE</pre>
                </figure>
             </preferred>
             <domain hidden="true">rice</domain>
             <definition>
                <p id="_">
                   &lt;
                   <domain>rice</domain>
                   &gt; rice retaining its husk after threshing
                </p>
             </definition>
          </term>
       </terms>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
                    <termsource status='identical' type='authoritative'>
                      <origin bibitemid='ISO2191' type='inline' citeas=''>
                        <localityStack>
                          <locality type='section'>
                            <referenceFrom>1</referenceFrom>
                          </locality>
                        </localityStack>
                      </origin>
                    </termsource>
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
                <termsource status='identical' type='authoritative'>
                  <origin bibitemid='ISO2191' type='inline' citeas=''>
                    <localityStack>
                      <locality type='section'>
                        <referenceFrom>2</referenceFrom>
                      </locality>
                    </localityStack>
                  </origin>
                </termsource>
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
                    <termsource status='identical' type='authoritative'>
                      <origin bibitemid='ISO2191' type='inline' citeas=''>
                        <localityStack>
                          <locality type='section'>
                            <referenceFrom>3</referenceFrom>
                          </locality>
                        </localityStack>
                      </origin>
                    </termsource>
                  </non-verbal-representation>
                </definition>
              </term>
            </terms>
          </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
       <terms id='A' obligation='normative' displayorder='2'>
                 <title id="_">Terms and definitions</title>
          <fmt-title depth="1">
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
         <p id='B'>For the purposes of this document, the following terms and definitions apply.</p>
         <term id='term-term'>
              <fmt-name>
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
           <preferred><strong>Term</strong></preferred>
           <definition>
             <p id='C'>Definition</p>
             <termsource status='identical' type='authoritative'>[SOURCE:
               <origin bibitemid='ISO2191' type='inline' citeas=''>
                 <localityStack>
                   <locality type='section'>
                     <referenceFrom>1</referenceFrom>
                   </locality>
                 </localityStack>
                 , Section 1
               </origin>]
             </termsource>
                      <table id="D" autonum="1">
            <fmt-name>
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
           </definition>
           <termsource status='identical' type='authoritative'>[SOURCE:
             <origin bibitemid='ISO2191' type='inline' citeas=''>
               <localityStack>
                 <locality type='section'>
                   <referenceFrom>2</referenceFrom>
                 </locality>
               </localityStack>
               , Section 2
             </origin>]
           </termsource>
         </term>
         <term id='term-term-2'>
              <fmt-name>
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
           <preferred><strong>Term 2</strong></preferred>
           <definition>
                    <figure id="E" autonum="1">
            <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="E">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="E">1</semx>
            </fmt-xref-label>
               <pre id='F'>Literal</pre>
             </figure>
                     <formula id="G" autonum="1">
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
              <semx element="autonum" source="G">1</semx>
              <span class="fmt-autonum-delim">)</span>
           </fmt-xref-label>
               <stem type='MathML'>
                 <math xmlns='http://www.w3.org/1998/Math/MathML'>
                   <mi>x</mi>
                   <mo>=</mo>
                   <mi>y</mi>
                 </math>
                 <asciimath>x = y</asciimath>
               </stem>
             </formula>
             <termsource status='identical' type='authoritative'>[SOURCE:
               <origin bibitemid='ISO2191' type='inline' citeas=''>
                 <localityStack>
                   <locality type='section'>
                     <referenceFrom>3</referenceFrom>
                   </locality>
                 </localityStack>
                 , Section 3
               </origin>]
             </termsource>
           </definition>
         </term>
       </terms>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong>Second Term</strong>
                , &lt;Field, Usage Info 1&gt;
             </preferred>
             <definition>Definition 1</definition>
          </term>
          <term id="C">
             <fmt-name>
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
             <preferred language="fr" script="Latn" type="prefix">
                <strong>First Designation</strong>
             </preferred>
             <p>
                <strong>CONTRAST:</strong>
                <em>
                   <preferred>
                      <strong>Fifth Designation</strong>
                      , n
                   </preferred>
                </em>
                (
                <xref target="second">
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="second">1</semx>
                </xref>
                )
             </p>
             <p>
                <strong>SEE:</strong>
                <strong>**RELATED TERM NOT FOUND**</strong>
             </p>
             <p>
                <strong>SEE ALSO:</strong>
                <strong>**RELATED TERM NOT FOUND**</strong>
             </p>
             <definition>Definition 2</definition>
          </term>
       </terms>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
        </termsource>
        <termsource status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </termsource>
      </term></terms>
      </sections></iso-standard>
    INPUT
    output = <<~OUTPUT
       <terms id="terms_and_definitions" obligation="normative" displayorder="2">
          <title id="_">Terms and Definitions</title>
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong>paddy</strong>
             </preferred>
             <definition>
                <p id="_">rice retaining its husk after threshing</p>
             </definition>
             <termsource status="identical">
                [SOURCE:
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , adapted — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , modified — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , adapted ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , modified]
             </termsource>
          </term>
       </terms>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
          <title id="_">Terms and Definitions</title>
          <fmt-title depth="1">
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
             <fmt-name>
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
             <preferred>
                <strong>paddy</strong>
             </preferred>
             <definition>
                <p id="_">rice retaining its husk after threshing</p>
             </definition>
             <termsource status="identical">
                [QUELLE:
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , angepasst — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , geändert — with adjustments ;
                <origin citeas="">
                   <termref base="IEV" target="xyz">t1</termref>
                </origin>
                ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , angepasst ;
                <origin citeas="">
                   <termref base="IEV" target="xyz"/>
                </origin>
                , geändert]
             </termsource>
          </term>
       </terms>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
          .new(presxml_options)
          .convert("test", input.sub(%r{<language>en</language>},
                                     "<language>de</language>"), true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
           <fmt-title depth="1">
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
              <fmt-name>
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
              <preferred>
                 <strong>paddy</strong>
                 <bookmark id="b1"/>
              </preferred>
              <definition>
                 <p id="_">rice retaining its husk after threshing</p>
              </definition>
           </term>
           <term id="muddy">
              <fmt-name>
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
              <preferred>
                 <strong>muddy</strong>
                 <bookmark id="b2"/>
              </preferred>
              <definition>
                 <p id="_">rice not retaining its husk after threshing</p>
              </definition>
           </term>
        </terms>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))
      .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
