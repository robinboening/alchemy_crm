class MailingsController < AlchemyMailingsController
  
  def show
    begin
      @host = get_server
      @server = @host.gsub(/http:\/\//, '')
      @mailing = Mailing.find_by_id_and_sha1(params[:id], params[:nh])
      @page = @mailing.page
      @contact = Contact.find_by_id_and_email_sha1(params[:contact_id], params[:h]) rescue nil
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => "404"
    else
      render :layout => "mailings"
    end
  end
  
  def signout
    begin
      @page = Page.find_by_layout("mailing_abmelden")
      element = @page.elements.find_by_name("mailing_signout")
      if request.post?
        @contact = Contact.find_by_email(params[:contact][:email])
        unless @contact.blank?
          unless @contact.newsletters.empty?
            MailingsMailer.deliver_signout_mail(@contact, get_server.gsub(/http:\/\//, ""), element)
            flash[:frontend_notice] = element.contents.find_by_name("mail_delivered").essence.body
          else
            flash[:frontend_notice] = element.contents.find_by_name("mail_without_formats").essence.body
          end
        else
          flash[:frontend_notice] = element.contents.find_by_name("mail_not_found").essence.body
        end
      end
    rescue
      log_error($!)
    end
    render :layout => "pages"
  end
  
end
