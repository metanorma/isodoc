require_relative "html_function/html"
require_relative "html_function/postprocess"
require_relative "html_function/form"

module IsoDoc
  class HtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Form
    include HtmlFunction::Html

    def initialize(options)
      @format = :html
      @suffix = "html"
      super
    end

    # Apply empty_tags even when postprocess is skipped (debug mode),
    # so convert1's output is valid HTML5 (non-void self-closing tags
    # expanded: <a id="_"/> -> <a id="_"></a>). Idempotent: running
    # again in postprocess#toHTML is a no-op.
    def convert1(docxml, filename, dir)
      empty_tags(super)
    end

    # The HTML artifact is published beside the output file and outlives
    # the compile's work root, so its emitted image references target a
    # published asset directory keyed by the document name: multi-document
    # output directories keep documents' asset sets apart, and the alt
    # output leg gets its own set. The names within are the asset store's
    # content addresses: compiling the same document twice emits the same
    # paths.
    def rel_asset_path
      "#{File.basename(@filename)}#{'_alt' if @options[:alt]}_htmlimages"
    end

    # Wipe-on-first-materialize keeps the published asset set exactly this
    # compile's: a recompile into an existing output directory cannot
    # leave stale images behind.
    def materialize_asset(name, artifact_dir)
      dir = File.join(artifact_dir, rel_asset_path)
      @asset_dir_prepped ||= begin
        FileUtils.rm_rf(dir)
        FileUtils.mkdir_p(dir)
        true
      end
      dest = File.join(dir, name)
      File.exist?(dest) or FileUtils.cp asset_store.path(name), dest
    end
  end
end
