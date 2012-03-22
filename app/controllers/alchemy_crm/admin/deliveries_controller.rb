# encoding: UTF-8
module AlchemyCrm
	module Admin
		class DeliveriesController < Alchemy::Admin::BaseController

			SEND_DELAY = Time.now + 1.hour
			before_filter :load_mailing, :only => [:index, :new]

			def index
				@deliveries = @mailing.deliveries.order('deliver_at DESC')
				render :layout => false
			end

			def new
				@delivery = Delivery.new(
					:deliver_at => SEND_DELAY,
					:mailing => @mailing
				)
				render :layout => false
			end

			def create
				@delivery = Delivery.new(params[:delivery])
				@mailing = @delivery.mailing = Mailing.find(params[:delivery][:mailing_id])
				if @delivery.save
					@delivery.send_chunks(
						:language_id => session[:language_id],
						:protocol => request.protocol,
						:host => request.host_with_port
					)
					flash[:notice] = "Das Mailing wurde für den Versand vorbereitet."
				end
				redirect_to admin_mailings_path
			end

			def edit
				@delivery = Delivery.find(params[:id])
				@mailing = @delivery.mailing
				render :layout => false
			end

			def show
				begin
					@delivery = Delivery.find(params[:id])
					@recipients = @delivery.recipients
					@read = @delivery.recipients.select{|r| r.read}
					@reacted = @delivery.recipients.select{|r| r.reacted}
					@bounced = @delivery.recipients.select{|r| r.bounced}
				rescue
					log_error($!)
				end
				render :layout => false
			end

		private

			def load_mailing
				@mailing = Mailing.find(params[:mailing_id])
			end

		end
	end
end
