require "fileutils"
require "pathname"

module IsoDoc
  module Function
    module ToWordHtml
      def note?
        @note
      end

      def init_file(filename, debug)
        filepath = Pathname.new(filename)
        filename = filepath.sub_ext("").sub(/\.presentation$/, "").to_s
        dir = init_dir(filename, debug)
        @filename = filename
        @output_dir = File.dirname(filename)
        @localdir = "#{@baseassetpath || filepath.parent.to_s}/"
        @sourcedir = @localdir
        @sourcefilename and
          @sourcedir = "#{Pathname.new(@sourcefilename).parent}/"
        [filename, dir]
      end

      def init_dir(filename, debug)
        dir = "#{filename}#{@tmpfilesdir_suffix}"
        unless debug
          FileUtils.mkdir_p(dir)
          FileUtils.chmod 0o777, dir
          FileUtils.rm_rf "#{dir}/*"
        end
        dir
      end

      # tmp image dir is same directory as @filename
      def tmpimagedir
        @filename + @tmpimagedir_suffix
      end

      def rel_tmpimagedir
        Pathname.new(@filename).basename.to_s + @tmpimagedir_suffix
      end

      def info(isoxml, out)
        @meta.localdir = @localdir
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
        @meta.presentation isoxml, out
        @meta.get
      end
    end
  end
end
