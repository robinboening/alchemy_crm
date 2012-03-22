# encoding: UTF-8
module AlchemyCrm
	class Delivery < ActiveRecord::Base

		attr_accessor :chunk_delay

		belongs_to :mailing
		has_many :recipients, :dependent => :destroy

		after_create :recipients_from_mailing_contacts

		scope :delivered, where("`alchemy_crm_deliveries`.`delivered_at` IS NOT NULL")
		scope :pending, where("`alchemy_crm_deliveries`.`delivered_at` IS NULL")

		def delivered?
			!self.delivered_at.nil?
		end

		# Sending mails in chunks.
		def deliver!(controller)
			@controller = controller
			raise "No Mailing Given" if mailing.blank?
			@chunk_delay = 0
			recipients.each_slice(self.class.settings(:send_mails_in_chunks_of)) do |recipients_chunk|
				send_mail_chunk(recipients_chunk)
				@chunk_delay += 1
			end
			update_attribute(:delivered_at, Time.now)
		end
		#handle_asynchronously :deliver!, :run_at => proc { |m| m.deliver_at || Time.now }

		# Send the mail chunk via delayed_job and waiting some time before next is enqueued
		def send_mail_chunk(recipients_chunk)
			recipients_chunk.each do |recipient|
				MailingsMailer.build(
					@controller,
					mailing,
					recipient
				).deliver
			end
		end
		#handle_asynchronously :send_mail_chunk, :run_at => proc { |m| (m.chunk_delay * m.class.settings(:send_mail_chunks_every)).minutes.from_now }

		def self.settings(name)
			AlchemyCrm::Config.get(name)
		end

	private

		def recipients_from_mailing_contacts
			raise "No Mailing Given" if mailing.blank?
			mailing.contacts.each do |contact|
				recipients << Recipient.create!(
					:email => contact.email,
					:contact => contact
				)
			end
		end

	end
end
