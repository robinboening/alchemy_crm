module AlchemyCrm
	class Recipient < ActiveRecord::Base

		belongs_to :delivery
		belongs_to :contact
		has_many :reactions

		validates_presence_of :email
		validates_format_of :email, :with => Authlogic::Regex.email, :if => proc { email.present? }

		def reacts!(options={})
			update_attributes(
				:reacted => true,
				:reacted_at => Time.now
			)
			reactions.create(
				:element_id => options[:element_id],
				:page_id => options[:page_id],
				:url => options[:url]
			)
		end

	end
end
