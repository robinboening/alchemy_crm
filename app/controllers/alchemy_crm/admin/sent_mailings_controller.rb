# encoding: UTF-8
module AlchemyCrm
	module Admin
		class SentMailingsController < Alchemy::Admin::ResourcesController

			SEND_DELAY = Time.now + 1.hour
			before_filter :load_mailing, :only => [:index, :new]

			def index
				@sent_mailings = @mailing.sent_mailings.order('deliver_at DESC')
				render :layout => false
			end

			def new
				@sent_mailing = SentMailing.new(
					:deliver_at => SEND_DELAY,
					:mailing => @mailing
				)
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

		before_filter

			def load_mailing
				@mailing = Mailing.find(params[:mailing_id])
			end

		end
	end
end
