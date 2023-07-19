# coding: utf-8
# © 2016-2023 Graylog, Inc.

Gem::Specification.new do |spec|
  spec.name = 'resurfaceio-logger'
  spec.version = '2.1.1'

  spec.summary = 'Library for usage logging'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/resurfaceio/logger-ruby'
  spec.license = 'Apache-2.0'
  spec.authors = ['RobDickinson']

  spec.files = `git ls-files -z ./lib`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.6'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rack', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0.3'
  spec.add_development_dependency 'rspec', '~> 3.10'
end
