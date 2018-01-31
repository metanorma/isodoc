require_relative "isodoc/version"

require "nokogiri"
require "asciimath"
require "xml/xslt"
require "uuidtools"
require "base64"
require "mime/types"
require "image_size"
require_relative "isodoc/iso2wordhtml"
require_relative "isodoc/postprocessing"
require_relative "isodoc/utils"
require_relative "isodoc/metadata"
require_relative "isodoc/section"
require_relative "isodoc/references"
require_relative "isodoc/terms"
require_relative "isodoc/blocks"
require_relative "isodoc/lists"
require_relative "isodoc/table"
require_relative "isodoc/inline"
require_relative "isodoc/xref_gen"
require "pp"

module IsoDoc
  class Convert
  #include ::IsoDoc::ISO2WordHTML
  #include ::IsoDoc::Postprocessing
  #include ::IsoDoc::Utils
  #include ::IsoDoc::Metadata
  #include ::IsoDoc::Section
  #include ::IsoDoc::References
  #include ::IsoDoc::Terms
  #include ::IsoDoc::Blocks
  #include ::IsoDoc::Lists
  #include ::IsoDoc::Table
  #include ::IsoDoc::Inline
  #include ::IsoDoc::XrefGen

    def self.convert(filename)
    docxml = Nokogiri::XML(File.read(filename))
    filename, dir = init_file(filename)
    docxml.root.default_namespace = ""
    result = noko do |xml|
      xml.html do |html|
        html_header(html, docxml, filename, dir)
        make_body(html, docxml)
      end
    end.join("\n")
    postprocess(result, filename, dir)
  end
end
end
