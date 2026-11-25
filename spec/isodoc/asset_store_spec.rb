require "spec_helper"
require "tmpdir"

RSpec.describe IsoDoc::AssetStore do
  subject(:store) { described_class.new(root) }

  let(:root) do
    File.join(Dir.mktmpdir("isodoc-assets"), "assets")
  end

  after { FileUtils.rm_rf(File.dirname(root)) }

  let(:image) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "assets",
                               "rice_image1.png"))
  end

  it "creates its directory" do
    store
    expect(Dir.exist?(root)).to be(true)
  end

  it "keys stored assets by the SHA-256 of their bytes" do
    name = store.add(image, "png")
    expect(name).to eq("#{Digest::SHA256.file(image).hexdigest}.png")
    expect(File.exist?(store.path(name))).to be(true)
    expect(File.binread(store.path(name))).to eq(File.binread(image))
  end

  it "stores identical content once" do
    name1 = store.add(image, "png")
    mtime = File.mtime(store.path(name1))
    name2 = store.add(image, "png")
    expect(name2).to eq(name1)
    # the stored file is not rewritten on a repeat store
    expect(File.mtime(store.path(name1))).to eq(mtime)
  end

  it "keeps distinct content distinct" do
    other = Tempfile.open(%w[image .png]) do |f|
      f.binmode
      f.write(File.binread(image) + "x")
      f.path
    end
    name1 = store.add(image, "png")
    name2 = store.add(other, "png")
    expect(name1).not_to eq(name2)
    expect(store.hash(image)).not_to eq(store.hash(other))
  end
end
