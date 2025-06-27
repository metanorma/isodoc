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

def metadata(hash)
  hash.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def strip_guid(xml)
  xml = xml.gsub(%r{ id="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' id="_"')
    .gsub(%r{ target="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' target="_"')
    .gsub(%r{ from="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' from="_"')
    .gsub(%r{ to="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' to="_"')
    .gsub(%r{ source="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' source="_"')
    .gsub(%r{ container="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' container="_"')
    .gsub(%r{ original-id="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' original-id="_"')
    .gsub(%r{ original-reference="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"}, ' original-reference="_"')
    .gsub(%r( href="#_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#_"')
    .gsub(%r( href="#fn:_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#fn:_"')
    .gsub(%r( id="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' id="_"')
    .gsub(%r( id="ftn_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{13}"), ' id="ftn_"')
    .gsub(%r( id="fn:_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' id="fn:_"')
    .gsub(%r( name="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' name="_"')
    .gsub(%r( reference="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' reference="_"')
    .gsub(%r[ src="([^/]+)/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.], ' src="\\1/_.')
    .gsub(%r[ semx-id="([^"]+)"], "")
    .gsub(%r[ _Ref\d+{8,10}], " _Ref")
    .gsub(%r[:_Ref\d+{8,10}], ":_Ref")
  escape_zs_chars(xml)
end

HTML_HDR = <<~HEADER.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
    <head/>
    <body lang="en">
      <div class="title-section">
        <p>\\u00a0</p>
      </div>
      <br/>
      <div class="prefatory-section">
        <p>\\u00a0</p>
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
             <p>\\u00a0</p>
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

# Converts all characters in a string matching Unicode regex character class \p{Zs},
# except for space (U+0020), to their HTMLEntities escaped counterparts.
# Note: Tab (U+0009) is not in \p{Zs}, it's in \p{Cc} (control characters)
def escape_zs_chars(str)
  # Match all characters in \p{Zs} except space (U+0020)
  str.gsub(/[\p{Zs}&&[^\u0020]]/) do |char|
    "\\u#{char.ord.to_s(16).rjust(4, '0')}"
  end
end
