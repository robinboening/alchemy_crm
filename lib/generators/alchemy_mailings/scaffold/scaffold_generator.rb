require 'rails'

module AlchemyMailings
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy Mailings scaffold."
      source_root File.expand_path('templates', File.dirname(__FILE__))
      
      def create_newsletter_layout_files
        empty_directory "#{Rails.root}/app/views/newsletter_layouts"
        copy_file File.join(File.dirname(__FILE__), "templates/_standard.html.erb"), "#{Rails.root}/app/views/newsletter_layouts/_standard.html.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/_standard.plain.erb"), "#{Rails.root}/app/views/newsletter_layouts/_standard.plain.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/newsletters.html.erb"), "#{Rails.root}/app/views/layouts/newsletters.html.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/newsletters.plain.erb"), "#{Rails.root}/app/views/layouts/newsletters.plain.erb"
      end
      
    end
  end
end
