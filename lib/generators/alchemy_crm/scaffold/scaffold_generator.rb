require 'rails'

module AlchemyCrm
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy CRM scaffold."
      source_root File.expand_path('files', File.dirname(__FILE__))
      
      def create_newsletter_scaffold

        empty_directory "#{Rails.root}/app/views/alchemy/newsletter_layouts"

        copy_file "_standard.html.erb", "#{Rails.root}/app/views/alchemy/newsletter_layouts/_standard.html.erb"
        copy_file "_standard.text.erb", "#{Rails.root}/app/views/alchemy/newsletter_layouts/_standard.text.erb"
        copy_file "newsletters.html.erb", "#{Rails.root}/app/views/layouts/alchemy/newsletters.html.erb"
        copy_file "newsletters.text.erb", "#{Rails.root}/app/views/layouts/alchemy/newsletters.text.erb"
        copy_file "newsletter_layouts.yml", "#{Rails.root}/config/alchemy/newsletter_layouts.yml"

      end
      
    end
  end
end
