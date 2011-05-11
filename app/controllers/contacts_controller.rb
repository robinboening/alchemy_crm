class ContactsController < AlchemyMailingsController
  
  helper :pages
  
  def signup
    @contact = Contact.new(params[:contact])
    @element = Element.find(params[:element_id])
    if @contact.save
      followup_page = Page.find(@element.content_by_name('followup_page').ingredient)
      MailingsMailer.deliver_verification_mail(
        @contact,
        current_server,
        @element,
        @contact.newsletter_subscriptions.collect(&:newsletter_id)
      )
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    else
      @page = @element.page
			@root_page = @page.get_language_root
      render :template => '/pages/show', :layout => 'pages'
    end
  end
  
  def verify
    @element = Element.find(params[:element_id])
    unless params[:sha1].blank?
      @contact = Contact.find_by_email_sha1(params[:sha1])
      @subscriptions = @contact.newsletter_subscriptions.find_all_by_newsletter_id(params[:newsletter_ids])
      @subscriptions.each do |subscription|
        subscription.update_attributes(:verified => true)
      end
      @contact.update_attributes(:verified => true)
      followup_page = Page.find(@element.content_by_name('verification_followup_page').ingredient)
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    end
  end
  
  def signout
    @element = Element.find(params[:element_id])
    @contact = Contact.find_by_email(params[:email])
    if @contact.blank?
      flash[:notice] = 'Diese Email Adresse ist uns nicht bekannt.'
      @page = @element.page
      render :template => '/pages/show', :layout => 'pages'
    else
      followup_page = Page.find(@element.content_by_name('followup_page').ingredient)
      MailingsMailer.deliver_signout_mail(
        @contact,
        current_server,
        @element
      )
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    end
  end
  
  def destroy
    @element = Element.find(params[:element_id])
    begin
      @contact = Contact.find_by_email_sha1(params[:sha1])
      @contact.destroy
      followup_page = Page.find(@element.content_by_name('signout_followup_page').ingredient)
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    rescue
      log_error($!)
      render :file => Rails.root + 'public/422.html', :status => 422
    end
  end
  
end
