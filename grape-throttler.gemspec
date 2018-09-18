# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape-throttler/version'

Gem::Specification.new do |spec|
  spec.name = 'grape-throttler'
  spec.version = GrapeThrottler::VERSION
  spec.authors = ['Juan Gomez']
  spec.email = ['j.gomez@drexed.com']

  spec.summary = 'Gem for throttling grape requests.'
  spec.description = 'A middleware for Grape to add endpoint-specific throttling.'
  spec.homepage = 'http://drexed.github.io/grape-throttler'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_runtime_dependency 'grape', '>= 0.16.0'
  spec.add_runtime_dependency 'rails'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fakeredis'
  spec.add_development_dependency 'fasterer'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
