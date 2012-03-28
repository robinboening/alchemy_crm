# encoding: UTF-8
module AlchemyCrm
	class ContactGroup < ActiveRecord::Base

		acts_as_taggable_on :contact_tags

		has_many :filters, :dependent => :destroy, :class_name => "AlchemyCrm::ContactGroupFilter"

		validates_presence_of :name

		accepts_nested_attributes_for :filters, :allow_destroy => true

		def contacts
			Contact.tagged_with(self.contact_tags, :any => true).where(filters_sql_string)
		end

		def filters_sql_string
			filters.map(&:sql_string).join(' AND ')
		end

		def humanized_name
			"#{self.name} (#{self.contacts.length})"
		end

	end
end
