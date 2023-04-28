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
      bibitem_lookup(docxml)
      info docxml, nil
      conversions(docxml)
      docxml.root["type"] = "presentation"
      docxml.to_xml.gsub(/&lt;/, "&#x3c;").gsub(/&gt;/, "&#x3e;")
    end

    def bibitem_lookup(docxml)
      @bibitems = docxml.xpath(ns("//references/bibitem"))
        .each_with_object({}) do |b, m|
        m[b["id"]] = b
      end
    end

    def conversions(docxml)
      semantic_xml_insert(docxml)
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
      rearrange_clauses docxml # feeds toc, display_order, clausetitle, clause
      annex docxml
      clause docxml # feeds clausetitle
      term docxml
      index docxml
      clausetitle docxml # feeds floattitle
      floattitle docxml # feeds rearrange_clauses
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
      source docxml
      ol docxml
      permission docxml
      requirement docxml
      recommendation docxml
      requirement_render docxml
    end

    def inline(docxml)
      xref docxml
      eref docxml # feeds docxml
      origin docxml # feeds docxml
      quotesource docxml # feeds docxml
      eref2link docxml
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

    def semantic_xml_insert(xml)
      @semantic_xml_insert or return
      embed = embedable_semantic_xml(xml)
      ins = metanorma_extension_insert_pt(xml)
      ins = ins.at(ns("./metanorma")) || ins.add_child("<metanorma/>").first
      ins = ins.add_child("<source/>").first
      ins << embed
    end

    def metanorma_extension_insert_pt(xml)
      xml.at(ns("//metanorma-extension")) ||
        xml.at(ns("//bibdata"))&.after("<metanorma-extension/>")
        &.next_element ||
        xml.root.elements.first.before("<metanorma-extension/>")
          .previous_element
    end

    def embedable_semantic_xml(xml)
      xml = embedable_semantic_xml_tags(xml)
      embedable_semantic_xml_attributes(xml)
    end

    def embedable_semantic_xml_tags(xml)
      ret = to_xml(xml)
        .sub(/ xmlns=['"][^"']+['"]/, "") # root XMLNS
        .split(/(?=[<> \t\r\n\f\v])/).map do |x|
          case x
          when /^<[^:]+:/ then x.sub(/:/, ":semantic__")
          when /^<[^:]+$/ then x.sub(%r{(</?)([[:alpha:]])},
                                     "\\1semantic__\\2")
          else x end
        end
      Nokogiri::XML(ret.join).root
    end

    def embedable_semantic_xml_attributes(xml)
      Metanorma::Utils::anchor_attributes.each do |(tag_name, attr_name)|
        tag_name == "*" or tag_name = "semantic__#{tag_name}"
        xml.xpath("//#{tag_name}[@#{attr_name}]").each do |elem|
          elem.attributes[attr_name].value =
            "semantic__#{elem.attributes[attr_name].value}"
        end
      end
      xml
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
