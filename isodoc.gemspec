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

  spec.homepage      = "https://github.com/riboseinc/isodoc"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "asciimath"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "nokogiri"
  spec.add_dependency "ruby-xslt"
  spec.add_dependency "thread_safe"
  spec.add_dependency "uuidtools"
  spec.add_dependency "html2doc", "~> 0.8.1"
  spec.add_dependency "liquid"
  spec.add_dependency "roman-numerals"
  spec.add_dependency "sassc", "~> 1.12.1"
  spec.add_dependency "metanorma", "~> 0.2.7"
  spec.add_dependency "rake", "~> 12.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
end
