require_relative "html_function/html"
require "fileutils"

module IsoDoc
  class HeadlessHtmlConvert < ::IsoDoc::Convert
    include HtmlFunction::Html

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

      tmp_html = File.join(leg_workdir, "#{File.basename(filename)}.tmp.html")
      postprocess(result, tmp_html, dir)
      strip_head(tmp_html, output_filename || "#{filename}.#{@suffix}")
    ensure
      teardown_workdir unless debug
    end

    # The headless fragment is assembled into larger outputs by the
    # consumers, which relocate or encode image targets themselves; the
    # emitted references stay document-keyed and content-addressed, and
    # no asset set is materialized beside the fragment.
    def materialize_asset(_name, _artifact_dir); end

    def rel_asset_path
      "#{File.basename(@filename)}_headlessimages"
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
