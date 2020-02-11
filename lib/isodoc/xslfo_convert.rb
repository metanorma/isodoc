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

    def convert(filename, file = nil, debug = false)
      docxml, outname_html, dir = convert_init(file, filename, debug)
      FileUtils.rm_rf dir
      ::Metanorma::Output::XslfoPdf.new.convert("#{filename}.xml", outname_html + ".pdf", nil)
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".pdf#") :
        "##{node["target"]}"
      out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
