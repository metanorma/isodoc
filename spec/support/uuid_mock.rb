# This file contains a helper method to mock identifier generation
# to return an incrementing number (1, 2, 3, 4, etc.) each time it's called
# to return an incrementing number (1, 2, 3, 4, etc.) each time it's
# called within a test.

module UuidMock
  # Mock the identifier generators to return an incrementing counter
  def mock_uuid_increment
    counter = 0

    allow(Metanorma::Utils).to receive(:random_uuid) do
      counter += 1
      counter.to_s
    end


    # Mock content hashing, preserving these GUIDs instead
    allow_any_instance_of(IsoDoc::PresentationXMLConvert)
      .to receive(:add_new_contenthash_id) do |_instance, doc, *args|
      ret = doc.xpath("//*[@id]").each_with_object({}) do |x, m|
        # should always be true
        m[x["id"]] = x["id"]
        args[0][x["id"]] = x["id"]
      end
      warn ret
      ret
    end
  end
end

RSpec.configure do |config|
  config.include UuidMock
end
