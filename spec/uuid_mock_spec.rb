require_relative "spec_helper"

RSpec.describe "UUIDTools::UUID.random_create mock" do
  describe "mock_uuid_increment" do
    before do
      # Set up the mock before each test
      mock_uuid_increment
    end

    it "returns incrementing numbers for each call to UUIDTools::UUID.random_create" do
      # First call should return 1
      uuid1 = UUIDTools::UUID.random_create
      expect(uuid1.to_s).to eq("1")

      # Second call should return 2
      uuid2 = UUIDTools::UUID.random_create
      expect(uuid2.to_s).to eq("2")

      # Third call should return 3
      uuid3 = UUIDTools::UUID.random_create
      expect(uuid3.to_s).to eq("3")
    end

    it "works with string interpolation" do
      uuid = UUIDTools::UUID.random_create
      expect("id_#{uuid}").to eq("id_1")
    end

    it "resets the counter for each test" do
      # This is a new test, so counter should start at 1 again
      uuid = UUIDTools::UUID.random_create
      expect(uuid.to_s).to eq("1")
    end
  end
end
