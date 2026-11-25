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

    # Images are embedded into the output by Html2Doc, not moved through
    # the asset store; the base convert's teardown removes the work root
    # when this converter derived it itself, and the compile driver owns
    # it otherwise.
  end
end
