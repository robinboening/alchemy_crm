begin
  require 'spork'
rescue LoadError => e
end

def configure
  # Configure Rails Environment
  ENV["RAILS_ENV"] = "test"

  require File.expand_path("../dummy/config/environment.rb",  __FILE__)

  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation

  require "rails/test_help"
  require "rspec/rails"
  require "email_spec"
  require 'factory_girl'

  require 'authlogic/test_case'
  include Authlogic::TestCase

  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!

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
  end

end

def seed
  # This code will be run each time you run your specs.
  DatabaseCleaner.clean

  # Seed the database
  Alchemy::Seeder.seed!
  AlchemyCrm::Seeder.seed!
end

if defined?(Spork)
  Spork.prefork  { configure }
  Spork.each_run { seed }
else
  configure
  seed
end
