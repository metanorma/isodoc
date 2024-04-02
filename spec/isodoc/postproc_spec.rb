# frozen_string_literal: true

require "spec_helper"
require "fileutils"

options = { wordstylesheet: "spec/assets/word.css",
            htmlstylesheet: "spec/assets/html.scss" }

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        filename: "test" },
    ).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
          <preface><foreword displayorder="1">
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
        filename: "test" },
    ).convert("spec/assets/test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
          <preface><foreword displayorder="1">
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
          <preface><foreword displayorder="1">
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
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
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
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
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
        htmlstylesheet: "html.scss" },
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
        htmlstylesheet: "html.scss" },
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
        htmlstylesheet: "html.scss" },
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
        scripts_override: "spec/assets/scripts_override.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
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
    expect(html).to match(/This is > also a script/)
    expect(html).not_to match(/CDATA/)
    expect(html).to match(%r{Antaŭparolo</h1>})
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
        olstyle: "l2" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = File.read("test.html")
    expect(html).to match(/another empty stylesheet/)
    expect(html).to match(/p \{[^}]*?font-family: Arial/m)
    expect(html).to match(/code \{[^}]*?font-family: Courier New/m)
    expect(html).to match(/h1 \{[^}]*?font-family: Arial/m)
    expect(html).to match(/p \{[^}]*?font-size: 1em;/m)
    expect(html).to match(/code \{[^}]*?font-size: 0.8em/m)
    expect(html).to match(/p\.note \{[^}]*?font-size: 0.9em/m)
    expect(html).to match(/aside \{[^}]*?font-size: 0.9em/m)
    expect(html).to match(/an empty html cover page/)
    expect(html).to match(/an empty html intro page/)
    expect(html).to match(/This is > a script/)
    expect(html).not_to match(/CDATA/)
    expect(html).to match(%r{Antaŭparolo</h1>})
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
        olstyle: "l2" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
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
        olstyle: "l2" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    word = File.read("test.doc")
    expect(word).to match(/another empty stylesheet/)
    expect(word).to match(/p \{[^}]*?font-family: Arial/m)
    expect(word).to match(/code \{[^}]*?font-family: Courier New/m)
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

  it "cleans up HTML output preface placeholder paragraphs" do
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
        scripts_override: "spec/assets/scripts_override.html",
        i18nyaml: "spec/assets/i18n.yaml",
        ulstyle: "l1",
        olstyle: "l2" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1" id="fwd">
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = Nokogiri::XML(File.read("test.html")).at("//body")
    html.xpath("//script").each(&:remove)
    expect(strip_guid(xmlpp(html.to_xml)))
      .to be_equivalent_to <<~OUTPUT
      <body lang="en" xml:lang="en">
          <div class="title-section">
      /* an empty html cover page */
          </div>
          <br/>
          <div class="prefatory-section">
      /* an empty html intro page */
      <ul id="toc-list"/>
             <div id="toc"><ul><li class="h1"><a href="#_">      Antaŭparolo</a></li></ul></div>
       </div>
         <br/>
         <main class="main-section">
           <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
           <br/>
           <div id="fwd">
             <h1 class="ForewordTitle" id="_">Antaŭparolo</h1>
             <div class="Note">
               <p>  These results are based on a study carried out on three different types of kernel.</p>
             </div>
           </div>
         </main>
       </body>
    OUTPUT
  end

  it "populates HTML ToC" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new({htmlintropage: "spec/assets/htmlintro.html"})
      .convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword displayorder="1"><title>Foreword</title>
        <variant-title type="toc">FORVORT</variant-title>
        </foreword></preface>
        <sections>
        <clause displayorder="2"><title>First Clause</title>
        <clause><title>First Subclause</title>
        <variant-title type="toc">SUBCLOZ</variant-title>
        </clause>
        </clause>
        <clause displayorder="3"><title>Second Clause</title><clause><title>Subclause</title></clause></clause>
        </sections>
        </iso-standard>
      INPUT
    html = Nokogiri::XML(File.read("test.html"))
      .at("//div[@id = 'toc']")
    expect(strip_guid(xmlpp(html.to_xml)))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
       <div id="toc">
         <ul>
           <li class="h1">
             <a href="#_">      FORVORT</a>
           </li>
           <li class="h1">
             <a href="#_">      First Clause</a>
           </li>
           <li class="h2">
             <a href="#_">      SUBCLOZ</a>
           </li>
           <li class="h1">
             <a href="#_">      Second Clause</a>
           </li>
           <li class="h2">
             <a href="#_">      Subclause</a>
           </li>
         </ul>
       </div>
    OUTPUT
  end

  it "reorders footnote numbers in HTML" do
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss",
        wordintropage: "spec/assets/wordintro.html" },
    ).convert("test", <<~INPUT, false)
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <sections>
                     <clause id="A" inline-header="false" obligation="normative" displayorder="1"><title>Clause 4</title><fn reference="3">
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
      .sub(/^.*<main class="main-section">/m,
           '<main xmlns:epub="epub" class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~OUTPUT)
          <main  xmlns:epub="epub" class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
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

  it "moves images in HTML #1" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf Dir.glob "test_*_htmlimages"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
             <figure id="_">
             <name>Split-it-right sample divider</name>
                      <svg xmlns="http://www.w3.org/2000/svg" src="spec/assets/rice_image1.png" id="_" width="20000" height="300000"/>
                            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000">
      <g transform="translate(-0.0000, -0.0000)">
      <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
      <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
      <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
      </g>
      </g>
      </svg>
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
    expect(`ls test_*_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))
    .gsub(/test_[^_]+_htmlimages/, "test_htmlimages"))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
                   <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
                     <br />
                     <div>
                       <h1 class="ForewordTitle">Foreword</h1>
                       <div id="_" class="figure">
                                    <svg xmlns='http://www.w3.org/2000/svg' src='spec/assets/rice_image1.png' id='_' width='53' height='800' viewBox='0 0 20002 300002'/>
             <svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' version='1.1' width='800' height='800' viewBox='0 0 1277 1277'>
               <g transform='translate(-0.0000, -0.0000)'>
                 <g transform='matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)'>
                   <path d='M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z ' fill='#000099' stroke='none'/>
                   <path d='M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z ' fill='#FFFFFF' stroke='none'/>
                 </g>
               </g>
             </svg>
                       <img src="test_htmlimages/_.png" height="776" width="922" />
                       <img src="test_htmlimages/_.png" height="776" width="922" />
        <img src="test_htmlimages/_.png" height="800" width="53" />
        <img src="test_htmlimages/_.png" height="83" width="99" />
        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAB9AAAAfQCAAAAAC/U5ulAAAjo0lEQVR4nOzVMQ0AMAzAsPInvYHoMS2yEeTLHADge/M6AADYM3QACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIMHQACDB0AAgwdAAIuAAAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMCB0ABgIAAP//7NWBDAAAAMAgf+t7fCWR0AFgQOgAMCB0ABgQOgAMCB0ABoQOAANCB4ABoQPAgNABYEDoADAgdAAYEDoADAgdAAaEDgADQgeAAaEDwIDQAWBA6AAwIHQAGBA6AAwIHQAGhA4AA0IHgAGhA8CA0AFgQOgAMCB0ABgQOgAMBAAA//8DAE/7hyLdS2yEAAAAAElFTkSuQmCC" height="800" width="800" />
        <img src='data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==' height='20' width='0'/>
               <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
                     </div>
                   </main>
      OUTPUT
  end

  it "moves images in HTML #2" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "test_htmlimages"
    IsoDoc::HtmlConvert.new(
      { baseassetpath: "spec/assets",
        wordstylesheet: "word.css",
        htmlstylesheet: "html.scss" },
    ).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1">
       <figure id="_">
       <name>Split-it-right sample divider</name>
       <image src="rice_image1.png" id="_" mimetype="image/png"/>
       </figure>
      </foreword></preface>
      </iso-standard>
    INPUT
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_*_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))
           .gsub(/test_[^_]+_htmlimages/, "test_htmlimages"))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
            <main class='main-section'>
          <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
          <br/>
          <div>
            <h1 class='ForewordTitle'>Foreword</h1>
            <div id='_' class='figure'>
              <img src='test_htmlimages/_.png' height='776' width='922'/>
              <p class='FigureTitle' style='text-align:center;'>Split-it-right sample divider</p>
            </div>
          </div>
        </main>
      OUTPUT
  end

  describe "mathvariant to plain" do
    context "when `mathvariant` attr equal to `script`" do
      it "converts mathvariant text chars into associated plain chars" do
        FileUtils.rm_f "test.html"
        input = <<~INPUT
          <?xml version="1.0" encoding="UTF-8"?>
          <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" version="1.5.14">
            <sections>
              <clause id="_clause" inline-header="false" obligation="normative" displayorder="1">
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
        input = <<~INPUT
          <?xml version="1.0" encoding="UTF-8"?>
          <iso-standard xmlns="https://www.metanorma.org/ns/iso" type="semantic" version="1.5.14">
            <sections>
              <clause id="_clause" inline-header="false" obligation="normative" displayorder="1">
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
    FileUtils.rm_rf Dir.glob "test_*_htmlimages"
    IsoDoc::HtmlConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword displayorder="1">
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
    expect(`ls test_*_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))
    .gsub(/test_[^_]+_htmlimages/, "test_htmlimages"))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
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
           </main>
      OUTPUT
  end

  it "moves images in HTML, using relative file location" do
    FileUtils.rm_f "spec/test.html"
    FileUtils.rm_rf "spec/test_htmlimages"
    IsoDoc::HtmlConvert
      .new(wordstylesheet: "assets/word.css",
           htmlstylesheet: "assets/html.scss")
      .convert("spec/test", <<~"INPUT", false)
         <iso-standard xmlns="http://riboseinc.com/isoxml">
         <preface><foreword displayorder="1">
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
    expect(`ls test_*_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))
           .gsub(/test_[^_]+_htmlimages/, "test_htmlimages"))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
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
                   </main>
      OUTPUT
  end

  it "encodes images in HTML as data URIs" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf Dir.glob "test_*_htmlimages"
    IsoDoc::HtmlConvert
      .new(htmlstylesheet: "spec/assets/html.scss", datauriimage: true)
      .convert("test", <<~"INPUT", false)
         <iso-standard xmlns="http://riboseinc.com/isoxml">
         <preface><foreword displayorder="1">
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
    expect(xmlpp(html
      .gsub(%r{src="data:image/png;base64,[^"]+"}, %{src="data:image/png;base64,_"})))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
            <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
              <br />
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div id="_" class="figure">
                <img src="data:image/png;base64,_" height="776" width="922" />
                <img src="data:image/png;base64,_" height="776" width="922" />
        <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
              </div>
            </main>
      OUTPUT
  end

  it "encodes images in HTML as data URIs, using relative file location" do
    FileUtils.rm_f "spec/test.html"
    FileUtils.rm_rf Dir.glob "test_*_htmlimages"
    IsoDoc::HtmlConvert
      .new({ htmlstylesheet: "assets/html.scss", datauriimage: true })
      .convert("spec/test", <<~"INPUT", false)
         <iso-standard xmlns="http://riboseinc.com/isoxml">
         <preface><foreword displayorder="1">
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
    expect(xmlpp(html
      .gsub(%r{src="data:image/png;base64,[^"]+"}, %{src="data:image/png;base64,_"})))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
            <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
              <br />
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div id="_" class="figure">
                <img src="data:image/png;base64,_" height="776" width="922" />
                <img src="data:image/png;base64,_" height="776" width="922" />
        <p class="FigureTitle" style="text-align:center;">Split-it-right sample divider</p></div>
              </div>
            </main>
      OUTPUT
  end

  it "processes IsoXML terms for HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    IsoDoc::HtmlConvert.new(options)
      .convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <sections>
            <terms id="_terms_and_definitions" obligation="normative" displayorder="1"><title>Terms and Definitions</title>
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

  it "does not lose HTML escapes in postprocessing" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
          <sourcecode id="samplecode">
          <name>XML code</name>
        &lt;xml&gt; &amp;
      </sourcecode>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::HtmlConvert.new(options).convert("test", input, false)
    html = File.read("test.html")
      .sub(/^.*<main class="main-section">/m, '<main class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~OUTPUT)
      <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
        <br />
        <div>
          <h1 class="ForewordTitle">Foreword</h1>
          <pre id="samplecode" class="sourcecode"><br />&#xA0;&#xA0;&#xA0; <br />&#xA0; &lt;xml&gt; &amp;<br />
          </pre>
          <p class="SourceTitle" style="text-align:center;">XML code</p>
        </div>
      </main>
    OUTPUT

    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::WordConvert.new(options).convert("test", input, false)
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
          <p class="Sourcecode" style="page-break-after:avoid;"><a name="samplecode" id="samplecode"></a><br/>&#xA0;&#xA0;&#xA0; <br/>&#xA0; &lt;xml&gt; &amp;<br/></p><p class="SourceTitle" style="text-align:center;">XML code</p>
        </div>
        <p class="MsoNormal">&#xA0;</p>
      </div>
    OUTPUT
  end

  it "cleans up boilerplate" do
    input = <<~INPUT
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
    html = <<~OUTPUT
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
    doc = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::HtmlConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
      .html_preface(Nokogiri::XML(input)).to_xml)
      .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
       .word_cleanup(Nokogiri::XML(input)).to_xml)
       .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(doc)
  end

  it "cleans up coverpage note" do
    input = <<~INPUT
      <html>
      <head/>
      <body>
      <div class="main-section">
                      <div id='FB' class='Note' coverpage='true'>
                 <p><span class='note_label'>NOTE</span>&#160; XYZ</p>
               </div>
               <div id='FC' class='Admonition' coverpage='true'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
      <hr/>
      <div id="coverpage-note-destination"/>
      </div>
      </body>
      </html>
    INPUT
    html = <<~OUTPUT
      <main class='main-section'>
        <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
        <hr/>
        <div id='coverpage-note-destination'>
          <div id='FB' class='Note'>
            <p>
              <span class='note_label'>NOTE</span>
              &#xA0; XYZ
            </p>
          </div>
          <div id='FC' class='Admonition'>
            <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
            <p>XYZ</p>
          </div>
        </div>
      </main>
    OUTPUT
    doc = <<~OUTPUT
          <html>
        <head/>
        <body>
          <div class='main-section'>
            <hr/>
            <div id='coverpage-note-destination'>
              <div id='FB' class='Note'>
                <p>
                  <span class='note_label'>NOTE</span>
                  &#xA0; XYZ
                </p>
              </div>
              <div id='FC' class='Admonition'>
                <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                <p>XYZ</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert
  .new(wordstylesheet: "spec/assets/word.css",
       htmlstylesheet: "spec/assets/html.scss", filename: "test")
  .html_preface(Nokogiri::XML(input)).to_xml)
  .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
       .word_cleanup(Nokogiri::XML(input)).to_xml)
       .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(doc)
  end

  it "removes coverpage note destination if unused" do
    input = <<~INPUT
      <html>
      <head/>
      <body>
      <div class="main-section">
                      <div id='FB' class='Note'>
                 <p><span class='note_label'>NOTE</span>&#160; XYZ</p>
               </div>
               <div id='FC' class='Admonition'>
                 <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
                 <p>XYZ</p>
               </div>
      <hr/>
      <div id="coverpage-note-destination"/>
      </div>
      </body>
      </html>
    INPUT
    html = <<~OUTPUT
      <main class='main-section'>
        <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
        <div id='FB' class='Note'>
          <p>
            <span class='note_label'>NOTE</span>
            &#xA0; XYZ
          </p>
        </div>
        <div id='FC' class='Admonition'>
          <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
          <p>XYZ</p>
        </div>
        <hr/>
      </main>
    OUTPUT
    doc = <<~OUTPUT
          <html>
        <head/>
        <body>
          <div class='main-section'>
            <div id='FB' class='Note'>
              <p>
                <span class='note_label'>NOTE</span>
                &#xA0; XYZ
              </p>
            </div>
            <div id='FC' class='Admonition'>
              <p class='AdmonitionTitle' style='text-align:center;'>WARNING</p>
              <p>XYZ</p>
            </div>
            <hr/>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert
  .new(wordstylesheet: "spec/assets/word.css",
       htmlstylesheet: "spec/assets/html.scss", filename: "test")
  .html_preface(Nokogiri::XML(input)).to_xml)
  .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert
      .new(wordstylesheet: "spec/assets/word.css",
           htmlstylesheet: "spec/assets/html.scss", filename: "test")
       .word_cleanup(Nokogiri::XML(input)).to_xml)
       .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(doc)
  end

  it "generates bare HTML file" do
    FileUtils.rm_f "test.html"
    IsoDoc::HtmlConvert.new(
      { bare: true,
        htmlstylesheet: "spec/assets/html.scss",
        filename: "test" },
    ).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title language="en">test</title>
              </bibdata>
              <boilerplate>
              <feedback-statement>
              <clause><title>I am boilerplate</title></clause>
              </feedback-statement>
              </boilerplate>
          <preface><foreword displayorder="1">
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <body lang='en' xml:lang='en'>
        <main class='main-section'>
          <br/>
          <div>
            <h1 class='ForewordTitle'>Foreword</h1>
            <div class='Note'>
              <p>
                &#xA0; These results are based on a study carried out on three
                different types of kernel.
              </p>
            </div>
          </div>
        </main>
        <script/>
      </body>
    OUTPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
      .sub(%r{^.*<body}m, "<body")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(%r{<script.+?</script>}m, "<script/>")
      .sub(%r{(<script/>\s+)+}m, "<script/>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(output)
  end

  it "cleans up lists (HTML)" do
    input = <<~INPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops">
      <head/>
      <body>
        <div class="main-section">
        <ul>
        <div>N1</div>
        <li>A</li>
        <li>B</li>
        <div>N2</div>
        <li>C</li>
        <div>N3</div>
        </div>
      </body>
      </html>
    INPUT
    output = <<~OUTPUT
      <main class='main-section'>
        <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
        <ul>
          <li>
            A
            <div>N1</div>
          </li>
          <li>
            B
            <div>N2</div>
          </li>
          <li>
            C
            <div>N3</div>
          </li>
        </ul>
      </main>
    OUTPUT
    expect(xmlpp(IsoDoc::HtmlConvert
  .new(htmlstylesheet: "spec/assets/html.scss", filename: "test")
  .html_cleanup(Nokogiri::XML(input)).to_xml)
  .sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))
      .to be_equivalent_to xmlpp(output)
  end

  it "has hex-only XML escapes" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1">
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">&lt;X&gt;</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::HtmlConvert.new({ wordstylesheet: "spec/assets/word.css" })
      .convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html")
    expect(html).to include "&#x3c;X&#x3e;"
    expect(html).not_to include "&lt;X&gt;"
    IsoDoc::WordConvert.new({ wordstylesheet: "spec/assets/word.css" })
      .convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc")
    expect(html).not_to include "&#x3c;X&#x3e;"
    expect(html).to include "&lt;X&gt;"
  end
end
