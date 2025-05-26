require "spec_helper"

RSpec.describe IsoDoc do
  it "processes unordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>
          <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">Foreword</fmt-title>
                <ul id="_" keep-with-next="true" keep-lines-together="true">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li>
                      <fmt-name id="_">
                         <semx element="autonum" source="">—</semx>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li>
                      <fmt-name id="_">
                         <semx element="autonum" source="">—</semx>
                      </fmt-name>
                      <p id="_">deletion of 4.3.</p>
                      <ul id="_" keep-with-next="true" keep-lines-together="true">
                         <li>
                            <fmt-name id="_">
                               <semx element="autonum" source="">—</semx>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ul id="_" keep-with-next="true" keep-lines-together="true">
                               <li>
                                  <fmt-name id="_">
                                     <semx element="autonum" source="">—</semx>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ul id="_" keep-with-next="true" keep-lines-together="true">
                                     <li>
                                        <fmt-name id="_">
                                           <semx element="autonum" source="">—</semx>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ul>
                               </li>
                            </ul>
                         </li>
                      </ul>
                   </li>
                </ul>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
    INPUT
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
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div class="ul_wrap">
                      <p class="ListTitle">Caption</p>
                      <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                         <li>
                            <p id="_">Level 1</p>
                         </li>
                         <li>
                            <p id="_">deletion of 4.3.</p>
                            <div class="ul_wrap">
                               <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                                  <li>
                                     <p id="_">Level 2</p>
                                     <div class="ul_wrap">
                                        <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                                           <li>
                                              <p id="_">Level 3</p>
                                              <div class="ul_wrap">
                                                 <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                                                    <li>
                                                       <p id="_">Level 4</p>
                                                    </li>
                                                 </ul>
                                              </div>
                                           </li>
                                        </ul>
                                     </div>
                                  </li>
                               </ul>
                            </div>
                         </li>
                      </ul>
                   </div>
                </div>
                <br/>
                <div id="_" class="TOC">
                   <h1 class="IntroTitle">Table of contents</h1>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
       <div id="fwd">
          <h1 class="ForewordTitle">Foreword</h1>
          <div class="ul_wrap">
             <p class="ListTitle">Caption</p>
             <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                <li>
                   <p id="_">Level 1</p>
                </li>
                <li>
                   <p id="_">deletion of 4.3.</p>
                   <div class="ul_wrap">
                      <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                         <li>
                            <p id="_">Level 2</p>
                            <div class="ul_wrap">
                               <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                                  <li>
                                     <p id="_">Level 3</p>
                                     <div class="ul_wrap">
                                        <ul id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                                           <li>
                                              <p id="_">Level 4</p>
                                           </li>
                                        </ul>
                                     </div>
                                  </li>
                               </ul>
                            </div>
                         </li>
                      </ul>
                   </div>
                </li>
             </ul>
          </div>
       </div>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    xml = Nokogiri::XML(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))
    xml = xml.at("//div[@id = 'fwd']")
    expect(strip_guid(Xml::C14n.format(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes unordered checklists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>
          <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb">
        <li  checkedcheckbox="true" uncheckedcheckbox="false">
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">updated normative references;</p>
        </li>
        <li checkedcheckbox="false" uncheckedcheckbox="true">
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
         <div id="_">
                   <h1 class='ForewordTitle'>Foreword</h1>
                   <div class="ul_wrap">
                   <ul id='_'>
                     <li>
                     <span class='zzMoveToFollowing'>
                       <input type='checkbox'/>
                       </span>
                       <p id='_'>updated normative references;</p>
                     </li>
                     <li>
                     <span class='zzMoveToFollowing'>
                       <input type='checkbox'  checked='checked'/>
                       </span>
                       <p id='_'>deletion of 4.3.</p>
                     </li>
                   </ul>
                   </div>
                 </div>
               </div>
             </body>
           </html>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
                    <p class="page-break">
                      <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
                    </p>
                    <div id="_">
                      <h1 class='ForewordTitle'>Foreword</h1>
                      <div class="ul_wrap">
                      <ul id='_'>
                        <li>
                          <span class='zzMoveToFollowing'>&#9745; </span>
                          <p id='_'>updated normative references;</p>
                        </li>
                        <li>
                        <span class='zzMoveToFollowing'>&#9744; </span>
                          <p id='_'>deletion of 4.3.</p>
                        </li>
                      </ul>
                    </div>
                    </div>
                    <p>\\u00a0</p>
                  </div>
                  <p class="section-break">
                    <br clear='all' class='section'/>
                  </p>
                  <div class='WordSection3'>
                  </div>
                </body>
              </html>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
          </ol>
        <ol id="A">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">Level 1</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 2</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 3</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 4</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
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
                <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                </ol>
                <ol id="A" type="alphabet">
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                      <ol type="arabic">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ol type="roman">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">i</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ol type="alphabet_upper">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">A</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ol>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
          </preface>
       </iso-standard>
    INPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div class="ol_wrap">
                      <p class="ListTitle">Caption</p>
                      <ol type="a" id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                         <li id="_">
                            <p id="_">Level 1</p>
                         </li>
                      </ol>
                   </div>
                   <div class="ol_wrap">
                      <ol type="a" id="A">
                         <li id="_">
                            <p id="_">Level 1</p>
                         </li>
                         <li id="_">
                            <p id="_">Level 1</p>
                            <div class="ol_wrap">
                               <ol type="1">
                                  <li id="_">
                                     <p id="_">Level 2</p>
                                     <div class="ol_wrap">
                                        <ol type="i">
                                           <li id="_">
                                              <p id="_">Level 3</p>
                                              <div class="ol_wrap">
                                                 <ol type="A">
                                                    <li id="_">
                                                       <p id="_">Level 4</p>
                                                    </li>
                                                 </ol>
                                              </div>
                                           </li>
                                        </ol>
                                     </div>
                                  </li>
                               </ol>
                            </div>
                         </li>
                      </ol>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
              <p class="page-break">
                <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
              </p>
               <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div class="ol_wrap">
                      <p class="ListTitle">Caption</p>
                      <ol type="a" id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                         <li id="_">
                            <p id="_">Level 1</p>
                         </li>
                      </ol>
                   </div>
                   <div class="ol_wrap">
                      <ol type="a" id="A">
                         <li id="_">
                            <p id="_">Level 1</p>
                         </li>
                         <li id="_">
                            <p id="_">Level 1</p>
                            <div class="ol_wrap">
                               <ol type="1">
                                  <li id="_">
                                     <p id="_">Level 2</p>
                                     <div class="ol_wrap">
                                        <ol type="i">
                                           <li id="_">
                                              <p id="_">Level 3</p>
                                              <div class="ol_wrap">
                                                 <ol type="A">
                                                    <li id="_">
                                                       <p id="_">Level 4</p>
                                                    </li>
                                                 </ol>
                                              </div>
                                           </li>
                                        </ol>
                                     </div>
                                  </li>
                               </ol>
                            </div>
                         </li>
                      </ol>
                   </div>
                </div>
                <p>\\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes Roman Upper ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>

        <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="roman_upper">
        <li id="_ae34a226-aab4-496d-987b-1aa7b6314027">
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
        </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
                   <div id="_">
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div class="ol_wrap">
                     <ol type="I" id="_">
             <li id="_">
               <p id="_">all information necessary for the complete identification of the sample;</p>
             </li>
             <li>
               <p id="_">a reference to this document (i.e. ISO 17301-1);</p>
             </li>
             <li>
               <p id="_">the sampling method used;</p>
             </li>
           </ol>
           </div>
                   </div>
                 </div>
               </body>
           </html>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes definition lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <dl id="_732d3f57-4f88-40bf-9ae9-633891edc395"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <dt>
          W
        </dt>
        <dd>
          <p id="_05d81174-3a41-44af-94d8-c78b8d2e175d">mass fraction of gelatinized kernels, expressed in per cent</p>
        </dd>
        <dt><stem type="AsciiMath">w</stem></dt>
        <dd><p>??</p></dd>
        <note><p>This is a note</p></note>
        </dl>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
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
                 <dl id="_" keep-with-next="true" keep-lines-together="true" autonum="">
                    <name id="_">Caption</name>
                    <fmt-name id="_">
                       <semx element="name" source="_">Caption</semx>
                    </fmt-name>
                    <dt>
            W
          </dt>
                    <dd>
                       <p id="_">mass fraction of gelatinized kernels, expressed in per cent</p>
                    </dd>
                    <dt>
               <stem type="AsciiMath" id="_">w</stem>
               <fmt-stem type="AsciiMath">
                  <semx element="stem" source="_">w</semx>
               </fmt-stem>
                    </dt>
                    <dd>
                       <p>??</p>
                    </dd>
                    <note>
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                          </span>
                          <span class="fmt-label-delim">
                             <tab/>
                          </span>
                       </fmt-name>
                       <p>This is a note</p>
                    </note>
                 </dl>
              </foreword>
           </preface>
        </iso-standard>
    INPUT
    html = <<~OUTPUT
         #{HTML_HDR}
              <br/>
              <div id="_">
                <h1 class="ForewordTitle">Foreword</h1>
                <div class="figdl">
                <p class='ListTitle'>Caption</p>
                <dl id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                  <dt>
                    <p>
          W
        </p>
                  </dt>
                  <dd>
          <p id="_">mass fraction of gelatinized kernels, expressed in per cent</p>
        </dd>
                  <dt>
                    <span class="stem">(#(w)#)</span>
                  </dt>
                  <dd>
                    <p>??</p>
                  </dd>
                </dl>
                <div class="Note">
           <p><span class="note_label">NOTE\\u00a0 </span>This is a note</p>
         </div>
         </div>
              </div>
            </div>
          </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
      #{WORD_HDR}
               <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div id="_">
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p class='ListTitle'>Caption</p>
                 <table class="dl" id="_">
                   <tr>
                     <td valign="top" align="left">
                       <p align="left" style="margin-left:0pt;text-align:left;">
           W
         </p>
                     </td>
                     <td valign="top">
           <p id="_">mass fraction of gelatinized kernels, expressed in per cent</p>
         </td>
                   </tr>
                   <tr>
                     <td valign="top" align="left">
                     <p align="left" style="margin-left:0pt;text-align:left;">
                       <span class="stem">(#(w)#)</span>
                     </p>
                     </td>
                     <td valign="top">
                       <p>??</p>
                     </td>
                   </tr>
                   <tr>
                    <td colspan="2">
                      <div class="Note">
                        <p class="Note">
                           <span class="note_label">
                              NOTE
                              <span style="mso-tab-count:1">\\u00a0 </span>
                           </span>
                           This is a note
                        </p>
                      </div>
                     </td>
                   </tr>
                 </table>
               </div>
               <p>\\u00a0</p>
             </div>
             <p class="section-break"><br clear="all" class="section"/></p>
             <div class="WordSection3">
             </div>
           </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(strip_guid(Xml::C14n.format(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(strip_guid(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes nested definition lists (Word)" do
    input = <<~INPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
       <dl id="_732d3f57-4f88-40bf-9ae9-633891edc394">
       <dt>A Deflist</dt>
       <dd>
         <dl id="_732d3f57-4f88-40bf-9ae9-633891edc395">
         <dt>W</dt>
         <dd><p id="_05d81174-3a41-44af-94d8-c78b8d2e175d">mass fraction of gelatinized kernels</p></dd>
         </dl>
       </dd>
       </dl>
       <table id="_732d3f57-4f88-40bf-9ae9-633891edc396">
       <tbody>
       <tr>
       <td>
         <dl id="_732d3f57-4f88-40bf-9ae9-633891edc397">
         <dt>X</dt>
         <dd><p id="_05d81174-3a41-44af-94d8-c78b8d2e175e">expressed in per cent</p></dd>
         </dl>
       </td>
      </tr>
       </tbody>
       </table>
       </foreword></preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
       <head>
         <style>
         </style>
       </head>
          <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
                <p>\\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection2">
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <table id="_" class="dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">A Deflist</p>
                         </td>
                         <td valign="top">
                            <div class="figdl">
                               <a id="_"/>
                               <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">
                                  W
                                  <span style="mso-tab-count:1">\\u00a0 </span>
                                  mass fraction of gelatinized kernels
                               </p>
                            </div>
                         </td>
                      </tr>
                   </table>
                   <div align="center" class="table_container">
                      <table id="_" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                                  <div class="figdl">
                                     <a id="_"/>
                                     <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">
                                        X
                                        <span style="mso-tab-count:1">\\u00a0 </span>
                                        expressed in per cent
                                     </p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </div>
                </div>
                <p>\\u00a0</p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
          </body>
       </html>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
