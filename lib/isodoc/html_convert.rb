require_relative "html_function/html"
require_relative "html_function/postprocess"
require_relative "html_function/form"

module IsoDoc
  class HtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Form
    include HtmlFunction::Html

    def tmpimagedir_suffix
      "_#{SecureRandom.hex(8)}_htmlimages"
    end

    def initialize(options)
      @format = :html
      @suffix = "html"
      super
    end

    def convert(filename, file = nil, debug = false, output_filename = nil)
      ret = super
      Dir.exist?(tmpimagedir) and Dir["#{tmpimagedir}/*"].empty? and
        FileUtils.rm_r tmpimagedir
      ret
    end
  end
end
