require_relative "html_function/comments.rb"
require_relative "html_function/footnotes.rb"
require_relative "html_function/html.rb"

module IsoDoc
  class HtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Comments
    include HtmlFunction::Footnotes
    include HtmlFunction::Html

    @tmpimagedir = "_images"
  end
end
