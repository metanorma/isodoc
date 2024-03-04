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
           <foreword id="fwd" displayorder="2">
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new({})
      .convert("test", input, true))))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true))
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new(presxml_options)
  .convert("test", input, true))
  .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ tocfigures: true,
             toctables: true,
             tocrecommendations: true }
      .merge(presxml_options))
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
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
    expect(xmlpp(strip_guid(IsoDoc::PresentationXMLConvert
      .new({ fonts: "font1; font2", fontlicenseagreement: "no-install-fonts" }
      .merge(presxml_options))
      .convert("test", input, true)))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
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
                   <foreword displayorder="1">
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
                <p>NONE-SPECIFIED:  : note</p>
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
                <p class="Note">NONE-SPECIFIED:<span style="mso-tab-count:1">  </span>: note</p>
              </div>
              <p class="TermNum" id=""/>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(word)
  end

  it "extracts attachments" do
    FileUtils.rm_rf("_test_attachments")
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <metanorma-extension><attachment name="spec_helper.rb">data:text/html;base64,cmVxdWlyZSAidmNyIgoKVkNSLmNvbmZpZ3VyZSBkbyB8Y29uZmlnfAogIGNvbmZpZy5jYXNzZXR0ZV9saWJyYXJ5X2RpciA9ICJzcGVjL3Zjcl9jYXNzZXR0ZXMiCiAgY29uZmlnLmhvb2tfaW50byA6d2VibW9jawogIGNvbmZpZy5kZWZhdWx0X2Nhc3NldHRlX29wdGlvbnMgPSB7CiAgICBjbGVhbl9vdXRkYXRlZF9odHRwX2ludGVyYWN0aW9uczogdHJ1ZSwKICAgIHJlX3JlY29yZF9pbnRlcnZhbDogMTUxMjAwMCwKICAgIHJlY29yZDogOm9uY2UsCiAgfQplbmQKCnJlcXVpcmUgInNpbXBsZWNvdiIKU2ltcGxlQ292LnN0YXJ0IGRvCiAgYWRkX2ZpbHRlciAiL3NwZWMvIgplbmQKCnJlcXVpcmUgImJ1bmRsZXIvc2V0dXAiCnJlcXVpcmUgImFzY2lpZG9jdG9yIgpyZXF1aXJlICJtZXRhbm9ybWEtc3RhbmRvYyIKcmVxdWlyZSAicnNwZWMvbWF0Y2hlcnMiCnJlcXVpcmUgImVxdWl2YWxlbnQteG1sIgpyZXF1aXJlICJtZXRhbm9ybWEvc3RhbmRvYyIKCkRpcltGaWxlLmV4cGFuZF9wYXRoKCIuL3N1cHBvcnQvKiovKiovKi5yYiIsIF9fZGlyX18pXQogIC5zb3J0LmVhY2ggeyB8ZnwgcmVxdWlyZSBmIH0KClJTcGVjLmNvbmZpZ3VyZSBkbyB8Y29uZmlnfAogICMgRW5hYmxlIGZsYWdzIGxpa2UgLS1vbmx5LWZhaWx1cmVzIGFuZCAtLW5leHQtZmFpbHVyZQogIGNvbmZpZy5leGFtcGxlX3N0YXR1c19wZXJzaXN0ZW5jZV9maWxlX3BhdGggPSAiLnJzcGVjX3N0YXR1cyIKCiAgIyBEaXNhYmxlIFJTcGVjIGV4cG9zaW5nIG1ldGhvZHMgZ2xvYmFsbHkgb24gYE1vZHVsZWAgYW5kIGBtYWluYAogIGNvbmZpZy5kaXNhYmxlX21vbmtleV9wYXRjaGluZyEKCiAgY29uZmlnLmV4cGVjdF93aXRoIDpyc3BlYyBkbyB8Y3wKICAgIGMuc3ludGF4ID0gOmV4cGVjdAogIGVuZAoKICBjb25maWcuYXJvdW5kIDplYWNoIGRvIHxleGFtcGxlfAogICAgZXhhbXBsZS5ydW4KICByZXNjdWUgU3lzdGVtRXhpdAogICAgZmFpbCAiVW5leHBlY3RlZCBleGl0IGVuY291bnRlcmVkIgogIGVuZAplbmQKCk9QVElPTlMgPSBbYmFja2VuZDogOnN0YW5kb2MsIGhlYWRlcl9mb290ZXI6IHRydWUsIGFncmVlX3RvX3Rlcm1zOiB0cnVlXS5mcmVlemUKCmRlZiBzdHJpcF9ndWlkKHhtbCkKICB4bWwuZ3N1YiglcnsgaWQ9Il9bXiJdKyJ9LCAnIGlkPSJfIicpCiAgICAuZ3N1YiglcnsgdGFyZ2V0PSJfW14iXSsifSwgJyB0YXJnZXQ9Il8iJykKZW5kCgpkZWYgc3RyaXBfc3JjKHhtbCkKICB4bWwuZ3N1YigvXHNzcmM9IlteIl0rIi8sICcgc3JjPSJfIicpCmVuZAoKWFNMID0gTm9rb2dpcmk6OlhTTFQoPDx+WFNMLmZyZWV6ZSkKICA8eHNsOnN0eWxlc2hlZXQgdmVyc2lvbj0iMS4wIiB4bWxuczp4c2w9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvWFNML1RyYW5zZm9ybSI+CiAgICA8eHNsOm91dHB1dCBtZXRob2Q9InhtbCIgZW5jb2Rpbmc9IlVURi04IiBpbmRlbnQ9InllcyIvPgogICAgPHhzbDpzdHJpcC1zcGFjZSBlbGVtZW50cz0iKiIvPgogICAgPHhzbDp0ZW1wbGF0ZSBtYXRjaD0iLyI+CiAgICAgIDx4c2w6Y29weS1vZiBzZWxlY3Q9Ii4iLz4KICAgIDwveHNsOnRlbXBsYXRlPgogIDwveHNsOnN0eWxlc2hlZXQ+ClhTTAoKZGVmIHhtbHBwKHhtbCkKICBjID0gSFRNTEVudGl0aWVzLm5ldwogIHhtbCAmJj0geG1sLnNwbGl0KC8oJlxTKz87KS8pLm1hcCBkbyB8bnwKICAgIGlmIC9eJlxTKz87JC8ubWF0Y2g/KG4pCiAgICAgIGMuZW5jb2RlKGMuZGVjb2RlKG4pLCA6aGV4YWRlY2ltYWwpCiAgICBlbHNlIG4KICAgIGVuZAogIGVuZC5qb2luCiAgWFNMLnRyYW5zZm9ybShOb2tvZ2lyaTo6WE1MKHhtbCwgJjpub2JsYW5rcykpCiAgICAudG9feG1sKGluZGVudDogMiwgZW5jb2Rpbmc6ICJVVEYtOCIpCiAgICAuZ3N1Yiglcns8ZmV0Y2hlZD5bXjxdKzwvZmV0Y2hlZD59LCAiPGZldGNoZWQvPiIpCiAgICAuZ3N1Yiglcnsgc2NoZW1hLXZlcnNpb249IlteIl0rIn0sICIiKQplbmQKCkFTQ0lJRE9DX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogIDpub2RvYzoKICA6bm92YWxpZDoKICA6bm8taXNvYmliOgogIDpkYXRhLXVyaS1pbWFnZTogZmFsc2UKCkhEUgoKRFVNQlFVT1RFX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogIDpub2RvYzoKICA6bm92YWxpZDoKICA6bm8taXNvYmliOgogIDpzbWFydHF1b3RlczogZmFsc2UKCkhEUgoKSVNPQklCX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogIDpub2RvYzoKICA6bm92YWxpZDoKICA6bm8taXNvYmliLWNhY2hlOgoKSERSCgpGTFVTSF9DQUNIRV9JU09CSUJfQkxBTktfSERSID0gPDx+SERSLmZyZWV6ZQogID0gRG9jdW1lbnQgdGl0bGUKICBBdXRob3IKICA6ZG9jZmlsZTogdGVzdC5hZG9jCiAgOm5vZG9jOgogIDpub3ZhbGlkOgogIDpmbHVzaC1jYWNoZXM6CgpIRFIKCkNBQ0hFRF9JU09CSUJfQkxBTktfSERSID0gPDx+SERSLmZyZWV6ZQogID0gRG9jdW1lbnQgdGl0bGUKICBBdXRob3IKICA6ZG9jZmlsZTogdGVzdC5hZG9jCiAgOm5vZG9jOgogIDpub3ZhbGlkOgoKSERSCgpMT0NBTF9DQUNIRURfSVNPQklCX0JMQU5LX0hEUiA9IDw8fkhEUi5mcmVlemUKICA9IERvY3VtZW50IHRpdGxlCiAgQXV0aG9yCiAgOmRvY2ZpbGU6IHRlc3QuYWRvYwogIDpub2RvYzoKICA6bm92YWxpZDoKICA6bG9jYWwtY2FjaGU6CgpIRFIKCkxPQ0FMX09OTFlfQ0FDSEVEX0lTT0JJQl9CTEFOS19IRFIgPSA8PH5IRFIuZnJlZXplCiAgPSBEb2N1bWVudCB0aXRsZQogIEF1dGhvcgogIDpkb2NmaWxlOiB0ZXN0LmFkb2MKICA6bm9kb2M6CiAgOm5vdmFsaWQ6CiAgOmxvY2FsLWNhY2hlLW9ubHk6CgpIRFIKClZBTElEQVRJTkdfQkxBTktfSERSID0gPDx+SERSLmZyZWV6ZQogID0gRG9jdW1lbnQgdGl0bGUKICBBdXRob3IKICA6ZG9jZmlsZTogdGVzdC5hZG9jCiAgOm5vZG9jOgogIDpuby1pc29iaWI6CgpIRFIKCk5PUk1fUkVGX0JPSUxFUlBMQVRFID0gPDx+SERSLmZyZWV6ZQogIDxwIGlkPSJfIj5UaGUgZm9sbG93aW5nIGRvY3VtZW50cyBhcmUgcmVmZXJyZWQgdG8gaW4gdGhlIHRleHQgaW4gc3VjaCBhIHdheSB0aGF0IHNvbWUgb3IgYWxsIG9mIHRoZWlyIGNvbnRlbnQgY29uc3RpdHV0ZXMgcmVxdWlyZW1lbnRzIG9mIHRoaXMgZG9jdW1lbnQuIEZvciBkYXRlZCByZWZlcmVuY2VzLCBvbmx5IHRoZSBlZGl0aW9uIGNpdGVkIGFwcGxpZXMuIEZvciB1bmRhdGVkIHJlZmVyZW5jZXMsIHRoZSBsYXRlc3QgZWRpdGlvbiBvZiB0aGUgcmVmZXJlbmNlZCBkb2N1bWVudCAoaW5jbHVkaW5nIGFueSBhbWVuZG1lbnRzKSBhcHBsaWVzLjwvcD4KSERSCgpCTEFOS19IRFIgPSA8PH4iSERSIi5mcmVlemUKICA8P3htbCB2ZXJzaW9uPSIxLjAiIGVuY29kaW5nPSJVVEYtOCI/PgogIDxzdGFuZGFyZC1kb2N1bWVudCB4bWxucz0iaHR0cHM6Ly93d3cubWV0YW5vcm1hLm9yZy9ucy9zdGFuZG9jIiB2ZXJzaW9uPSIje01ldGFub3JtYTo6U3RhbmRvYzo6VkVSU0lPTn0iIHR5cGU9InNlbWFudGljIj4KICA8YmliZGF0YSB0eXBlPSJzdGFuZGFyZCI+CiAgPHRpdGxlIGxhbmd1YWdlPSJlbiIgZm9ybWF0PSJ0ZXh0L3BsYWluIj5Eb2N1bWVudCB0aXRsZTwvdGl0bGU+CiAgICA8bGFuZ3VhZ2U+ZW48L2xhbmd1YWdlPgogICAgPHNjcmlwdD5MYXRuPC9zY3JpcHQ+CiAgICA8c3RhdHVzPjxzdGFnZT5wdWJsaXNoZWQ8L3N0YWdlPjwvc3RhdHVzPgogICAgPGNvcHlyaWdodD4KICAgICAgPGZyb20+I3tUaW1lLm5ldy55ZWFyfTwvZnJvbT4KICAgIDwvY29weXJpZ2h0PgogICAgPGV4dD4KICAgIDxkb2N0eXBlPnN0YW5kYXJkPC9kb2N0eXBlPgogICAgPC9leHQ+CiAgPC9iaWJkYXRhPgogICAgPG1ldGFub3JtYS1leHRlbnNpb24+CiAgICA8cHJlc2VudGF0aW9uLW1ldGFkYXRhPgogICAgICA8bmFtZT5UT0MgSGVhZGluZyBMZXZlbHM8L25hbWU+CiAgICAgIDx2YWx1ZT4yPC92YWx1ZT4KICAgIDwvcHJlc2VudGF0aW9uLW1ldGFkYXRhPgogICAgPHByZXNlbnRhdGlvbi1tZXRhZGF0YT4KICAgICAgPG5hbWU+SFRNTCBUT0MgSGVhZGluZyBMZXZlbHM8L25hbWU+CiAgICAgIDx2YWx1ZT4yPC92YWx1ZT4KICAgIDwvcHJlc2VudGF0aW9uLW1ldGFkYXRhPgogICAgPHByZXNlbnRhdGlvbi1tZXRhZGF0YT4KICAgICAgPG5hbWU+RE9DIFRPQyBIZWFkaW5nIExldmVsczwvbmFtZT4KICAgICAgPHZhbHVlPjI8L3ZhbHVlPgogICAgPC9wcmVzZW50YXRpb24tbWV0YWRhdGE+CiAgICA8cHJlc2VudGF0aW9uLW1ldGFkYXRhPgogICAgICA8bmFtZT5QREYgVE9DIEhlYWRpbmcgTGV2ZWxzPC9uYW1lPgogICAgICA8dmFsdWU+MjwvdmFsdWU+CiAgICA8L3ByZXNlbnRhdGlvbi1tZXRhZGF0YT4KICA8L21ldGFub3JtYS1leHRlbnNpb24+CkhEUgoKQkxBTktfTUVUQU5PUk1BX0hEUiA9IDw8fiJIRFIiLmZyZWV6ZQogIDwhRE9DVFlQRSBodG1sIFBVQkxJQyAiLS8vVzNDLy9EVEQgSFRNTCA0LjAgVHJhbnNpdGlvbmFsLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL1RSL1JFQy1odG1sNDAvbG9vc2UuZHRkIj4KICA8P3htbCB2ZXJzaW9uPSIxLjAiIGVuY29kaW5nPSJVVEYtOCI/PjxodG1sPjxib2R5PgogIDxzdGFuZGFyZC1kb2N1bWVudCB4bWxucz0iaHR0cHM6Ly93d3cubWV0YW5vcm1hLm9yZy9ucy9zdGFuZG9jIiB2ZXJzaW9uPSIje01ldGFub3JtYTo6U3RhbmRvYzo6VkVSU0lPTn0iIHR5cGU9InNlbWFudGljIj4KICA8YmliZGF0YSB0eXBlPSJzdGFuZGFyZCI+CiAgPHRpdGxlIGxhbmd1YWdlPSJlbiIgZm9ybWF0PSJ0ZXh0L3BsYWluIj5Eb2N1bWVudCB0aXRsZTwvdGl0bGU+CiAgICA8bGFuZ3VhZ2U+ZW48L2xhbmd1YWdlPgogICAgPHNjcmlwdD5MYXRuPC9zY3JpcHQ+CiAgICA8c3RhdHVzPjxzdGFnZT5wdWJsaXNoZWQ8L3N0YWdlPjwvc3RhdHVzPgogICAgPGNvcHlyaWdodD4KICAgICAgPGZyb20+I3tUaW1lLm5ldy55ZWFyfTwvZnJvbT4KICAgIDwvY29weXJpZ2h0PgogICAgPGV4dD4KICAgIDxkb2N0eXBlPmFydGljbGU8L2RvY3R5cGU+CiAgICA8L2V4dD4KICA8L2JpYmRhdGE+CkhEUgoKSFRNTF9IRFIgPSA8PH5IRFIuZnJlZXplCiAgPGh0bWwgeG1sbnM6ZXB1Yj0iaHR0cDovL3d3dy5pZHBmLm9yZy8yMDA3L29wcyI+CiAgICA8aGVhZD4KICAgICAgPHRpdGxlPnRlc3Q8L3RpdGxlPgogICAgPC9oZWFkPgogICAgPGJvZHkgbGFuZz0iRU4tVVMiIGxpbms9ImJsdWUiIHZsaW5rPSIjOTU0RjcyIj4KICAgICAgPGRpdiBjbGFzcz0idGl0bGUtc2VjdGlvbiI+CiAgICAgICAgPHA+JiMxNjA7PC9wPgogICAgICA8L2Rpdj4KICAgICAgPGJyLz4KICAgICAgPGRpdiBjbGFzcz0icHJlZmF0b3J5LXNlY3Rpb24iPgogICAgICAgIDxwPiYjMTYwOzwvcD4KICAgICAgPC9kaXY+CiAgICAgIDxici8+CiAgICAgIDxkaXYgY2xhc3M9Im1haW4tc2VjdGlvbiI+CkhEUgoKV09SRF9IRFIgPSA8PH5IRFIuZnJlZXplCiAgPGh0bWwgeG1sbnM6ZXB1Yj0iaHR0cDovL3d3dy5pZHBmLm9yZy8yMDA3L29wcyI+CiAgICA8aGVhZD4KICAgICAgPHRpdGxlPnRlc3Q8L3RpdGxlPgogICAgPC9oZWFkPgogICAgPGJvZHkgbGFuZz0iRU4tVVMiIGxpbms9ImJsdWUiIHZsaW5rPSIjOTU0RjcyIj4KICAgICAgPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24xIj4KICAgICAgICA8cD4mIzE2MDs8L3A+CiAgICAgIDwvZGl2PgogICAgICA8YnIgY2xlYXI9ImFsbCIgY2xhc3M9InNlY3Rpb24iLz4KICAgICAgPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24yIj4KICAgICAgICA8cD4mIzE2MDs8L3A+CiAgICAgIDwvZGl2PgogICAgICA8YnIgY2xlYXI9ImFsbCIgY2xhc3M9InNlY3Rpb24iLz4KICAgICAgPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24zIj4KSERSCgpkZWYgZXhhbXBsZXNfcGF0aChwYXRoKQogIEZpbGUuam9pbihGaWxlLmV4cGFuZF9wYXRoKCIuL2V4YW1wbGVzIiwgX19kaXJfXyksIHBhdGgpCmVuZAoKZGVmIGZpeHR1cmVzX3BhdGgocGF0aCkKICBGaWxlLmpvaW4oRmlsZS5leHBhbmRfcGF0aCgiLi9maXh0dXJlcyIsIF9fZGlyX18pLCBwYXRoKQplbmQKCmRlZiBzdHViX2ZldGNoX3JlZigqKm9wdHMpCiAgeG1sID0gIiIKCiAgaGl0ID0gZG91YmxlKCJoaXQiKQogIGV4cGVjdChoaXQpLnRvIHJlY2VpdmUoOltdKS53aXRoKCJ0aXRsZSIpIGRvCiAgICBOb2tvZ2lyaTo6WE1MKHhtbCkuYXQoIi8vZG9jaWRlbnRpZmllciIpLmNvbnRlbnQKICBlbmQuYXRfbGVhc3QoOm9uY2UpCgogIGhpdF9pbnN0YW5jZSA9IGRvdWJsZSgiaGl0X2luc3RhbmNlIikKICBleHBlY3QoaGl0X2luc3RhbmNlKS50byByZWNlaXZlKDpoaXQpLmFuZF9yZXR1cm4oaGl0KS5hdF9sZWFzdCg6b25jZSkKICBleHBlY3QoaGl0X2luc3RhbmNlKS50byByZWNlaXZlKDp0b194bWwpIGRvIHxidWlsZGVyLCBvcHR8CiAgICBleHBlY3QoYnVpbGRlcikudG8gYmVfaW5zdGFuY2Vfb2YgTm9rb2dpcmk6OlhNTDo6QnVpbGRlcgogICAgZXhwZWN0KG9wdCkudG8gZXEgb3B0cwogICAgYnVpbGRlciA8PCB4bWwKICBlbmQuYXRfbGVhc3QgOm9uY2UKCiAgaGl0X3BhZ2UgPSBkb3VibGUoImhpdF9wYWdlIikKICBleHBlY3QoaGl0X3BhZ2UpLnRvIHJlY2VpdmUoOmZpcnN0KS5hbmRfcmV0dXJuKGhpdF9pbnN0YW5jZSkuYXRfbGVhc3QgOm9uY2UKCiAgaGl0X3BhZ2VzID0gZG91YmxlKCJoaXRfcGFnZXMiKQogIGV4cGVjdChoaXRfcGFnZXMpLnRvIHJlY2VpdmUoOmZpcnN0KS5hbmRfcmV0dXJuKGhpdF9wYWdlKS5hdF9sZWFzdCA6b25jZQoKICBleHBlY3QoUmVsYXRvbklzbzo6SXNvQmlibGlvZ3JhcGh5KS50byByZWNlaXZlKDpzZWFyY2gpCiAgICAuYW5kX3dyYXBfb3JpZ2luYWwgZG8gfHNlYXJjaCwgKmFyZ3N8CiAgICBjb2RlID0gYXJnc1swXQogICAgZXhwZWN0KGNvZGUpLnRvIGJlX2luc3RhbmNlX29mIFN0cmluZwogICAgeG1sID0gZ2V0X3htbChzZWFyY2gsIGNvZGUsIG9wdHMpCiAgICBoaXRfcGFnZXMKICBlbmQuYXRfbGVhc3QgOm9uY2UKZW5kCgpwcml2YXRlCgpkZWYgZ2V0X3htbChzZWFyY2gsIGNvZGUsIG9wdHMpCiAgYyA9IGNvZGUuZ3N1YiglcntbL1xzOi1dfSwgIl8iKS5zdWIoJXJ7XyskfSwgIiIpLmRvd25jYXNlCiAgZmlsZSA9IGV4YW1wbGVzX3BhdGgoIiN7W2MsIG9wdHMua2V5cy5qb2luKCdfJyldLmpvaW4gJ18nfS54bWwiKQogIGlmIEZpbGUuZXhpc3Q/IGZpbGUKICAgIEZpbGUucmVhZCBmaWxlCiAgZWxzZQogICAgeG1sID0gc2VhcmNoLmNhbGwoY29kZSkmLmZpcnN0Ji5maXJzdCYudG9feG1sIG5pbCwgb3B0cwogICAgRmlsZS53cml0ZSBmaWxlLCB4bWwKICAgIHhtbAogIGVuZAplbmQKCmRlZiBtb2NrX29wZW5fdXJpKGNvZGUpCiAgZXhwZWN0KE9wZW5VUkkpLnRvIHJlY2VpdmUoOm9wZW5fdXJpKS5hbmRfd3JhcF9vcmlnaW5hbCBkbyB8bSwgKmFyZ3N8CiAgICAjIGV4cGVjdChhcmdzWzBdKS50byBiZV9pbnN0YW5jZV9vZiBTdHJpbmcKICAgIGZpbGUgPSBleGFtcGxlc19wYXRoKCIje2NvZGUudHIoJy0nLCAnXycpfS5odG1sIikKICAgIEZpbGUud3JpdGUgZmlsZSwgbS5jYWxsKCphcmdzKS5yZWFkIHVubGVzcyBGaWxlLmV4aXN0PyBmaWxlCiAgICBGaWxlLnJlYWQgZmlsZSwgZW5jb2Rpbmc6ICJ1dGYtOCIKICBlbmQuYXRfbGVhc3QgOm9uY2UKZW5kCgpkZWYgbWV0YW5vcm1hX3Byb2Nlc3MoaW5wdXQpCiAgTWV0YW5vcm1hOjpJbnB1dDo6QXNjaWlkb2MKICAgIC5uZXcKICAgIC5wcm9jZXNzKGlucHV0LCAidGVzdC5hZG9jIiwgOnN0YW5kb2MpCmVuZAoKZGVmIHhtbF9zdHJpbmdfY29uZW50KHhtbCkKICBzdHJpcF9ndWlkKE5va29naXJpOjpIVE1MKHhtbCkudG9fcykKZW5kCg==</attachment></metanorma-extension>
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
      .to include "VCR.configure"
  end

  private

  def mock_preprocess_xslt_read
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:preprocess_xslt_read)
      .and_return "spec/assets/preprocess-xslt.xml"
  end
end
