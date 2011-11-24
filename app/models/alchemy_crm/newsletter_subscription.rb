module AlchemyCrm
	class NewsletterSubscription < ActiveRecord::Base

		belongs_to :contact
		belongs_to :newsletter

	end
end
