require File.join(File.dirname(__FILE__), 'lib', 'alchemy_mailings', 'models', 'element_extension')
require File.join(File.dirname(__FILE__), 'lib', 'alchemy_mailings', 'admin', 'elements_controller_extension')

if defined?(FastGettext)
  FastGettext.add_text_domain 'alchemy-mailings', :path => File.join(File.dirname(__FILE__), 'locale')
end
