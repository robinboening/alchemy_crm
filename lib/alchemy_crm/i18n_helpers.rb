module AlchemyCrm
	module I18nHelpers

		def self.included(controller)
			controller.send(:helper_method, [:i18n_t, :translate_model_attribute, :alchemy_crm_t])
		end

		# This is a proxy to the ::I18n.t method with an alchem_crm scope.
		# 
		# We can't use +t+ in views, because Alchemy overrides it and scopes everything into the +alchemy+ namespace.
		# 
		# === NOTE:
		# 
		# The keys are scoped into +alchemy_crm+ namespace.
		# Even if you pass a scope this is scoped under +alchemy_crm+.
		# 
		def alchemy_crm_t(key, options={})
			scope = options[:scope].blank? ? 'alchemy_crm' : "alchemy_crm.#{options.delete(:scope)}"
			::I18n.t(key, {:scope => scope, :default => key.to_s.humanize}.merge(options))
		end

		# This is a proxy to the ::I18n.t method without any scope.
		# 
		# We can't use +t+ in views, because Alchemy overrides it and scopes everything into the +alchemy+ namespace.
		# 
		def i18n_t(key, options={})
			::I18n.t(key, options.merge(:default => key.to_s.humanize))
		end

		def translate_model_attribute(model, key)
			"alchemy_crm/#{model.to_s.underscore}".classify.constantize.human_attribute_name(key)
		end

	end
end
