class Admin::SentMailingsController < AlchemyMailingsController
  require "pdf/writer"
  require "pdfwriter_extensions"
  
  filter_access_to :all
  
  def index
    @mailing = Mailing.find_by_id(params[:mailing_id])
    @sent_mailings = @mailing.sent_mailings
  end
  
  def show
    begin
      @sent_mailing = SentMailing.find(params[:id])
      @recipients = @sent_mailing.recipients
      @read = @sent_mailing.recipients.select{|r| r.read}
      @reacted = @sent_mailing.recipients.select{|r| r.reacted}
      @bounced = @sent_mailing.recipients.select{|r| r.bounced}
    rescue
      log_error($!)
    end
    render :layout => false
  end
  
  def pdf
    sent_mailing = SentMailing.find(params[:id])
    send_file(sent_mailing.pdf_path)
  end
  
end
