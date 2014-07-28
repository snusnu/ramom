# encoding: utf-8

source 'https://rubygems.org'

SNUSNU = 'https://github.com/snusnu'.freeze
MBJ    = 'https://github.com/mbj'.freeze
DKUBB  = 'https://github.com/dkubb'.freeze
ROM_RB = 'https://github.com/rom-rb'.freeze
DM_120 = 'https://github.com/datamapper'.freeze

MASTER = 'master'.freeze
RL_120 = 'release-1.2'.freeze

gemspec

gem 'anima',                 git: "#{MBJ}/anima.git",                  branch: MASTER
gem 'morpher',               git: "#{MBJ}/morpher.git",                branch: MASTER
gem 'lupo',                  git: "#{SNUSNU}/lupo.git",                branch: MASTER
gem 'procto',                git: "#{SNUSNU}/procto.git",              branch: MASTER

gem 'axiom',                 git: "#{DKUBB}/axiom.git",                branch: 'add-relation-one'
gem 'axiom-optimizer',       git: "#{DKUBB}/axiom-optimizer.git",      branch: MASTER
gem 'axiom-do-adapter',      git: "#{DKUBB}/axiom-do-adapter.git",     branch: 'add-relation-one'
gem 'axiom-types',           git: "#{DKUBB}/axiom-types.git",          branch: MASTER

group :development do
  gem 'devtools',            git: "#{ROM_RB}/devtools.git",            branch: MASTER
  gem 'dm-core',             git: "#{DM_120}/dm-core.git",             branch: RL_120
  gem 'dm-migrations',       git: "#{DM_120}/dm-migrations.git",       branch: RL_120
  gem 'dm-postgres-adapter', git: "#{DM_120}/dm-postgres-adapter.git", branch: RL_120
  gem 'mom',                 git: "#{SNUSNU}/mom.git",                 branch: MASTER
end

# added by devtools
eval_gemfile 'Gemfile.devtools'
