module AlchemyCrm
	class MailingsController < AlchemyCrm::BaseController

		layout "alchemy/newsletters"
		#layout :layout_for_page
		filter_access_to :show, :unless => proc { params[:id].blank? }

		def show
			# @host = current_server
			# @server = @host.gsub(/http:\/\//, '')
			@mailing = Mailing.find_by_sha1(params[:mailing_hash])
			if @mailing.nil? && !params[:id].blank?
				@mailing = Mailing.find(params[:id])
			end
			@page = @mailing.page
			@contact = Contact.find_by_email_sha1(params[:sha1]) rescue nil
			# TODO / WIP: The recipient has to be found via recipient_id, or the contact.
			if @contact.nil?
				@contact = Contact.fake
			end
			@recipient = Recipient.new(:contact => @contact)
		rescue
			render :file => "#{Rails.root.to_s}/public/422.html", :status => "422"
		end

	end
end
