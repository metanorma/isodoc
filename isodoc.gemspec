# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "isodoc/version"

Gem::Specification.new do |spec|
  spec.name          = "isodoc"
  spec.version       = IsoDoc::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Convert documents in IsoDoc into Word and HTML "\
    "in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    isodoc converts documents in the IsoDoc document model into
    Microsoft Word and HTML.

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/isodoc"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "asciimath"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "nokogiri", "~> 1.10.4"
  spec.add_dependency "thread_safe"
  spec.add_dependency "uuidtools"
  spec.add_dependency "html2doc", "~> 1.0.0"
  spec.add_dependency "liquid", "~> 4"
  spec.add_dependency "twitter_cldr", ">= 6.6.0"
  spec.add_dependency "roman-numerals"
  spec.add_dependency "metanorma", "~> 1.2.0"
  spec.add_dependency "relaton-cli"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "sassc", "~> 2.4.0"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 1.5.2"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "rexml"
end
