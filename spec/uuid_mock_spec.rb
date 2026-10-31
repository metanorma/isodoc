require_relative "spec_helper"

RSpec.describe "Metanorma::Utils.random_uuid mock" do
  describe "mock_uuid_increment" do
    before do
      mock_uuid_increment
    end

    it "returns incrementing numbers for each call to random_uuid" do
      expect(Metanorma::Utils.random_uuid).to eq("1")
      expect(Metanorma::Utils.random_uuid).to eq("2")
      expect(Metanorma::Utils.random_uuid).to eq("3")
    end

    it "works with string interpolation" do
      uuid = Metanorma::Utils.random_uuid
      expect("id_#{uuid}").to eq("id_1")
    end

    it "resets the counter for each test" do
      expect(Metanorma::Utils.random_uuid).to eq("1")
    end
  end
end
