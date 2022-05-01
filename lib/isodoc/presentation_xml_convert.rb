require_relative "presentation_function/block"
require_relative "presentation_function/terms"
require_relative "presentation_function/inline"
require_relative "presentation_function/math"
require_relative "presentation_function/section"
require_relative "presentation_function/bibdata"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def initialize(options)
      @format = :presentation
      @suffix = "presentation.xml"
      super
    end

    def convert1(docxml, _filename, _dir)
      @xrefs.parse docxml
      info docxml, nil
      conversions(docxml)
      docxml.root["type"] = "presentation"
      docxml.to_xml.gsub(/&lt;/, "&#x3c;").gsub(/&gt;/, "&#x3e;")
    end

    def conversions(docxml)
      bibdata docxml
      @xrefs.parse docxml
      section docxml
      block docxml
      terms docxml
      inline docxml
    end

    def section(docxml)
      clause docxml
      annex docxml
      term docxml
      references docxml
      index docxml
      clausetitle docxml
      floattitle docxml
      toc docxml
      display_order docxml
    end

    def block(docxml)
      amend docxml
      table docxml
      figure docxml
      sourcecode docxml
      formula docxml
      example docxml
      note docxml
      admonition docxml
      ol docxml
      permission docxml
      requirement docxml
      recommendation docxml
    end

    def inline(docxml)
      xref docxml
      eref docxml
      origin docxml
      quotesource docxml
      mathml docxml
      variant docxml
    end

    def terms(docxml)
      termexample docxml
      termnote docxml
      termdefinition docxml
      designation docxml
      termsource docxml
      concept docxml
      related docxml
    end

    def postprocess(result, filename, _dir)
      to_xml(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def to_xml(result, filename)
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
    end
  end
end
