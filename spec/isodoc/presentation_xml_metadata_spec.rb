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
                   <foreword>
                   <note><name>HTML</name></note>
                   <example><name>WORD</name></example>
                   </foreword>
                   </preface>
                   <sections>
                   <terms>
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
            <p class="zzSTDTitle1"/>
            <div>
              <h1/>
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
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p>
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
          <p>
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
            <div>
              <h1/>
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

  private

  def mock_preprocess_xslt_read
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:preprocess_xslt_read)
      .and_return "spec/assets/preprocess-xslt.xml"
  end
end
