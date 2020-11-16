require_relative "word_function/comments.rb"
require_relative "word_function/footnotes.rb"
require_relative "word_function/body.rb"
require_relative "word_function/postprocess.rb"

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
