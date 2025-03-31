require_relative "function/blocks"
require_relative "function/cleanup"
require_relative "function/form"
require_relative "function/inline"
require_relative "function/footnotes"
require_relative "function/lists"
require_relative "function/references"
require_relative "function/section"
require_relative "function/table"
require_relative "function/terms"
require_relative "function/to_word_html"
require_relative "function/utils"
require_relative "function/reqt"
require_relative "class_utils"

module IsoDoc
  class Common
    include Function::Blocks
    include Function::Cleanup
    include Function::Form
    include Function::Inline
    include Function::Footnotes
    include Function::Lists
    include Function::References
    include Function::Section
    include Function::Table
    include Function::Terms
    include Function::ToWordHtml
    include Function::Utils

    extend ::IsoDoc::ClassUtils
  end
end
