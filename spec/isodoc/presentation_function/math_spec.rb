require "spec_helper"

RSpec.describe IsoDoc::PresentationXMLConvert do
  it "correctly parses options with commas inside values" do
    converter = IsoDoc::PresentationXMLConvert.new({})
    options = "'group_digits=3','fraction_group_digits=3','decimal=,','group= ','fraction_group= ','notation=general'"
    result = converter.numberformat_extract(options)
    
    expect(result).to eq({
      group_digits: "3",
      fraction_group_digits: "3",
      decimal: ",",
      group: " ",
      fraction_group: " ",
      notation: "general"
    })
  end
end
