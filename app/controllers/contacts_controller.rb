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
        @contact.newsletter_subscriptions.select(&:newsletter_id)
      )
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    else
      @page = @element.page
      render :template => '/pages/show', :layout => 'pages'
    end
  end
  
  def verify
    @element = Element.find(params[:element_id])
    unless params[:sha1].blank?
      @contact = Contact.find_by_email_sha1(params[:sha1])
      @subscriptions = @contact.newsletter_subscriptions.find_all_by_newsletter_id(params[:newsletter_ids])
      @subscriptions.map { |subscription| subscription.update_attributes(:verified => true) }
      @contact.save
      followup_page = Page.find(@element.content_by_name('verification_followup_page').ingredient)
      if multi_language?
        redirect_to show_page_with_language_path(:urlname => followup_page.urlname, :lang => session[:language])
      else
        redirect_to show_page_path(:urlname => followup_page.urlname)
      end
    end
  end
  
  def signout
    @page = Page.find_by_layout("Mailing_abmelden")
    element = @page.elements.find_by_name("mailing_signout")
    begin
      @contact = Contact.find_by_id_and_email_sha1(params[:id], params[:h])
      @newsletter = Newsletter.find(params[:format_id])
      
      @contact.newsletter_subscriptions.find_by_newsletter_id(@newsletter.id).update_attributes(:wants => false)
      if @contact.save!
        flash[:frontend_notice] = element.contents.find_by_name("mailing_signout_success").essence.body
      end
    rescue
      flash[:frontend_notice] = element.contents.find_by_name("mailing_signout_failure").essence.body
      log_error($!)
    end
  end
  
end
