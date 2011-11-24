# encoding: UTF-8
module AlchemyCrm
	class ContactsController < AlchemyCrm::BaseController

		helper 'Alchemy::Pages'

		def signup
			@contact = Contact.new(params[:contact])
			@element = Alchemy::Element.find(params[:element_id])
			if @contact.save
				followup_page = Alchemy::Page.find(@element.content_by_name('followup_page').ingredient)
				MailingsMailer.deliver_verification_mail(
					@contact,
					current_server,
					@element,
					@contact.newsletter_subscriptions.collect(&:newsletter_id)
				)
				redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
			else
				@page = @element.page
				@root_page = @page.get_language_root
				render :template => 'alchemy/pages/show', :layout => 'alchemy/pages'
			end
		end

		def verify
			@element = Alchemy::Element.find(params[:element_id])
			unless params[:sha1].blank?
				@contact = Contact.find_by_email_sha1(params[:sha1])
				@subscriptions = @contact.newsletter_subscriptions.find_all_by_newsletter_id(params[:newsletter_ids])
				@subscriptions.each do |subscription|
					subscription.update_attributes(:verified => true)
				end
				@contact.update_attributes(:verified => true)
				followup_page = Alchemy::Page.find(@element.content_by_name('verification_followup_page').ingredient)
				redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
			end
		end

		def signout
			@element = Alchemy::Element.find(params[:element_id])
			@contact = Contact.find_by_email(params[:email])
			if @contact.blank?
				flash[:notice] = 'Diese Email Adresse ist uns nicht bekannt.'
				@page = @element.page
				render :template => 'alchemy/pages/show', :layout => 'alchemy/pages'
			else
				followup_page = Alchemy::Page.find(@element.content_by_name('followup_page').ingredient)
				MailingsMailer.deliver_signout_mail(
					@contact,
					current_server,
					@element
				)
				redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
			end
		end

		def destroy
			@element = Alchemy::Element.find(params[:element_id])
			@contact = Contact.find_by_email_sha1(params[:sha1])
			@contact.destroy
			followup_page = Alchemy::Page.find(@element.content_by_name('signout_followup_page').ingredient)
			redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
		rescue
			log_error($!)
			render :file => Rails.root + 'public/422.html', :status => 422
		end

	end
end
