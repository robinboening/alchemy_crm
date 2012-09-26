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
      @contact = Contact.find_or_initialize_by_email(params[:contact])
      enable_contact if @contact.disabled?
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
      @contact = Contact.find_by_email_sha1(params[:token])
      if @contact
        @contact_verified = @contact.update_attribute(:verified, true)
        @page = @element.page
        @root_page = @page.get_language_root
        render :template => 'alchemy/pages/show'
      else
        contact_not_found
      end
    end

    def signout
      @contact = Contact.find_by_email_and_verified(params[:email], true)
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
        @page = @element.page
        @root_page = @page.get_language_root
        render :template => 'alchemy/pages/show'
      else
        contact_not_found
      end
    end

  private

    def load_signup_form
      @element = Alchemy::Element.find_by_name('newsletter_signup_form')
      if @element.blank?
        raise ActiveRecord::RecordNotFound, "Alchemy::Element with name 'newsletter_signup_form' not found!"
      end
    end

    def load_signout_form
      @element = Alchemy::Element.find_by_name('newsletter_signout_form')
      if @element.blank?
        raise ActiveRecord::RecordNotFound, "Alchemy::Element with name 'newsletter_signout_form' not found!"
      end
    end

    def contact_not_found
      raise ActionController::RoutingError.new('Contact Not Found')
    end

    def enable_contact
      @contact.disabled = false
      if params[:contact][:subscriptions_attributes].present?
        params[:contact][:subscriptions_attributes].each do |i, subscription_attributes|
          @contact.subscriptions.new(subscription_attributes)
        end
      end
    end

  end
end
