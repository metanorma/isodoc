require_relative "presentation_function/block"
require_relative "presentation_function/terms"
require_relative "presentation_function/xrefs"
require_relative "presentation_function/erefs"
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

    # parse annex after term, references,
    # to deal with single-term and single-ref annexes
    def section(docxml)
      references docxml
      # triggers xrefs reparse, so put references before all other sections,
      # which alter titles and thus can alter xrefs
      annex docxml
      clause docxml
      term docxml
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
      requirement_render docxml
    end

    def inline(docxml)
      xref docxml
      eref docxml
      origin docxml
      quotesource docxml
      mathml docxml
      variant docxml
      identifier docxml
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
      to_xml_file(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def to_xml_file(result, filename)
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
    end
  end
end
