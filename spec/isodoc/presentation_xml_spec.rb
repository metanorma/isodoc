require "spec_helper"
  
RSpec.describe IsoDoc do
it "generates file based on string input" do
  FileUtils.rm_f "test.presentation.xml"
    IsoDoc::PresentationXMLConvert.new({filename: "test"}).convert("test", <<~"INPUT", false)
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
    expect(File.exist?("test.presentation.xml")).to be true
  end
end
