class Admin::MailingsController < ApplicationController
  
  layout 'admin'
  
  def index
    if params[:query].blank?
      @mailings = Mailing.all
    else
      @mailings = Mailing.find(:all, :conditions => {:name => params[:query], :subject => params[:query]})
    end
  end
  
  def new
    @mailing = Mailing.new
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def create
    @mailing = Mailing.new(params[:mailing])
    if @mailing.save
      mailing_root = Page.find_by_name('Mailing Root')
      page = Page.new(
        :name => "Mailing #{params[:mailing][:name]}",
        :layoutpage => true,
        :sitemap => false,
        :page_layout => @mailing.newsletter.layout
      )
      if page.save
        page.move_to_child_of mailing_root
        @mailing.page = page
        @mailing.save
      end
    end
    render_errors_or_redirect(@mailing, admin_mailings_path, "Das Mailing wurde angelegt.")
  end
  
  def edit
    @mailing = Mailing.find(params[:id])
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def update
    @mailing = Mailing.find(params[:id])
    @mailing.update_attributes(params[:mailing])
    render_errors_or_redirect(@mailing, admin_mailings_path, "Das Mailing wurde gespeichert.")
  end
  
  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy
    flash[:notice] = 'Mailing wurde gelöscht'
    render :update do |page|
      page.redirect_to admin_mailings_path
      Alchemy::Notice.show_via_ajax(page, 'Das Mailing wurde gelöscht')
    end
  end
  
  def edit_content
    @mailing = Mailing.find(params[:id])
    @page = @mailing.page
  end
  
  def preview
    @page = Page.find(params[:id])
    @server = get_server.gsub(/http:\/\//, '')
    render :layout => 'mailings'
  end
  
  def deliver
    a = Time.now
    @mailing = Mailing.find(params[:id])
    if request.post? && params[:confirm_to_send] == "send"
      mailing_elements = @mailing.page.elements
      sent_mailing = SentMailing.create(:name => @mailing.name, :mailing => @mailing)
      additional_email_addresses = @mailing.all_additional_email_addresses.collect{|u| Contact.new(:email => u)}
      all_contacts = @mailing.all_contacts + additional_email_addresses
      all_contacts.each do |contact|
        recipient             = Recipient.create(:email => contact.email, :contact => contact, :sent_mailing => sent_mailing)
        mail                  = MailingsMailer.create_my_mail(@mailing, mailing_elements, contact, recipient, :mail_from => plugin_conf("mailings")[:mail_from], :server => get_server.gsub(/http:\/\//, ''))
        send_mail             = MailingsMailer.deliver(mail)
        recipient.message_id  = send_mail.message_id
        recipient.save!
      end
      sent_mailing.save!
      a = Time.now - a
      logger.info("§§§ rendered mailing in #{a} s")
      flash[:notice] = "Das Mailing wird nun versendet"
      redirect_to :action => 'index'
    else
      render :layout => false
    end
  end
  
end
