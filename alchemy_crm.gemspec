# -*- encoding: utf-8 -*-
require File.expand_path('../lib/alchemy_crm/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Thomas von Deyen"]
  gem.email         = ["tvd@magiclabs.de"]
  gem.description   = %q{A fully featured CRM / Newsletter and Mailings Module for Alchemy CMS. Building and sending Newsletters has never been easier!}
  gem.summary       = %q{A fully featured CRM / Newsletter and Mailings Module for Alchemy CMS.}
  gem.homepage      = "http://alchemy-cms.com"
  gem.license       = 'BSD New'
  gem.required_ruby_version = '>= 1.9.2'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "alchemy_crm"
  gem.require_paths = ["lib"]
  gem.version       = AlchemyCrm::VERSION

  gem.add_dependency 'alchemy_cms', ["~> 2.1.12"]
  gem.add_dependency 'vcard', ['~> 0.1.1']
  gem.add_dependency 'csv_magic', ['~> 0.2.3']
  gem.add_dependency 'delayed_job_active_record', ["~> 0.3.2"]
  gem.add_dependency 'acts-as-taggable-on', ['~> 2.1.0']
  gem.add_dependency 'rails3-jquery-autocomplete', ['~> 1.0.4']
  gem.add_dependency "magic-localized_country_select", ["~> 0.2.0"]

  gem.add_development_dependency 'rspec-rails', ["~> 2.8.0"]
  gem.add_development_dependency 'sqlite3', ["~> 1.3.5"]

end
