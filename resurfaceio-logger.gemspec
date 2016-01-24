# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resurfaceio/logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'resurfaceio-logger'
  spec.version       = Resurfaceio::Logger::VERSION

  spec.summary       = 'Ruby library for logging to resurface.io'
  spec.homepage      = 'https://github.com/resurfaceio/resurfaceio-logger-ruby'
  spec.license       = 'Apache-2.0'
  spec.authors       = ['Rob Dickinson']
  spec.email         = ['resurfacelabs@gmail.com']

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
