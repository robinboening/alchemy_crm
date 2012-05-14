# encoding: UTF-8
module AlchemyCrm
  module Admin
    class TagsController < Alchemy::Admin::BaseController

      include I18nHelpers
      helper 'AlchemyCrm::Admin::Base'

      before_filter :load_tag, :only => [:edit, :update, :destroy]

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
        render_errors_or_redirect @tag, admin_tags_path, alchemy_crm_t('New Tag Created')
      end

      def edit
        @tags = ActsAsTaggableOn::Tag.order("name ASC").all - [@tag]
        render :layout => false
      end

      def update
        if params[:replace]
          @new_tag = ActsAsTaggableOn::Tag.find(params[:tag][:merge_to])
          Contact.replace_tag @tag, @new_tag
          operation_text = alchemy_crm_t('Replaced Tag %{old_tag} with %{new_tag}') % {:old_tag => @tag.name, :new_tag => @new_tag.name}
          @tag.destroy
        else
          @tag.update_attributes(params[:tag])
          @tag.save
          operation_text = alchemy_crm_t(:successfully_updated_tag)
        end
        render_errors_or_redirect @tag, admin_tags_path, operation_text
      end

      def destroy
        if request.delete?
          @tag.destroy
          flash[:notice] = alchemy_crm_t(:successfully_deleted_tag)
        end
        @redirect_url = admin_tags_path
        render :action => :redirect
      end

    private

      def load_tag
        @tag = ActsAsTaggableOn::Tag.find(params[:id])
      end

    end
  end
end
