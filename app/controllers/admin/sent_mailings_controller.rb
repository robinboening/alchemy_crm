# encoding: UTF-8

class Admin::SentMailingsController < AlchemyMailingsController
  
  filter_access_to :all
  
	SEND_DELAY = Time.now + 1.hour
  
  def index
    @mailing = Mailing.find(params[:mailing_id])
    @sent_mailings = @mailing.sent_mailings.order('deliver_at DESC')
		render :layout => false
  end

  def new
		@mailing = Mailing.find(params[:mailing_id])
		@sent_mailing = SentMailing.new(
			:deliver_at => SEND_DELAY,
			:mailing => @mailing
		)
		@mailing = @sent_mailing.mailing
    render :layout => false
  end

	def create
		@sent_mailing = SentMailing.new(params[:sent_mailing])
		@mailing = @sent_mailing.mailing = Mailing.find(params[:sent_mailing][:mailing_id])
		if @sent_mailing.save
			@sent_mailing.deliver!(current_server)
			flash[:notice] = "Das Mailing wurde für den Versand vorbereitet."
		end
		redirect_to admin_mailings_path
	end

	def edit
		@sent_mailing = SentMailing.find(params[:id])
		@mailing = @sent_mailing.mailing
		render :layout => false
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
