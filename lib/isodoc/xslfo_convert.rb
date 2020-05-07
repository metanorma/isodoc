require "metanorma"

module IsoDoc
  class XslfoPdfConvert < ::IsoDoc::Convert

    def initialize(options)
      super
      @maxwidth = 500
      @maxheight = 800
    end

    def tmpimagedir_suffix
      "_pdfimages"
    end

    def initialize(options)
      @format = :pdf
      super
    end

    def convert(filename, file = nil, debug = false)
      file = File.read(filename, encoding: "utf-8") if file.nil?
      docxml, outname_html, dir = convert_init(file, filename, debug)
      FileUtils.rm_rf dir
      ::Metanorma::Output::XslfoPdf.new.convert(filename, outname_html + ".pdf", nil)
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".pdf#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
