# encoding: UTF-8
module AlchemyCrm
  class Newsletter < ActiveRecord::Base

    has_and_belongs_to_many :contact_groups, :join_table => 'alchemy_contact_groups_newsletters'
    has_many :mailings
    has_many :subscriptions
    has_many :subscribers, :through => :subscriptions, :uniq => true, :source => :contact

    validates_presence_of :name
    validates_presence_of :layout

    before_destroy :can_delete_mailings?

    scope :subscribables, where(:public => true)

    def contacts
      Contact.where("#{n.verified_contact_group_contacts.to_sql} UNION #{n.verified_subscribers.to_sql}")
    end

    # get all uniq contacts from my contact groups
    def verified_contact_group_contacts
      contacts = Contact.tagged_with(contact_groups.collect(&:contact_tags).flatten.uniq, :any => true)
      if contact_groups_filter_strings.present?
        contacts = contacts.where(contact_groups_filter_strings.join(" OR "))
      end
      contacts.available
    end

    def contact_groups_filter_strings
      contact_groups.collect(&:filters_sql_string).delete_if(&:blank?)
    end

    def humanized_name
      "#{name} (#{contacts_count})"
    end

    def verified_subscribers
      subscribers.available.includes(:subscriptions).where(:alchemy_crm_subscriptions => {:verified => true, :wants => true})
    end

    def can_delete_mailings?
      raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
    end

    def layout_name
      NewsletterLayout.display_name_for(layout)
    end

  end
end
