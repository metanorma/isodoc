require_relative "presentation_function/block"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def initialize(options)
      @format = :presentation
      @suffix = "presentation.xml"
      super
    end

    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      info docxml, nil
      figure docxml
      sourcecode docxml
      formula docxml
      example docxml
      docxml.to_xml
    end

    def postprocess(result, filename, dir)
      #result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
      toXML(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def toXML(result, filename)
      #result = (from_xhtml(html_cleanup(to_xhtml(result))))
      #result = from_xhtml(move_images(to_xhtml(result)))
      #result = html5(script_cdata(inject_script(result)))
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
    end
  end
end
