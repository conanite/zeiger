# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zeiger/version'

Gem::Specification.new do |spec|
  spec.name          = "zeiger"
  spec.version       = Zeiger::VERSION
  spec.authors       = ["conanite"]
  spec.email         = ["conan@conandalton.net"]
  spec.summary       = %q{Provide text index of files in current directory tree and a unix socket to query on}
  spec.description   = %q{Maintain an in-memory text index of files in current directory tree, allow querying via unix socket in current directory }
  spec.homepage      = "https://github.com/conanite/zeiger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
end
