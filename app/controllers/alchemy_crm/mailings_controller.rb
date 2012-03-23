module AlchemyCrm
	class MailingsController < AlchemyCrm::BaseController

		def show
			@mailing = Mailing.find_by_sha1(params[:m])
			if @mailing.nil? && !params[:id].blank?
				@mailing = Mailing.find(params[:id])
			end
			@page = @mailing.page
			if params[:r].present?
				@recipient = @mailing.recipients.find_by_sha1(params[:r])
				@contact = @recipient.contact || Contact.new_from_recipient(@recipient)
			else
				@contact = Contact.fake
				@recipient = Recipient.new_from_contact(@contact)
			end
		end

	end
end
