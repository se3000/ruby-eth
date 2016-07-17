# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ethereum-tx'

Gem::Specification.new do |spec|
  spec.name          = "ethereum-tx"
  spec.version       = Ethereum::Tx::VERSION
  spec.authors       = ["Steve Ellis"]
  spec.email         = ["email@steveell.is"]

  spec.summary       = %q{Deprecated: see 'eth' gem instead}
  spec.description   = %q{Deprecated: see https://github.com/se3000/ruby-eth instead}
  spec.homepage      = "https://github.com/se3000/ruby-eth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "digest-sha3", "~> 1.1"
  spec.add_dependency "ethereum-base", "0.1.2"
  spec.add_dependency "ffi", "~> 1.0"
  spec.add_dependency "money-tree", "~> 0.9"
  spec.add_dependency "rlp", "~> 0.7"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "pry", "~> 0.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
