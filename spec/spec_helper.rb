begin
  require 'spork'
rescue LoadError => e
end

def configure
  # Configure Rails Environment
  ENV["RAILS_ENV"] = "test"

  require File.expand_path("../dummy/config/environment.rb",  __FILE__)

  require "rails/test_help"
  require "rspec/rails"
  require "email_spec"
  require 'factory_girl'

  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!
  # Disable rails loggin for faster IO. Remove this if you want to have a test.log
  Rails.logger.level = 4

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

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
    # Make sure the database is clean and ready for test
    config.before(:suite) do
      truncate_all_tables
      Alchemy::Seeder.seed!
      AlchemyCrm::Seeder.seed!
    end
  end

  Alchemy::PageLayout.add('name' => 'standard', 'elements' => 'all')

end

if defined?(Spork)
  Spork.prefork { configure }
else
  configure
end
