# encoding: UTF-8
module AlchemyCrm
  class ContactGroup < ActiveRecord::Base

    acts_as_taggable_on :contact_tags

    has_and_belongs_to_many :newsletters, :join_table => 'alchemy_contact_groups_newsletters'
    has_many :filters, :dependent => :destroy, :class_name => "AlchemyCrm::ContactGroupFilter"

    validates_presence_of :name

    accepts_nested_attributes_for :filters, :allow_destroy => true

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
      Contact.available.joins(:taggings).where(:taggings => {:tag_id => self.contact_tags.collect(&:id)}).where(filters_sql_string)
    end

    def contacts_count
      contacts.uniq.count
    end

    def filters_sql_string
      return "" if filters.blank?
      "(#{filters.map(&:sql_string).join(' AND ')})"
    end

    def humanized_name
      "#{self.name} (#{self.contacts.length})"
    end

    def subscribe_contacts_to_newsletter(newsletter)
      Subscription.mass_create(newsletter, contacts.not_subscribed_to(newsletter).uniq, self.id)
    end

  end
end
