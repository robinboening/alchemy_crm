module AlchemyCrm
class BAseController < Alchemy::BaseController

	layout "alchemy/pages"
	before_filter :set_gettext_domain

	private

		def set_gettext_domain
			FastGettext.text_domain = 'alchemy_crm'
		end

	end
end
