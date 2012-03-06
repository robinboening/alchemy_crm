# encoding: UTF-8
module AlchemyCrm
	class SubscriptionsMailer < ActionMailer::Base

		helper "Alchemy::Base"
		helper "AlchemyCrm::Base"
		helper "Alchemy::Pages"
		helper_method :logged_in?, :configuration

		def logged_in?; false; end

		def configuration(name)
			Alchemy::Config.get(name)
		end

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
