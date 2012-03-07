# encoding: UTF-8
module AlchemyCrm
	class Newsletter < ActiveRecord::Base

		has_and_belongs_to_many :contact_groups, :join_table => 'alchemy_contact_groups_newsletters'
		has_many :mailings
		has_many :subscriptions
		has_many :subscribers, :through => :subscriptions, :uniq => true, :source => :contact

		validates_presence_of :name, :message => "^Bitte geben Sie einen Namen an."
		validates_presence_of :layout, :message => "^Bitte wählen Sie einen Layout aus."

		before_destroy :can_delete_mailings?

		scope :subscribables, where(:public => true)

		def contacts
			(verified_contact_group_contacts + verified_subscribers).uniq
		end

		def contacts_count
			return 0 if contacts.blank?
			contacts.length
		end

		# get all uniq contacts from my contact groups
		def verified_contact_group_contacts
			contact_groups.collect { |contact_group| contact_group.contacts.available }.flatten.uniq
		end

		def humanized_name
			"#{self.name} (#{self.contacts_count})"
		end

		def verified_subscribers
			subscribers.available.includes(:subscriptions).where(:alchemy_crm_subscriptions => {:verified => true, :wants => true})
		end

		def can_delete_mailings?
			raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
		end

		def layout_name
			AlchemyCrm::NewsletterLayout.display_name_for(self.layout)
		end

	end
end
