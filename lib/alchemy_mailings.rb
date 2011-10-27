if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'acts-as-taggable-on'
  require 'alchemy_mailings/version'
  require 'alchemy_mailings/newsletter_layout'
  require "alchemy_mailings/seeder"
  require 'alchemy_mailings/engine'
  require 'alchemy_mailings/models/element_extension'
  require 'alchemy_mailings/admin/elements_controller_extension'
else
  raise "Alchemy Mailings 2.0 needs Rails 3.0 or higher. You are currently using Rails #{Rails::VERSION::MAJOR}"
end
