module AlchemyCrm
	class MailingsMailer < ActionMailer::Base

		default :from => AlchemyCrm::Config.get(:mail_from)

		helper "AlchemyCrm::Base"
		helper "AlchemyCrm::Mailings"
		helper_method :logged_in?, :configuration, :current_language, :current_server, :current_host, :session

		# Faking that we are not logged in
		def logged_in?
			false
		end

		# Session Hash for Alchemy::PagesHelper
		def session
			{
				:language_id => @language.id,
				:language_code => @language.code
			}
		end

		def configuration(name)
			Alchemy::Config.get(name)
		end

		def current_language
			@language ||= Alchemy::Language.find(@options[:language_id])
		end

		def current_server
			@current_server ||= [@options[:protocol], @options[:host]].join
		end

		def current_host
			@current_host ||= @options[:host]
		end

		# Renders the email sent to the mailing recipient
		# It takes the layout from +layouts/alchemy_crm/mailings.erb+ and renders a html and a text part from it.
		def build(mailing, recipient, options = {})
			@options = options
			@mailing = mailing
			@page = @mailing.page
			@recipient = recipient
			@contact = @recipient.contact || Contact.new_from_recipient(@recipient)

			mail(:to => @recipient.email, :subject => mailing.subject) do |format|
				format.html { render("layouts/alchemy_crm/mailings.html") }
				format.text { render("layouts/alchemy_crm/mailings.text") }
			end
		end

	end
end
