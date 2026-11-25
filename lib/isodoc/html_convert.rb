require_relative "html_function/html"
require_relative "html_function/postprocess"
require_relative "html_function/form"

module IsoDoc
  class HtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Form
    include HtmlFunction::Html

    # The image directory name is part of the published HTML output (img
    # src attributes reference it), so it is derived from the document
    # filename alone: compiling the same document twice must produce the
    # same HTML. https://github.com/metanorma/isodoc/issues/861
    def tmpimagedir_suffix
      "_htmlimages"
    end

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

    def convert(filename, file = nil, debug = false, output_filename = nil)
      ret = super
      Dir.exist?(tmpimagedir) and Dir["#{tmpimagedir}/*"].empty? and
        FileUtils.rm_r tmpimagedir
      ret
    end
  end
end
