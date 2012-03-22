# encoding: UTF-8
module AlchemyCrm
	module Admin
		class ContactGroupsController < Alchemy::Admin::ResourcesController

			before_filter :load_additional_data, :only => [:new, :edit]
			helper "AlchemyCrm::Admin::Base"

			def add_filter
				@contact_group = ContactGroup.find(params[:contact_group_id])
				@filter = @contact_group.filters.build
				@count = @contact_group.filters.length - 1
			end

		private

			def load_additional_data
				@contacts = Contact.all
				@tags = ActsAsTaggableOn::Tag.order("name ASC").all
			end

		end
	end
end
