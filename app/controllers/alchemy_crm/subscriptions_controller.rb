module AlchemyCrm
	class SubscriptionsController < AlchemyCrm::BaseController

		before_filter :load_contact, :except => :deliver_subscriptions_overview

		def index
			@page = Alchemy::Page.find_by_page_layout('newsletter_views')
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show', :layout => layout_for_page
		end

		def new

		end

		def create
			
		end

		def edit

		end

		def update
			
		end

		def destroy
			@subscription = @contact.subscriptions.find(params[:subscription_id])
			@subscription.destroy
			flash[:notice] = t(:subscription_destroyed)
			@page = Alchemy::Page.find_by_page_layout('newsletter_views')
			@root_page = @page.get_language_root
			render :template => 'alchemy/pages/show', :layout => layout_for_page
		end

		def overview
			@contact = Contact.find_by_email(params[:email])
			if @contact
				SubscriptionsMailer.overview_mail.deliver(@contact, @element)
				flash[:notice] = t(:send_subscriptions_overview_via_email)
				redirect_to :index
			else
				flash[:error] = t(:no_subscriber_found)
				render :index
			end
		end
		
	private

		def load_contact
			@contact = Contact.find_by_email_sha1(params[:token])
		end

	end
end
