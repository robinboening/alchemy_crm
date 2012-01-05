# encoding: UTF-8
module AlchemyCrm
	class Newsletter < ActiveRecord::Base

		has_and_belongs_to_many :contact_groups, :join_table => 'alchemy_contact_groups_newsletters'
		has_many :mailings
		has_many :subscriptions
		has_many :contacts, :through => :subscriptions, :uniq => true

		validates_presence_of :name, :message => "Bitte geben Sie einen Namen an."

		before_destroy :can_delete_mailings?

		scope :subscribables, where(:public => true)

		def all_contacts
			(all_contact_group_contacts + verified_direct_contacts).uniq
		end

		def contacts_count
			self.contacts.count + contact_groups.inject(0){ |sum, cg| sum += cg.contacts.count }
		end

		# get all uniq contacts from my contact groups
		def all_contact_group_contacts
			self.contact_groups.inject([]){|contacts, contact_group| contacts + contact_group.contacts}.uniq
		end

		def humanized_name
			"#{self.name} (#{self.contacts_count})"
		end

		def verified_direct_contacts
			subscriptions.where(:verified => true, :wants => true)
		end

		def can_delete_mailings?
			raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
		end

		def layout_name
			AlchemyCrm::NewsletterLayout.display_name_for(self.layout)
		end

	end
end
