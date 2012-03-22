module AlchemyCrm
	class MailingsController < AlchemyCrm::BaseController

		include ControllerHelpers
		before_filter :set_options_for_helpers

		def show
			@mailing = Mailing.find_by_sha1(params[:m])
			if @mailing.nil? && !params[:id].blank?
				@mailing = Mailing.find(params[:id])
			end
			@page = @mailing.page
			if params[:r].present?
				@recipient = @mailing.recipients.find_by_sha1(params[:r])
			end
			@contact = @recipient ? @recipient.contact || Contact.new_from_recipient(@recipient) : Contact.fake
		end

	private

		def set_options_for_helpers
			@options = {:language_id => session[:language_id], :host => request.host_with_port, :protocol => request.protocol}
		end

	end
end
