module AlchemyCrm
	class Engine < Rails::Engine

		isolate_namespace AlchemyCrm
		engine_name 'alchemy_crm'

		# Enabling assets precompiling
		initializer 'alchemy_crm.assets', :group => :assets do |app|
			app.config.assets.precompile += [
				"alchemy_crm/scripts.js",
				"alchemy_crm/styles.css"
			]
		end

		initializer 'alchemy_crm.register_as_alchemy_module' do
			Alchemy::Modules.register_module(YAML.load_file(File.join(File.dirname(__FILE__), '../..', 'config/module_definition.yml')))
		end

		# Loading authorization rules and register them to auth engine instance
		initializer "alchemy_crm.add_authorization_rules" do
			Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
		end

		# Adding additional page layout for root page.
		initializer "alchemy_crm.add_page_layouts" do
			Alchemy::PageLayout.add({
				'name' => 'alchemy_crm_rootpage'
			})
		end

		# Loading all alchemy core extensions found in app folder.
		config.to_prepare do
			Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_extension.rb")) do |e|
				Rails.env.production? ? require(e) : load(e)
			end
		end

	end
end
