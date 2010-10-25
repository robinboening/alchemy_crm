class MailingsController < AlchemyMailingsController
  
  def show
    begin
      @host = current_server
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
  
end
