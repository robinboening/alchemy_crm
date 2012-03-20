# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
require "email_spec"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Configure capybara for integration testing
# require "capybara/rails"
# Capybara.default_driver   = :rack_test
# Capybara.default_selector = :css

Alchemy::Seeder.seed!
AlchemyCrm::Seeder.seed!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
	# Remove this line if you don't want RSpec's should and should_not
	# methods or matchers
	require 'rspec/expectations'
	config.include RSpec::Matchers
	# for testing mails
	config.include(EmailSpec::Helpers)
	config.include(EmailSpec::Matchers)
	config.use_transactional_fixtures = true
	# == Mock Framework
	config.mock_with :rspec
end
