Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

eval_gemfile("Gemfile.devel") rescue nil

gem "bigdecimal"
gem "canon", github: "lutaml/canon"
gem "debug"
gem "guard"
gem "guard-rspec"
gem "openssl", "~> 3.0"
gem "rake"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "sassc-embedded"
gem "simplecov"
gem "timecop"
