# coding: utf-8
# © 2016-2017 Resurface Labs LLC

Gem::Specification.new do |spec|
  spec.name = 'resurfaceio-logger'
  spec.version = '1.7.12'

  spec.summary = 'Library for usage logging'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/resurfaceio/logger-ruby'
  spec.license = 'Apache-2.0'
  spec.authors = ['RobDickinson']

  spec.files = `git ls-files -z ./lib`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rack', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
