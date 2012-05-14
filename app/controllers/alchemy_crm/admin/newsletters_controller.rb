# encoding: UTF-8
module AlchemyCrm
  module Admin
    class NewslettersController < AlchemyCrm::Admin::BaseController

      before_filter :load_additional_data, :only => [:new, :edit]

      def update
        params[:newsletter][:contact_group_ids] ||= []
        @newsletter = Newsletter.find(params[:id])
        @newsletter.update_attributes(params[:newsletter])
        render_errors_or_redirect @newsletter, admin_newsletters_path, alchemy_crm_t(:successfully_updated_newsletter)
      end

    private

      def load_additional_data
        @page_layouts = AlchemyCrm::NewsletterLayout.get_layouts_for_select()
        @contact_groups = ContactGroup.order("name ASC").all
      end

    end
  end
end
