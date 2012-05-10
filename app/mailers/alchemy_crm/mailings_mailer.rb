module AlchemyCrm
	class MailingsMailer < ActionMailer::Base

		default :from => AlchemyCrm::Config.get(:mail_from)

		helper "AlchemyCrm::Mailings", "Application"
		helper_method :logged_in?, :configuration

		# Renders the email sent to the mailing recipient
		# It takes the layout from +layouts/alchemy_crm/mailings.erb+ and renders a html and a text part from it.
		def build(mailing, recipient, options = {})
			@options = options
			::I18n.locale = @options[:locale]
			@mailing = mailing
			@page = @mailing.page
			@recipient = recipient
			@contact = @recipient.contact || Contact.new_from_recipient(@recipient)

			mail(:to => @recipient.mail_to, :subject => mailing.subject) do |format|
				format.text { render("layouts/alchemy_crm/mailings.text") }
				format.html { render("layouts/alchemy_crm/mailings.html") }
			end
		end

		# Faking that we are not logged in
		def logged_in?
			false
		end

		# Proxy to Alchemy config for view helpers
		def configuration(name)
			Alchemy::Config.get(name)
		end

		# Simple session object that contains the language id for view helpers.
		def session
			{
				:language_id => @options[:language_id]
			}
		end

		# Setting default url options for rails url_for helpers.
		def default_url_options
			{:host => @options[:host], :port => @options[:port]}
		end

	end
end
