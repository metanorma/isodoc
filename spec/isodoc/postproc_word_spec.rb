require "spec_helper"
require "fileutils"

options = { wordstylesheet: "spec/assets/word.css",
            htmlstylesheet: "spec/assets/html.scss" }

RSpec.describe IsoDoc do
  it "converts definition lists to tables for Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", <<~INPUT, false)
       <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1">
      <dl>
      <dt>Term</dt>
      <dd>Definition</dd>
      <dt>Term 2</dt>
      <dd>Definition 2</dd>
      </dl>
      </foreword></preface>
      </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class="WordSection2">
              <p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <table class="dl">
                  <tr>
                    <td valign="top" align="left">
                      <p align="left" style="margin-left:0pt;text-align:left;" class="MsoNormal">Term</p>
                    </td>
                    <td valign="top">Definition</td>
                  </tr>
                  <tr>
                    <td valign="top" align="left">
                      <p align="left" style="margin-left:0pt;text-align:left;" class="MsoNormal">Term 2</p>
                    </td>
                    <td valign="top">Definition 2</td>
                  </tr>
                </table>
              </div>
              <p class="MsoNormal">&#xA0;</p>
            </div>
    OUTPUT
  end

  it "removes cover page and pagebreak if no cover page template supplied" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1">
      <dl>
      <dt>Term</dt>
      <dd>Definition</dd>
      <dt>Term 2</dt>
      <dd>Definition 2</dd>
      </dl>
      </foreword></preface>
      </iso-standard>
    INPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        wordcoverpage: "spec/assets/wordcover.html",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection1">/m, '<div class="WordSection1">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection2">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class="WordSection1">
      /* an empty word cover page */

      <p class="MsoNormal"> </p></div>
    OUTPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection1">/m, '<div class="WordSection1">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection2">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
    OUTPUT
  end

  it "populates Word header" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        header: "spec/assets/header.html" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
                     <bibdata type="article">
                              <docidentifier>
                 <project-number part="1">1000</project-number>
               </docidentifier>
              </bibdata>
      </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(%r{^.*Content-ID: <header.html>}m, "Content-ID: <header.html>")
      .sub(/------=_NextPart.*$/m, "")
    expect(word).to be_equivalent_to <<~OUTPUT
      Content-ID: <header.html>
      Content-Disposition: inline; filename="header.html"
      Content-Transfer-Encoding: base64
      Content-Type: text/html charset="utf-8"
      Ci8qIGFuIGVtcHR5IGhlYWRlciAqLwoKU1RBUlQgRE9DIElEOiAKICAgICAgICAgICAxMDAwCiAg
      ICAgICAgIDogRU5EIERPQyBJRAoKRklMRU5BTUU6IHRlc3QKCg==
    OUTPUT
  end

  it "populates Word ToC" do
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <sections>
                     <clause id="A" inline-header="false" obligation="normative" displayorder="1"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction<bookmark id="Q"/> to this <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/> <fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative" displayorder="2">
               <title>Clause 4.2</title>
               <p>A<fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
      <clause id="P" inline-header="false" obligation="normative">
      <title>Clause 4.2.1</title>
      <variant-title type="toc">SUBCLOZ</variant-title>
      </clause>
             </clause></clause>
              </sections>
              </iso-standard>
    INPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" },
    ).convert("test", input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
          <div class="WordSection2">
        /* an empty word intro page */

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"></span><span style="mso-spacerun:yes">&#xA0;</span>TOC
          \o "1-2" \h \z \u <span style="mso-element:field-separator"></span></span>
        <span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
        <a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-tab-count:1 dotted">. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-element:field-begin"></span></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span></span></p>
        <p class="MsoToc2">
          <span class="MsoHyperlink">
            <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
        <a href="#_Toc">Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-tab-count:1 dotted">. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-element:field-begin"></span></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
          </span>
        </p>
        <p class="MsoToc2">
          <span class="MsoHyperlink">
            <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
        <a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-tab-count:1 dotted">. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-element:field-begin"></span></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
          </span>
        </p>
        <p class="MsoToc1">
          <span lang="EN-GB" xml:lang="EN-GB">
            <span style="mso-element:field-end"></span>
          </span>
          <span lang="EN-GB" xml:lang="EN-GB">
          <o:p class="MsoNormal"> </o:p>
          </span>
        </p>
                <p class="MsoNormal">&#xA0;</p>
              </div>
      OUTPUT
  end

  it "removes ToC header if no ToC placeholder" do
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
              <clause displayorder="1" type="toc"><title>Table of Contents</title></clause>
              </preface>
              <sections>
                     <clause id="A" inline-header="false" obligation="normative" displayorder="1"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction<bookmark id="Q"/> to this <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/> <fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative" displayorder="2">
               <title>Clause 4.2</title>
               <p>A<fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
      <clause id="P" inline-header="false" obligation="normative">
      <title>Clause 4.2.1</title>
      <variant-title type="toc">SUBCLOZ</variant-title>
      </clause>
             </clause></clause>
              </sections>
              </iso-standard>
    INPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro_notoc.html" },
    ).convert("test", input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
           <div class="WordSection2">
         /* an empty word intro page */
        <p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p><div class="TOC"><p class="zzContents">Table of Contents</p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC \o "1-2" \h \z \u <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Introduction to this  <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p></div><p class="MsoNormal"> </p></div>
      OUTPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "" },
    ).convert("test", input, false)
    word = File.read("test.doc")
    expect(word.include?('<div class="TOC">')).to be false
  end

  it "populates Word ToC with custom levels" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" },
    ).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <metanorma-extension>
          <presentation-metadata>
            <name>TOC Heading Levels</name>
            <value>2</value>
          </presentation-metadata>
          <presentation-metadata>
            <name>HTML TOC Heading Levels</name>
            <value>2</value>
          </presentation-metadata>
          <presentation-metadata>
            <name>DOC TOC Heading Levels</name>
            <value>3</value>
          </presentation-metadata>
        </metanorma-extension>
                    <sections>
                           <clause id="A" inline-header="false" obligation="normative" displayorder="1"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
                     <title>Introduction<bookmark id="Q"/> to this<fn reference="1">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
            </fn></title>
                   </clause>
                   <clause id="O" inline-header="false" obligation="normative" displayorder="2">
                     <title>Clause 4.2</title>
                     <p>A<fn reference="1">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
            </fn></p>
            <clause id="P" inline-header="false" obligation="normative">
            <title>Clause 4.2.1</title>
            </clause>
                   </clause></clause>
                    </sections>
                    </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
                .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
                   <div class="WordSection2">
               /* an empty word intro page */

               <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"></span><span style="mso-spacerun:yes">&#xA0;</span>TOC
                 \o "1-3" \h \z \u <span style="mso-element:field-separator"></span></span>
               <span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-tab-count:1 dotted">. </span>
               </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-element:field-begin"></span></span>
               <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span></span></p>
               <p class="MsoToc2">
                 <span class="MsoHyperlink">
                   <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-tab-count:1 dotted">. </span>
               </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-element:field-begin"></span></span>
               <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
                 </span>
               </p>
               <p class="MsoToc2">
                 <span class="MsoHyperlink">
                   <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-tab-count:1 dotted">. </span>
               </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
               <span style="mso-element:field-begin"></span></span>
               <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
                 </span>
               </p>
               <p class="MsoToc3">
          <span class="MsoHyperlink">
            <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
        <a href="#_Toc">Clause 4.2.1<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-tab-count:1 dotted">. </span>
        </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
        <span style="mso-element:field-begin"></span></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
          </span>
        </p>
               <p class="MsoToc1">
                 <span lang="EN-GB" xml:lang="EN-GB">
                   <span style="mso-element:field-end"></span>
                 </span>
                 <span lang="EN-GB" xml:lang="EN-GB">
                 <o:p class="MsoNormal"> </o:p>
                 </span>
               </p>
                       <p class="MsoNormal">&#xA0;</p>
                     </div>
    OUTPUT
  end

  it "populates Word ToC with figures, tables, recommendations" do
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <metanorma-extension>
          <presentation-metadata>
            <name>TOC Heading Levels</name>
            <value>2</value>
          </presentation-metadata>
          <presentation-metadata>
            <name>HTML TOC Heading Levels</name>
            <value>2</value>
          </presentation-metadata>
          <presentation-metadata>
            <name>DOC TOC Heading Levels</name>
            <value>3</value>
          </presentation-metadata>
        </metanorma-extension>
                    <sections>
                           <clause id="A" inline-header="false" obligation="normative" displayorder="1"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
                     <title>Introduction<bookmark id="Q"/> to this<fn reference="1">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
            </fn></title>
                   </clause>
                   <clause id="O" inline-header="false" obligation="normative" displayorder="2">
                     <title>Clause 4.2</title>
                     <recommendation id="AC" type="abstracttest" model="default">
              <name>/ogc/recommendation/wfs/3</name>
              </recommendation>
                     <recommendation id="AA" model="default">
              <name>/ogc/recommendation/wfs/2</name>
              </recommendation>
                     <recommendation id="AB" type="abstracttest" model="default">
              <name>/ogc/recommendation/wfs/3</name>
              </recommendation>
              <figure id="BA"><name>First figure</name></figure>
              <table id="CA"><name>First table</name></table>
                     <p>A<fn reference="1">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
            </fn></p>
            <clause id="P" inline-header="false" obligation="normative">
            <title>Clause 4.2.1</title>
            </clause>
                   </clause></clause>
                    </sections>
                    </iso-standard>
    INPUT
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" },
    ).convert("test", input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
                .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
        <div class="WordSection2">
         /* an empty word intro page */

         <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC \o "1-3" \h \z \u <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

         <p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

         <p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

         <p class="MsoToc3"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2.1<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
           <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

         <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p>

         <p class="MsoNormal"> </p></div>
      OUTPUT

    toc_input = input.sub(%r{<metanorma-extension>},
                          <<~MISC,
                            <metanorma-extension>
                            <toc type="table"><title>List of tables</title></toc>
                            <toc type="figure"><title>List of figures</title></toc>
                            <toc type="recommendation"><title>List of recommendations</title></toc>
                          MISC
                         )
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" },
    ).convert("test", toc_input, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
                .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
        <div class="WordSection2">
        /* an empty word intro page */

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC \o "1-3" \h \z \u <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc3"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2.1<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p>
        <p class="TOCTitle">List of tables</p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC
        \h \z \t TableTitle,tabletitle <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">First table<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p>
        <p class="TOCTitle">List of figures</p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC
        \h \z \t FigureTitle,figuretitle <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">First figure<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p>
        <p class="TOCTitle">List of recommendations</p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC \h \z \t RecommendationTitle,RecommendationTestTitle,recommendationtitle,recommendationtesttitle
        <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">/ogc/recommendation/wfs/2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">/ogc/recommendation/wfs/3<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">/ogc/recommendation/wfs/3<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span>
        <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
          <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p>

        <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p>

        <p class="MsoNormal"> </p></div>
      OUTPUT
  end

  it "generates HTML output with custom ToC levels function" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({})
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <metanorma-extension>
            <presentation-metadata>
              <name>TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>HTML TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>DOC TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
          </metanorma-extension>
                    <preface><foreword>
                    <note>
                  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
                </note>
                    </foreword></preface>
                    </iso-standard>
      INPUT
    html = File.read("test.html")
    toclevel = <<~TOCLEVEL
      function toclevel() { return "h1:not(:empty):not(.TermNum):not(.noTOC),h2:not(:empty):not(.TermNum):not(.noTOC),h3:not(:empty):not(.TermNum):not(.noTOC)";}
    TOCLEVEL
    expect(html).to include toclevel
  end

  it "creates continuation styles for multiparagraph list items in Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options)
      .convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
            <ul>
            <li><p>A</p>
            <p>B</p></li>
            <li><ol><li><p>C</p>
            <p>D</p>
            <sourcecode>E</sourcecode></li>
            </ol></li>
            </ul>
            <ol>
            <li><p>A1</p>
            <p>B1</p></li>
            <li><ul><li><p>C1</p>
            <formula id="_5fc1ef0f-75d2-4b54-802c-b1bad4a53b62">
            <stem type="AsciiMath">D1</stem>
            </formula>
            <dl id="_f8fb7ed7-7874-44a8-933f-06e0e86fb264">
        <dt>
        <em>n</em>
        </dt>
        <dd>
        <p id="_a27281a4-b20e-4d0b-a780-bab9e851b03e">is the number of coating layers</p>
        </dd>
        </dl>
            </ul></li>
            </ol>
            </foreword></preface>
            </iso-standard>
      INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2" xmlns:m="m">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div xmlns:m="m" class="WordSection2">
          <p class="MsoNormal">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="ForewordTitle">Foreword</h1>
            <div class="ul_wrap">
              <p class="MsoListParagraphCxSpFirst" style="">A
            <div class="ListContLevel1"><p class="MsoNormal">B</p></div></p>
              <p class="MsoListParagraphCxSpLast">
                <div class="ol_wrap">
                  <p class="MsoListParagraphCxSpFirst" style="">C
            <div class="ListContLevel2"><p class="MsoNormal">D</p></div>
            <div class="ListContLevel2"><p class="Sourcecode">E</p></div></p>
                </div>
              </p>
            </div>
            <div class="ol_wrap">
              <p class="MsoListParagraphCxSpFirst" style="">A1
            <div class="ListContLevel1"><p class="MsoNormal">B1</p></div></p>
              <p class="MsoListParagraphCxSpLast">
                <div class="ul_wrap">
                  <p class="MsoListParagraphCxSpFirst" style="">C1
            <div class="ListContLevel2"><div><a name="_5fc1ef0f-75d2-4b54-802c-b1bad4a53b62" id="_5fc1ef0f-75d2-4b54-802c-b1bad4a53b62"/><div class="formula"><p class="MsoNormal"><span class="stem">(#(D1)#)</span><span style="mso-tab-count:1">  </span></p></div></div></div>
            <div class="ListContLevel2"><table class="dl"><a name="_f8fb7ed7-7874-44a8-933f-06e0e86fb264" id="_f8fb7ed7-7874-44a8-933f-06e0e86fb264"/><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;" class="MsoNormal"><i>n</i></p></td><td valign="top"><p class="MsoNormal"><a name="_a27281a4-b20e-4d0b-a780-bab9e851b03e" id="_a27281a4-b20e-4d0b-a780-bab9e851b03e"/>is the number of coating layers</p></td></tr></table></div>
            </p>
                </div>
              </p>
            </div>
          </div>
          <p class="MsoNormal"> </p>
        </div>
    OUTPUT
  end

  it "propagates example style to paragraphs in postprocessing (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options).convert("test", <<~INPUT, false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
          <example id="samplecode">
        <p>ABC</p>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class="WordSection2">
                   <p class="MsoNormal">
                     <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                   </p>
                   <div>
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div class="example"><a name="samplecode" id="samplecode"></a>
               <p class="example">ABC</p>
             </div>
                   </div>
                   <p class="MsoNormal">&#xA0;</p>
                 </div>
    OUTPUT
  end

  it "deals with image captions (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options)
      .convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
        <figure id="fig1">
          <name>Typical arrangement of the far-field scan set-up</name>
          <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/>
          </figure>
           </foreword></preface>
            </iso-standard>
      INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
      .sub(/src="[^"]+"/, 'src="_"')
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class="WordSection2">
               <p class="MsoNormal">
                 <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               </p>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="figure"><a name="fig1" id="fig1"></a>
           <p style="page-break-after:avoid;" class="figure"><img src="_" width="400" height="337"/></p>
           <p class="FigureTitle" style="text-align:center;">Typical arrangement of the far-field scan set-up</p></div>
               </div>
               <p class="MsoNormal">&#xA0;</p>
             </div>
    OUTPUT
  end

  it "deals with empty table titles (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options)
      .convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
        <table id="_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7" unnumbered="true"><thead><tr>
              <td rowspan="2">
                <p id="_c47d9b39-adb2-431d-9320-78cb148fdb56">Output wavelength <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mo>(</mo><mi>μ</mi><mi>m</mi><mo>)</mo></mrow></math></stem></p>
              </td>
              <th colspan="3" align="left">Predictive wavelengths</th>
            </tr>
            </thead>
            </table>
            </foreword>
            </preface>
            </iso-standard>
      INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2" xmlns:m="m">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
      .sub(/src="[^"]+"/, 'src="_"')
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class="WordSection2" xmlns:m="m">
              <p class="MsoNormal">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div align="center" class="table_container">
                  <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;"><a name="_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7" id="_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7"></a>
                    <thead>
                      <tr>
                         <td rowspan="2" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                         <p style="page-break-after:avoid" class="MsoNormal"><a name="_c47d9b39-adb2-431d-9320-78cb148fdb56" id="_c47d9b39-adb2-431d-9320-78cb148fdb56"/>Output wavelength <span class="stem"><m:oMath><m:d><m:dPr><m:begChr m:val="("/><m:sepChr m:val=""/><m:endChr m:val=")"/></m:dPr><m:e><m:r><m:t>μ</m:t></m:r><m:r><m:t>m</m:t></m:r></m:e></m:d></m:oMath></span></p>
              </td>
               <th colspan="3" align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Predictive wavelengths</th>
                      </tr>
                    </thead>
                  </table>
                </div>
              </div>
              <p class="MsoNormal">&#xA0;</p>
            </div>
    OUTPUT
  end

  it "propagates alignment of table cells (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface><foreword displayorder="1">
              <table id="_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7" unnumbered="true"><thead><tr>
                    <td rowspan="2" align="left">
                      <p id="_c47d9b39-adb2-431d-9320-78cb148fdb56">Output wavelength</p>
                      <p id="_c47d9b39-adb2-431d-9320-78cb148fdb57">Output wavelength</p>
                    </td>
                    <th colspan="3" align="right"><p id="_c47d9b39-adb2-431d-9320-78cb148fdb58">Predictive wavelengths</p></th>
                  </tr>
                  </thead>
                  </table>
                  </preface>
                  </iso-standard>
      INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2" xmlns:m="m">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
      .sub(/src="[^"]+"/, 'src="_"')
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <div class='WordSection2' xmlns:m='m'>
           <p class='MsoNormal'>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div>
             <h1 class='ForewordTitle'>Foreword</h1>
             <div align='center' class="table_container">
               <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                 <a name='_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7' id='_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7'/>
                                <thead>
                 <tr>
                   <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                     <p style="text-align: left;page-break-after:avoid" class="MsoNormal"><a name="_c47d9b39-adb2-431d-9320-78cb148fdb56" id="_c47d9b39-adb2-431d-9320-78cb148fdb56"/>Output wavelength</p>
                     <p style="text-align: left;page-break-after:avoid" class="MsoNormal"><a name="_c47d9b39-adb2-431d-9320-78cb148fdb57" id="_c47d9b39-adb2-431d-9320-78cb148fdb57"/>Output wavelength</p>
                   </td>
                   <th colspan="3" align="right" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                     <p style="text-align: right;page-break-after:avoid" class="MsoNormal"><a name="_c47d9b39-adb2-431d-9320-78cb148fdb58" id="_c47d9b39-adb2-431d-9320-78cb148fdb58"/>Predictive wavelengths</p>
                   </th>
                 </tr>
               </thead>
               </table>
             </div>
           </div>
           <p class='MsoNormal'>&#xA0;</p>
         </div>
    OUTPUT
  end

  it "deals with landscape and portrait pagebreaks (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss", filename: "test" },
    ).convert("test", <<~INPUT, false)
              <standard-document xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
               <title language="en" format="text/plain">Document title</title>
               <version>
                 <draft>1.2</draft>
               </version>
               <language>en</language>
               <script>Latn</script>
               <status><stage>published</stage></status>
               <ext>
               <doctype>article</doctype>
               </ext>
             </bibdata>
             <preface>
             <introduction displayorder="1"><title>Preface 1</title>
             <p align="center">This is a <pagebreak orientation="landscape"/> paragraph</p>
             <table>
             <tbody>
             <tr><td>A</td><td>B</td></tr>
             </tbody>
             </table>
             <clause><title>Preface 1.1</title>
             <p>On my side</p>
             <pagebreak orientation="portrait"/>
             <p>Upright again</p>
             </clause>
             <clause><title>Preface 1.3</title>
             <p>And still upright</p>
             </clause>
             </introduction>
             </preface>
             <sections><clause displayorder="2"><title>Foreword</title>
             <note>
             <p id="_">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p>
             <pagebreak orientation="landscape"/>
             <table id="_c09a7e60-b0c7-4418-9bfc-2ef0bc09a249">
      <thead>
      <tr>
      <th align="left">A</th>
      <th align="left">B</th>
      </tr>
      </thead>
      <tbody>
      <tr>
      <td align="left">C</td>
      <td align="left">D</td>
      </tr>
      </tbody>
      <note id="_8fff1596-290e-4314-b03c-7a8aab97eebe">
      <p id="_32c22439-387a-48cf-a006-5ab3b934ba73">B</p>
      </note></table>
             <pagebreak orientation="portrait"/>
             <p>And up</p>
             </note>
             <pagebreak orientation="portrait"/>
              </clause></sections>
              <annex id="_level_1" inline-header="false" obligation="normative" displayorder="3">
              <title>Annex 1</title>
              </annex>
             </standard-document>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).to include "div.WordSection2_0 {page:WordSection2P;}"
    expect(html).to include "div.WordSection2_1 {page:WordSection2L;}"
    expect(html).to include "div.WordSection3_0 {page:WordSection3P;}"
    expect(html).to include "div.WordSection3_1 {page:WordSection3P;}"
    expect(html).to include "div.WordSection3_2 {page:WordSection3L;}"

    expect(xmlpp(html.sub(/^.*<body /m, "<body ")
      .sub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~OUTPUT)
                <body lang='EN-US' xml:lang='EN-US' link='blue' vlink='#954F72'>
                  <div class='WordSection2'>
                  <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
                    <div class='Section3' id=''>
                      <h1 class='IntroTitle'>Preface 1</h1>
                      <p align='center' style='text-align:center;' class='MsoNormal'>
                        This is a
                        <p class='MsoNormal'>
                          <br clear='all' class='section'/>
                        </p>
                         paragraph
                      </p>
                    </div>
                  </div>
                           <div class="WordSection2_1">
            <div align="center" class="table_container">
              <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                <tbody>
                  <tr>
                    <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">A</td>
                    <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">B</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div>
              <h2>Preface 1.1</h2>
              <p class="MsoNormal">On my side</p>
              <p class="MsoNormal">
                <br clear="all" class="section"/>
              </p>
            </div>
          </div>
          <div class="WordSection2_0">
            <p class="MsoNormal">Upright again</p>
            <div>
              <h2>Preface 1.3</h2>
              <p class="MsoNormal">And still upright</p>
            </div>
            <p class="MsoNormal"> </p>
          </div>
          <p class="MsoNormal">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
            <div>
              <h1>Foreword</h1>
              <div class="Note">
                <p class="Note"><span class="note_label"/><span style="mso-tab-count:1">  </span>For further information on the Foreword, see <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b></p>
                <p class="Note">
                  <br clear="all" class="section"/>
                </p>
              </div>
            </div>
          </div>
          <div class="WordSection3_2">
            <div align="center" class="table_container">
              <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                <a name="_c09a7e60-b0c7-4418-9bfc-2ef0bc09a249" id="_c09a7e60-b0c7-4418-9bfc-2ef0bc09a249"/>
                <thead>
                  <tr>
                    <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">A</th>
                    <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">B</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">C</td>
                    <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">D</td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="2" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                      <div class="Note">
                        <a name="_8fff1596-290e-4314-b03c-7a8aab97eebe" id="_8fff1596-290e-4314-b03c-7a8aab97eebe"/>
                        <p class="Note"><span class="note_label"/><span style="mso-tab-count:1">  </span>B</p>
                      </div>
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
            <p class="Note">
              <br clear="all" class="section"/>
            </p>
          </div>
          <div class="WordSection3_1">
            <p class="Note">And up</p>
            <p class="MsoNormal">
              <br clear="all" class="section"/>
            </p>
          </div>
          <div class="WordSection3_0">
            <div class="Section3">
              <a name="_level_1" id="_level_1"/>
              <h1 class="Annex">Annex 1</h1>
            </div>
          </div>
          <div style="mso-element:footnote-list"/>
        </body>
      OUTPUT
  end

  it "expands out nested tables in Word" do
    input = <<~INPUT
          <html>
          <head/>
          <body>
          <div class="main-section">
          <table id="_7830dff8-419e-4b9e-85cf-a063689f44ca" class="recommend" style="border-collapse:collapse;border-spacing:0;"><thead><tr style="background:#A5A5A5;"><th style="vertical-align:top;" class="recommend" colspan="2"><p class="RecommendationTitle">Requirement 1:</p></th></tr></thead><tbody><tr><td style="vertical-align:top;" class="recommend" colspan="2"><p>requirement label</p></td></tr>
      <table id="_a0f8c202-fd34-460c-bd5e-b2f4cc29210d" class="recommend" style="border-collapse:collapse;border-spacing:0;"><thead><tr style="background:#A5A5A5;"><th style="vertical-align:top;" class="recommend" colspan="2"><p class="RecommendationTitle">Requirement 1-1:</p></th></tr></thead><tbody><tr style="background:#C9C9C9;"><td style="vertical-align:top;" class="recommend" colspan="2">
      <p id="_2e2c247b-ce4c-48c5-96dd-f3e090a5b4a7">Description text</p>
      </td></tr></tbody></table>
      </tbody></table>
      </div>
              <div id="_second_sample"><h2>1.2.<span style="mso-tab-count:1">&#xA0; </span>Second sample</h2>
      <table id="_9846c486-14e5-4b1c-bb2f-55cc254dd309" class="recommend" style="border-collapse:collapse;border-spacing:0;"><thead><tr style="background:#A5A5A5;"><th style="vertical-align:top;" class="recommend" colspan="2"><p class="RecommendationTitle">Requirement 2:</p></th></tr></thead><tbody><tr><td style="vertical-align:top;" class="recommend" colspan="2"><p>requirement label</p></td></tr><table id="_62de974c-7128-44d6-ba86-99f818f1d467" class="recommend" style="border-collapse:collapse;border-spacing:0;"><thead><tr style="background:#A5A5A5;"><th style="vertical-align:top;" class="recommend" colspan="2"><p class="RecommendationTitle">Requirement 2-1:</p></th></tr></thead><tbody><tr style="background:#C9C9C9;"><td style="vertical-align:top;" class="recommend" colspan="2">
      <p id="_30b90b08-bd71-4497-bbcc-8c61fbb9f772">Description text</p>
      </td></tr></tbody></table>
      <table id="_fede5681-71f6-47bb-bc65-7bd0b11acd01" class="recommend" style="border-collapse:collapse;border-spacing:0;"><thead><tr style="background:#A5A5A5;"><th style="vertical-align:top;" class="recommend" colspan="2"><p class="RecommendationTitle">Requirement 2-2:</p></th></tr></thead><tbody><tr><td style="vertical-align:top;" class="recommend" colspan="2">
      <p id="_8daa3d74-90fd-4a57-9169-de457a68cfda">Description text</p>
      </td></tr></tbody></table></tbody></table>
          </div>
          </body>
          </html>
    INPUT
    output = <<~OUTPUT
          <html>
        <head/>
        <body>
          <div class='main-section'>
               <table id='_7830dff8-419e-4b9e-85cf-a063689f44ca' class='recommend' style='border-collapse:collapse;border-spacing:0;'>
             <thead>
               <tr style='background:#A5A5A5;'>
                 <th style='vertical-align:top;' class='recommend' colspan='2'>
                   <p class='RecommendationTitle'>Requirement 1:</p>
                 </th>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td style='vertical-align:top;' class='recommend' colspan='2'>
                   <p>requirement label</p>
                 </td>
               </tr>
             </tbody>
           </table>
           <table id='_a0f8c202-fd34-460c-bd5e-b2f4cc29210d' class='recommend' style='border-collapse:collapse;border-spacing:0;'>
             <thead>
               <tr style='background:#A5A5A5;'>
                 <th style='vertical-align:top;' class='recommend' colspan='2'>
                   <p class='RecommendationTitle'>Requirement 1-1:</p>
                 </th>
               </tr>
             </thead>
             <tbody>
               <tr style='background:#C9C9C9;'>
                 <td style='vertical-align:top;' class='recommend' colspan='2'>
                   <p id='_2e2c247b-ce4c-48c5-96dd-f3e090a5b4a7'>Description text</p>
                 </td>
               </tr>
             </tbody>
           </table>
         </div>
         <div id='_second_sample'>
           <h2>
             1.2.
             <span style='mso-tab-count:1'>&#xA0; </span>
             Second sample
           </h2>
           <table id='_9846c486-14e5-4b1c-bb2f-55cc254dd309' class='recommend' style='border-collapse:collapse;border-spacing:0;'>
             <thead>
               <tr style='background:#A5A5A5;'>
                 <th style='vertical-align:top;' class='recommend' colspan='2'>
                   <p class='RecommendationTitle'>Requirement 2:</p>
                 </th>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td style='vertical-align:top;' class='recommend' colspan='2'>
                   <p>requirement label</p>
                 </td>
               </tr>
             </tbody>
           </table>
           <table id='_62de974c-7128-44d6-ba86-99f818f1d467' class='recommend' style='border-collapse:collapse;border-spacing:0;'>
             <thead>
               <tr style='background:#A5A5A5;'>
                 <th style='vertical-align:top;' class='recommend' colspan='2'>
                   <p class='RecommendationTitle'>Requirement 2-1:</p>
                 </th>
               </tr>
             </thead>
             <tbody>
               <tr style='background:#C9C9C9;'>
                 <td style='vertical-align:top;' class='recommend' colspan='2'>
                   <p id='_30b90b08-bd71-4497-bbcc-8c61fbb9f772'>Description text</p>
                 </td>
               </tr>
             </tbody>
           </table>
           <table id='_fede5681-71f6-47bb-bc65-7bd0b11acd01' class='recommend' style='border-collapse:collapse;border-spacing:0;'>
             <thead>
               <tr style='background:#A5A5A5;'>
                 <th style='vertical-align:top;' class='recommend' colspan='2'>
                   <p class='RecommendationTitle'>Requirement 2-2:</p>
                 </th>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td style='vertical-align:top;' class='recommend' colspan='2'>
                   <p id='_8daa3d74-90fd-4a57-9169-de457a68cfda'>Description text</p>
                 </td>
               </tr>
             </tbody>
           </table>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
      .word_cleanup(Nokogiri::XML(input)).to_xml)
      .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(output)
  end

  it "allocate widths to tables (Word)" do
    input = <<~INPUT
             <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
               <head><style/></head>
               <body lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection2'>
                   <p>
                     <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
                   </p>
                   <div>
                     <h1 class='ForewordTitle'>Foreword</h1>
                     <p class='TableTitle' style='text-align:center;'>
                        Table 1&#160;&#8212; Repeatability and reproducibility of
                       <i>husked</i>
                        rice yield
                       <span style='mso-bookmark:_Ref'>
                         <a class='FootnoteRef' href='#ftn1' epub:type='footnote'>
                           <sup>1</sup>
                         </a>
                       </span>
                     </p>
                     <div align='center' class='table_container'>
                       <table id='tableD-1' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;' title='tool tip' summary='long desc' width='70%'>
                       <colgroup>
        <col width='30%'/>
        <col width='20%'/>
        <col width='20%'/>
        <col width='20%'/>
        <col width='10%'/>
      </colgroup>
                         <thead>
                           <tr>
                             <td rowspan='2' align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>Description</td>
                             <td colspan='4' align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>Rice sample</td>
                           </tr>
                           <tr>
                             <td align='left' valign="top" style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>Arborio</td>
                             <td align='center' valign="middle" style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                                Drago
                               <a href='#tableD-1a' class='TableFootnoteRef'>a</a>
                               <aside>
                                 <div id='ftntableD-1a'>
                                   <span>
                                     <span id='tableD-1a' class='TableFootnoteRef'>a</span>
                                     <span style='mso-tab-count:1'>&#160; </span>
                                   </span>
                                   <p id='_0fe65e9a-5531-408e-8295-eeff35f41a55'>Parboiled rice.</p>
                                 </div>
                               </aside>
                             </td>
                             <td align='center' valign="bottom" style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                                Balilla
                               <a href='#tableD-1a' class='TableFootnoteRef'>a</a>
                             </td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>Thaibonnet</td>
                           </tr>
                         </thead>
                         <tbody>
                           <tr>
                             <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>Number of laboratories retained after eliminating outliers</th>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>13</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>11</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>13</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>13</td>
                           </tr>
                           <tr>
                             <td align='left' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>Mean value, g/100 g</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>81,2</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>82,0</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>81,8</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>77,7</td>
                           </tr>
                         </tbody>
                         <tfoot>
                           <tr>
                             <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                                Reproducibility limit,
                               <span class='stem'>(#(R)#)</span>
                                (= 2,83
                               <span class='stem'>(#(s_R)#)</span>
                                )
                             </td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>2,89</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>0,57</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>2,26</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>6,06</td>
                           </tr>
                         </tfoot>
                         <table class='dl'>
                           <tr>
                             <td valign='top' align='left'>
                               <p align='left' style='margin-left:0pt;text-align:left;'>Drago</p>
                             </td>
                             <td valign='top'>A type of rice</td>
                           </tr>
                         </table>
                         <div class='Note'>
                           <p class='Note'>
                             <span class='note_label'>NOTE</span>
                             <span style='mso-tab-count:1'>&#160; </span>
                             This is a table about rice
                           </p>
                         </div>
                       </table>
                     </div>
                     <div align='center' class='table_container'>
                       <table id='tableD-2' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                         <tbody>
                           <tr>
                             <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>A</td>
                           </tr>
                         </tbody>
                       </table>
                     </div>
                   </div>
                   <p>&#160;</p>
                 </div>
                 <p>
                   <br clear='all' class='section'/>
                 </p>
                 <div class='WordSection3'>
                   <aside id='ftn1'>
                     <p>X</p>
                   </aside>
                 </div>
               </body>
             </html>
    INPUT
    output = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
               <head>
                 <style/>
               </head>
               <body lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection2'>
                   <p>
                     <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
                   </p>
                   <div>
                     <h1 class='ForewordTitle'>Foreword</h1>
                     <p class='TableTitle' style='text-align:center;'>
                        Table 1&#xA0;&#x2014; Repeatability and reproducibility of
                       <i>husked</i>
                        rice yield
                       <span style='mso-bookmark:_Ref'>
                         <a class='FootnoteRef' href='#ftn1' epub:type='footnote'>
                           <sup>1</sup>
                         </a>
                       </span>
                     </p>
                     <div align='center' class='table_container'>
                       <table id='tableD-1' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;' title='tool tip' summary='long desc' width='70%'>
                         <colgroup>
                           <col width='30%'/>
                           <col width='20%'/>
                           <col width='20%'/>
                           <col width='20%'/>
                           <col width='10%'/>
                         </colgroup>
                         <thead>
                           <tr>
                             <td rowspan='2' align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='30.0%'>Description</td>
                             <td colspan='4' align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='70.0%'>Rice sample</td>
                           </tr>
                           <tr>
                             <td align='left' valign='top' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>Arborio</td>
                             <td align='center' valign='middle' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>
                                Drago
                               <a href='#tableD-1a' class='TableFootnoteRef'>a</a>
                               <aside>
                                 <div id='ftntableD-1a'>
                                   <span>
                                     <span id='tableD-1a' class='TableFootnoteRef'>a</span>
                                     <span style='mso-tab-count:1'>&#xA0; </span>
                                   </span>
                                   <p id='_0fe65e9a-5531-408e-8295-eeff35f41a55'>Parboiled rice.</p>
                                 </div>
                               </aside>
                             </td>
                             <td align='center' valign='bottom' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>
                                Balilla
                               <a href='#tableD-1a' class='TableFootnoteRef'>a</a>
                             </td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='10.0%'>Thaibonnet</td>
                           </tr>
                         </thead>
                         <tbody>
                           <tr>
                             <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='30.0%'>Number of laboratories retained after eliminating outliers</th>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='20.0%'>13</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='20.0%'>11</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='20.0%'>13</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' width='10.0%'>13</td>
                           </tr>
                           <tr>
                             <td align='left' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='30.0%'>Mean value, g/100 g</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>81,2</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>82,0</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>81,8</td>
                             <td align='center' style='border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='10.0%'>77,7</td>
                           </tr>
                         </tbody>
                         <tfoot>
                           <tr>
                             <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='30.0%'>
                                Reproducibility limit,
                               <span class='stem'>(#(R)#)</span>
                                (= 2,83
                               <span class='stem'>(#(s_R)#)</span>
                                )
                             </td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>2,89</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>0,57</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='20.0%'>2,26</td>
                             <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' width='10.0%'>6,06</td>
                           </tr>
                         </tfoot>
                         <div class='Note'>
                           <p class='Note'>
                             <span class='note_label'>NOTE</span>
                             <span style='mso-tab-count:1'>&#xA0; </span>
                              This is a table about rice
                           </p>
                         </div>
                       </table>
                       <table class='dl'>
                         <tr>
                           <td valign='top' align='left'>
                             <p align='left' style='margin-left:0pt;text-align:left;'>Drago</p>
                           </td>
                           <td valign='top'>A type of rice</td>
                         </tr>
                       </table>
                     </div>
                     <div align='center' class='table_container'>
                       <table id='tableD-2' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                         <tbody>
                           <tr>
                             <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>A</td>
                           </tr>
                         </tbody>
                       </table>
                     </div>
                   </div>
                   <p>&#xA0;</p>
                 </div>
                 <p>
                   <br clear='all' class='section'/>
                 </p>
                 <div class='WordSection3'>
                   <aside id='ftn1'>
                     <p>X</p>
                   </aside>
                 </div>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::WordConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
      .word_cleanup(Nokogiri::XML(input)).to_xml)
      .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(output)
  end
end
