require File.join(File.dirname(__FILE__), 'lib', 'element_extension.rb')
if defined?(FastGettext)
  FastGettext.add_text_domain 'alchemy-mailings', :path => File.join(File.dirname(__FILE__), 'locale')
end
