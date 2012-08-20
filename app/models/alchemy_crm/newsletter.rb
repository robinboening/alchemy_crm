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

    def humanized_name
      "#{name} (#{contacts_count})"
    end

    def verified_subscribers
      subscribers.available.includes(:subscriptions).where(:alchemy_crm_subscriptions => {:wants => true})
    end
    alias_method :contacts, :verified_subscribers

    def verified_subscribers_count
      verified_subscribers.count(:distinct => true)
    end
    alias_method :contacts_count, :verified_subscribers_count

    def can_delete_mailings?
      raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
    end

    def layout_name
      NewsletterLayout.display_name_for(layout)
    end

  end
end
