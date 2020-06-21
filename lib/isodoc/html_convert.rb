require_relative "html_function/comments.rb"
require_relative "html_function/footnotes.rb"
require_relative "html_function/html.rb"
require_relative "html_function/postprocess.rb"

module IsoDoc
  class HtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Comments
    include HtmlFunction::Footnotes
    include HtmlFunction::Html

    def tmpimagedir_suffix
      "_htmlimages"
    end

    def initialize(options)
      @format = :html
      @suffix = "html"
      super
    end

    def convert(filename, file = nil, debug = false, output_filename = nil)
      ret = super
      Dir.exists?(tmpimagedir) and Dir["#{tmpimagedir}/*"].empty? and
        FileUtils.rm_r tmpimagedir
      ret
    end
  end
end
