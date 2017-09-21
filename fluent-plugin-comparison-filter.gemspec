# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/filter_comparison/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-comparison-filter"
  spec.version       = Fluent::Plugin::FilterComparison::VERSION
  spec.authors       = ["reizist"]
  spec.email         = ["reizist@gmail.com"]

  spec.summary       = %q{A fluent filter plugin to filter by comparing records.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/reizist/fluent-plugin-comparison-filter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", [">= 0.14", "< 2"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0.0"
  spec.add_development_dependency "test-unit", "~> 3.2.5"
  spec.add_development_dependency "pry"
end
