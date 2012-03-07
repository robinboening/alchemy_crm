module AlchemyCrm
	class Recipient < ActiveRecord::Base

		belongs_to :delivery
		belongs_to :contact
		has_many :reactions

		validates_presence_of :email
		validates_format_of :email, :with => Authlogic::Regex.email, :if => proc { email.present? }

	end
end
