# encoding: UTF-8
module AlchemyCrm
	class ContactsController < AlchemyCrm::BaseController

		helper 'Alchemy::Pages'
		layout :layout_for_page

		def signup
			@contact = Contact.new(params[:contact])
			@element = Alchemy::Element.find_by_id(params[:element_id])
			if @contact.save
				followup_page = Alchemy::Page.find(@element.ingredient('followup_page'))
				ContactsMailer.signup_mail(
					@contact,
					@contact.subscriptions.collect(&:newsletter_id),
					Alchemy::Page.find_by_page_layout_and_language_id('newsletter_mails', session[:language_id])
				).deliver
				redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
			else
				@page = @element.page
				@root_page = @page.get_language_root
				render :template => 'alchemy/pages/show'
			end
		end

		def verify
			@element = Alchemy::Element.find(params[:element_id])
			if params[:token].blank?
				flash[:notice] = 'Diese E-Mail Adresse ist uns nicht bekannt.'
				@page = @element.page
				@root_page = @page.get_language_root
				render :template => 'alchemy/pages/show'
			else
				@contact = Contact.find_by_email_sha1(params[:token])
				@subscriptions = @contact.subscriptions.where(:newsletter_id => params[:newsletter_ids])
				@subscriptions.each do |subscription|
					subscription.update_attributes(:verified => true)
				end
				@contact.update_attributes(:verified => true)
				followup_page = Alchemy::Page.find(@element.ingredient('followup_page'))
				redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
			end
		end

		def signout
			@element = Alchemy::Element.find(params[:element_id])
			@contact = Contact.find_by_email(params[:email])
			if @contact.blank?
				flash[:notice] = 'Diese E-Mail Adresse ist uns nicht bekannt.'
				@page = @element.page
				@root_page = @page.get_language_root
				render :template => 'alchemy/pages/show'
			else
				followup_page = Alchemy::Page.find(@element.ingredient('followup_page'))
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
			@contact = Contact.find_by_email_sha1(params[:token])
			@contact.destroy
			followup_page = Alchemy::Page.find(@element.ingredient('followup_page'))
			redirect_to alchemy.show_page_path(:urlname => followup_page.urlname, :lang => multi_language? ? session[:language_code] : nil)
		rescue
			log_error($!)
			render :file => Rails.root + 'public/422.html', :status => 422
		end

	end
end
