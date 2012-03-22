module AlchemyCrm
	class MailingsMailer < ActionMailer::Base

		helper "AlchemyCrm::Base"
		helper "AlchemyCrm::Mailings"
		helper_method :logged_in?, :configuration, :session, :current_server

		# Faking helper methods
		def logged_in?; false; end
		def configuration(name); return ::Alchemy::Config.get(name); end

		def session
			@controller.session
		end

		def current_server
			[@controller.request.protocol, @controller.request.host_with_port].join
		end

		# Renders the email sent to the mailing recipient
		# It takes the layout from +layouts/alchemy_crm/mailings.erb+ and renders a html and a text part from it.
		def build(controller, mailing, recipient, options = {})
			@controller = controller
			options = {
				:mail_from => AlchemyCrm::Config.get(:mail_from)
			}.update(options)
			@mailing = mailing
			@page = @mailing.page
			@recipient = recipient
			@contact = @recipient.contact || Contact.new_from_recipient(@recipient)
			mail(:to => @recipient.email, :from => options[:mail_from], :subject => mailing.subject) do |format|
				format.html { render("layouts/alchemy_crm/mailings.html") }
				format.text { render("layouts/alchemy_crm/mailings.text") }
			end
		end

	end
end
