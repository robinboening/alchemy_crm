# encoding: UTF-8
module AlchemyCrm
	module Admin
		class TagsController < Alchemy::Admin::ResourcesController

			def index
				@tags = ActsAsTaggableOn::Tag.where(
					"name LIKE '%#{params[:query]}%'"
				).paginate(
					:page => params[:page] || 1,
					:per_page => 20
				).order("name ASC")
			end

			def new
				@tag = ActsAsTaggableOn::Tag.new
				render :layout => false
			end

			def create
				@tag = ActsAsTaggableOn::Tag.create(params[:tag])
				render_errors_or_redirect @tag, admin_tags_path, _('New Tag Created')
			end

			def edit
				@tag = ActsAsTaggableOn::Tag.find(params[:id])
				@tags = ActsAsTaggableOn::Tag.order("name ASC").all - [@tag]
				render :layout => false
			end

			def update
				@tag = ActsAsTaggableOn::Tag.find(params[:id])
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
				@tag = ActsAsTaggableOn::Tag.find(params[:id])
				if request.delete?
					@tag.destroy
					flash[:notice] = "Das Tag wurde gelöscht"
				end
				redirect_to admin_tags_path
			end

		end
	end
end
