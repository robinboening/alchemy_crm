# encoding: UTF-8
module AlchemyCrm
	module Admin
		class ContactGroupsController < Alchemy::Admin::ResourcesController

			before_filter :load_additional_data, :only => [:new, :edit]

			def add_filter
				@filter = ContactGroupFilter.new
				@count = params[:size]
			end

		private

			def load_additional_data
				@contacts = Contact.all
				@tags = ActsAsTaggableOn::Tag.order("name ASC").all
			end

		end
	end
end
