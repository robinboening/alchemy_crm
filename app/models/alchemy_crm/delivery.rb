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
		def deliver!(current_server)
			raise "No Mailing Given" if self.mailing.blank?
			#100.times { |i| self.recipients << Recipient.new(:email => "tvdeyen+#{i}@gmail.com") }
			@chunk_delay = 0
			self.recipients.each_slice(settings(:send_mails_in_chunks_of)) do |recipients_chunk|
				send_mail_chunk(recipients_chunk, current_server)
				@chunk_delay += 1
			end
			self.update_attribute(:delivered_at, Time.now)
		end
		handle_asynchronously :deliver!, :run_at => Proc.new { |m| m.deliver_at || Time.now }

		# Send the mail chunk via delayed_job and waiting some time before next is enqueued
		def send_mail_chunk(recipients_chunk, current_server)
			recipients_chunk.each do |recipient|
				# MailingsMailer.my_mail(
				# 	self.mailing,
				# 	recipient,
				# 	:server => current_server
				# ).deliver
				puts "sending mail at: #{recipient.email}"
			end
		end
		handle_asynchronously :send_mail_chunk, :run_at => Proc.new { |m| (m.chunk_delay * m.settings(:send_mail_chunks_every)).minutes.from_now }

		def settings(name)
			AlchemyCrm::Config.get(name)
		end

	private

		def recipients_from_mailing_contacts
			raise "No Mailing Given" if mailing.blank?
			mailing.contacts.each do |contact|
				recipients << Recipient.create(
					:email => contact.email,
					:contact => contact
				)
			end
		end

	end
end
