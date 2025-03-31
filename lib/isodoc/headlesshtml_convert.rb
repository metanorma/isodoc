require_relative "html_function/html"
require "fileutils"

module IsoDoc
  class HeadlessHtmlConvert < ::IsoDoc::Convert
    include HtmlFunction::Html

    def tmpimagedir_suffix
      "_#{SecureRandom.hex(8)}_headlessimages"
    end

    def initialize(options)
      @format = :html
      @suffix = "headless.html"
      super
    end

    def convert(input_filename, file = nil, debug = false, output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug

      postprocess(result, "#{filename}.tmp.html", dir)
      FileUtils.rm_rf dir
      strip_head("#{filename}.tmp.html",
                 output_filename || "#{filename}.#{@suffix}")
      FileUtils.rm_rf ["#{filename}.tmp.html", tmpimagedir]
    end

    def strip_head(input, output)
      file = File.read(input, encoding: "utf-8")
      doc = Nokogiri::XML(file)
      doc.xpath("//head").each(&:remove)
      doc.xpath("//html").each { |x| x.name = "div" }
      body = doc.at("//body")
      body.replace(body.children)
      File.open(output, "w") { |f| f.write(doc.to_xml) }
    end
  end
end
