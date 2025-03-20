require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "isodoc"
require "rspec/matchers"
require "equivalent-xml"
require "tzinfo"
require "xml-c14n"
require_relative "support/uuid_mock"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def presxml_options
  { semanticxmlinsert: "false" }
end

def new_xrefs
  klass = IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")
  klass.i18n_init("en", "Latn", nil)
  IsoDoc::Xref
    .new("en", "Latn", klass, klass.i18n,
         { bibrender: klass.bibrenderer })
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <!--<xsl:strip-space elements="*"/>-->
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
end

def metadata(hash)
  hash.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{ container="_[^"]+"}, ' container="_"')
    .gsub(%r{ original-id="_[^"]+"}, ' original-id="_"')
    .gsub(%r{ original-reference="_[^"]+"}, ' original-reference="_"')
    .gsub(%r( href="#_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#_"')
    .gsub(%r( href="#fn:_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#fn:_"')
    .gsub(%r( id="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' id="_"')
    .gsub(%r( id="ftn_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{13}"), ' id="ftn_"')
    .gsub(%r( id="fn:_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' id="fn:_"')
    .gsub(%r( name="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' name="_"')
    .gsub(%r( reference="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' reference="_"')
    .gsub(%r[ src="([^/]+)/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.], ' src="\\1/_.')
    .gsub(%r[ _Ref\d+{8,10}], " _Ref")
    .gsub(%r[:_Ref\d+{8,10}], ":_Ref")
end

HTML_HDR = <<~HEADER.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
    <head/>
    <body lang="en">
      <div class="title-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="prefatory-section">
        <p>&#160;</p>
      </div>
      <br/>
      <div class="main-section">
         <br/>
            <div class="TOC" id="_">
        <h1 class="IntroTitle">Table of contents</h1>
      </div>
HEADER

WORD_HDR = <<~HEADER.freeze
       <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
           <head>
    <style>
      <!--
      -->
    </style>
  </head>
         <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p class="section-break"><br clear="all" class="section"/></p>
           <div class="WordSection2">
            <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div class="TOC" id="_">
            <p class="zzContents">Table of contents</p>
          </div>
HEADER

# It is profoundly embarrassing that this is necessary...
def timezone_identifier_local
  offset = Time.now.utc_offset
  timezones = TZInfo::Timezone.all
  timezones.each do |timezone|
    if timezone.utc_offset == offset
      return timezone.identifier
    end
  end
  nil # Return nil if no timezone found with the given offset
end
