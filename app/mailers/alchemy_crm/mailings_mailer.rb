# encoding: UTF-8
module AlchemyCrm
	class MailingsMailer < ActionMailer::Base

		helper "Alchemy::Base"
		helper "AlchemyCrm::Base"
		helper "Alchemy::Pages"
		helper_method :logged_in?, :configuration

		def logged_in?; false; end

		def configuration(name)
			return Alchemy::Config.get(name)
		end

		# This renders the mail sent as newsletter to the recipient
		def my_mail(mailing, recipient, options = {})
			default_options = {
				:mail_from => AlchemyCrm::Config.get(:mail_from),
				:subject => mailing.subject,
				:server => "http://localhost:3000"
			}
			options = default_options.merge(options)
			@mailing = mailing
			@page = @mailing.page
			@elements = @page.elements
			@recipient = recipient
			@contact = @recipient.contact
			@server = options[:server].gsub(/http:\/\//, '')
			@host = options[:server]
			mail(:to => @recipient.email, :from => options[:mail_from], :subject => options[:subject]) do |format|
				format.html { render("layouts/newsletters.html") }
				format.text { render("layouts/newsletters.text") }
			end
		end

		def signout_mail(contact, server, element)
			recipients contact.email
			from element.ingredient("mail_from")
			subject element.ingredient("mail_subject")
			content_type "text/html"
			body(
				:contact => contact,
				:server => server.gsub(/http:\/\//, ''),
				:element => element
			)
		end

	end
end
