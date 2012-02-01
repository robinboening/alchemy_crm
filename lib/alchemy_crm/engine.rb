module AlchemyCrm
	class Engine < Rails::Engine

		isolate_namespace AlchemyCrm
		engine_name 'alchemy_crm'

		initializer 'alchemy_crm.register_as_alchemy_module' do
			Alchemy::Modules.register_module(YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config/module_definition.yml')))
		end

		# Loading authorization rules and register them to auth engine instance
		initializer "alchemy_crm.add_authorization_rules" do
			Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
		end

		initializer "alchemy_crm.add_newsletter_layouts" do
			newsletter_layouts_file = Rails.root.join('config', 'alchemy', 'newsletter_layouts.yml')
			if File.exist? newsletter_layouts_file
				YAML.load_file(newsletter_layouts_file).each do |newsletter_layout|
					Alchemy::PageLayout.add(newsletter_layout.merge({'newsletter' => true}))
				end
			else
				puts "!!! Alchemy CRM Warning: Newsletter Layouts File not found!\nPlease run 'rails generate alchemy_crm:scaffold' or create a 'newsletter_layouts.yml' file in config/alchemy folder."
			end
		end

		# Loading all alchemy core extensions found in app folder.
		config.to_prepare do
			Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_extension.rb")) do |e|
				Rails.env.production? ? require(e) : load(e)
			end
		end

	end
end
