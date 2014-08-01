# -*- encoding: utf-8 -*-

require File.expand_path('../lib/ramom/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "ramom"
  gem.version     = Ramom::VERSION.dup
  gem.authors     = [ "Martin Gamsjaeger (snusnu)" ]
  gem.email       = [ "gamsnjaga@gmail.com" ]
  gem.description = "Relational Algebra meets Object Mapping"
  gem.summary     = "Design database interactions with relations as first class citzizens"
  gem.homepage    = "https://github.com/snusnu/ramom"

  gem.require_paths    = [ "lib" ]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.md TODO.md]
  gem.license          = 'MIT'

  gem.add_dependency 'concord',          '~> 0.1', '>= 0.1.5'
  gem.add_dependency 'anima',            '~> 0.2', '>= 0.2.0'
  gem.add_dependency 'lupo',             '~> 0.0', '>= 0.0.1'
  gem.add_dependency 'procto',           '~> 0.0', '>= 0.0.2'
  gem.add_dependency 'orc',              '~> 0.0', '>= 0.0.1'
  gem.add_dependency 'morpher',          '~> 0.2', '>= 0.2.3'
  gem.add_dependency 'adamantium',       '~> 0.2', '>= 0.2.0'
  gem.add_dependency 'abstract_type',    '~> 0.0', '>= 0.0.7'
  gem.add_dependency 'inflecto',         '~> 0.0', '>= 0.0.2'
  gem.add_dependency 'axiom',            '~> 0.2', '>= 0.2.0'
  gem.add_dependency 'axiom-do-adapter', '~> 0.2', '>= 0.2.0'
  gem.add_dependency 'axiom-types',      '~> 0.1', '>= 0.1.1'
  gem.add_dependency 'axiom-optimizer',  '~> 0.2', '>= 0.2.0'

  gem.add_development_dependency 'bundler',             '~> 1.6', '>= 1.6.5'
  gem.add_development_dependency 'dm-core',             '~> 1.2', '>= 1.2.0'
  gem.add_development_dependency 'dm-migrations',       '~> 1.2', '>= 1.2.0'
  gem.add_development_dependency 'dm-postgres-adapter', '~> 1.2', '>= 1.2.0'
  gem.add_development_dependency 'rspec',               '~> 3.0'  '>= 3.0.0'
end
