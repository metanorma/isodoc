require "digest"
require "fileutils"

module IsoDoc
  # Content-addressed asset store shared by every converter of a compile.
  #
  # Each image enters the store exactly once, keyed by the SHA-256 of its
  # bytes ("<sha256>.<ext>"): identical images within a document, and the
  # same image consumed by different converters of one compile, resolve to
  # a single stored file. The store lives under the compile's work root,
  # whose lifecycle belongs to the compile driver (Metanorma::Compile);
  # converters only ingest into it and materialize from it.
  #
  # Content addressing also makes random filenames in published output
  # unrepresentable: emitted image names are the store's content addresses.
  class AssetStore
    attr_reader :dir

    def initialize(dir)
      @dir = dir
      FileUtils.mkdir_p @dir
    end

    # Copy the image at +source_path+ into the store under its content
    # address, and return the store-relative filename. Already-stored
    # content is not rewritten, so unchanged images are reused as-is
    # (the cache unit for change-proportional rebuilds).
    def add(source_path, ext)
      name = filename(source_path, ext)
      File.exist?(path(name)) or FileUtils.cp(source_path, path(name))
      name
    end

    def path(name)
      File.join(@dir, name)
    end

    def filename(source_path, ext)
      "#{hash(source_path)}.#{ext}"
    end

    def hash(source_path)
      Digest::SHA256.file(source_path).hexdigest
    end
  end
end
