Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gem "benchmark"
gem "canon"
gem "debug"
gem "equivalent-xml", "~> 0.6"
gem "guard", "~> 2.14"
gem "guard-rspec", "~> 4.7"
gem "rake"
gem "rspec", "~> 3.6"
gem "rubocop", "~> 1"
gem "rubocop-performance"
gem "sassc-embedded", "~> 1"
gem "simplecov", "~> 0.15"
gem "timecop", "~> 0.9"

eval_gemfile("Gemfile.devel") rescue nil

gemspec

