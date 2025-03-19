require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    mock_uuid_increment
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title><fn reference="43"><p>C</p></fn></title>
      </bibdata>
      <boilerplate>
      <copyright-statement>
      <clause><title><fn reference="44"><p>D</p></fn><</title>
      </clause>
      </copyright-statement>
      </boilerplate>
          <preface>
          <foreword id="F"><title>Foreword</title>
          <p>A.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>C.<fn reference="1">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
      </fn></p>
          </foreword>
          </preface>
          <sections>
          <clause id="A">
          A.<fn reference="42">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Third footnote.</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          </clause>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products<fn reference="7">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">ISO is a standards organisation.</p>
      </fn></title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references>
      </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <title>
               <fn reference="1" original-reference="43" id="_7" target="_8">
                  <p>C</p>
                  <fmt-fn-label>
                     <sup>
                        <semx element="autonum" source="_7">1</semx>
                     </sup>
                  </fmt-fn-label>
               </fn>
            </title>
         </bibdata>
      #{'   '}
         <boilerplate>
            <copyright-statement>
               <clause>
                  <title id="_2">
                     <fn reference="2" original-reference="44" id="_9" target="_10">
                        <p>D</p>
                        <fmt-fn-label>
                           <sup>
                              <semx element="autonum" source="_9">2</semx>
                           </sup>
                        </fmt-fn-label>
                     </fn>
                  </title>
                  <fmt-title depth="1">
                     <semx element="title" source="_2">
                        <fn reference="2" original-reference="44" id="_11" target="_10">
                           <p>D</p>
                           <fmt-fn-label>
                              <sup>
                                 <semx element="autonum" source="_11">2</semx>
                              </sup>
                           </fmt-fn-label>
                        </fn>
                     </semx>
                  </fmt-title>
               </clause>
            </copyright-statement>
         </boilerplate>
         <preface>
            <clause type="toc" id="_1" displayorder="1">
               <fmt-title depth="1">Table of contents</fmt-title>
            </clause>
            <foreword id="F" displayorder="2">
               <title id="_4">Foreword</title>
               <fmt-title depth="1">
                  <semx element="title" source="_4">Foreword</semx>
               </fmt-title>
               <p>
                  A.
                  <fn reference="3" original-reference="2" id="_12" target="_13">
                     <p original-id="_">Formerly denoted as 15 % (m/m).</p>
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_12">3</semx>
                        </sup>
                     </fmt-fn-label>
                  </fn>
               </p>
               <p>
                  B.
                  <fn reference="3" original-reference="2" id="_14" target="_13">
                     <p id="_">Formerly denoted as 15 % (m/m).</p>
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_14">3</semx>
                        </sup>
                     </fmt-fn-label>
                  </fn>
               </p>
               <p>
                  C.
                  <fn reference="4" original-reference="1" id="_15" target="_16">
                     <p original-id="_">Hello! denoted as 15 % (m/m).</p>
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_15">4</semx>
                        </sup>
                     </fmt-fn-label>
                  </fn>
               </p>
            </foreword>
         </preface>
         <sections>
            <clause id="A" displayorder="5">
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="A">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">2</semx>
               </fmt-xref-label>
               A.
               <fn reference="6" original-reference="42" id="_21" target="_22">
                  <p original-id="_">Third footnote.</p>
                  <fmt-fn-label>
                     <sup>
                        <semx element="autonum" source="_21">6</semx>
                     </sup>
                  </fmt-fn-label>
               </fn>
            </clause>
            <p displayorder="3">
               B.
               <fn reference="3" original-reference="2" id="_17" target="_13">
                  <p id="_">Formerly denoted as 15 % (m/m).</p>
                  <fmt-fn-label>
                     <sup>
                        <semx element="autonum" source="_17">3</semx>
                     </sup>
                  </fmt-fn-label>
               </fn>
            </p>
            <references id="_normative_references" obligation="informative" normative="true" displayorder="4">
               <title id="_6">Normative References</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_normative_references">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_6">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="_normative_references">1</semx>
               </fmt-xref-label>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <bibitem id="ISO712" type="standard">
                  <formattedref>
                     International Organization for Standardization.
                     <em>
                        Cereals and cereal products
                        <fn reference="5" original-reference="7" id="_18" target="_19">
                           <p original-id="_">ISO is a standards organisation.</p>
                           <fmt-fn-label>
                              <sup>
                                 <semx element="autonum" source="_18">5</semx>
                              </sup>
                           </fmt-fn-label>
                        </fn>
                     </em>
                     .
                  </formattedref>
                  <title format="text/plain">Cereals or cereal products</title>
                  <title type="main" format="text/plain">
                     Cereals and cereal products
                     <fn reference="5" original-reference="7" id="_20" target="_19">
                        <p id="_">ISO is a standards organisation.</p>
                        <fmt-fn-label>
                           <sup>
                              <semx element="autonum" source="_20">5</semx>
                           </sup>
                        </fmt-fn-label>
                     </fn>
                  </title>
                  <docidentifier type="ISO">ISO 712</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>International Organization for Standardization</name>
                     </organization>
                  </contributor>
                  <biblio-tag>ISO 712, </biblio-tag>
               </bibitem>
            </references>
         </sections>
         <bibliography>
      </bibliography>
         <fmt-footnote-container>
            <fmt-fn-body id="_8" target="_7" reference="1">
               <semx element="fn" source="_7">
                  <p>
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_7">1</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     C
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_10" target="_9" reference="2">
               <semx element="fn" source="_9">
                  <p>
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_9">2</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     D
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_13" target="_12" reference="3">
               <semx element="fn" source="_12">
                  <p id="_">
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_12">3</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     Formerly denoted as 15 % (m/m).
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_16" target="_15" reference="4">
               <semx element="fn" source="_15">
                  <p id="_">
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_15">4</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     Hello! denoted as 15 % (m/m).
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_19" target="_18" reference="5">
               <semx element="fn" source="_18">
                  <p id="_">
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_18">5</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     ISO is a standards organisation.
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_22" target="_21" reference="6">
               <semx element="fn" source="_21">
                  <p id="_">
                     <fmt-fn-label>
                        <sup>
                           <semx element="autonum" source="_21">6</semx>
                        </sup>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     Third footnote.
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p> </p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p> </p>
            </div>
            <br/>
            <div class="main-section">
               <div class="authority">
                  <div class="boilerplate-copyright">
                     <div>
                        <h1>
                           <a class="FootnoteRef" href="#fn:_10">
                              <sup>2</sup>
                           </a>
                        </h1>
                     </div>
                  </div>
               </div>
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <br/>
               <div id="F">
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p>
                     A.
                     <a class="FootnoteRef" href="#fn:_13">
                        <sup>3</sup>
                     </a>
                  </p>
                  <p>
                     B.
                     <a class="FootnoteRef" href="#fn:_13">
                        <sup>3</sup>
                     </a>
                  </p>
                  <p>
                     C.
                     <a class="FootnoteRef" href="#fn:_16">
                        <sup>4</sup>
                     </a>
                  </p>
               </div>
               <p>
                  B.
                  <a class="FootnoteRef" href="#fn:_13">
                     <sup>3</sup>
                  </a>
               </p>
               <div>
                  <h1>1.  Normative References</h1>
                  <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                  <p id="ISO712" class="NormRef">
                     ISO 712, International Organization for Standardization.
                     <i>
                        Cereals and cereal products
                        <a class="FootnoteRef" href="#fn:_19">
                           <sup>5</sup>
                        </a>
                     </i>
                     .
                  </p>
               </div>
               <div id="A">
                  <h1>2.</h1>
                  <a class="FootnoteRef" href="#fn:_22">
                     <sup>6</sup>
                  </a>
               </div>
               <aside id="fn:_8" class="footnote">
                  <p>C</p>
               </aside>
               <aside id="fn:_10" class="footnote">
                  <p>D</p>
               </aside>
               <aside id="fn:_13" class="footnote">
                  <p id="_">Formerly denoted as 15 % (m/m).</p>
               </aside>
               <aside id="fn:_16" class="footnote">
                  <p id="_">Hello! denoted as 15 % (m/m).</p>
               </aside>
               <aside id="fn:_19" class="footnote">
                  <p id="_">ISO is a standards organisation.</p>
               </aside>
               <aside id="fn:_22" class="footnote">
                  <p id="_">Third footnote.</p>
               </aside>
            </div>
         </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
             <div class="authority">
                <div class="boilerplate-copyright">
                   <div>
                      <h1>
                         <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                            <a class="FootnoteRef" epub:type="footnote" href="#ftn_10">2</a>
                         </span>
                      </h1>
                   </div>
                </div>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_1" class="TOC">
                <p class="zzContents">Table of contents</p>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="F">
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
                   A.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#ftn_13">3</a>
                   </span>
                </p>
                <p>
                   B.
                   <span class="MsoFootnoteReference">
                      <span style="mso-element:field-begin"/>
                      NOTEREF _Ref \\f \\h
                      <span style="mso-element:field-separator"/>
                      3
                      <span style="mso-element:field-end"/>
                   </span>
                </p>
                <p>
                   C.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#ftn_16">4</a>
                   </span>
                </p>
             </div>
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
             <p>
                B.
                <span class="MsoFootnoteReference">
                   <span style="mso-element:field-begin"/>
                   NOTEREF _Ref \\f \\h
                   <span style="mso-element:field-separator"/>
                   3
                   <span style="mso-element:field-end"/>
                </span>
             </p>
             <div>
                <h1>
                   1.
                   <span style="mso-tab-count:1">  </span>
                   Normative References
                </h1>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <p id="ISO712" class="NormRef">
                   ISO 712, International Organization for Standardization.
                   <i>
                      Cereals and cereal products
                      <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                         <a class="FootnoteRef" epub:type="footnote" href="#ftn_19">5</a>
                      </span>
                   </i>
                   .
                </p>
             </div>
             <div id="A">
                <h1>2.</h1>
                <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                   <a class="FootnoteRef" epub:type="footnote" href="#ftn_22">6</a>
                </span>
             </div>
             <aside id="ftn_8">
                <p>C</p>
             </aside>
             <aside id="ftn_10">
                <p>D</p>
             </aside>
             <aside id="ftn_13">
                <p id="_">Formerly denoted as 15 % (m/m).</p>
             </aside>
             <aside id="ftn_16">
                <p id="_">Hello! denoted as 15 % (m/m).</p>
             </aside>
             <aside id="ftn_19">
                <p id="_">ISO is a standards organisation.</p>
             </aside>
             <aside id="ftn_22">
                <p id="_">Third footnote.</p>
             </aside>
          </div>
       </body>
    OUTPUT
    doc1 = <<~OUTPUT
        <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
          <div class="WordSection2">
             <div class="authority">
                <div class="boilerplate-copyright">
                   <div>
       </div>
                </div>
             </div>
             <p class="MsoNormal">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div>
                <a name="F" id="F"/>
                <h1 class="ForewordTitle">Foreword</h1>
                <p class="MsoNormal">
                   A.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#_ftn1" style="mso-footnote-id:ftn1" name="_ftnref1" title="" id="_ftnref1">
                         <span class="MsoFootnoteReference">
                            <span style="mso-special-character:footnote"/>
                         </span>
                      </a>
                   </span>
                </p>
                <p class="MsoNormal">
                   B.
                   <span class="MsoFootnoteReference">
                      <span style="mso-element:field-begin"/>
                      NOTEREF _Ref \\f \\h
                      <span style="mso-element:field-separator"/>
                      3
                      <span style="mso-element:field-end"/>
                   </span>
                </p>
                <p class="MsoNormal">
                   C.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#_ftn2" style="mso-footnote-id:ftn2" name="_ftnref2" title="" id="_ftnref2">
                         <span class="MsoFootnoteReference">
                            <span style="mso-special-character:footnote"/>
                         </span>
                      </a>
                   </span>
                </p>
             </div>
             <p class="MsoNormal"> </p>
          </div>
          <p class="MsoNormal">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
             <p class="MsoNormal">
                B.
                <span class="MsoFootnoteReference">
                   <span style="mso-element:field-begin"/>
                   NOTEREF _Ref \\f \\h
                   <span style="mso-element:field-separator"/>
                   3
                   <span style="mso-element:field-end"/>
                </span>
             </p>
             <div>
                <h1>
                   1.
                   <span style="mso-tab-count:1">  </span>
                   Normative References
                </h1>
                <p class="MsoNormal">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <p class="NormRef">
                   <a name="ISO712" id="ISO712"/>
                   ISO 712, International Organization for Standardization.
                   <i>
                      Cereals and cereal products
                      <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                         <a class="FootnoteRef" epub:type="footnote" href="#_ftn3" style="mso-footnote-id:ftn3" name="_ftnref3" title="" id="_ftnref3">
                            <span class="MsoFootnoteReference">
                               <span style="mso-special-character:footnote"/>
                            </span>
                         </a>
                      </span>
                   </i>
                   .
                </p>
             </div>
             <div>
                <a name="A" id="A"/>
                <h1>2.</h1>
                <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                   <a class="FootnoteRef" epub:type="footnote" href="#_ftn4" style="mso-footnote-id:ftn4" name="_ftnref4" title="" id="_ftnref4">
                      <span class="MsoFootnoteReference">
                         <span style="mso-special-character:footnote"/>
                      </span>
                   </a>
                </span>
             </div>
             <aside>
                <a name="ftn_8" id="ftn_8"/>
                <p class="MsoNormal">C</p>
             </aside>
             <aside>
                <a name="ftn_10" id="ftn_10"/>
                <p class="MsoNormal">D</p>
             </aside>
          </div>
          <div style="mso-element:footnote-list">
             <div style="mso-element:footnote" id="ftn1">
                <p class="MsoFootnoteText">
                   <a name="_" id="_"/>
                   <a style="mso-footnote-id:ftn1" href="#_ftn1" name="_ftnref1" title="" id="_ftnref1">
                      <span class="MsoFootnoteReference">
                         <span style="mso-special-character:footnote"/>
                      </span>
                   </a>
                   Formerly denoted as 15 % (m/m).
                </p>
             </div>
             <div style="mso-element:footnote" id="ftn2">
                <p class="MsoFootnoteText">
                   <a name="_" id="_"/>
                   <a style="mso-footnote-id:ftn2" href="#_ftn2" name="_ftnref2" title="" id="_ftnref2">
                      <span class="MsoFootnoteReference">
                         <span style="mso-special-character:footnote"/>
                      </span>
                   </a>
                   Hello! denoted as 15 % (m/m).
                </p>
             </div>
             <div style="mso-element:footnote" id="ftn3">
                <p class="MsoFootnoteText">
                   <a name="_" id="_"/>
                   <a style="mso-footnote-id:ftn3" href="#_ftn3" name="_ftnref3" title="" id="_ftnref3">
                      <span class="MsoFootnoteReference">
                         <span style="mso-special-character:footnote"/>
                      </span>
                   </a>
                   ISO is a standards organisation.
                </p>
             </div>
             <div style="mso-element:footnote" id="ftn4">
                <p class="MsoFootnoteText">
                   <a name="_" id="_"/>
                   <a style="mso-footnote-id:ftn4" href="#_ftn4" name="_ftnref4" title="" id="_ftnref4">
                      <span class="MsoFootnoteReference">
                         <span style="mso-special-character:footnote"/>
                      </span>
                   </a>
                   Third footnote.
                </p>
             </div>
          </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    output = Nokogiri::XML(IsoDoc::HtmlConvert.new({})
    .convert("test", pres_output, true))
    output.at("//div[@class='TOC']")["id"] = "_"
    expect(Xml::C14n.format(strip_guid(output.to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//body").to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(doc))
    FileUtils.rm_f("test.doc")
    IsoDoc::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc").sub(/^.*<body/m, "<body").sub(
      %r{</body>.*$}m, "</body>"
    )
    expect(strip_guid(Xml::C14n.format(output)))
      .to be_equivalent_to Xml::C14n.format(doc1)
  end

  it "processes IsoXML reviewer notes" do
    mock_uuid_increment
    FileUtils.rm_f "test.html"
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword displayorder="1"><title>Foreword</title>
        <p id="A"><em><strong>A.</strong></em> <bookmark id="A1"/> B <em><strong>C.</strong></em></p>
        <p id="B"><em><strong>A.</strong></em> B <em><strong>C.</strong></em></p>
        </foreword>
        <introduction displayorder="2"><title>Introduction</title>
          <p id="C">C.</p>
       </introduction>
        </preface>
        <review-container>
        <review reviewer="ISO" date="20170101T0000" from="A" to="B"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
          <p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review>
        <review reviewer="ISO" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
        <review reviewer="ISO" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c09">Third note.</p></review>
        <review reviewer="ISO" date="20170108T0000" from="A1" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c0a">Fourth note.</p></review>
         <review reviewer="ISO" date="20170108T0000" from="A1" to="A1" id="B1"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c0b">Fifth note.</p></review>
          <review reviewer="ISO" date="20170108T0000" from="B1" to="B1" id="B1"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c0c">Sixth note.</p></review>
      </review-container>
        </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_3" displayorder="1">
               <fmt-title depth="1">Table of contents</fmt-title>
            </clause>
            <foreword displayorder="2" id="_1">
               <title id="_5">Foreword</title>
               <fmt-title depth="1">
                  <semx element="title" source="_5">Foreword</semx>
               </fmt-title>
               <p id="A">
                  <em>
                     <strong>
                        <fmt-review-start id="_9" source="_8"/>
                        <fmt-review-start id="_17" source="_16"/>
                        A.
                     </strong>
                  </em>
                  <fmt-review-start id="_21" source="_20"/>
                  <fmt-review-start id="_24" source="_23"/>
                  <bookmark id="A1"/>
                  <fmt-review-end id="_25" source="_23"/>
                  B
                  <em>
                     <strong>C.</strong>
                  </em>
               </p>
               <p id="B">
                  <em>
                     <strong>
                        A.
                        <fmt-review-end id="_10" source="_8"/>
                     </strong>
                  </em>
                  B
                  <em>
                     <strong>C.</strong>
                  </em>
               </p>
            </foreword>
            <introduction displayorder="3" id="_2">
               <title id="_6">Introduction</title>
               <fmt-title depth="1">
                  <semx element="title" source="_6">Introduction</semx>
               </fmt-title>
               <p id="C">
                  <fmt-review-start id="_13" source="_12"/>
                  C.
                  <fmt-review-end id="_22" source="_20"/>
                  <fmt-review-end id="_18" source="_16"/>
                  <fmt-review-end id="_14" source="_12"/>
               </p>
            </introduction>
         </preface>
         <review-container>
            <review reviewer="ISO" date="20170101T0000" from="A" to="B" id="_7">
               <p original-id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
               <p original-id="_">
                  For further information on the Foreword, see
                  <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
               </p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170101T0000" from="_9" to="_10" id="_8">
               <semx element="review" source="_7">
                  <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
                  <p id="_">
                     For further information on the Foreword, see
                     <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                  </p>
               </semx>
            </fmt-review-body>
            <review reviewer="ISO" date="20170108T0000" from="C" to="C" id="_11">
               <p original-id="_">Second note.</p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170108T0000" from="_13" to="_14" id="_12">
               <semx element="review" source="_11">
                  <p id="_">Second note.</p>
               </semx>
            </fmt-review-body>
            <review reviewer="ISO" date="20170108T0000" from="A" to="C" id="_15">
               <p original-id="_">Third note.</p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170108T0000" from="_17" to="_18" id="_16">
               <semx element="review" source="_15">
                  <p id="_">Third note.</p>
               </semx>
            </fmt-review-body>
            <review reviewer="ISO" date="20170108T0000" from="A1" to="C" id="_19">
               <p original-id="_">Fourth note.</p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170108T0000" from="_21" to="_22" id="_20">
               <semx element="review" source="_19">
                  <p id="_">Fourth note.</p>
               </semx>
            </fmt-review-body>
            <review reviewer="ISO" date="20170108T0000" from="A1" to="A1" id="B1">
               <p original-id="_">
                  <fmt-review-start id="_27" source="_26"/>
                  Fifth note.
                  <fmt-review-end id="_28" source="_26"/>
               </p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170108T0000" from="_24" to="_25" id="_23">
               <semx element="review" source="B1">
                  <p id="_">Fifth note.</p>
               </semx>
            </fmt-review-body>
            <review reviewer="ISO" date="20170108T0000" from="B1" to="B1" id="B1">
               <p original-id="_">Sixth note.</p>
            </review>
            <fmt-review-body reviewer="ISO" date="20170108T0000" from="_27" to="_28" id="_26">
               <semx element="review" source="B1">
                  <p id="_">Sixth note.</p>
               </semx>
            </fmt-review-body>
         </review-container>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
          <div id="_3" class="TOC">
             <h1 class="IntroTitle">
                <a class="anchor" href="#_3"/>
                <a class="header" href="#_3">Table of contents</a>
             </h1>
          </div>
          <br/>
          <div id="_1">
             <h1 class="ForewordTitle">
                <a class="anchor" href="#_1"/>
                <a class="header" href="#_1">Foreword</a>
             </h1>
             <p id="A">
                <i>
                   <b>A.</b>
                </i>
                <a id="A1"/>
                B
                <i>
                   <b>C.</b>
                </i>
             </p>
             <p id="B">
                <i>
                   <b>A.</b>
                </i>
                B
                <i>
                   <b>C.</b>
                </i>
             </p>
          </div>
          <br/>
          <div class="Section3" id="_2">
             <h1 class="IntroTitle">
                <a class="anchor" href="#_2"/>
                <a class="header" href="#_2">Introduction</a>
             </h1>
             <p id="C">C.</p>
          </div>
       </main>
           OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div><a name="_" id="_"/>
             <h1 class="ForewordTitle">Foreword</h1>
             <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="B">
               <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                 <a style="mso-comment-reference:SMC_1;mso-comment-date:20170101T0000">
                   <span style="MsoCommentReference" target="3" class="commentLink" from="A" to="C">
                     <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                       <a style="mso-comment-reference:SMC_3;mso-comment-date:20170108T0000">
                         <p class="MsoNormal"><a name="A" id="A"/>A.</p>
                       </a>
                       <span style="mso-comment-continuation:3">
                         <span style="mso-special-character:comment" target="3"/>
                       </span>
                     </span>
                   </span>
                 </a>
                 <span style="mso-comment-continuation:3">
                   <span style="mso-comment-continuation:1">
                     <span style="mso-special-character:comment" target="1"/>
                   </span>
                 </span>
               </span>
             </span>
             <p class="MsoNormal">
               <a name="B" id="B"/>
               <span style="mso-comment-continuation:3">
                 <span style="mso-comment-continuation:1">B.</span>
               </span>
             </p>
             <span style="MsoCommentReference" target="2" class="commentLink" from="C" to="C">
               <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                 <a style="mso-comment-reference:SMC_2;mso-comment-date:20170108T0000">
                   <p class="MsoNormal">
                     <a name="C" id="C"/>
                     <span style="mso-comment-continuation:3">C.</span>
                   </p>
                 </a>
                 <span style="mso-special-character:comment" target="2"/>
               </span>
             </span>
           </div>
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div class="Section3"><a name="_" id="_"/>
             <h1 class="IntroTitle">Introduction</h1>
           </div>
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <div style="mso-element:comment-list">
             <div style="mso-element:comment">
               <a name="3" id="3"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
             <div style="mso-element:comment">
               <a name="1" id="1"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
               <p class="MsoCommentText"><a name="_" id="_"/>For further information on the Foreword, see <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b></p>
             </div>
             <div style="mso-element:comment">
               <a name="2" id="2"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
           </div>
         </div>
         <div style="mso-element:footnote-list"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.html").sub(/^.*<main/m, "<main").sub(
      %r{</main>.*$}m, "</main>"
    )
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.doc").sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m,
                                                              "</body>")
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes IsoXML reviewer notes spanning list" do
    mock_uuid_increment
    FileUtils.rm_f "test.html"
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface>
       <foreword displayorder="1"><title>Foreword</title>
       <ol>
       <li id="A"><p>A.</p><p>A1</p></li>
       <li id="B">B.</li>
       <ul>
       <li><p>C.</p><p id="C">C1</p></li>
       <li id="D">D.</li>
       </ul>
       </ol>
       </foreword>
       <introduction displayorder="2"><title>Introduction</title>
       </introduction>
       </preface>
            <review-container>
        <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
          </review-container>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_3" displayorder="1">
               <fmt-title depth="1">Table of contents</fmt-title>
            </clause>
            <foreword displayorder="2" id="_1">
               <title id="_5">Foreword</title>
               <fmt-title depth="1">
                  <semx element="title" source="_5">Foreword</semx>
               </fmt-title>
               <ol type="alphabet">
                  <li id="A" label="">
                     <p>
                        <fmt-review-start id="_8" source="_7"/>
                        A.
                     </p>
                     <p>A1</p>
                  </li>
                  <li id="B" label="">B.</li>
                  <ul>
                     <li>
                        <p>C.</p>
                        <p id="C">
                           C1
                           <fmt-review-end id="_9" source="_7"/>
                        </p>
                     </li>
                     <li id="D">D.</li>
                  </ul>
               </ol>
            </foreword>
            <introduction displayorder="3" id="_2">
               <title id="_6">Introduction</title>
               <fmt-title depth="1">
                  <semx element="title" source="_6">Introduction</semx>
               </fmt-title>
            </introduction>
         </preface>
         <review-container>
            <review reviewer="ISO" id="_" date="20170108T0000" from="A" to="C">
               <p original-id="_">Second note.</p>
            </review>
            <fmt-review-body reviewer="ISO" id="_7" date="20170108T0000" from="_8" to="_9">
               <semx element="review" source="_">
                  <p id="_">Second note.</p>
               </semx>
            </fmt-review-body>
         </review-container>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
       <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
          <div id="_3" class="TOC">
             <h1 class="IntroTitle">
                <a class="anchor" href="#_3"/>
                <a class="header" href="#_3">Table of contents</a>
             </h1>
          </div>
          <br/>
          <div id="_1">
             <h1 class="ForewordTitle">
                <a class="anchor" href="#_1"/>
                <a class="header" href="#_1">Foreword</a>
             </h1>
             <div class="ol_wrap">
                <ol type="a">
                   <li id="A">
                      <p>A.</p>
                      <p>A1</p>
                   </li>
                   <li id="B">
                      B.
                      <div class="ul_wrap">
                         <ul>
                            <li>
                               <p>C.</p>
                               <p id="C">C1</p>
                            </li>
                            <li id="D">D.</li>
                         </ul>
                      </div>
                   </li>
                </ol>
             </div>
          </div>
          <br/>
          <div class="Section3" id="_2">
             <h1 class="IntroTitle">
                <a class="anchor" href="#_2"/>
                <a class="header" href="#_2">Introduction</a>
             </h1>
          </div>
       </main>
    OUTPUT
    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
         <div class="WordSection2">
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div><a name="_" id="_"/>
             <h1 class="ForewordTitle">Foreword</h1>
             <div class="ol_wrap">
               <span style="MsoCommentReference" target="1" class="commentLink" from="A" to="C">
                 <span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB">
                   <a style="mso-comment-reference:SMC_1;mso-comment-date:20170108T0000">
                     <li class="MsoNormal">
                       <a name="A" id="A"/>
                       <p class="MsoNormal">A.</p>
                       <div class="ListContLevel1">
                         <p class="MsoNormal">A1</p>
                       </div>
                     </li>
                   </a>
                   <span style="mso-comment-continuation:1">
                     <span style="mso-special-character:comment" target="1"/>
                   </span>
                 </span>
               </span>
               <p class="MsoListParagraphCxSpFirst">
                 <a name="B" id="B"/>
                 <span style="mso-comment-continuation:1">B.</span>
               </p>
               <div class="ul_wrap">
                 <p class="MsoListParagraphCxSpFirst" style="">
                   <span style="mso-comment-continuation:1">C.</span>
                   <p class="MsoListParagraphCxSpMiddle">
                     <a name="C" id="C"/>
                     <span style="mso-comment-continuation:1">C1</span>
                   </p>
                 </p>
                 <p class="MsoListParagraphCxSpLast"><a name="D" id="D"/>D.</p>
               </div>
             </div>
           </div>
           <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div class="Section3"><a name="_" id="_"/>
             <h1 class="IntroTitle">Introduction</h1>
           </div>
           <p class="MsoNormal"> </p>
         </div>
         <p class="MsoNormal">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <div style="mso-element:comment-list">
             <div style="mso-element:comment">
               <a name="1" id="1"/>
               <span style="mso-comment-author:&quot;ISO&quot;"/>
               <p class="MsoCommentText"><a name="_" id="_"/><span style="MsoCommentReference"><span lang="EN-GB" style="font-size:9.0pt" xml:lang="EN-GB"><span style="mso-special-character:comment"/></span></span>Second note.</p>
             </div>
           </div>
         </div>
         <div style="mso-element:footnote-list"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.html").sub(/^.*<main/m, "<main").sub(
      %r{</main>.*$}m, "</main>"
    )
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css",
                              htmlstylesheet: "spec/assets/html.scss" })
      .convert("test", pres_output, false)
    out = File.read("test.doc")
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
