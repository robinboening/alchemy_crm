class MailingsController < AlchemyMailingsController
  
  def show
    begin
      @host = current_server
      @server = @host.gsub(/http:\/\//, '')
      @mailing = Mailing.find_by_sha1(params[:mailing_hash])
      @page = @mailing.page
      @contact = Contact.find_by_email_sha1(params[:sha1]) rescue nil
    rescue
      render :file => "#{Rails.root.to_s}/public/422.html", :status => "422"
    else
      render :layout => "mailings"
    end
  end
  
end
