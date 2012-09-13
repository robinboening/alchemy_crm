source 'http://rubygems.org'

# Specify your gem's dependencies in alchemy_crm.gemspec
gemspec

group :development do
  if !ENV["CI"]
    gem 'guard-spork'
    gem 'debugger',   :platform => :ruby_19
    gem 'ruby-debug', :platform => :ruby_18
  end
end

group :test do
  gem "database_cleaner"
  gem 'email_spec'
end
