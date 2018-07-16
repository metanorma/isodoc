require_relative "html_function/comments.rb"
require_relative "html_function/footnotes.rb"
require_relative "html_function/html.rb"

module IsoDoc
  class HeadlessHtmlConvert < ::IsoDoc::Convert

    include HtmlFunction::Comments
    include HtmlFunction::Footnotes
    include HtmlFunction::Html

    def initialize(options)
      super
      @tmpimagedir = "_headlessimages"
    end

    def convert(filename, file = nil, debug = false)
      file = File.read(filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, outname_html, dir = convert_init(file, filename, debug)
      result = convert1(docxml, outname_html, dir)
      return result if debug
      postprocess(result, filename + ".tmp", dir)
      system "rm -fr #{dir}"
      strip_head(filename + ".tmp.html", outname_html + ".headless.html")
      system "rm -r #{filename + '.tmp.html'} #{@tmpimagedir}"
    end

    def strip_head(input, output)
      file = File.read(input, encoding: "utf-8")
      doc = Nokogiri::XML(file)
      doc.xpath("//head").each { |x| x.remove }
      doc.xpath("//html").each { |x| x.name = "div" }
      body = doc.at("//body")
      body.replace(body.children)
      File.open(output, "w") { |f| f.write(doc.to_xml) }
    end
  end
end
