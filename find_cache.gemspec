# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'find_cache/version'

Gem::Specification.new do |spec|
  spec.name        = "find_cache"
  spec.version     = FindCache::VERSION
  spec.authors     = ["Mustafa Turan"]
  spec.email       = ["mustafaturan.net@gmail.com"]
  spec.homepage    = "https://github.com/mustafaturan/find_cache"
  spec.summary     = "Thread-safe cache for ActiveRecord >=3.0.0 find_by_PrimaryKey(id) and find_by_(attr) methods and models based on Rails.cache methods."
  spec.description = "Makes ActiveRecord 'find_by_id, find_by_(attr)' methods and 'has_one, belongs_to' relations are cacheable by PrimaryKey(PK) or any referenced columns using Rails.cache methods. It also supports fetching multiple records using PKs(ids) with find_all_cache method(if cache store supports multiple reads [hint: memcached_store, dalli_store supports.])."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", [">= 3.0.0"]
  spec.add_dependency "activesupport", [">= 3.0.0"]
  spec.add_dependency "railties", [">= 3.0.0"]
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  spec.add_development_dependency "factory_girl", "~> 4.5.0"
  spec.add_development_dependency "sqlite3", "~> 1.3.11"
  spec.add_development_dependency "database_cleaner", "~> 1.5.1"
end
