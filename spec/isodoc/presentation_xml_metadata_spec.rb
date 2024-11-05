require "spec_helper"

RSpec.describe IsoDoc do
  it "inserts copy of Semantic XML by default" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p><math id="b" xmlns:sodipodi='ABC'><sodipodi:b> xmlns:sodipodi</sodipodi:b></math>
        <xref target="N1"/>
        </p>
        </foreword>
            <introduction id="intro">
            <figure id="N1"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
      </introduction></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <metanorma-extension>
           <metanorma>
             <source>
               <semantic__iso-standard>
                 <semantic__preface>
                   <semantic__foreword id="semantic__fwd">
                     <semantic__p>
                        <semantic__math xmlns:sodipodi="ABC" id="semantic__b">
                         <sodipodi:semantic__b> xmlns:sodipodi</sodipodi:semantic__b>
                       </semantic__math>
                       <semantic__xref target="semantic__N1"/>
                     </semantic__p>
                   </semantic__foreword>
                   <semantic__introduction id="semantic__intro">
                     <semantic__figure id="semantic__N1">
                       <semantic__name>Split-it-right sample divider</semantic__name>
                       <semantic__image src="rice_images/rice_image1.png" id="semantic___8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
                     </semantic__figure>
                   </semantic__introduction>
                 </semantic__preface>
               </semantic__iso-standard>
             </source>
           </metanorma>
         </metanorma-extension>
         <preface>
             <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause>
           <foreword id="fwd" displayorder="2"><title>Foreword</title>
             <p>
               <math xmlns:sodipodi="ABC" id="b">
                 <sodipodi:b> xmlns:sodipodi</sodipodi:b>
               </math>
               <xref target="N1">Figure 1</xref>
             </p>
           </foreword>
           <introduction id="intro" displayorder="3">
             <figure id="N1">
               <name>Figure 1 — Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_" mimetype="image/png"/>
             </figure>
           </introduction>
         </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "inserts preprocess-xslt" do
    mock_preprocess_xslt_read
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard"/>
          <metanorma-extension><clause id="_user_css" inline-header="false" obligation="normative">
      <title>user-css</title>
      <sourcecode id="_2d494494-0538-c337-37ca-6d083d748646">.green { background-color: green }</sourcecode>

      </clause>
      </metanorma-extension>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata type="standard"/>

        <metanorma-extension>
          <clause id="_user_css" inline-header="false" obligation="normative">
            <title depth="1">user-css</title>
            <sourcecode id="_2d494494-0538-c337-37ca-6d083d748646">.green { background-color: green }</sourcecode>
          </clause>
          <render>
             <preprocess-xslt format="pdf">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
                 <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                 <xsl:strip-space elements="*"/>
                 <!-- note/name -->
                 <xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']">
                   <xsl:copy>
                     <xsl:apply-templates select="@*|node()"/>
                     <xsl:if test="normalize-space() != ''">:<tab/>
       						</xsl:if>
                   </xsl:copy>
                 </xsl:template>
               </xsl:stylesheet>
             </preprocess-xslt>
           </render>
          <source-highlighter-css>
      .green { background-color: green }</source-highlighter-css>
        </metanorma-extension>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true))
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes user-css" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard"/>
          <metanorma-extension><clause id="_user_css" inline-header="false" obligation="normative">
      <title>user-css</title>
      <sourcecode id="_2d494494-0538-c337-37ca-6d083d748646">.green { background-color: green }</sourcecode>

      </clause>
      </metanorma-extension>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata type="standard"/>

        <metanorma-extension>
          <clause id="_user_css" inline-header="false" obligation="normative">
            <title depth="1">user-css</title>
            <sourcecode id="_2d494494-0538-c337-37ca-6d083d748646">.green { background-color: green }</sourcecode>
          </clause>
          <source-highlighter-css>
      .green { background-color: green }</source-highlighter-css>
        </metanorma-extension>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true))
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "inserts toc metadata" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata/>
        <metanorma-extension>
          <toc type='figure'>
            <title>List of figures</title>
          </toc>
          <toc type='table'>
            <title>List of tables</title>
          </toc>
          <toc type='recommendation'>
            <title>List of recommendations</title>
          </toc>
        </metanorma-extension>
         <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
        <sections> </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ tocfigures: true,
             toctables: true,
             tocrecommendations: true }
      .merge(presxml_options))
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "passes font names to Presentation XML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
      <sections>
       <clause id="A" inline-header="false" obligation="normative">
       <title>Section</title>
       <figure id="B1">
       <name>First</name>
       </figure>
       </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata/>
        <metanorma-extension>
          <presentation-metadata>
          <name>font-license-agreement</name>
          <value>no-install-fonts</value>
        </presentation-metadata>
        <presentation-metadata>
          <name>fonts</name>
          <value>font2</value>
        </presentation-metadata>
        <presentation-metadata>
          <name>fonts</name>
          <value>font1</value>
        </presentation-metadata>
        </metanorma-extension>
        <preface> <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of contents</title> </clause> </preface>
                 <sections>
           <clause id='A' inline-header='false' obligation='normative' displayorder='2'>
             <title depth='1'>
               1.
               <tab/>
               Section
             </title>
             <figure id='B1'>
               <name>Figure 1&#xA0;&#x2014; First</name>
             </figure>
           </clause>
         </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ fonts: "font1; font2", fontlicenseagreement: "no-install-fonts" }
      .merge(presxml_options))
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes preprocessing XSLT" do
    input = <<~INPUT
         <iso-standard xmlns="http://riboseinc.com/isoxml">
         <metanorma-extension>
         <render>
         <preprocess-xslt format="html">
         <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mn="http://riboseinc.com/isoxml" version="1.0">
      	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
      	<xsl:strip-space elements="*"/>
                                   <xsl:template match="@* | node()">
                                     <xsl:copy>
                                       <xsl:apply-templates select="@* | node()"/>
                                     </xsl:copy>
                                    </xsl:template>
      	<xsl:template match="mn:note/mn:name">
      		<xsl:copy>
      			<xsl:apply-templates select="@*|node()"/>
      			<xsl:if test="normalize-space() != ''">:<tab/>
      			</xsl:if>
      		</xsl:copy>
      	</xsl:template>
      </xsl:stylesheet>
         </preprocess-xslt>
         <preprocess-xslt format="doc">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mn="http://riboseinc.com/isoxml" version="1.0">
                                   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                                   <xsl:strip-space elements="*"/>
                                   <xsl:template match="@* | node()">
                                     <xsl:copy>
                                       <xsl:apply-templates select="@* | node()"/>
                                     </xsl:copy>
                                    </xsl:template>
                                   <xsl:template match="mn:example/mn:name">
                                           <xsl:copy>
                                                   <xsl:apply-templates select="@*|node()"/>
                                                   <xsl:if test="normalize-space() != ''">:<tab/>
                                                   </xsl:if>
                                           </xsl:copy>
                                   </xsl:template>
                           </xsl:stylesheet>
         </preprocess-xslt>
         <preprocess-xslt format="html,doc">
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mn="http://riboseinc.com/isoxml" version="1.0">
                                   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                                   <xsl:strip-space elements="*"/>
                                   <xsl:template match="@* | node()">
                                     <xsl:copy>
                                       <xsl:apply-templates select="@* | node()"/>
                                     </xsl:copy>
                                    </xsl:template>
                                   <xsl:template match="mn:termnote/mn:name">
                                           <xsl:copy>
                                                   <xsl:apply-templates select="@*|node()"/>
                                                   <xsl:if test="normalize-space() != ''">:<tab/>
                                                   </xsl:if>
                                           </xsl:copy>
                                   </xsl:template>
                           </xsl:stylesheet>
         </preprocess-xslt>
         <preprocess-xslt>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mn="http://riboseinc.com/isoxml" version="1.0">
                                   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
                                   <xsl:strip-space elements="*"/>
                                   <xsl:template match="@* | node()">
                                     <xsl:copy>
                                       <xsl:apply-templates select="@* | node()"/>
                                     </xsl:copy>
                                    </xsl:template>
                                   <xsl:template match="mn:termexample/mn:name">
                                           <xsl:copy>
                                                   <xsl:apply-templates select="@*|node()"/>
                                                   <xsl:if test="normalize-space() != ''">:<tab/>
                                                   </xsl:if>
                                           </xsl:copy>
                                   </xsl:template>
                           </xsl:stylesheet>
         </preprocess-xslt>
         </render>
         </metanorma-extension>
                   <preface>
                   <foreword displayorder="1"><title>Foreword</title>
                   <note><name>HTML</name></note>
                   <example><name>WORD</name></example>
                   </foreword>
                   </preface>
                   <sections>
                   <terms displayorder="2">
                   <term>
                   <termexample><name>HTML-AND-WORD</name> <p>note</p></termexample>
                   <termnote><name>NONE-SPECIFIED</name> <p>note</p></termnote>
                   <term>
                   </terms>
                   </sections>
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
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div class="Note">
                <p><span class="note_label">HTML:  </span>  </p>
              </div>
              <div class="example">
                <p class="example-title">WORD</p>
              </div>
            </div>
            <div>
              <p class="TermNum" id=""/>
              <div class="example">
                <p class="example-title">HTML-AND-WORD:  </p>
                <p>note</p>
              </div>
              <div class="Note">
                <p>NONE-SPECIFIED:  note</p>
              </div>
              <p class="TermNum" id=""/>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">>
         <head>
           <style> </style>
         </head>
            <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p> </p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div class="Note">
                <p class="Note">
                  <span class="note_label">HTML</span>
                  <span style="mso-tab-count:1">  </span>
                </p>
              </div>
              <div class="example">
                <p class="example-title">WORD:<span style="mso-tab-count:1">  </span></p>
              </div>
            </div>
            <p> </p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <div>
              <p class="TermNum" id=""/>
              <div class="example">
                <p class="example-title">HTML-AND-WORD:<span style="mso-tab-count:1">  </span></p>
                <p>note</p>
              </div>
              <div class="Note">
                <p class="Note">NONE-SPECIFIED:<span style="mso-tab-count:1">  </span> note</p>
              </div>
              <p class="TermNum" id=""/>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(word)
  end

  it "extracts attachments" do
    FileUtils.rm_rf("_test_attachments")
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <metanorma-extension><attachment name="_a_attachments/spec_helper.rb">data:text/html;base64,cmVxdWlyZSAidmNyIgoKVkNSLmNvbmZpZ3VyZS
BkbyB8Y29uZmlnfAogIGNvbmZpZy5jYXNzZXR0ZV9saWJyYXJ5X2RpciA9IC
JzcGVjL3Zjcl9jYXNzZXR0ZXMiCiAgY29uZmlnLmhvb2tfaW50byA6d2VibW
9jawogIGNvbmZpZy5kZWZhdWx0X2Nhc3NldHRlX29wdGlvbnMgPSB7CiAgIC
BjbGVhbl9vdXRkYXRlZF9odHRwX2ludGVyYWN0aW9uczogdHJ1ZSwKICAgIH
JlX3JlY29yZF9pbnRlcnZhbDogMTUxMjAwMCwKICAgIHJlY29yZDogOm9uY2
UsCiAgfQplbmQKCnJlcXVpcmUgInNpbXBsZWNvdiIKU2ltcGxlQ292LnN0YX
J0IGRvCiAgYWRkX2ZpbHRlciAiL3NwZWMvIgplbmQKCnJlcXVpcmUgImJ1bm
RsZXIvc2V0dXAiCnJlcXVpcmUgImFzY2lpZG9jdG9yIgpyZXF1aXJlICJtZX
Rhbm9ybWEtc3RhbmRvYyIKcmVxdWlyZSAicnNwZWMvbWF0Y2hlcnMiCnJlcX
VpcmUgImVxdWl2YWxlbnQteG1sIgpyZXF1aXJlICJtZXRhbm9ybWEvc3Rhbm
RvYyIKcmVxdWlyZSAieG1sLWMxNG4iCgpEaXJbRmlsZS5leHBhbmRfcGF0aC
giLi9zdXBwb3J0LyoqLyoqLyoucmIiLCBfX2Rpcl9fKV0KICAuc29ydC5lYW
NoIHsgfGZ8IHJlcXVpcmUgZiB9CgpSU3BlYy5jb25maWd1cmUgZG8gfGNvbm
ZpZ3wKICAjIEVuYWJsZSBmbGFncyBsaWtlIC0tb25seS1mYWlsdXJlcyBhbm
QgLS1uZXh0LWZhaWx1cmUKICBjb25maWcuZXhhbXBsZV9zdGF0dXNfcGVyc2
lzdGVuY2VfZmlsZV9wYXRoID0gIi5yc3BlY19zdGF0dXMiCgogICMgRGlzYW
JsZSBSU3BlYyBleHBvc2luZyBtZXRob2RzIGdsb2JhbGx5IG9uIGBNb2R1bG
VgIGFuZCBgbWFpbmAKICBjb25maWcuZGlzYWJsZV9tb25rZXlfcGF0Y2hpbm
chCgogIGNvbmZpZy5leHBlY3Rfd2l0aCA6cnNwZWMgZG8gfGN8CiAgICBjLn
N5bnRheCA9IDpleHBlY3QKICBlbmQKCiAgY29uZmlnLmFyb3VuZCA6ZWFjaC
BkbyB8ZXhhbXBsZXwKICAgIGV4YW1wbGUucnVuCiAgcmVzY3VlIFN5c3RlbU
V4aXQKICAgIGZhaWwgIlVuZXhwZWN0ZWQgZXhpdCBlbmNvdW50ZXJlZCIKIC
BlbmQKZW5kCgpPUFRJT05TID0gW2JhY2tlbmQ6IDpzdGFuZG9jLCBoZWFkZX
JfZm9vdGVyOiB0cnVlLCBhZ3JlZV90b190ZXJtczogdHJ1ZV0uZnJlZXplCg
pkZWYgc3RyaXBfZ3VpZCh4bWwpCiAgeG1sLmdzdWIoJXJ7IGlkPSJfW14iXS
sifSwgJyBpZD0iXyInKQogICAgLmdzdWIoJXJ7IHRhcmdldD0iX1teIl0rIn
0sICcgdGFyZ2V0PSJfIicpCiAgICAuZ3N1Yiglcns8ZmV0Y2hlZD5bXjxdKz
wvZmV0Y2hlZD59LCAiPGZldGNoZWQvPiIpCiAgICAuZ3N1Yiglcnsgc2NoZW
1hLXZlcnNpb249IlteIl0rIn0sICIiKQplbmQKCmRlZiBzdHJpcF9zcmMoeG
1sKQogIHhtbC5nc3ViKC9cc3NyYz0iW14iXSsiLywgJyBzcmM9Il8iJykKZW
5kCgpYU0wgPSBOb2tvZ2lyaTo6WFNMVCg8PH5YU0wuZnJlZXplKQogIDx4c2
w6c3R5bGVzaGVldCB2ZXJzaW9uPSIxLjAiIHhtbG5zOnhzbD0iaHR0cDovL3
d3dy53My5vcmcvMTk5OS9YU0wvVHJhbnNmb3JtIj4KICAgIDx4c2w6b3V0cH
V0IG1ldGhvZD0ieG1sIiBlbmNvZGluZz0iVVRGLTgiIGluZGVudD0ieWVzIi
8+CiAgICA8eHNsOnN0cmlwLXNwYWNlIGVsZW1lbnRzPSIqIi8+CiAgICA8eH
NsOnRlbXBsYXRlIG1hdGNoPSIvIj4KICAgICAgPHhzbDpjb3B5LW9mIHNlbG
VjdD0iLiIvPgogICAgPC94c2w6dGVtcGxhdGU+CiAgPC94c2w6c3R5bGVzaG
VldD4KWFNMCgpBU0NJSURPQ19CTEFOS19IRFIgPSA8PH5IRFIuZnJlZXplCi
AgPSBEb2N1bWVudCB0aXRsZQogIEF1dGhvcgogIDpkb2NmaWxlOiB0ZXN0Lm
Fkb2MKICA6bm9kb2M6CiAgOm5vdmFsaWQ6CiAgOm5vLWlzb2JpYjoKICA6ZG
F0YS11cmktaW1hZ2U6IGZhbHNlCgpIRFIKCkRVTUJRVU9URV9CTEFOS19IRF
IgPSA8PH5IRFIuZnJlZXplCiAgPSBEb2N1bWVudCB0aXRsZQogIEF1dGhvcg
ogIDpkb2NmaWxlOiB0ZXN0LmFkb2MKICA6bm9kb2M6CiAgOm5vdmFsaWQ6Ci
AgOm5vLWlzb2JpYjoKICA6c21hcnRxdW90ZXM6IGZhbHNlCgpIRFIKCklTT0
JJQl9CTEFOS19IRFIgPSA8PH5IRFIuZnJlZXplCiAgPSBEb2N1bWVudCB0aX
RsZQogIEF1dGhvcgogIDpkb2NmaWxlOiB0ZXN0LmFkb2MKICA6bm9kb2M6Ci
AgOm5vdmFsaWQ6CiAgOm5vLWlzb2JpYi1jYWNoZToKCkhEUgoKRkxVU0hfQ0
FDSEVfSVNPQklCX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3
VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogID
pub2RvYzoKICA6bm92YWxpZDoKICA6Zmx1c2gtY2FjaGVzOgoKSERSCgpDQU
NIRURfSVNPQklCX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3
VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogID
pub2RvYzoKICA6bm92YWxpZDoKCkhEUgoKTE9DQUxfQ0FDSEVEX0lTT0JJQl
9CTEFOS19IRFIgPSA8PH5IRFIuZnJlZXplCiAgPSBEb2N1bWVudCB0aXRsZQ
ogIEF1dGhvcgogIDpkb2NmaWxlOiB0ZXN0LmFkb2MKICA6bm9kb2M6CiAgOm
5vdmFsaWQ6CiAgOmxvY2FsLWNhY2hlOgoKSERSCgpMT0NBTF9PTkxZX0NBQ0
hFRF9JU09CSUJfQkxBTktfSERSID0gPDx+SERSLmZyZWV6ZQogID0gRG9jdW
1lbnQgdGl0bGUKICBBdXRob3IKICA6ZG9jZmlsZTogdGVzdC5hZG9jCiAgOm
5vZG9jOgogIDpub3ZhbGlkOgogIDpsb2NhbC1jYWNoZS1vbmx5OgoKSERSCg
pWQUxJREFUSU5HX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3
VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogID
pub2RvYzoKICA6bm8taXNvYmliOgoKSERSCgpOT1JNX1JFRl9CT0lMRVJQTE
FURSA9IDw8fkhEUi5mcmVlemUKICA8cCBpZD0iXyI+VGhlIGZvbGxvd2luZy
Bkb2N1bWVudHMgYXJlIHJlZmVycmVkIHRvIGluIHRoZSB0ZXh0IGluIHN1Y2
ggYSB3YXkgdGhhdCBzb21lIG9yIGFsbCBvZiB0aGVpciBjb250ZW50IGNvbn
N0aXR1dGVzIHJlcXVpcmVtZW50cyBvZiB0aGlzIGRvY3VtZW50LiBGb3IgZG
F0ZWQgcmVmZXJlbmNlcywgb25seSB0aGUgZWRpdGlvbiBjaXRlZCBhcHBsaW
VzLiBGb3IgdW5kYXRlZCByZWZlcmVuY2VzLCB0aGUgbGF0ZXN0IGVkaXRpb2
4gb2YgdGhlIHJlZmVyZW5jZWQgZG9jdW1lbnQgKGluY2x1ZGluZyBhbnkgYW
1lbmRtZW50cykgYXBwbGllcy48L3A+CkhEUgoKQkxBTktfSERSID0gPDx+Ik
hEUiIuZnJlZXplCiAgPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVV
RGLTgiPz4KICA8c3RhbmRhcmQtZG9jdW1lbnQgeG1sbnM9Imh0dHBzOi8vd3
d3Lm1ldGFub3JtYS5vcmcvbnMvc3RhbmRvYyIgdmVyc2lvbj0iI3tNZXRhbm
9ybWE6OlN0YW5kb2M6OlZFUlNJT059IiB0eXBlPSJzZW1hbnRpYyI+CiAgPG
JpYmRhdGEgdHlwZT0ic3RhbmRhcmQiPgogIDx0aXRsZSBsYW5ndWFnZT0iZW
4iIGZvcm1hdD0idGV4dC9wbGFpbiI+RG9jdW1lbnQgdGl0bGU8L3RpdGxlPg
ogICAgPGxhbmd1YWdlPmVuPC9sYW5ndWFnZT4KICAgIDxzY3JpcHQ+TGF0bj
wvc2NyaXB0PgogICAgPHN0YXR1cz48c3RhZ2U+cHVibGlzaGVkPC9zdGFnZT
48L3N0YXR1cz4KICAgIDxjb3B5cmlnaHQ+CiAgICAgIDxmcm9tPiN7VGltZS
5uZXcueWVhcn08L2Zyb20+CiAgICA8L2NvcHlyaWdodD4KICAgIDxleHQ+Ci
AgICA8ZG9jdHlwZT5zdGFuZGFyZDwvZG9jdHlwZT4KICAgIDwvZXh0PgogID
wvYmliZGF0YT4KICAgIDxtZXRhbm9ybWEtZXh0ZW5zaW9uPgogICAgPHByZX
NlbnRhdGlvbi1tZXRhZGF0YT4KICAgICAgPG5hbWU+VE9DIEhlYWRpbmcgTG
V2ZWxzPC9uYW1lPgogICAgICA8dmFsdWU+MjwvdmFsdWU+CiAgICA8L3ByZX
NlbnRhdGlvbi1tZXRhZGF0YT4KICAgIDxwcmVzZW50YXRpb24tbWV0YWRhdG
E+CiAgICAgIDxuYW1lPkhUTUwgVE9DIEhlYWRpbmcgTGV2ZWxzPC9uYW1lPg
ogICAgICA8dmFsdWU+MjwvdmFsdWU+CiAgICA8L3ByZXNlbnRhdGlvbi1tZX
RhZGF0YT4KICAgIDxwcmVzZW50YXRpb24tbWV0YWRhdGE+CiAgICAgIDxuYW
1lPkRPQyBUT0MgSGVhZGluZyBMZXZlbHM8L25hbWU+CiAgICAgIDx2YWx1ZT
4yPC92YWx1ZT4KICAgIDwvcHJlc2VudGF0aW9uLW1ldGFkYXRhPgogICAgPH
ByZXNlbnRhdGlvbi1tZXRhZGF0YT4KICAgICAgPG5hbWU+UERGIFRPQyBIZW
FkaW5nIExldmVsczwvbmFtZT4KICAgICAgPHZhbHVlPjI8L3ZhbHVlPgogIC
AgPC9wcmVzZW50YXRpb24tbWV0YWRhdGE+CiAgPC9tZXRhbm9ybWEtZXh0ZW
5zaW9uPgpIRFIKCkJMQU5LX01FVEFOT1JNQV9IRFIgPSA8PH4iSERSIi5mcm
VlemUKICA8IURPQ1RZUEUgaHRtbCBQVUJMSUMgIi0vL1czQy8vRFREIEhUTU
wgNC4wIFRyYW5zaXRpb25hbC8vRU4iICJodHRwOi8vd3d3LnczLm9yZy9UUi
9SRUMtaHRtbDQwL2xvb3NlLmR0ZCI+CiAgPD94bWwgdmVyc2lvbj0iMS4wIi
BlbmNvZGluZz0iVVRGLTgiPz48aHRtbD48Ym9keT4KICA8c3RhbmRhcmQtZG
9jdW1lbnQgeG1sbnM9Imh0dHBzOi8vd3d3Lm1ldGFub3JtYS5vcmcvbnMvc3
RhbmRvYyIgdmVyc2lvbj0iI3tNZXRhbm9ybWE6OlN0YW5kb2M6OlZFUlNJT0
59IiB0eXBlPSJzZW1hbnRpYyI+CiAgPGJpYmRhdGEgdHlwZT0ic3RhbmRhcm
QiPgogIDx0aXRsZSBsYW5ndWFnZT0iZW4iIGZvcm1hdD0idGV4dC9wbGFpbi
I+RG9jdW1lbnQgdGl0bGU8L3RpdGxlPgogICAgPGxhbmd1YWdlPmVuPC9sYW
5ndWFnZT4KICAgIDxzY3JpcHQ+TGF0bjwvc2NyaXB0PgogICAgPHN0YXR1cz
48c3RhZ2U+cHVibGlzaGVkPC9zdGFnZT48L3N0YXR1cz4KICAgIDxjb3B5cm
lnaHQ+CiAgICAgIDxmcm9tPiN7VGltZS5uZXcueWVhcn08L2Zyb20+CiAgIC
A8L2NvcHlyaWdodD4KICAgIDxleHQ+CiAgICA8ZG9jdHlwZT5hcnRpY2xlPC
9kb2N0eXBlPgogICAgPC9leHQ+CiAgPC9iaWJkYXRhPgpIRFIKCkhUTUxfSE
RSID0gPDx+SERSLmZyZWV6ZQogIDxodG1sIHhtbG5zOmVwdWI9Imh0dHA6Ly
93d3cuaWRwZi5vcmcvMjAwNy9vcHMiPgogICAgPGhlYWQ+CiAgICAgIDx0aX
RsZT50ZXN0PC90aXRsZT4KICAgIDwvaGVhZD4KICAgIDxib2R5IGxhbmc9Ik
VOLVVTIiBsaW5rPSJibHVlIiB2bGluaz0iIzk1NEY3MiI+CiAgICAgIDxkaX
YgY2xhc3M9InRpdGxlLXNlY3Rpb24iPgogICAgICAgIDxwPiYjMTYwOzwvcD
4KICAgICAgPC9kaXY+CiAgICAgIDxici8+CiAgICAgIDxkaXYgY2xhc3M9In
ByZWZhdG9yeS1zZWN0aW9uIj4KICAgICAgICA8cD4mIzE2MDs8L3A+CiAgIC
AgIDwvZGl2PgogICAgICA8YnIvPgogICAgICA8ZGl2IGNsYXNzPSJtYWluLX
NlY3Rpb24iPgpIRFIKCldPUkRfSERSID0gPDx+SERSLmZyZWV6ZQogIDxodG
1sIHhtbG5zOmVwdWI9Imh0dHA6Ly93d3cuaWRwZi5vcmcvMjAwNy9vcHMiPg
ogICAgPGhlYWQ+CiAgICAgIDx0aXRsZT50ZXN0PC90aXRsZT4KICAgIDwvaG
VhZD4KICAgIDxib2R5IGxhbmc9IkVOLVVTIiBsaW5rPSJibHVlIiB2bGluaz
0iIzk1NEY3MiI+CiAgICAgIDxkaXYgY2xhc3M9IldvcmRTZWN0aW9uMSI+Ci
AgICAgICAgPHA+JiMxNjA7PC9wPgogICAgICA8L2Rpdj4KICAgICAgPGJyIG
NsZWFyPSJhbGwiIGNsYXNzPSJzZWN0aW9uIi8+CiAgICAgIDxkaXYgY2xhc3
M9IldvcmRTZWN0aW9uMiI+CiAgICAgICAgPHA+JiMxNjA7PC9wPgogICAgIC
A8L2Rpdj4KICAgICAgPGJyIGNsZWFyPSJhbGwiIGNsYXNzPSJzZWN0aW9uIi
8+CiAgICAgIDxkaXYgY2xhc3M9IldvcmRTZWN0aW9uMyI+CkhEUgoKZGVmIG
V4YW1wbGVzX3BhdGgocGF0aCkKICBGaWxlLmpvaW4oRmlsZS5leHBhbmRfcG
F0aCgiLi9leGFtcGxlcyIsIF9fZGlyX18pLCBwYXRoKQplbmQKCmRlZiBmaX
h0dXJlc19wYXRoKHBhdGgpCiAgRmlsZS5qb2luKEZpbGUuZXhwYW5kX3BhdG
goIi4vZml4dHVyZXMiLCBfX2Rpcl9fKSwgcGF0aCkKZW5kCgpkZWYgc3R1Yl
9mZXRjaF9yZWYoKipvcHRzKQogIHhtbCA9ICIiCgogIGhpdCA9IGRvdWJsZS
giaGl0IikKICBleHBlY3QoaGl0KS50byByZWNlaXZlKDpbXSkud2l0aCgidG
l0bGUiKSBkbwogICAgTm9rb2dpcmk6OlhNTCh4bWwpLmF0KCIvL2RvY2lkZW
50aWZpZXIiKS5jb250ZW50CiAgZW5kLmF0X2xlYXN0KDpvbmNlKQoKICBoaX
RfaW5zdGFuY2UgPSBkb3VibGUoImhpdF9pbnN0YW5jZSIpCiAgZXhwZWN0KG
hpdF9pbnN0YW5jZSkudG8gcmVjZWl2ZSg6aGl0KS5hbmRfcmV0dXJuKGhpdC
kuYXRfbGVhc3QoOm9uY2UpCiAgZXhwZWN0KGhpdF9pbnN0YW5jZSkudG8gcm
VjZWl2ZSg6dG9feG1sKSBkbyB8YnVpbGRlciwgb3B0fAogICAgZXhwZWN0KG
J1aWxkZXIpLnRvIGJlX2luc3RhbmNlX29mIE5va29naXJpOjpYTUw6OkJ1aW
xkZXIKICAgIGV4cGVjdChvcHQpLnRvIGVxIG9wdHMKICAgIGJ1aWxkZXIgPD
wgeG1sCiAgZW5kLmF0X2xlYXN0IDpvbmNlCgogIGhpdF9wYWdlID0gZG91Ym
xlKCJoaXRfcGFnZSIpCiAgZXhwZWN0KGhpdF9wYWdlKS50byByZWNlaXZlKD
pmaXJzdCkuYW5kX3JldHVybihoaXRfaW5zdGFuY2UpLmF0X2xlYXN0IDpvbm
NlCgogIGhpdF9wYWdlcyA9IGRvdWJsZSgiaGl0X3BhZ2VzIikKICBleHBlY3
QoaGl0X3BhZ2VzKS50byByZWNlaXZlKDpmaXJzdCkuYW5kX3JldHVybihoaX
RfcGFnZSkuYXRfbGVhc3QgOm9uY2UKCiAgZXhwZWN0KFJlbGF0b25Jc286Ok
lzb0JpYmxpb2dyYXBoeSkudG8gcmVjZWl2ZSg6c2VhcmNoKQogICAgLmFuZF
93cmFwX29yaWdpbmFsIGRvIHxzZWFyY2gsICphcmdzfAogICAgY29kZSA9IG
FyZ3NbMF0KICAgIGV4cGVjdChjb2RlKS50byBiZV9pbnN0YW5jZV9vZiBTdH
JpbmcKICAgIHhtbCA9IGdldF94bWwoc2VhcmNoLCBjb2RlLCBvcHRzKQogIC
AgaGl0X3BhZ2VzCiAgZW5kLmF0X2xlYXN0IDpvbmNlCmVuZAoKcHJpdmF0ZQ
oKZGVmIGdldF94bWwoc2VhcmNoLCBjb2RlLCBvcHRzKQogIGMgPSBjb2RlLm
dzdWIoJXJ7Wy9cczotXX0sICJfIikuc3ViKCVye18rJH0sICIiKS5kb3duY2
FzZQogIGZpbGUgPSBleGFtcGxlc19wYXRoKCIje1tjLCBvcHRzLmtleXMuam
9pbignXycpXS5qb2luICdfJ30ueG1sIikKICBpZiBGaWxlLmV4aXN0PyBmaW
xlCiAgICBGaWxlLnJlYWQgZmlsZQogIGVsc2UKICAgIHhtbCA9IHNlYXJjaC
5jYWxsKGNvZGUpJi5maXJzdCYuZmlyc3QmLnRvX3htbCBuaWwsIG9wdHMKIC
AgIEZpbGUud3JpdGUgZmlsZSwgeG1sCiAgICB4bWwKICBlbmQKZW5kCgpkZW
YgbW9ja19vcGVuX3VyaShjb2RlKQogIGV4cGVjdChPcGVuVVJJKS50byByZW
NlaXZlKDpvcGVuX3VyaSkuYW5kX3dyYXBfb3JpZ2luYWwgZG8gfG0sICphcm
dzfAogICAgIyBleHBlY3QoYXJnc1swXSkudG8gYmVfaW5zdGFuY2Vfb2YgU3
RyaW5nCiAgICBmaWxlID0gZXhhbXBsZXNfcGF0aCgiI3tjb2RlLnRyKCctJy
wgJ18nKX0uaHRtbCIpCiAgICBGaWxlLndyaXRlIGZpbGUsIG0uY2FsbCgqYX
JncykucmVhZCB1bmxlc3MgRmlsZS5leGlzdD8gZmlsZQogICAgRmlsZS5yZW
FkIGZpbGUsIGVuY29kaW5nOiAidXRmLTgiCiAgZW5kLmF0X2xlYXN0IDpvbm
NlCmVuZAoKZGVmIG1ldGFub3JtYV9wcm9jZXNzKGlucHV0KQogIE1ldGFub3
JtYTo6SW5wdXQ6OkFzY2lpZG9jCiAgICAubmV3CiAgICAucHJvY2Vzcyhpbn
B1dCwgInRlc3QuYWRvYyIsIDpzdGFuZG9jKQplbmQKCmRlZiB4bWxfc3RyaW
5nX2NvbmVudCh4bWwpCiAgc3RyaXBfZ3VpZChOb2tvZ2lyaTo6SFRNTCh4bW
wpLnRvX3MpCmVuZAo=</attachment>
        </metanorma-extension>
            <preface>
            <introduction id="intro">
            <figure id="N1"> <name>Split-it-right sample divider</name>
               <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
            </figure>
      </introduction></preface>
      </iso-standard>
    INPUT
    IsoDoc::PresentationXMLConvert.new({ filename: "test" }
      .merge(presxml_options))
      .convert("test", input, false)
    expect(File.exist?("_test_attachments/spec_helper.rb")).to be true
    expect(File.read("_test_attachments/spec_helper.rb"))
      .to include("VCR.configure")
  end

  private

  def mock_preprocess_xslt_read
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:preprocess_xslt_read)
      .and_return "spec/assets/preprocess-xslt.xml"
  end
end
