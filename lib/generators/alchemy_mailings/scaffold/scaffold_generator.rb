require 'rails'

module AlchemyMailings
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy Mailings scaffold."
      source_root File.expand_path('templates', File.dirname(__FILE__))
      
      def create_newsletter_scaffold

        empty_directory "#{Rails.root}/app/views/page_layouts"

        copy_file File.join(File.dirname(__FILE__), "templates/_standard.html.erb"), "#{Rails.root}/app/views/page_layouts/_newsletter_standard.html.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/_standard.text.erb"), "#{Rails.root}/app/views/page_layouts/_newsletter_standard.text.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/newsletters.html.erb"), "#{Rails.root}/app/views/layouts/newsletters.html.erb"
        copy_file File.join(File.dirname(__FILE__), "templates/newsletters.text.erb"), "#{Rails.root}/app/views/layouts/newsletters.text.erb"

        # Thors append_to_file does not work. But who needs it anyway?
        # Has many bugs through Rails ^_^
        File.open(Rails.root.join('config/alchemy/page_layouts.yml'), 'a') do |f|
          f << "\n\n# Newsletter page layouts"
          f << "\n- name: newsletter_standard\n"
          f << "  newsletter: true\n"
          f << "  elements: []\n"
        end

      end
      
    end
  end
end
