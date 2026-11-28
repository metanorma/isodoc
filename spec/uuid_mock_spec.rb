require_relative "spec_helper"

RSpec.describe "Presentation XML id mint mock" do
  describe "mock_uuid_increment" do
    it "mints incrementing ids from a fresh converter" do
      mock_uuid_increment
      klass = IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")

      expect(klass.add_id_text("x")).to eq('id="_1"')
      expect(klass.add_id_text("y")).to eq('id="_2"')
    end

    it "resets the counter for each test" do
      mock_uuid_increment
      klass = IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")

      expect(klass.add_id_text("x")).to eq('id="_1"')
    end
  end
end
