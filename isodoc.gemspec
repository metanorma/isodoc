# coding: utf-8

require_relative "lib/isodoc/version"

Gem::Specification.new do |spec|
  spec.name          = "isodoc"
  spec.version       = IsoDoc::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Convert documents in IsoDoc into Word and HTML " \
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
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bin|.github)/}) \
    || f.match(%r{Rakefile|bin/rspec})
  end
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.add_dependency "base64"
  spec.add_dependency "bigdecimal"
  spec.add_dependency "html2doc", "~> 1.10.0"
  # spec.add_dependency "isodoc-i18n", "~> 1.1.0" # already in relaton-render and mn-requirements
  # spec.add_dependency "relaton-cli"
  # spec.add_dependency "metanorma-utils", "~> 1.5.0" # already in isodoc-i18n
  spec.add_dependency "mn2pdf", ">= 2.13"
  spec.add_dependency "mn-requirements", "~> 0.5.0"
  spec.add_dependency "relaton-render", "~> 1.0.0"
  spec.add_dependency "roman-numerals"
  spec.add_dependency "rouge", "~> 4.0"
  spec.add_dependency "thread_safe"
  spec.add_dependency "twitter_cldr", ">= 6.6.0"
  spec.add_dependency "uuidtools"
  # spec.metadata["rubygems_mfa_required"] = "true"
end
