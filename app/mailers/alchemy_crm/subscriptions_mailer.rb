# encoding: UTF-8
module AlchemyCrm
	class SubscriptionsMailer < ActionMailer::Base

		def overview_mail(contact, element)
			@contact = contact
			@subscriptions = contact.subscriptions
			@element = element
			mail(
				:from => element.ingredient("mail_from"),
				:to => contact.email,
				:subject => element.ingredient("mail_subject")
			)
		end

	end
end
