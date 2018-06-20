require "spec_helper"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", filename: "test"}).convert("test", <<~"INPUT", false)
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
    expect(html).to match(%r{<title>test</title><style>})
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/2\.7\.1/MathJax\.js})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
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
    expect(html).to match(%r{<title>test</title><style>})
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/2\.7\.1/MathJax\.js})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates Word output docs with null configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
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
  end

  it "generates HTML output docs with null configuration from file" do
    system "rm -f spec/assets/iso.doc"
    system "rm -f spec/assets/iso.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html")
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    system "rm -f spec/assets/iso.doc"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc")
    expect(word).to match(/one empty stylesheet/)
  end

  it "generates HTML output docs with complete configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", standardstylesheet: "spec/assets/std.css", header: "spec/assets/header.html", htmlcoverpage: "spec/assets/htmlcover.html", htmlintropage: "spec/assets/htmlintro.html", scripts: "spec/assets/scripts.html", wordcoverpage: "spec/assets/wordcover.html", wordintropage: "spec/assets/wordintro.html", i18nyaml: "spec/assets/i18n.yaml", ulstyle: "l1", olstyle: "l2"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.html")
    expect(html).to match(/a third empty stylesheet/)
    expect(html).to match(/an empty html cover page/)
    expect(html).to match(/an empty html intro page/)
    expect(html).to match(/This is > a script/)
    expect(html).not_to match(/CDATA/)
    expect(html).to match(%r{Enkonduko</h1>})
  end

  it "generates Word output docs with complete configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", standardstylesheet: "spec/assets/std.css", header: "spec/assets/header.html", htmlcoverpage: "spec/assets/htmlcover.html", htmlintropage: "spec/assets/htmlintro.html", wordcoverpage: "spec/assets/wordcover.html", wordintropage: "spec/assets/wordintro.html", i18nyaml: "spec/assets/i18n.yaml", ulstyle: "l1", olstyle: "l2"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    word = File.read("test.doc")
    expect(word).to match(/a third empty stylesheet/)
    expect(word).to match(/<title>test<\/title>/)
    expect(word).to match(/test_files\/header.html/)
    expect(word).to match(/an empty word cover page/)
    expect(word).to match(/an empty word intro page/)
    expect(word).to match(%r{Enkonduko</h1>})
  end

  it "converts definition lists to tables for Word" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
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
    word = File.read("test.doc").sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">').
      sub(%r{<br clear="all" class="section"/>\s*<div class="WordSection3">.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
        <div class="WordSection2">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
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

  it "converts annex subheadings to h2Annex class for Word" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         </clause>
                <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
    </annex>
    </iso-standard>
    INPUT
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div class="Section3"><a name="P" id="P"></a>
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div><a name="Q" id="Q"></a>
            <p class="h2Annex">A.1. Annex A.1</p>
       </div>
              <div><a name="Q2" id="Q2"></a>
                <p class="h2Annex">Appendix 1. An Appendix</p>
                </div>
               </div>
             </div>
    OUTPUT
  end

  it "populates Word template with terms reference labels" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>

<term id="paddy1"><preferred>paddy</preferred>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termsource status="modified">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

</terms>
</sections>
</iso-standard>

    INPUT
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <div><a name="_terms_and_definitions" id="_terms_and_definitions"></a><h1>1.<span style="mso-tab-count:1">&#xA0; </span>Terms and definitions</h1><p class="MsoNormal">For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="MsoNormal">ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li class="MsoNormal"> <p class="MsoNormal">ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li class="MsoNormal"> <p class="MsoNormal">IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <p class="TermNum"><a name="paddy1" id="paddy1"></a>1.1</p><p class="Terms" style="text-align:left;">paddy</p>
       <p class="MsoNormal"><a name="_eb29b35e-123e-4d1c-b50b-2714d41e747f" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f"></a>rice retaining its husk after threshing</p>
       <p class="MsoNormal">[SOURCE: <a href="#ISO7301">ISO 7301: 2011, 3.1</a>, modified &mdash; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p></div>
             </div>
    OUTPUT
  end

  it "populates Word header" do
    system "rm -f test.doc"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", header: "spec/assets/header.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="article">
                        <docidentifier>
           <project-number part="1">1000</project-number>
         </docidentifier>
        </bibdata>
</iso-standard>

    INPUT
    word = File.read("test.doc").sub(%r{^.*Content-Location: file:///C:/Doc/test_files/header.html}m, "Content-Location: file:///C:/Doc/test_files/header.html").
      sub(/------=_NextPart.*$/m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"

Content-Location: file:///C:/Doc/test_files/header.html
Content-Transfer-Encoding: base64
Content-Type: text/html charset="utf-8"

Ci8qIGFuIGVtcHR5IGhlYWRlciAqLwoKU1RBUlQgRE9DIElEOiAxMDAwLTE6IEVORCBET0MgSUQK
CkZJTEVOQU1FOiB0ZXN0Cgo=

    OUTPUT
  end

  it "populates Word ToC" do
    system "rm -f test.doc"
    IsoDoc::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", wordintropage: "spec/assets/wordintro.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
               <clause inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">

         <title>Introduction<bookmark id="Q"/> to this<fn reference="1">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
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
    word = File.read("test.doc").sub(/^.*<div class="WordSection2">/m, '<div class="WordSection2">').
      sub(%r{<br clear="all" class="section"/>\s*<div class="WordSection3">.*$}m, "")
    expect(word.gsub(/_Toc\d\d+/, "_Toc")).to be_equivalent_to <<~'OUTPUT'
           <div class="WordSection2">
       /* an empty word intro page */

       <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"></span><span style="mso-spacerun:yes">&#xA0;</span>TOC
         \o "1-2" \h \z \u <span style="mso-element:field-separator"></span></span>
       <span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1.<span style="mso-tab-count:1">&#xA0; </span>Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-tab-count:1 dotted">. </span>
       </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-element:field-begin"></span></span>
       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span></span></p>

       <p class="MsoToc2">
         <span class="MsoHyperlink">
           <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1.1. Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
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
       <a href="#_Toc">1.2. Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
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

  it "reorders footnote numbers in HTML" do
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", wordintropage: "spec/assets/wordintro.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
               <clause inline-header="false" obligation="normative"><title>Clause 4</title><fn reference="3">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">This is a footnote.</p>
</fn><clause id="N" inline-header="false" obligation="normative">

         <title>Introduction to this<fn reference="2">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
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
    html = File.read("test.html").sub(/^.*<main class="main-section">/m, '<main class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(html).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <div>
               <h1>1.&#xA0; Clause 4</h1>
               <a rel="footnote" href="#fn:3" epub:type="footnote" id="fnref:1">
                 <sup>1</sup>
               </a>
               <div id="N">

                <h2>1.1. Introduction to this<a rel="footnote" href="#fn:2" epub:type="footnote" id="fnref:2"><sup>2</sup></a></h2>
              </div>
               <div id="O">
                <h2>1.2. Clause 4.2</h2>
                <p>A<a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
              </div>
             </div>
             <aside id="fn:3" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:3" epub:type="footnote" id="fnref:1">
                 <sup>1</sup>
               </a>This is a footnote.</p>
       <a href="#fnref:1">&#x21A9;</a></aside>
             <aside id="fn:2" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:2" epub:type="footnote" id="fnref:2"><sup>2</sup></a>Formerly denoted as 15 % (m/m).</p>
       <a href="#fnref:2">&#x21A9;</a></aside>

           </main>
    OUTPUT
  end

  it "moves images in HTML" do
    system "rm -f test.html"
    system "rm -rf _images"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
         <figure id="_">
         <name>Split-it-right sample divider</name>
                  <image src="spec/assets/rice_image1.png" id="_" imagetype="PNG"/>
       </figure>
       </foreword></preface>
        </iso-standard>
    INPUT
    html = File.read("test.html").sub(/^.*<main class="main-section">/m, '<main class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(`ls _images`).to match(/\.png$/)
    expect(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png")).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <br />
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="figure">

                  <img src="_images/_.png" width="800" height="673" />
       <p class="FigureTitle" align="center">Figure 1&#xA0;&#x2014; Split-it-right sample divider</p></div>
             </div>
             <p class="zzSTDTitle1"></p>
           </main>
    OUTPUT

  end

  it "processes IsoXML terms for HTML" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
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
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

<term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
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
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
</termsource></term>
</terms>
</sections>
</iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to match(%r{<h2 class="TermNum" id="paddy1">1\.1</h2>})
    expect(html).to match(%r{<h2 class="TermNum" id="paddy">1\.2</h2>})
  end

end
