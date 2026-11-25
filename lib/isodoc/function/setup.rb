require "digest"
require "fileutils"
require "pathname"

module IsoDoc
  module Function
    module ToWordHtml
      def note?
        @note
      end

      def init_file(filename, file, debug)
        filepath = Pathname.new(filename)
        filename = filepath.sub_ext("").sub(/\.presentation$/, "").to_s
        init_workdirs(file, debug)
        dir = init_dir(debug)
        @filename = filename
        @output_dir = File.dirname(filename)
        @localdir = "#{@baseassetpath || filepath.parent.to_s}/"
        @sourcedir = @localdir
        @sourcefilename and
          @sourcedir = "#{Pathname.new(@sourcefilename).parent}/"
        [filename, dir]
      end

      # The work root hosts the compile's shared asset store and this
      # converter's scratch directory. It is supplied by the compile
      # driver (Metanorma::Compile), which derives it from the source
      # content and owns its teardown; absent a driver, the root is
      # derived from the source content itself, never from entropy, so
      # identical compiles use identical roots.
      def init_workdirs(file, debug)
        @workdir ||= File.join(
          Dir.tmpdir, "isodoc-work",
          "doc-#{Digest::SHA256.hexdigest(file.to_s)}",
        )
        @asset_store = AssetStore.new(File.join(@workdir, "assets")) unless debug
      end

      # Per-converter scratch under the work root, keyed by the converter
      # class so parallel output legs never share scratch state.
      def init_dir(debug)
        dir = File.join(leg_workdir, "files")
        unless debug
          FileUtils.mkdir_p(dir)
          FileUtils.chmod 0o777, dir
          FileUtils.rm_rf "#{dir}/*"
        end
        dir
      end

      # This converter's leg directory under the work root: hosts its
      # scratch and its transient intermediate artifacts. Removed with the
      # work root, whose teardown belongs to the compile driver (or to
      # this converter, when it derived the root itself).
      def leg_workdir
        File.join(@workdir, converter_work_name)
      end

      def converter_work_name
        self.class.name.split("::").last
          .gsub(/(.)([A-Z])/) { "#{Regexp.last_match(1)}_#{Regexp.last_match(2)}" }
          .downcase
      end

      # The asset store of the compile. Images are ingested here exactly
      # once, under their content address; emitted output resolves them
      # through rel_asset_path.
      def asset_store
        @asset_store
      end

      def info(isoxml, out)
        @meta.localdir = @localdir
        @meta.presentation isoxml, out
        @meta.bibdata isoxml, out
        @meta.code_css isoxml, out
        @meta.title isoxml, out
        @meta.subtitle isoxml, out
        @meta.docstatus isoxml, out
        @meta.docid isoxml, out
        @meta.otherid isoxml, out
        @meta.docnumeric isoxml, out
        @meta.doctype isoxml, out
        @meta.author isoxml, out
        @meta.bibdate isoxml, out
        @meta.relations isoxml, out
        @meta.version isoxml, out
        @meta.url isoxml, out
        @meta.keywords isoxml, out
        @meta.note isoxml, out
        @meta.images isoxml, out
        @meta.get
      end
    end
  end
end
