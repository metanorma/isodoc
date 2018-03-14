require "spec_helper"

RSpec.describe IsoDoc do
  it "generates output docs with null configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::Convert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert_file(<<~"INPUT", "test", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.html")).to be true
    word = File.read("test.doc")
    expect(word).to match(/one empty stylesheet/)
    html = File.read("test.html")
    expect(html).to match(/another empty stylesheet/)
  end

  it "generates output docs with null configuration from file" do
    system "rm -f spec/assets/iso.doc"
    system "rm -f spec/assets/iso.html"
    IsoDoc::Convert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    expect(File.exist?("spec/assets/iso.html")).to be true
    word = File.read("spec/assets/iso.doc")
    expect(word).to match(/one empty stylesheet/)
    html = File.read("spec/assets/iso.html")
    expect(html).to match(/another empty stylesheet/)
  end


  it "generates output docs with complete configuration" do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::Convert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", standardstylesheet: "spec/assets/std.css", header: "spec/assets/header.html", htmlcoverpage: "spec/assets/htmlcover.html", htmlintropage: "spec/assets/htmlintro.html", wordcoverpage: "spec/assets/wordcover.html", wordintropage: "spec/assets/wordintro.html", i18nyaml: "spec/assets/i18n.yaml", ulstyle: "l1", olstyle: "l2"}).convert_file(<<~"INPUT", "test", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
    INPUT
    word = File.read("test.doc")
    expect(word).to match(/a third empty stylesheet/)
    expect(word).to match(/test_files\/header.html/)
    expect(word).to match(/an empty word cover page/)
    expect(word).to match(/an empty word intro page/)
    expect(word).to match(%r{Enkonduko</h1>})
    html = File.read("test.html")
    expect(html).to match(/a third empty stylesheet/)
    expect(html).to match(/an empty html cover page/)
    expect(html).to match(/an empty html intro page/)
    expect(html).to match(%r{Enkonduko</h1>})
  end

  it "converts Word " do
    system "rm -f test.doc"
    system "rm -f test.html"
    IsoDoc::Convert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", standardstylesheet: "spec/assets/std.css", header: "spec/assets/header.html", htmlcoverpage: "spec/assets/htmlcover.html", htmlintropage: "spec/assets/htmlintro.html", wordcoverpage: "spec/assets/wordcover.html", wordintropage: "spec/assets/wordintro.html", i18nyaml: "spec/assets/i18n.yaml", ulstyle: "l1", olstyle: "l2"}).convert_file(<<~"INPUT", "test", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword>
    </iso-standard>
    INPUT
  end

end
