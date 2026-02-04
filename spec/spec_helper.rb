require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "isodoc"
require "rspec/matchers"
require "tzinfo"
require "canon"
require_relative "support/uuid_mock"

Canon::Config.instance.tap do |cfg|
  # Configure Canon to use spec-friendly match profiles
  cfg.xml.match.profile = :spec_friendly
  cfg.html.match.profile = :spec_friendly

  # Configure Canon to show all diffs (including inactive diffs)
  cfg.html.diff.show_diffs = :all
  cfg.xml.diff.show_diffs = :all

  # Enable verbose diff output for debugging
  cfg.html.diff.verbose_diff = true
  cfg.xml.diff.verbose_diff = true

  # Use semantic tree diff algorithm for matching decisions
  # Can be overridden with Canon's ENV variables:
  #   CANON_ALGORITHM=dom bundle exec rspec        (applies to all formats)
  #   CANON_HTML_DIFF_ALGORITHM=dom bundle exec rspec  (HTML only)
  #   CANON_XML_DIFF_ALGORITHM=dom bundle exec rspec   (XML only)
  cfg.html.diff.algorithm = :dom
  cfg.xml.diff.algorithm = :dom
end

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
  uuid_pattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"

  # Attributes with underscore prefix
  %w[id target from to source container original-id original-reference
     name].each do |attr|
    xml = xml.gsub(%r{ #{attr}="_#{uuid_pattern}"}, " #{attr}=\"_\"")
  end

  xml = xml.gsub(%r( href="#_?#{uuid_pattern}"), ' href="#_"')
    .gsub(%r( href="#fn:_?#{uuid_pattern}"), ' href="#fn:_"')
    .gsub(%r(id="(_)?#{uuid_pattern}"), 'id="\1"')
    .gsub(%r( id="(ftn_?)?#{uuid_pattern}"), ' id="\1"')
    .gsub(%r( id="fn:(_)?#{uuid_pattern}"), ' id="fn:\1"')
    .gsub(%r( reference="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' reference="_"')
    .gsub(%r[ src="([^/]+)/#{uuid_pattern}\.], ' src="\1/_.')
    .gsub(%r[ semx-id="[^"]+"], "")
    .gsub(%r[ _Ref\d{8,10}], " _Ref")
    .gsub(%r[:_Ref\d{8,10}], ":_Ref")

  escape_zs_chars(xml)
end

def strip_html_comments(html)
  html.gsub(/<!--.*?-->/m, "<!-- -->")
end

HTML_HDR = <<~HEADER.freeze
  <html lang="en">
    <head/>
    <body lang="en">
      <div class="title-section">
        <p>\u00a0</p>
      </div>
      <br/>
      <div class="prefatory-section">
        <p>\u00a0</p>
      </div>
      <br/>
      <div class="main-section">
         <br/>
            <div class="TOC" id="_">
        <h1 class="IntroTitle">Table of contents</h1>
      </div>
HEADER

WORD_HDR = <<~HEADER.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" lang="en">
   <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <style>
    <!--
    -->
    </style>
  </head>
  <body lang="EN-US" link="blue" vlink="#954F72">
    <div class="WordSection1">
      <p>\u00a0</p>
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
  str
  # # Match all characters in \p{Zs} except space (U+0020)
  # str.gsub(/[\p{Zs}&&[^\u0020]]/) do |char|
  #   "\u#{char.ord.to_s(16).rjust(4, '0')}"
  # end
end
