require_relative "html_function/comments.rb"
require_relative "html_function/footnotes.rb"
require_relative "html_function/html.rb"

module IsoDoc
  class PdfConvert < ::IsoDoc::Convert

    include HtmlFunction::Comments
    include HtmlFunction::Footnotes
    include HtmlFunction::Html

    def convert(filename, file = nil, debug = false)
      outname_html = filename + ".html"
      IsoDoc::Rsd::HtmlConvert.new(options).convert(outname_html, file, debug)
      Metanorma::Output::Pdf.new.convert(outname_html, filename)
      @files_to_delete << outname_html
    end

    def move_image1(i, new_full_filename)
      system "cp #{i['src']} #{new_full_filename}"
      i["src"] = new_full_filename
      i["width"], i["height"] = Html2Doc.image_resize(i, 800, 500)
    end

    def postprocess(result, filename, dir)
      result = from_xhtml(cleanup(to_xhtml(result)))
      toHTML(result, filename)
      @files_to_delete.each { |f| system "rm #{f}" }
    end
  end
end
