# encoding: UTF-8
module AlchemyCrm
	module Admin
		class MailingsController < Alchemy::Admin::ResourcesController

			before_filter :load_newsletters, :only => [:new, :edit, :copy]

			helper 'Alchemy::Pages'

			def copy
				@mailing = Mailing.copy(params[:id])
				render :action => :new, :layout => false
			end

			def show
				@page = Alchemy::Page.find(params[:page_id])
				@mailing = Mailing.find(params[:id])
				@host = current_server
				@server = @host.gsub(/http:\/\//, '')
				@preview_mode = true
				render :layout => 'newsletters'
			end

			def edit_content
				@mailing = Mailing.find(params[:id])
				@page = @mailing.page
			end

		private

			def load_newsletters
				@newsletters = Newsletter.all
			end

		end
	end
end
