# frozen_string_literal: true
# coding: utf-8

lib = File.expand_path("lib", __dir__).freeze
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require "eth/version"

Gem::Specification.new do |spec|
  spec.name = "eth"
  spec.version = Eth::VERSION
  spec.authors = ["Steve Ellis", "Afri Schoedon"]
  spec.email = ["email@steveell.is", "ruby@q9f.cc"]

  spec.summary = %q{Simple API to sign Ethereum transactions.}
  spec.description = %q{Library to build, parse, and sign Ethereum transactions.}
  spec.homepage = "https://github.com/se3000/ruby-eth"
  spec.license = "MIT"

  spec.metadata = {
    "homepage_uri" => "https://github.com/se3000/ruby-eth",
    "source_code_uri" => "https://github.com/se3000/ruby-eth",
    "github_repo" => "https://github.com/se3000/ruby-eth",
    "bug_tracker_uri" => "https://github.com/se3000/ruby-eth/issues",
  }.freeze

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files = spec.files.grep %r{^(test|spec|features)/}

  spec.add_dependency "keccak", "~> 1.3"
  spec.add_dependency "ffi", "~> 1.15"
  spec.add_dependency "money-tree", "~> 0.11"
  spec.add_dependency "openssl", "~> 3.0"
  spec.add_dependency "rlp", "~> 0.7"
  spec.add_dependency "scrypt", "~> 3.0"

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.6", "< 4.0"

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
