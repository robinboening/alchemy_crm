module AlchemyCrm
	class ContactsMailer < ActionMailer::Base

		def signup_mail(contact, newsletter_ids, page)
			@contact = contact
			@newsletter_ids = newsletter_ids
			@element = page.elements.where(:name => 'newsletter_signup_mail').first
			mail(
				:from => @element.ingredient('mail_from'),
				:to => contact.email,
				:subject => @element.ingredient('subject')
			)
		end

	end
end
