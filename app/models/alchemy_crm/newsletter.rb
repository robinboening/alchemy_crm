# encoding: UTF-8
module AlchemyCrm
  class Newsletter < ActiveRecord::Base

    has_and_belongs_to_many :contact_groups, :join_table => 'alchemy_crm_contact_groups_newsletters'
    has_many :mailings
    has_many :subscriptions, :dependent => :destroy
    has_many :subscribers, :through => :subscriptions, :uniq => true, :source => :contact

    validates_presence_of :name
    validates_presence_of :layout

    before_destroy :can_delete_mailings?
    after_save :update_subscriptions

    scope :subscribables, where(:public => true)

    def humanized_name
      "#{name} (#{subscriptions_count})"
    end

    def verified_subscribers
      subscribers.available.joins(:subscriptions).where(:alchemy_crm_subscriptions => {:wants => true})
    end
    alias_method :contacts, :verified_subscribers

    def can_delete_mailings?
      raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
    end

    def layout_name
      NewsletterLayout.display_name_for(layout)
    end

    # Updates all subscription counter caches
    def update_subscriptions_counter_cache_columns
      update_column(:subscriptions_count, calculate_subscriptions_count)
      update_column(:user_subscriptions_count, calculate_user_subscriptions_count)
      update_column(:contact_group_subscriptions_count, calculate_contact_group_subscriptions_count)
    end

  private

    def update_subscriptions
      destroy_unused_subscriptions
      create_new_subscriptions
      update_subscriptions_counter_cache_columns
    end

    # Creates subscriptions for all contacts of associated contact_groups
    def create_new_subscriptions
      contact_groups.each do |contact_group|
        contact_group.subscribe_contacts_to_newsletter(self)
      end
    end

    # Destroys subscription of contacts belonging to contact_groups not associated to the newsletter
    def destroy_unused_subscriptions
      if contact_groups.empty?
        self.class.connection.execute(
          "DELETE FROM alchemy_crm_subscriptions WHERE newsletter_id = '#{self.id}' AND contact_group_id IS NOT NULL"
        )
      else
        self.class.connection.execute(
          "DELETE FROM alchemy_crm_subscriptions WHERE newsletter_id = '#{self.id}' AND (contact_group_id NOT IN(#{contact_groups.collect(&:id).join(',')}))"
        )
      end
    end

    # Recalculates counter cache for all subscriptions
    def calculate_subscriptions_count
      verified_subscribers.select("alchemy_crm_contacts.id").count(:distinct => true)
    end

    # Recalculates counter cache for subscriptions created by user
    def calculate_user_subscriptions_count
      subscriptions.select("alchemy_crm_subscriptions.id").where(:alchemy_crm_subscriptions => {:contact_group_id => nil}).count(:distinct => true)
    end

    # Recalculates counter cache for subscriptions associated with contact_group
    def calculate_contact_group_subscriptions_count
      subscriptions.select("alchemy_crm_subscriptions.id").where("alchemy_crm_subscriptions.contact_group_id IS NOT NULL").count(:distinct => true)
    end

  end
end
