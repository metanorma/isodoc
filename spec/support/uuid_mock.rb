# This file contains a helper method to mock identifier generation
# to return an incrementing number (1, 2, 3, 4, etc.) each time it's
# called within a test.

module UuidMock
  # Pin the Presentation XML id mint seam to an incrementing counter,
  # so golden fixtures record stable `_1`, `_2`, ... ids. In production
  # the mints are content-derived: PresentationXMLConvert#minted_id
  # hashes its seed through IsoDoc::PresentationXMLConvert#contenthash_str
  # (string seeds) or Metanorma::Utils.contenthash (element seeds). The
  # mock replaces both hash sources with one shared counter, so each
  # mint still receives exactly one mock id per call, in conversion
  # order. The contenthash cleanup pass is held at identity, so the mock
  # ids survive into the compared output.
  def mock_uuid_increment
    counter = 0
    mint = ->(*) do
      counter += 1
      "_#{counter}"
    end

    allow(IsoDoc::PresentationXMLConvert).to receive(:new).and_wrap_original do |m, *args|
      instance = m.call(*args)
      allow(instance).to receive(:contenthash_str, &mint)
      allow(Metanorma::Utils).to receive(:contenthash, &mint)
      instance
    end

    # Mock content hashing in the cleanup pass, preserving these GUIDs
    # instead
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
