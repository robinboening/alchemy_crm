module AlchemyCrm
	class BounceReceiver < ActionMailer::Base

		def receive(email)
			return unless email.content_type == "multipart/report"
			logger.info "*** Bounced email received -- #{Time.now} ***"
			bounce = AlchemyCrm::BouncedDelivery.from_email(email)
			recipient = AlchemyCrm::Recipient.find_by_message_id(bounce.original_message_id)
			recipient.bounced = (bounce.status == "Failure")
			recipient.save!
		end

	end
end
