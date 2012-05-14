# encoding: UTF-8
module AlchemyCrm
  module Admin
    class DeliveriesController < AlchemyCrm::Admin::BaseController

      before_filter :load_mailing, :only => [:index, :new]

      def index
        @deliveries = @mailing.deliveries.order('deliver_at DESC')
        render :layout => false
      end

      def new
        @delivery = Delivery.new(
          :deliver_at => Time.now + 1.hour,
          :mailing => @mailing
        )
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

      def create
        @delivery = Delivery.new(params[:delivery])
        @mailing = @delivery.mailing = Mailing.find(params[:delivery][:mailing_id])
        if @delivery.save
          @delivery.send_chunks(
            :language_id => session[:language_id],
            :protocol => request.protocol,
            :host => request.host,
            :port => request.port,
            :locale => ::I18n.locale
          )
          flash[:notice] = alchemy_crm_t(:successfully_scheduled_mailing)
        end
        redirect_to admin_mailings_path
      end

      def edit
        @delivery = Delivery.find(params[:id])
        @mailing = @delivery.mailing
        render :layout => false
      end

      def update
        @delivery = Delivery.find(params[:id])
        @delivery.update_attributes(params[:delivery])
        render_errors_or_redirect(
          @delivery,
          admin_mailings_path,
          alchemy_crm_t(:successfully_rescheduled_mailing)
        )
      end

      def destroy
        @delivery = Delivery.find(params[:id])
        @delivery.destroy
        render :js => "window.location.replace('#{admin_mailings_path}'); Alchemy.growl('#{successfully_canceled_delivery}')"
      end

    private

      def load_mailing
        @mailing = Mailing.find(params[:mailing_id])
      end

    end
  end
end
