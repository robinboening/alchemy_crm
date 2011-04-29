class AlchemyMailingsController < AlchemyController
	
	layout "alchemy"
	before_filter :set_gettext_domain

private

	def set_gettext_domain
		FastGettext.text_domain = 'alchemy-mailings'
	end

end
