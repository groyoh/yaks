# encoding: utf-8

require 'English'
require File.expand_path('../../yaks/lib/yaks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'yaks-transit'
  gem.version     = Yaks::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'Transit output format for Yaks'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/yaks'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = %w[README.md]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'yaks', Yaks::VERSION
  gem.add_runtime_dependency 'transit-ruby', '~> 0.8'
end
