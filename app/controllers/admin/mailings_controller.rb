# encoding: UTF-8

class Admin::MailingsController < AlchemyMailingsController
  
  filter_access_to :all
  
  def index
		@mailings = Mailing.paginate(:all, :page => params[:page] || 1, :per_page => 30, :conditions => "mailings.name LIKE '%#{params[:query]}%' OR mailings.subject LIKE '%#{params[:query]}%'")
  end
  
  def new
    @mailing = Mailing.new
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def create
    @mailing = Mailing.create(params[:mailing])
    render_errors_or_redirect(@mailing, admin_mailings_path, "Das Mailing wurde angelegt.")
	rescue Exception => e
		exception_handler(e)
  end
  
  def copy
    @mailing = Mailing.copy(params[:id])
    @newsletters = Newsletter.all
    render :action => :new, :layout => false
  end
  
  def show
    @page = Page.find(params[:page_id])
    @mailing = Mailing.find(params[:id])
    @host = current_server
    @server = @host.gsub(/http:\/\//, '')
    @preview_mode = true
    render :layout => 'newsletters'
  end
  
  def edit
    @mailing = Mailing.find(params[:id])
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def update
    @mailing = Mailing.find(params[:id])
    @mailing.update_attributes(params[:mailing])
    render_errors_or_redirect(@mailing, :back, "Das Mailing wurde gespeichert.")
  end
  
  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy
    flash[:notice] = 'Mailing wurde gelöscht'
    render :update do |page|
      page.redirect_to admin_mailings_path
      Alchemy::Notice.show(page, 'Das Mailing wurde gelöscht')
    end
  end
  
  def edit_content
    @mailing = Mailing.find(params[:id])
    @page = @mailing.page
  end
  
  def deliver
    a = Time.now
    @mailing = Mailing.find(params[:id])
    if request.post?
      mailing_elements = @mailing.page.elements
      sent_mailing = SentMailing.create(:name => @mailing.name, :mailing => @mailing)
      additional_email_addresses = @mailing.all_additional_email_addresses.collect{|u| Contact.new(:email => u)}
      all_contacts = @mailing.all_contacts + additional_email_addresses
      all_contacts.each do |contact|
        recipient             = Recipient.create(:email => contact.email, :contact => contact, :sent_mailing => sent_mailing)
        mail                  = MailingsMailer.create_my_mail(@mailing, mailing_elements, contact, recipient, :mail_from => plugin_conf("alchemy-mailings")[:mail_from], :server => current_server)
        send_mail             = MailingsMailer.deliver(mail)
        recipient.message_id  = send_mail.message_id
        recipient.save
      end
      sent_mailing.save
      a = Time.now - a
      logger.info("§§§ rendered mailing in #{a} s")
      flash[:notice] = "Das Mailing wurde versendet"
      redirect_to :action => 'index'
    else
      render :layout => false
    end
  end
  
end
