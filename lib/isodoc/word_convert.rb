require_relative "word_function/comments"
require_relative "word_function/footnotes"
require_relative "word_function/body"
require_relative "word_function/postprocess"

module IsoDoc
  class WordConvert < ::IsoDoc::Convert
    include WordFunction::Comments
    include WordFunction::Footnotes
    include WordFunction::Body
    include WordFunction::Postprocess

    def initialize(options)
      @format = :doc
      @suffix = "doc"
      super
    end

    def convert(filename, file = nil, debug = false, output_filename = nil)
      ret = super
      FileUtils.rm_rf tmpimagedir
      ret
    end
  end
end
