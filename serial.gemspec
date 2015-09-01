# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serial/version'

Gem::Specification.new do |spec|
  spec.name          = "serial"
  spec.version       = Serial::VERSION
  spec.authors       = ["Jonas Nicklas", "Kim Burgestrand"]
  spec.email         = ["jonas@elabs.se", "kim@elabs.se"]

  spec.summary       = %q{Plain old Ruby for generating simple data structures from object graphs.}
  spec.homepage      = "https://github.com/elabs/serial"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
