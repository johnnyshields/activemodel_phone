$:.push File.expand_path('../lib', __FILE__)
require 'active_model/phone/version'

Gem::Specification.new do |s|
  s.name        = 'activemodel_phone'
  s.version     = ActiveModel::Phone::VERSION
  s.authors     = ['Johnny Shields']
  s.homepage    = 'https://github.com/johnnyshields/activemodel_phone'
  s.license     = 'MIT'
  s.summary     = 'ActiveModel field wrapper for phone numbers'
  s.description = 'A lightweight, opinionated ActiveModel field wrapper for phone numbers, using the Phony gem.'
  s.email       = 'johnny.shields@gmail.com'
  s.date        = '2013-11-27'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.post_install_message = File.read('UPGRADING') if File.exists?('UPGRADING')

  s.add_runtime_dependency 'activemodel', '>= 3'
  s.add_runtime_dependency 'phony'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 2.13.0'
  s.add_development_dependency 'gem-release'
end
