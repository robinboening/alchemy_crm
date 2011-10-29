class MailingsController < AlchemyMailingsController

  layout "newsletters"
  filter_access_to :show, :unless => lambda { |c| c.params[:id].blank? }

  def show
    @host = current_server
    @server = @host.gsub(/http:\/\//, '')
    @mailing = Mailing.find_by_sha1(params[:mailing_hash])
    if @mailing.nil? && !params[:id].blank?
      @mailing = Mailing.find(params[:id])
    end
    @page = @mailing.page
    @contact = Contact.find_by_email_sha1(params[:sha1]) rescue nil
  rescue
    render :file => "#{Rails.root.to_s}/public/422.html", :status => "422"
  end
  
end
