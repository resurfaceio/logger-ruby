# coding: utf-8
# Copyright (c) 2016 Resurface Labs, All Rights Reserved

Gem::Specification.new do |spec|
  spec.name = 'resurfaceio-logger'
  spec.version = '1.0.0'

  spec.summary = 'Ruby library for logging to resurface.io'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/resurfaceio/resurfaceio-logger-ruby'
  spec.license = 'Apache-2.0'
  spec.authors = ['RobDickinson']
  spec.email = ['resurfacelabs@gmail.com']

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin|idea)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
