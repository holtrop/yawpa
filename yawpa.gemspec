# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yawpa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josh Holtrop"]
  gem.email         = ["jholtrop@gmail.com"]
  gem.description   = %q{Yet Another Way to Parse Arguments is an argument-parsing library for Ruby}
  gem.summary       = %q{Yet Another Way to Parse Arguments}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yawpa"
  gem.require_paths = ["lib"]
  gem.version       = Yawpa::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
end
