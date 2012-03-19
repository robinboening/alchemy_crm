# encoding: UTF-8
module AlchemyCrm
	class ContactsController < AlchemyCrm::BaseController

		helper 'Alchemy::Pages'
		layout :layout_for_page

		before_filter :load_signup_form, :only => [:show, :signup, :verify]
		before_filter :load_signout_form, :only => [:signout, :disable]

		def show
			@page = @element.page
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show'
		end

		def signup
			@contact = Contact.new(params[:contact])
			if @contact.save
				ContactsMailer.signup_mail(
					@contact,
					Alchemy::Page.find_by_page_layout_and_language_id('newsletter_mails', session[:language_id])
				).deliver
				@contact_signed_up = true
			else
				@contact_signed_up = false
			end
			@page = @element.page
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show'
		end

		def verify
			if params[:token].blank?
				flash[:notice] = ::I18n.t(:contact_unknown, :scope => :alchemy_crm)
			else
				@contact = Contact.find_by_email_sha1(params[:token])
				@subscriptions = @contact.subscriptions.where(:newsletter_id => params[:newsletter_ids])
				@subscriptions.each do |subscription|
					subscription.update_attributes(:verified => true)
				end
				@contact_verified = @contact.update_attributes(:verified => true)
			end
			@page = @element.page
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show'
		end

		def signout
			@contact = Contact.find_by_email(params[:email])
			if @contact.blank?
				flash[:notice] = ::I18n.t(:contact_unknown, :scope => :alchemy_crm)
				@contact_signed_out = false
			else
				ContactsMailer.signout_mail(
					@contact,
					Alchemy::Page.find_by_page_layout_and_language_id('newsletter_mails', session[:language_id])
				).deliver
				@contact_signed_out = true
			end
			@page = @element.page
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show'
		end

		def disable
			@contact = Contact.find_by_email_sha1(params[:token])
			if @contact
				@contact_disabled = @contact.disable!
			else
				flash[:notice] = ::I18n.t(:contact_unknown, :scope => :alchemy_crm)
				@contact_disabled = false
			end
			@page = @element.page
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show'
		end

	private

		def load_signup_form
			@element = Alchemy::Element.find_by_name('newsletter_signup_form')
			if @element.blank?
				if Rails.env.production?
					render :file => Rails.root.join('public', '404.html'), :status => 404
				else
					raise ActiveRecord::RecordNotFound, "Alchemy::Element with name 'newsletter_signup_form' not found!"
				end
			end
		end

		def load_signout_form
			@element = Alchemy::Element.find_by_name('newsletter_signout_form')
			if @element.blank?
				if Rails.env.production?
					render :file => Rails.root.join('public', '404.html'), :status => 404
				else
					raise ActiveRecord::RecordNotFound, "Alchemy::Element with name 'newsletter_signout_form' not found!"
				end
			end
		end

	end
end
