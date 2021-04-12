# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        filename: "test" }
    ).convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to match(%r{<title>test</title>})
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates file in a remote directory" do
    FileUtils.rm_f "spec/assets/test.doc"
    FileUtils.rm_f "spec/assets/test.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "word.css",
        htmlstylesheet: "html.scss",
        filename: "test" }
    ).convert("spec/assets/test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    expect(File.exist?("spec/assets/test.html")).to be true
    html = File.read("spec/assets/test.html")
    expect(html).to match(%r{<title>test</title>})
    expect(html).to match(/another empty stylesheet/)
  end

  it "ignores Liquid markup in the document body" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">{% elif %}These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::HtmlConvert.new(wordstylesheet: "spec/assets/word.css")
      .convert("test", input, false)
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css" })
      .convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to match(%r/\{% elif %}/)

    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc")
    expect(html).to match(%r/\{% elif %}/)
  end

  it "generates HTML output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css" })
      .convert("test", <<~"INPUT", false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).not_to match(%r{<title>test</title>})
    expect(html).not_to match(/another empty stylesheet/)
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
    expect(html).not_to match(/html-override/)
  end

  it "generates Word output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc")
    expect(word).to match(/one empty stylesheet/)
    expect(word).to match(/div\.table_container/)
    expect(word).not_to match(/word-override/)
  end

  it "generates HTML output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    FileUtils.rm_f "spec/assets/iso.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "word.css",
        htmlstylesheet: "html.scss" }
    ).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html")
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
    expect(html).to include "$('#toggle')"
    expect(html).not_to match(/CDATA/)
  end

  it "generates Headless HTML output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.html"
    IsoDoc::HeadlessHtmlConvert.new(
      { wordstylesheet: "word.css",
        htmlstylesheet: "html.scss" }
    ).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.headless.html")).to be true
    html = File.read("spec/assets/iso.headless.html")
    expect(html).not_to match(/another empty stylesheet/)
    expect(html).not_to match(%r{https://use.fontawesome.com})
    expect(html).not_to match(%r{libs/jquery})
    expect(html).not_to match(%r{<html})
    expect(html).not_to match(%r{<head})
    expect(html).not_to match(%r{<body})
    expect(html).to match(%r{<div})
  end

  it "generates Word output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "word.css",
        htmlstylesheet: "html.scss" }
    ).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc")
    expect(word).to match(/one empty stylesheet/)
  end

  it "generates HTML output docs with complete configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { bodyfont: "Zapf",
        monospacefont: "Consolas",
        headerfont: "Comic Sans",
        normalfontsize: "30pt",
        monospacefontsize: "29pt",
        smallerfontsize: "28pt",
        footnotefontsize: "27pt",
        htmlstylesheet: "spec/assets/html.scss",
        htmlstylesheet_override: "spec/assets/html_override.css",
        htmlcoverpage: "spec/assets/htmlcover.html",
        htmlintropage: "spec/assets/htmlintro.html",
        scripts: "spec/assets/scripts.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = File.read("test.html")
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(/p \{[^}]*?font-family: Zapf/m)
    expect(html).to match(/code \{[^}]*?font-family: Consolas/m)
    expect(html).to match(/h1 \{[^}]*?font-family: Comic Sans/m)
    expect(html).to match(/p \{[^}]*?font-size: 30pt/m)
    expect(html).to match(/code \{[^}]*?font-size: 29pt/m)
    expect(html).to match(/p\.note \{[^}]*?font-size: 28pt/m)
    expect(html).to match(/aside \{[^}]*?font-size: 27pt/m)
    expect(html).to match(/an empty html cover page/)
    expect(html).to match(/an empty html intro page/)
    expect(html).to match(/This is > a script/)
    expect(html).not_to match(/CDATA/)
    expect(html).to match(%r{Anta&#x16D;parolo</h1>})
    expect(html).to match(%r{html-override})
  end

  it "generates HTML output docs with default fonts" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { htmlstylesheet: "spec/assets/html.scss",
        htmlcoverpage: "spec/assets/htmlcover.html",
        htmlintropage: "spec/assets/htmlintro.html",
        scripts: "spec/assets/scripts.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = File.read("test.html")
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(/p \{[^}]*?font-family: Arial/m)
    expect(html).to match(/code \{[^}]*?font-family: Courier/m)
    expect(html).to match(/h1 \{[^}]*?font-family: Arial/m)
    expect(html).to match(/p \{[^}]*?font-size: 1em;/m)
    expect(html).to match(/code \{[^}]*?font-size: 0.8em/m)
    expect(html).to match(/p\.note \{[^}]*?font-size: 0.9em/m)
    expect(html).to match(/aside \{[^}]*?font-size: 0.9em/m)
    expect(html).to match(/an empty html cover page/)
    expect(html).to match(/an empty html intro page/)
    expect(html).to match(/This is > a script/)
    expect(html).not_to match(/CDATA/)
    expect(html).to match(%r{Anta&#x16D;parolo</h1>})
  end

  it "generates Word output docs with complete configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { bodyfont: "Zapf",
        monospacefont: "Consolas",
        headerfont: "Comic Sans",
        normalfontsize: "30pt",
        monospacefontsize: "29pt",
        smallerfontsize: "28pt",
        footnotefontsize: "27pt",
        wordstylesheet: "spec/assets/html.scss",
        wordstylesheet_override: "spec/assets/word_override.css",
        standardstylesheet: "spec/assets/std.css",
        header: "spec/assets/header.html",
        wordcoverpage: "spec/assets/wordcover.html",
        wordintropage: "spec/assets/wordintro.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
    expect(word).to match(/another empty stylesheet/)
    expect(word).to match(/p \{[^}]*?font-family: Zapf/m)
    expect(word).to match(/code \{[^}]*?font-family: Consolas/m)
    expect(word).to match(/h1 \{[^}]*?font-family: Comic Sans/m)
    expect(word).to match(/p \{[^}]*?font-size: 30pt/m)
    expect(word).to match(/code \{[^}]*?font-size: 29pt/m)
    expect(word).to match(/p\.note \{[^}]*?font-size: 28pt/m)
    expect(word).to match(/aside \{[^}]*?font-size: 27pt/m)
    expect(word).to match(/a third empty stylesheet/)
    expect(word)
      .to match(/Content-Disposition: inline; filename="filelist.xml"/)
    expect(word).to match(/an empty word cover page/)
    expect(word).to match(/an empty word intro page/)
    expect(word).to match(%r{Anta&#x16D;parolo</h1>})
    expect(word).to match(%r{word-override})
  end

  it "generates Word output docs with default fonts" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/html.scss",
        standardstylesheet: "spec/assets/std.css",
        header: "spec/assets/header.html",
        wordcoverpage: "spec/assets/wordcover.html",
        wordintropage: "spec/assets/wordintro.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
    expect(word).to match(/another empty stylesheet/)
    expect(word).to match(/p \{[^}]*?font-family: Arial/m)
    expect(word).to match(/code \{[^}]*?font-family: Courier/m)
    expect(word).to match(/h1 \{[^}]*?font-family: Arial/m)
    expect(word).to match(/p \{[^}]*?font-size: 12pt/m)
    expect(word).to match(/code \{[^}]*?font-size: 11pt/m)
    expect(word).to match(/p\.note \{[^}]*?font-size: 10pt/m)
    expect(word).to match(/aside \{[^}]*?font-size: 9pt/m)
    expect(word).to match(/a third empty stylesheet/)
    # expect(word).to match(/<title>test<\/title>/)
    expect(word)
      .to match(/Content-Disposition: inline; filename="filelist.xml"/)
    expect(word).to match(/an empty word cover page/)
    expect(word).to match(/an empty word intro page/)
    expect(word).to match(%r{Anta&#x16D;parolo</h1>})
  end

  it "converts definition lists to tables for Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" }
    ).convert("test", <<~"INPUT", false)
       <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
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
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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

  it "populates Word template with terms reference labels" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>1.<tab/>Terms and Definitions</title>
      <term id="paddy1"><name>1.1.</name><preferred>paddy</preferred>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">ISO 7301:2011, Clause 3.1</origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
          <div class="WordSection3">
              <p class="zzSTDTitle1"></p>
              <div><a name="_terms_and_definitions" id="_terms_and_definitions"></a><h1>1.<span style="mso-tab-count:1">&#xA0; </span>Terms and Definitions</h1>
      <p class="TermNum"><a name="paddy1" id="paddy1"></a>1.1.</p><p class="Terms" style="text-align:left;">paddy</p>
      <p class="MsoNormal"><a name="_eb29b35e-123e-4d1c-b50b-2714d41e747f" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f"></a>rice retaining its husk after threshing</p>
      <p class="MsoNormal">[SOURCE: <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p></div>
            </div>
    OUTPUT
  end

  it "populates Word header" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        header: "spec/assets/header.html" }
    ).convert("test", <<~"INPUT", false)
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
    expect(word).to be_equivalent_to <<~"OUTPUT"
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
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <sections>
                     <clause id="A" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction<bookmark id="Q"/> to this <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/> <fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
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
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc"))).to be_equivalent_to xmlpp(<<~'OUTPUT')
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
          <p class="MsoNormal">&#xA0;</p>
        </span>
      </p>
              <p class="MsoNormal">&#xA0;</p>
            </div>
    OUTPUT
  end

  it "populates Word ToC with custom levels" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html",
        doctoclevels: 3 }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <sections>
                     <clause id="A" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction<bookmark id="Q"/> to this<fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
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
    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")))
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
                   <p class="MsoNormal">&#xA0;</p>
                 </span>
               </p>
                       <p class="MsoNormal">&#xA0;</p>
                     </div>
    OUTPUT
  end

  it "generates HTML output with custom ToC levels function" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({ htmltoclevels: 3 })
      .convert("test", <<~"INPUT", false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    html = File.read("test.html")
    toclevel = <<~"TOCLEVEL"
      function toclevel() { return "h1:not(:empty):not(.TermNum):not(.noTOC),h2:not(:empty):not(.TermNum):not(.noTOC),h3:not(:empty):not(.TermNum):not(.noTOC)";}
    TOCLEVEL
    expect(html).to include toclevel
  end

  it "reorders footnote numbers in HTML" do
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" }
    ).convert("test", <<~"INPUT", false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <sections>
                     <clause id="A" inline-header="false" obligation="normative"><title>Clause 4</title><fn reference="3">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">This is a footnote.</p>
      </fn><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction to this<fn reference="2">
        Formerly denoted as 15 % (m/m).
      </fn></title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title>Clause 4.2</title>
               <p>A<fn reference="1">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
             </clause></clause>
              </sections>
              </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main xmlns:epub="epub" class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
          <main  xmlns:epub="epub" class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
            <p class="zzSTDTitle1"></p>
            <div id="A">
              <h1>Clause 4</h1>
              <a class='FootnoteRef' href='#fn:3' id='fnref:1'>
                <sup>1</sup>
              </a>
              <div id="N">
               <h2>Introduction to this<a class='FootnoteRef' href='#fn:2' id='fnref:2'><sup>2</sup></a></h2>
             </div>
              <div id="O">
               <h2>Clause 4.2</h2>
               <p>A<a class='FootnoteRef' href='#fn:2'><sup>2</sup></a></p>
             </div>
            </div>
            <aside id="fn:3" class="footnote">
        <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a class='FootnoteRef' href='#fn:3'>
                <sup>1</sup>
              </a>This is a footnote.</p>
      <a href="#fnref:1">&#x21A9;</a></aside>
            <aside id="fn:2" class="footnote">
        <a class='FootnoteRef' href='#fn:2'><sup>2</sup></a>Formerly denoted as 15 % (m/m).
      <a href="#fnref:2">&#x21A9;</a></aside>
          </main>
    OUTPUT
  end

  it "moves images in HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "test_htmlimages"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" }
    ).convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
             <figure id="_">
             <name>Split-it-right sample divider</name>
                      <image src="#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets/rice_image1.png'))}" id="_" mimetype="image/png"/>
                      <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/>
                      <image src="spec/assets/rice_image1.png" id="_" width="20000" height="300000" mimetype="image/png"/>
                      <image src="spec/assets/rice_image1.png" id="_" width="99" height="auto" mimetype="image/png"/>
      <image src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAB9AAAAfQCAAAAAC/U5ulAAAjo0lEQVR4nOzVMQ0AMAzAsPInvYHoMS2yEeTLHADge/M6AADYM3QACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIuAAAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMBAAA//8DAE/7hyLdS2yEAAAAAElFTkSuQmCC"  id="_8357ede4-6d44-4672-bac4-9a85e82ab7f3" mimetype="image/png"/>
      <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
           </figure>
           </foreword></preface>
            </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
                   <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
                     <br />
                     <div>
                       <h1 class="ForewordTitle">Foreword</h1>
                       <div id="_" class="figure">
                       <img src="test_htmlimages/_.png" height="776" width="922" />
                       <img src="test_htmlimages/_.png" height="776" width="922" />
        <img src="test_htmlimages/_.png" height="800" width="53" />
        <img src="test_htmlimages/_.png" height="83" width="99" />
        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAB9AAAAfQCAAAAAC/U5ulAAAjo0lEQVR4nOzVMQ0AMAzAsPInvYHoMS2yEeTLHADge/M6AADYM3QACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIuAAAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMBAAA//8DAE/7hyLdS2yEAAAAAElFTkSuQmCC" height="800" width="800" />
        <img src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='' width=''/>
               <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
                     </div>
                     <p class="zzSTDTitle1"></p>
                   </main>
      OUTPUT
  end

  describe "mathvariant to plain" do
    context "when `mathvariant` attr equal to `script`" do
      it "converts mathvariant text chars into associated plain chars" do
        FileUtils.rm_f "test.html"
        FileUtils.rm_rf "test_htmlimages"
        input = <<~INPUT
          <?xml version="1.0" encoding="UTF-8"?>
          <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" version="1.5.14">
            <sections>
              <clause id="_clause" inline-header="false" obligation="normative">
                <title>Clause</title>
                <p id="_20514f5a-9f86-454e-b6ce-927f65ba6441">
                  <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mi>x</mi>
                      <mo>=</mo>
                      <mstyle mathvariant="script">
                        <mi>l</mi>
                      </mstyle>
                      <mo>+</mo>
                      <mn>1</mn>
                    </math></stem>
                </p>
              </clause>
            </sections>
          </iso-standard>
        INPUT
        output = <<~OUTPUT
          <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
            <p class="zzSTDTitle1"></p>
            <div id="_clause">
              <h1>Clause</h1>
              <p id="_20514f5a-9f86-454e-b6ce-927f65ba6441">
              <span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mi>x</mi>
                  <mo>=</mo>
                  <mstyle mathvariant="script">
                    <mi>&#x1D4C1;</mi>
                  </mstyle>
                  <mo>+</mo>
                  <mn>1</mn>
                </math></span>
            </p>
            </div>
          </main>
        OUTPUT
        IsoDoc::HtmlConvert.new({}).convert("test", input, false)
        html = File.read("test.html")
          .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
          .sub(%r{</main>.*$}m, "</main>")
        expect(html).to(be_equivalent_to(output))
      end
    end

    context "when complex `mathvariant` combinations" do
      it "converts mathvariant text chars into associated plain chars" do
        FileUtils.rm_f "test.html"
        FileUtils.rm_rf "test_htmlimages"
        input = <<~INPUT
          <?xml version="1.0" encoding="UTF-8"?>
          <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" version="1.5.14">
            <sections>
              <clause id="_clause" inline-header="false" obligation="normative">
                <title>Clause</title>
                <p id="_20514f5a-9f86-454e-b6ce-927f65ba6441">
                  <stem type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mstyle mathvariant="sans-serif">
                        <mfrac>
                          <mrow>
                            <mrow>
                              <mi>n</mi>
                              <mfenced open="(" close=")">
                                <mrow>
                                  <mstyle mathvariant="bold">
                                    <mrow>
                                      <mi>n</mi>
                                      <mo>+</mo>
                                      <mn>1</mn>
                                      <mo>+</mo>
                                      <mstyle mathvariant="italic">
                                        <mi>x</mi>
                                      </mstyle>
                                    </mrow>
                                  </mstyle>
                                </mrow>
                              </mfenced>
                            </mrow>
                          </mrow>
                          <mrow>
                            <mstyle mathvariant="bold">
                              <mrow>
                                <mi>y</mi>
                                <mo>+</mo>
                                <mstyle mathvariant="fraktur">
                                  <mi>z</mi>
                                </mstyle>
                              </mrow>
                            </mstyle>
                          </mrow>
                        </mfrac>
                      </mstyle>
                    </math>
                  </stem>
                </p>
              </clause>
            </sections>
          </iso-standard>
        INPUT
        output = <<~OUTPUT
          <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
            <p class="zzSTDTitle1"></p>
            <div id="_clause">
              <h1>Clause</h1>
              <p id="_20514f5a-9f86-454e-b6ce-927f65ba6441">
              <span class="stem"><math xmlns="http://www.w3.org/1998/Math/MathML">
                  <mstyle mathvariant="sans-serif">
                    <mfrac>
                      <mrow>
                        <mrow>
                          <mi>&#x1D5C7;</mi>
                          <mfenced open="(" close=")">
                            <mrow>
                              <mstyle mathvariant="bold">
                                <mrow>
                                  <mi>&#x1D5FB;</mi>
                                  <mo>+</mo>
                                  <mn>&#x1D7ED;</mn>
                                  <mo>+</mo>
                                  <mstyle mathvariant="italic">
                                    <mi>&#x1D66D;</mi>
                                  </mstyle>
                                </mrow>
                              </mstyle>
                            </mrow>
                          </mfenced>
                        </mrow>
                      </mrow>
                      <mrow>
                        <mstyle mathvariant="bold">
                          <mrow>
                            <mi>&#x1D606;</mi>
                            <mo>+</mo>
                            <mstyle mathvariant="fraktur">
                              <mi>&#x1D59F;</mi>
                            </mstyle>
                          </mrow>
                        </mstyle>
                      </mrow>
                    </mfrac>
                  </mstyle>
                </math></span>
            </p>
            </div>
          </main>
        OUTPUT
        IsoDoc::HtmlConvert.new({}).convert("test", input, false)
        html = File.read("test.html")
          .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
          .sub(%r{</main>.*$}m, "</main>")
        expect(html).to(be_equivalent_to(output))
      end
    end
  end

  it "moves images in HTML with no file suffix" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "test_htmlimages"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" }
    ).convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
             <figure id="_">
             <name>Split-it-right sample divider</name>
                      <image src="spec/assets/rice_image1" id="_" mimetype="image/png"/>
                      <image src="spec/assets/rice_image1" id="_" mimetype="image/*"/>
      <image src="data:image/*;base64,iVBORw0KGgoAAAANSUhEUgAAB9AAAAfQCAAAAAC/U5ulAAAjo0lEQVR4nOzVMQ0AMAzAsPInvYHoMS2yEeTLHADge/M6AADYM3QACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIuAAAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMBAAA//8DAE/7hyLdS2yEAAAAAElFTkSuQmCC"  id="_8357ede4-6d44-4672-bac4-9a85e82ab7f3" mimetype="image/png"/>
           </figure>
           </foreword></preface>
            </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <main class='main-section'>
             <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
             <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='figure'>
                 <img src='test_htmlimages/_.png' height='776' width='922'/>
                 <img src='test_htmlimages/_.png' height='776' width='922'/>
                 <img src='data:image/*;base64,iVBORw0KGgoAAAANSUhEUgAAB9AAAAfQCAAAAAC/U5ulAAAjo0lEQVR4nOzVMQ0AMAzAsPInvYHoMS2yEeTLHADge/M6AADYM3QACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIuAAAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMBAAA//8DAE/7hyLdS2yEAAAAAElFTkSuQmCC' height='800' width='800'/>
                 <p class='FigureTitle' style='text-align:center;'>Split-it-right sample divider</p>
               </div>
             </div>
             <p class='zzSTDTitle1'/>
           </main>
      OUTPUT
  end

  it "moves images in HTML, using relative file location" do
    FileUtils.rm_f "spec/test.html"
    FileUtils.rm_rf "spec/test_htmlimages"
    IsoDoc::HtmlConvert.new({ wordstylesheet: "assets/word.css", htmlstylesheet: "assets/html.scss" }).convert("spec/test", <<~"INPUT", false)
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface><foreword>
        <figure id="_">
        <name>Split-it-right sample divider</name>
                 <image src="#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets/rice_image1.png'))}" id="_" mimetype="image/png"/>
                 <image src="assets/rice_image1.png" id="_" mimetype="image/png"/>
                 <image src="assets/rice_image1.png" id="_" width="20000" height="300000" mimetype="image/png"/>
                 <image src="assets/rice_image1.png" id="_" width="99" height="auto" mimetype="image/png"/>
      </figure>
      </foreword></preface>
       </iso-standard>
    INPUT
    html = File.read("spec/test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
                 <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
                   <br />
                   <div>
                     <h1 class="ForewordTitle">Foreword</h1>
                     <div id="_" class="figure">
                     <img src="test_htmlimages/_.png" height="776" width="922" />
                     <img src="test_htmlimages/_.png" height="776" width="922" />
      <img src="test_htmlimages/_.png" height="800" width="53" />
      <img src="test_htmlimages/_.png" height="83" width="99" />
             <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
                   </div>
                   <p class="zzSTDTitle1"></p>
                 </main>
    OUTPUT
  end

  it "encodes images in HTML as data URIs" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "test_htmlimages"
    IsoDoc::HtmlConvert.new({ htmlstylesheet: "spec/assets/html.scss", datauriimage: true }).convert("test", <<~"INPUT", false)
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface><foreword>
        <figure id="_">
        <name>Split-it-right sample divider</name>
                 <image src="#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets/rice_image1.png'))}" id="_" mimetype="image/png"/>
                 <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/>
      </figure>
      </foreword></preface>
       </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html.gsub(%r{src="data:image/png;base64,[^"]+"}, %{src="data:image/png;base64,_"}))).to be_equivalent_to xmlpp(<<~"OUTPUT")
          <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
            <br />
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="_" class="figure">
              <img src="data:image/png;base64,_" height="776" width="922" />
              <img src="data:image/png;base64,_" height="776" width="922" />
      <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
            </div>
            <p class="zzSTDTitle1"></p>
          </main>
    OUTPUT
  end

  it "encodes images in HTML as data URIs, using relative file location" do
    FileUtils.rm_f "spec/test.html"
    FileUtils.rm_rf "spec/test_htmlimages"
    IsoDoc::HtmlConvert.new({ htmlstylesheet: "assets/html.scss", datauriimage: true }).convert("spec/test", <<~"INPUT", false)
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface><foreword>
        <figure id="_">
        <name>Split-it-right sample divider</name>
                 <image src="#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets/rice_image1.png'))}" id="_" mimetype="image/png"/>
                 <image src="assets/rice_image1.png" id="_" mimetype="image/png"/>
      </figure>
      </foreword></preface>
       </iso-standard>
    INPUT
    html = File.read("spec/test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html.gsub(%r{src="data:image/png;base64,[^"]+"}, %{src="data:image/png;base64,_"}))).to be_equivalent_to xmlpp(<<~"OUTPUT")
          <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
            <br />
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="_" class="figure">
              <img src="data:image/png;base64,_" height="776" width="922" />
              <img src="data:image/png;base64,_" height="776" width="922" />
      <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
            </div>
            <p class="zzSTDTitle1"></p>
          </main>
    OUTPUT
  end

  it "processes IsoXML terms for HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1"><name>1.1.</name><preferred>paddy</preferred>
      <domain>rice</domain>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
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
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource></term>
      <term id="paddy"><name>1.2.</name><preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
      <ul><li>A</li></ul>
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termsource status="identical">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to match(%r{<h2 class="TermNum" id="paddy1">1\.1\.</h2>})
    expect(html).to match(%r{<h2 class="TermNum" id="paddy">1\.2\.</h2>})
  end

  it "processes empty term modifications" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
      <term id="paddy1"><preferred>paddy</preferred>
      <domain>rice</domain>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
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
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">ISO 7301:2011, Clause 3.1</origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489"/>
        </modification>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to include '[SOURCE: <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>, modified]'
  end

  it "creates continuation styles for multiparagraph list items in Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
          <div class='WordSection2' xmlns:m='m'>
               <p class='MsoNormal'>
                 <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
               </p>
               <div>
                 <h1 class='ForewordTitle'>Foreword</h1>
                 <p class='MsoListParagraphCxSpFirst'>
                   A
                   <div class='ListContLevel1'>
                     <p class='MsoNormal'>B</p>
                   </div>
                 </p>
                 <p class='MsoListParagraphCxSpLast'>
                   <p class='MsoListParagraphCxSpFirst'>
                     C
                     <div class='ListContLevel2'>
                       <p class='MsoNormal'>D</p>
                     </div>
                     <div class='ListContLevel2'>
                       <p class='Sourcecode'>E</p>
                     </div>
                   </p>
                 </p>
                 <p class='MsoListParagraphCxSpFirst'>
                   A1
                   <div class='ListContLevel1'>
                     <p class='MsoNormal'>B1</p>
                   </div>
                 </p>
                 <p class='MsoListParagraphCxSpLast'>
                   C1
                   <div class='ListContLevel2'>
                     <div>
                       <a name='_5fc1ef0f-75d2-4b54-802c-b1bad4a53b62' id='_5fc1ef0f-75d2-4b54-802c-b1bad4a53b62'/>
                     <div class='formula'>
                       <p class='MsoNormal'>
                         <span class='stem'>
                           <m:oMath>
                             <m:r>
                               <m:t>D1</m:t>
                             </m:r>
                           </m:oMath>
                         </span>
                         <span style='mso-tab-count:1'>&#xA0; </span>
                       </p>
                       </div>
                     </div>
                   </div>
                   <div class='ListContLevel2'>
        <table class='dl'>
          <tr>
            <td valign='top' align='left'>
              <p align='left' style='margin-left:0pt;text-align:left;' class='MsoNormal'>
                <i>n</i>
              </p>
            </td>
            <td valign='top'>
              <p class='MsoNormal'>
                <a name='_a27281a4-b20e-4d0b-a780-bab9e851b03e' id='_a27281a4-b20e-4d0b-a780-bab9e851b03e'/>
                is the number of coating layers
              </p>
            </td>
          </tr>
        </table>
      </div>
                 </p>
               </div>
               <p class='MsoNormal'>&#xA0;</p>
             </div>
    OUTPUT
  end

  it "does not lose HTML escapes in postprocessing" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <sourcecode id="samplecode">
          <name>XML code</name>
        &lt;xml&gt; &amp;
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <br />
        <div>
          <h1 class="ForewordTitle">Foreword</h1>
          <pre id="samplecode" class="prettyprint "><br />&#xA0;&#xA0;&#xA0; <br />&#xA0; &lt;xml&gt; &amp;<br />
          </pre>
          <p class="SourceTitle" style="text-align:center;">XML code</p>
        </div>
        <p class="zzSTDTitle1"></p>
      </main>
    OUTPUT
  end

  it "does not lose HTML escapes in postprocessing (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <sourcecode id="samplecode">
          <name>XML code</name>
        &lt;xml&gt; &amp;
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class="WordSection2">
        <p class="MsoNormal">
          <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
        <div>
          <h1 class="ForewordTitle">Foreword</h1>
          <p class="Sourcecode" style="page-break-after:avoid;"><a name="samplecode" id="samplecode"></a><br/>&#xA0;&#xA0;&#xA0; <br/>&#xA0; &lt;xml&gt; &amp;<br/></p><p class="SourceTitle" style="text-align:center;">XML code</p>
        </div>
        <p class="MsoNormal">&#xA0;</p>
      </div>
    OUTPUT
  end

  it "propagates example style to paragraphs in postprocessing (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <example id="samplecode">
        <p>ABC</p>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
      <table id="_fe12b8f8-6858-4cd6-af7d-d4b6f3ebd1a7" unnumbered="true"><thead><tr>
            <td rowspan="2">
              <p id="_c47d9b39-adb2-431d-9320-78cb148fdb56">Output wavelength <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mo>(</mo><mi>μ</mi><mi>m</mi><mo>)</mo></mrow></math></stem></p>
            </td>
            <th colspan="3" align="left">Predictive wavelengths</th>
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
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                        <td rowspan="2" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">
                <p class="MsoNormal"><a name="_c47d9b39-adb2-431d-9320-78cb148fdb56" id="_c47d9b39-adb2-431d-9320-78cb148fdb56"></a>Output wavelength <span class="stem">
                <m:oMath>
                            <span style='font-style:normal;'>
                              <m:r>
                                <m:rPr>
                                  <m:sty m:val='p'/>
                                </m:rPr>
                                <m:t>(</m:t>
                              </m:r>
                            </span>
                            <m:r>
                              <m:t>&#x3BC;m)</m:t>
                            </m:r>
                          </m:oMath>
        </span></p>
              </td>
                        <th colspan="3" align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Predictive wavelengths</th>
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
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss" }).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
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
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                     <td rowspan='2' align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;'>
                       <p style='text-align: left' class='MsoNormal'>
                         <a name='_c47d9b39-adb2-431d-9320-78cb148fdb56' id='_c47d9b39-adb2-431d-9320-78cb148fdb56'/>
                         Output wavelength
                       </p>
                       <p style='text-align: left' class='MsoNormal'>
                         <a name='_c47d9b39-adb2-431d-9320-78cb148fdb57' id='_c47d9b39-adb2-431d-9320-78cb148fdb57'/>
                         Output wavelength
                       </p>
                     </td>
                     <th colspan='3' align='right' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                       <p style='text-align: right' class='MsoNormal'>
                         <a name='_c47d9b39-adb2-431d-9320-78cb148fdb58' id='_c47d9b39-adb2-431d-9320-78cb148fdb58'/>
                         Predictive wavelengths
                       </p>
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

  it "cleans up boilerplate" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss", filename: "test" }).html_preface(Nokogiri::XML(<<~INPUT)).to_xml).sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>")).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html>
      <head/>
      <body>
      <div class="main-section">
      <div id="boilerplate-copyright"> <h1>Copyright</h1> </div>
      <div id="boilerplate-license"> <h1>License</h1> </div>
      <div id="boilerplate-legal"> <h1>Legal</h1> </div>
      <div id="boilerplate-feedback"> <h1>Feedback</h1> </div>
      <hr/>
      <div id="boilerplate-feedback-destination"/>
      <div id="boilerplate-legal-destination"/>
      <div id="boilerplate-license-destination"/>
      <div id="boilerplate-copyright-destination"/>
      </div>
      </body>
      </html>
    INPUT
      <main class='main-section'>
        <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
        <hr/>
        <div id='boilerplate-feedback'>
          <h1 class='IntroTitle'>Feedback</h1>
        </div>
        <div id='boilerplate-legal'>
          <h1 class='IntroTitle'>Legal</h1>
        </div>
        <div id='boilerplate-license'>
          <h1 class='IntroTitle'>License</h1>
        </div>
        <div id='boilerplate-copyright'>
          <h1 class='IntroTitle'>Copyright</h1>
        </div>
      </main>
    OUTPUT
  end

  it "cleans up boilerplate (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss", filename: "test" }).word_cleanup(Nokogiri::XML(<<~INPUT)).to_xml).sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>")).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html>
      <head/>
      <body>
      <div class="main-section">
      <div id="boilerplate-copyright"> <h1>Copyright</h1> </div>
      <div id="boilerplate-license"> <h1>License</h1> </div>
      <div id="boilerplate-legal"> <h1>Legal</h1> </div>
      <div id="boilerplate-feedback"> <h1>Feedback</h1> </div>
      <hr/>
      <div id="boilerplate-feedback-destination"/>
      <div id="boilerplate-legal-destination"/>
      <div id="boilerplate-license-destination"/>
      <div id="boilerplate-copyright-destination"/>
      </div>
      </body>
      </html>
    INPUT
          <html>
        <head/>
        <body>
          <div class='main-section'>
            <hr/>
            <div id='boilerplate-feedback'>
              <p class='TitlePageSubhead'>Feedback</p>
            </div>
            <div id='boilerplate-legal'>
              <p class='TitlePageSubhead'>Legal</p>
            </div>
            <div id='boilerplate-license'>
              <p class='TitlePageSubhead'>License</p>
            </div>
            <div id='boilerplate-copyright'>
              <p class='TitlePageSubhead'>Copyright</p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "deals with landscape and portrait pagebreaks (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss", filename: "test" }
    ).convert("test", <<~"INPUT", false)
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
             <introduction><title>Preface 1</title>
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
             <sections><clause><title>Foreword</title>
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
              <annex id="_level_1" inline-header="false" obligation="normative">
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
      .sub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <body lang='EN-US' xml:lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection1'>
                   <p class='MsoNormal'>&#xA0;</p>
                 </div>
                 <p class='MsoNormal'>
                   <br clear='all' class='section'/>
                 </p>
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
                 <div class='WordSection2_1'>
                   <div align='center' class='table_container'>
                     <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                       <tbody>
                         <tr>
                           <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>A</td>
                           <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>B</td>
                         </tr>
                       </tbody>
                     </table>
                   </div>
                   <div>
                     <h2>Preface 1.1</h2>
                     <p class='MsoNormal'>On my side</p>
                     <p class='MsoNormal'>
                       <br clear='all' class='section'/>
                     </p>
                   </div>
                 </div>
                 <div class='WordSection2_0'>
                   <p class='MsoNormal'>Upright again</p>
                   <div>
                     <h2>Preface 1.3</h2>
                     <p class='MsoNormal'>And still upright</p>
                   </div>
                   <p class='MsoNormal'>&#xA0;</p>
                 </div>
                 <p class='MsoNormal'>
                   <br clear='all' class='section'/>
                 </p>
                 <div class='WordSection3'>
                   <p class='zzSTDTitle1'>Document title</p>
                   <div>
                     <h1>Foreword</h1>
                     <div class='Note'>
                       <p class='Note'>
                         <span class='note_label'/>
                         <span style='mso-tab-count:1'>&#xA0; </span>
                         For further information on the Foreword, see
                         <b>ISO/IEC Directives, Part 2, 2016, Clause 12.</b>
                       </p>
                       <p class='Note'>
                         <br clear='all' class='section'/>
                       </p>
                     </div>
                   </div>
                 </div>
                 <div class='WordSection3_2'>
                   <div align='center' class='table_container'>
                     <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                       <a name='_c09a7e60-b0c7-4418-9bfc-2ef0bc09a249' id='_c09a7e60-b0c7-4418-9bfc-2ef0bc09a249'/>
                       <thead>
                         <tr>
                           <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>A</th>
                           <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>B</th>
                         </tr>
                       </thead>
                       <tbody>
                         <tr>
                           <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>C</td>
                           <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>D</td>
                         </tr>
                       </tbody>
                       <tfoot>
                         <tr>
                           <td colspan='2' style='border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                             <div class='Note'>
                               <a name='_8fff1596-290e-4314-b03c-7a8aab97eebe' id='_8fff1596-290e-4314-b03c-7a8aab97eebe'/>
                               <p class='Note'>
                                 <span class='note_label'/>
                                 <span style='mso-tab-count:1'>&#xA0; </span>
                                 B
                               </p>
                             </div>
                           </td>
                         </tr>
                       </tfoot>
                     </table>
                   </div>
                   <p class='Note'>
                     <br clear='all' class='section'/>
                   </p>
                 </div>
                 <div class='WordSection3_1'>
                   <p class='Note'>And up</p>
                      <p class='MsoNormal'>
             <br clear='all' class='section'/>
           </p>
         </div>
         <div class='WordSection3_0'>
           <div class='Section3'>
             <a name='_level_1' id='_level_1'/>
             <h1 class='Annex'>Annex 1</h1>
           </div>
                 </div>
                 <div style='mso-element:footnote-list'/>
               </body>
      OUTPUT
  end

  it "expands out nested tables in Word" do
    expect(xmlpp(IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss", filename: "test" }).word_cleanup(Nokogiri::XML(<<~INPUT)).to_xml).sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>")).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
  end

  it "allocate widths to tables (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.scss", filename: "test" }).word_cleanup(Nokogiri::XML(<<~INPUT)).to_xml).sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>")).to be_equivalent_to xmlpp(<<~"OUTPUT")
             <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
               <head><style/></head>
               <body lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection1'>
                   <p>&#160;</p>
                 </div>
                 <p>
                   <br clear='all' class='section'/>
                 </p>
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
                   <p class='zzSTDTitle1'/>
                   <aside id='ftn1'>
                     <p>X</p>
                   </aside>
                 </div>
               </body>
             </html>
    INPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
               <head>
                 <style/>
               </head>
               <body lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection1'>
                   <p>&#xA0;</p>
                 </div>
                 <p>
                   <br clear='all' class='section'/>
                 </p>
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
                   <p class='zzSTDTitle1'/>
                   <aside id='ftn1'>
                     <p>X</p>
                   </aside>
                 </div>
               </body>
             </html>
    OUTPUT
  end
end
