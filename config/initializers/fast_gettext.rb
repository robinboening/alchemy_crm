require 'fast_gettext'
FastGettext.add_text_domain 'alchemy_crm', :path => File.join(File.dirname(__FILE__), '..', '..', 'locale'), :type => :po
