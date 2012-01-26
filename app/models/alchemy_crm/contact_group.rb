# encoding: UTF-8
module AlchemyCrm
	class ContactGroup < ActiveRecord::Base

		acts_as_taggable_on :contact_tags

		has_many :contact_group_filters, :dependent => :destroy 

		validates_presence_of :name, :message => "^Bitte geben Sie einen Namen an."

		accepts_nested_attributes_for :contact_group_filters, :allow_destroy => true

		def contacts
			Contact.tagged_with(self.contact_tags).where(sql_string_for_filters)
		end

		def sql_string_for_filters
			filters.map do |filter|
				filter.sql_string
			end.join(' AND ')
		end

		def humanized_name
			"#{self.name} (#{self.contacts.length})"
		end

		def filters
			contact_group_filters
		end

	end
end
