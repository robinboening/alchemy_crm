if defined?(Rails) && Rails::VERSION::MAJOR == 3
	require 'acts-as-taggable-on'
	require 'localized_country_select'
	require 'rails3-jquery-autocomplete'
	require 'vcard'
	require 'digest/sha1'
	require 'delayed_job'
	require 'alchemy_cms'
	require 'alchemy_crm/version'
	require 'alchemy_crm/engine'
	require 'alchemy_crm/newsletter_layout'
	require "alchemy_crm/seeder"
else
	raise "Alchemy CRM 2.0 needs Rails 3.0 or higher. You are currently using Rails #{Rails::VERSION::MAJOR}"
end
