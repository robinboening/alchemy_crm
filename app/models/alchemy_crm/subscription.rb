module AlchemyCrm
	class Subscription < ActiveRecord::Base

		belongs_to :contact
		belongs_to :newsletter

	end
end
