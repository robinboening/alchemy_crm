require File.dirname(__FILE__) + '/lib/element_extension.rb'
FastGettext.add_text_domain 'mailings', :path => File.join(RAILS_ROOT, 'vendor/plugins/mailings/locale')