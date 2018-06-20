require_relative "./function/blocks"
require_relative "./function/cleanup"
require_relative "./function/i18n"
require_relative "./function/inline"
require_relative "./function/lists"
require_relative "./function/references"
require_relative "./function/section"
require_relative "./function/table"
require_relative "./function/terms"
require_relative "./function/to_word_html"
require_relative "./function/utils"
require_relative "./function/xref_gen"
require_relative "./function/xref_sect_gen"
require_relative "./class_utils"

module IsoDoc
  class Common
    include Function::Blocks
    include Function::Cleanup
    include Function::I18n
    include Function::Inline
    include Function::Lists
    include Function::References
    include Function::Section
    include Function::Table
    include Function::Terms
    include Function::ToWordHtml
    include Function::Utils
    include Function::XrefGen
    include Function::XrefSectGen

    extend ::IsoDoc::ClassUtils
  end
end
