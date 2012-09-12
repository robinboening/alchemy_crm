# encoding: UTF-8
module AlchemyCrm
  class ContactGroup < ActiveRecord::Base

    acts_as_taggable_on :contact_tags

    has_and_belongs_to_many :newsletters, :join_table => 'alchemy_contact_groups_newsletters'
    has_many :filters, :dependent => :destroy, :class_name => "AlchemyCrm::ContactGroupFilter"

    validates_presence_of :name

    accepts_nested_attributes_for :filters, :allow_destroy => true

    after_save :calculate_contacts_count, :update_subscriptions

    scope :with_matching_filters, lambda { |attributes|
      attributes_filters = []
      attributes.delete_if { |k, v| !Contact::FILTERABLE_ATTRIBUTES.include?(k) }.each do |k, v|
        attributes_filters << ContactGroupFilter.operator_where_string(k, v)
      end
      joins(:filters).where(["#{attributes_filters.join(' OR ')} AND 1=?", 1])
    }

    # Returns all non unique contacts.
    #
    # Not using acts_as_taggable_on #tagged_with method because of the DISTINCT usage inthe query that is very slow.
    # This is 100x faster.
    #
    # CAUTION: Can contain duplicates. Always use it with #uniq
    def contacts
      @contacts ||= Contact.available.joins(:taggings).where(:taggings => {:tag_id => self.contact_tags.collect(&:id)}).where(filters_sql_string)
    end

    def contact_ids
      @contact_ids ||= contacts.select("alchemy_crm_contacts.id").uniq.collect(&:id)
    end

    def filters_sql_string
      return "" if filters.blank?
      "(#{filters.map(&:sql_string).join(' AND ')})"
    end

    def humanized_name
      "#{self.name} (#{self.contacts_count})"
    end

    def subscribe_contacts_to_newsletter(newsletter)
      Subscription.mass_create(newsletter, contacts.not_subscribed_to(newsletter).select("alchemy_crm_contacts.id").uniq, self.id)
    end

  private

    def calculate_contacts_count
      update_column(:contacts_count, contacts.select("alchemy_crm_contacts.id").count(:distinct => true))
    end

    def update_subscriptions
      destroy_unused_subscriptions
      create_new_subscriptions
      update_newsletters_subscriptions_counter_cache_columns
    end

    def destroy_unused_subscriptions
      if contacts_count == 0
        self.class.connection.execute(
          "DELETE FROM alchemy_crm_subscriptions WHERE contact_group_id = '#{self.id}'"
        )
        return
      end
      subscriptions = Subscription.where(:contact_group_id => self.id)
      subscriptions = subscriptions.where("alchemy_crm_subscriptions.contact_id NOT IN(#{contact_ids.join(',')})")
      subscription_ids = subscriptions.select("alchemy_crm_subscriptions.id").all.collect(&:id)
      if subscription_ids.any?
        self.class.connection.execute(
          "DELETE FROM alchemy_crm_subscriptions WHERE id IN(#{subscription_ids.join(',')})"
        )
      end
    end

    def create_new_subscriptions
      return if contacts_count == 0
      newsletters.select(:id).each do |newsletter|
        subscribe_contacts_to_newsletter(newsletter)
      end
    end

    def update_newsletters_subscriptions_counter_cache_columns
      newsletters.each do |newsletter|
        newsletter.update_subscriptions_counter_cache_columns
      end
    end

  end
end
