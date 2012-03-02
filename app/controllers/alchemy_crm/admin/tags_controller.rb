# encoding: UTF-8
module AlchemyCrm
	module Admin
		class TagsController < Alchemy::Admin::ResourcesController

			before_filter :load_tag, :only => [:edit, :update, :destroy]
			helper "AlchemyCrm::Base"

			def index
				@tags = ActsAsTaggableOn::Tag.where(
					"name LIKE '%#{params[:query]}%'"
				).page(params[:page] || 1).per(per_page_value_for_screen_size).order("name ASC")
			end

			def new
				@tag = ActsAsTaggableOn::Tag.new
				render :layout => false
			end

			def create
				@tag = ActsAsTaggableOn::Tag.create(params[:tag])
				render_errors_or_redirect @tag, admin_tags_path, t('New Tag Created', :scope => 'alchemy_crm')
			end

			def edit
				@tags = ActsAsTaggableOn::Tag.order("name ASC").all - [@tag]
				render :layout => false
			end

			def update
				if params[:replace]
					@new_tag = ActsAsTaggableOn::Tag.find(params[:tag][:merge_to])
					Contact.replace_tag @tag, @new_tag
					operation_text = "Das Tag '#{@tag.name}' wurde durch das Tag '#{@new_tag.name}' ersetzt"
					@tag.destroy
				else
					@tag.update_attributes(params[:tag])
					@tag.save
					operation_text = "Das Tag wurde gespeichert"
				end
				render_errors_or_redirect @tag, admin_tags_path, operation_text
			end

			def destroy
				if request.delete?
					@tag.destroy
					flash[:notice] = "Das Tag wurde gelöscht"
				end
				redirect_to admin_tags_path
			end

		private

			def load_tag
				@tag = ActsAsTaggableOn::Tag.find(params[:id])
			end

		end
	end
end
