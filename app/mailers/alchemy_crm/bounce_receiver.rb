module AlchemyCrm
	class BounceReceiver < ActionMailer::Base

		def receive(email)
			return unless email.content_type == "multipart/report"
			bounce = BouncedDelivery.from_email(email)
			recipient = Recipient.find_by_message_id(bounce.original_message_id)
			recipient.bounced = (bounce.status == "Failure")
			recipient.save!
		end

	end
end
