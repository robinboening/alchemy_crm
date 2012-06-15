source 'http://rubygems.org'

# Specify your gem's dependencies in alchemy_crm.gemspec
gemspec

gem "alchemy_cms", :github => "magiclabs/alchemy_cms"

group :development do
  if !ENV["CI"]
    gem 'guard-spork'
    gem 'ruby-debug19', :require => 'ruby-debug', :platform => :ruby_19
    gem 'ruby-debug', :platform => :ruby_18
  end
end

group :test do
  gem 'sqlite3'
  gem "database_cleaner"
  gem 'email_spec'
end
