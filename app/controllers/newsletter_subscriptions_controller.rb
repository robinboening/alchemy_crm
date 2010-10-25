class NewsletterSubscriptionsController < AlchemyMailingsController
  
  def destroy
    begin
      @element = Element.find(params[:element_id])
      @contact = Contact.find_by_email_sha1(params[:sha1])
      @newsletter = Newsletter.find(params[:newsletter_id])
      @subscription = NewsletterSubscription.find_by_contact_id_and_newsletter_id(@contact.id, @newsletter.id)
      @subscription.destroy
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