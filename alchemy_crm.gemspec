# -*- encoding: utf-8 -*-
require File.expand_path('../lib/alchemy_crm/version', __FILE__)

Gem::Specification.new do |gem|

	gem.authors       = ["Thomas von Deyen"]
	gem.email         = ["tvd@magiclabs.de"]
	gem.description   = %q{A CRM module for Alchemy CMS with Newsletters, Contacts, Mailings.}
	gem.summary       = %q{A CRM module for Alchemy CMS}
	gem.homepage      = "http://alchemy-cms.com"

	gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	gem.files         = `git ls-files`.split("\n")
	gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	gem.name          = "alchemy_crm"
	gem.require_paths = ["lib"]
	gem.version       = AlchemyCrm::VERSION

	gem.add_dependency 'alchemy_cms', ["~> 2.1.rc1"]
	gem.add_dependency 'vcard', ['~> 0.1.1']
	gem.add_dependency 'delayed_job', ["~> 2.1.4"]
	gem.add_dependency 'prawn', ['~> 0.11.1']
	gem.add_dependency 'acts-as-taggable-on', ['~> 2.1.0']
	gem.add_dependency 'rails3-jquery-autocomplete', ['~> 1.0.4']
	gem.add_dependency "magic-localized_country_select", ["~> 0.1"]

	gem.add_development_dependency 'rspec-rails', ["~> 2.7"]

end
