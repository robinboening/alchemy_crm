class ContactsController < AlchemyMailingsController
  
  layout "pages"
  
  def signup
    @page = Page.find_by_layout("mailing_anmelden")
    @formats = Newsletter.find_all_by_public(true)
    element = @page.elements.find_by_name("mailing_signup")
    if request.post?
      
      params[:contact][:verified] = false
      @contact = Contact.find_or_create(params[:contact])
      @contact.update_attributes(params[:contact])
      
      session[:contact] = params[:contact]
      
      if @contact.valid?
        MailingsMailer.deliver_verification_mail(@contact, current_server.gsub(/http:\/\//, ""), element, params[:contact][:newsletter_ids])
        flash[:mailing_notice] = element.contents.find_by_name("email_success_text").essence.body
        session[:contact] = nil
      end
    else
      @contact = Contact.new
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
  
  def verify
    @page = Page.find_by_layout("Mailing_anmelden")
    element = @page.elements.find_by_name("mailing_signup")
    @verification = true
    unless params[:sha1].blank?
      @contact = Contact.find_by_email_sha1(params[:sha1])
      subscriptions = @contact.newsletter_subscriptions.find_all_by_newsletter_id(params[:newsletter_ids])
      subscriptions.each do |s|
        s.update_attributes(:verified => true, :wants => true)
      end
      @contact.save
      flash[:mailing_notice] = element.contents.find_by_name("verification_success").essence.body
    end
  end
  
end
