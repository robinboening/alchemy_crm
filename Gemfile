source 'http://rubygems.org'

# Specify your gem's dependencies in alchemy_crm.gemspec
gemspec

gem 'localized_country_select', :git => 'git://github.com/phonk64/localized_country_select.git'

group :development do
	if !ENV["CI"]
		gem 'ruby-debug-base19', '~> 0.11.26', :platform => :ruby_19
		gem 'linecache19', '~> 0.5.13', :platform => :ruby_19
		gem 'ruby-debug19', '~> 0.11.6', :require => 'ruby-debug', :platform => :ruby_19
		gem 'ruby-debug', :platform => :ruby_18
	end
end
