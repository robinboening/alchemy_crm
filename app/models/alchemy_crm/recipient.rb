module AlchemyCrm
	class Recipient < ActiveRecord::Base

		belongs_to :sent_mailing
		belongs_to :contact
		has_many :reactions

		validates_presence_of :email

	end
end
