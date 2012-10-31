# encoding: UTF-8
module AlchemyCrm
  class ContactGroup < ActiveRecord::Base

    acts_as_taggable_on :contact_tags

    has_and_belongs_to_many :newsletters, :join_table => 'alchemy_crm_contact_groups_newsletters'
    has_and_belongs_to_many :contacts, :join_table => 'alchemy_crm_contacts_contact_groups'
    has_many :filters, :dependent => :destroy, :class_name => "AlchemyCrm::ContactGroupFilter"
    has_many :subscriptions

    validates_presence_of :name

    accepts_nested_attributes_for :filters, :allow_destroy => true

    after_save :update_contacts_join_table, :update_contacts_count, :update_subscriptions

    scope :with_matching_filters, lambda { |attributes|
      attributes_filters = []
      attributes.delete_if { |k, v| !Contact::FILTERABLE_ATTRIBUTES.include?(k) }.each do |k, v|
        attributes_filters << ContactGroupFilter.operator_where_string(k, v)
      end
      joins(:filters).where(["#{attributes_filters.join(' OR ')} AND 1=?", 1])
    }

    def filters_sql_string
      return "" if filters.blank?
      "(#{filters.map(&:sql_string).join(' AND ')})"
    end

    def humanized_name
      "#{self.name} (#{self.contacts_count})"
    end

    def subscribe_contacts_to_newsletter(newsletter)
      contacts = self.contacts.not_subscribed_to(newsletter)
      contacts = contacts.select("DISTINCT alchemy_crm_contacts.id")
      subscriber_ids = self.class.connection.select_values(contacts.to_sql)

      Subscription.mass_create(newsletter.id, subscriber_ids, self.id)
    end

    def update_contacts_count
      update_column(:contacts_count, contacts.count)
    end

  private

    # Returns IDs from contacts in this contact group. Speedily. :)
    def speedy_contact_ids
      self.class.connection.select_values("SELECT contact_id FROM alchemy_crm_contacts_contact_groups WHERE contact_group_id = #{id}")
    end

    # Returns all unique contact ids from taggings and filters.
    def uniq_contact_ids_from_taggings_and_filters
      (contact_ids_from_tags + contact_ids_from_filters).uniq
    end

    # Returns returns all ids from contacts that are tag with a tag from contact_tag_list.
    def contact_ids_from_tags
      contacts_from_tags = Contact.available.joins(:taggings => :tag).where(:tags => {:name => contact_tag_list})
      contacts_from_tags = contacts_from_tags.select("DISTINCT alchemy_crm_contacts.id")
      self.class.connection.select_values(contacts_from_tags.to_sql)
    end

    # Returns all ids from contacts that are matched by a filter.
    def contact_ids_from_filters
      if filters_sql_string.present?
        contacts_from_filters = Contact.available.where(filters_sql_string)
        contacts_from_filters = contacts_from_filters.select("DISTINCT alchemy_crm_contacts.id")
        self.class.connection.select_values(contacts_from_filters.to_sql)
      else
        []
      end
    end

    # Delete all records that are not valid any more and insert new ones.
    def update_contacts_join_table
      delete_unused_contacts
      create_new_contacts
    end

    # Delete all records that we don't need any more from the contacts join table
    def delete_unused_contacts
      contact_ids_diff = speedy_contact_ids - uniq_contact_ids_from_taggings_and_filters
      if contact_ids_diff.present?
        query = "DELETE FROM alchemy_crm_contacts_contact_groups WHERE contact_group_id = #{self.id} AND contact_id IN (#{contact_ids_diff.join(', ')})"
        self.connection.execute(query)
      end
    end

    # Insert new records in the contacts join table
    def create_new_contacts
      contact_ids_diff = uniq_contact_ids_from_taggings_and_filters - speedy_contact_ids
      if contact_ids_diff.present?
        values = contact_ids_diff.map { |contact_id| "(#{contact_id}, #{self.id})" }
        query = "INSERT INTO alchemy_crm_contacts_contact_groups VALUES #{values.join(', ')}"
        self.connection.execute(query)
      end
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
        return true
      end
      subscriptions = self.subscriptions.where("alchemy_crm_subscriptions.contact_id NOT IN(#{speedy_contact_ids.join(',')})")
      subscription_ids = self.class.connection.select_values(subscriptions.select("alchemy_crm_subscriptions.id").to_sql)
      if subscription_ids.present?
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
