module AlchemyCrm
	class Recipient < ActiveRecord::Base

		belongs_to :delivery
		belongs_to :contact
		has_many :reactions

		validates_presence_of :email
		validates_format_of :email, :with => Authlogic::Regex.email, :if => proc { email.present? }

		before_create :set_sha1

		def mail_to
			contact.nil? ? email : "#{contact.name_with_title} <#{email}>"
		end

		def reads!
			update_attributes(:read => true, :read_at => Time.now)
		end

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

		def self.new_from_contact(contact)
			raise "No contact given!" if contact.nil?
			recipient = new(:contact => contact, :email => contact.email, :sha1 => Digest::SHA1.hexdigest(Time.now.to_i.to_s))
			recipient.readonly!
			recipient
		end

	private

		def set_sha1
			self.salt = [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
			self.sha1 = Digest::SHA1.hexdigest(Time.now.to_i.to_s + salt)
		end

	end
end
