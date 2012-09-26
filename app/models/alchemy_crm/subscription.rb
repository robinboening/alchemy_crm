module AlchemyCrm
  class Subscription < ActiveRecord::Base

    belongs_to :contact
    belongs_to :newsletter
    belongs_to :contact_group

    validates_presence_of :newsletter_id

    after_create :increment_newsletters_subscription_counter_caches, :if => proc {|s| s.newsletter.present? }
    after_destroy :decrement_newsletters_subscription_counter_caches, :if => proc {|s| s.newsletter.present? }

    scope :not_with_contact_group, lambda { |contact_group_ids|
      where("#{self.table_name}.contact_group_id NOT IN(#{contact_group_ids.join(',')})")
    }

    def self.mass_create(newsletter_id, contact_ids, contact_group_id)
      sql_values = []
      contact_ids.each do |contact_id|
        sql_values << ["(#{contact_id}, #{newsletter_id}, #{contact_group_id})"]
      end
      if sql_values.any?
        ActiveRecord::Base.connection.execute(
          "INSERT INTO #{self.table_name} (contact_id, newsletter_id, contact_group_id) VALUES #{sql_values.join(", ")}"
        )
      end
    end

  private

    def increment_newsletters_subscription_counter_caches
      update_newsletters_subscription_counter_caches(+1)
    end

    def decrement_newsletters_subscription_counter_caches
      update_newsletters_subscription_counter_caches(-1)
    end

    def update_newsletters_subscription_counter_caches(value)
      if contact_group_id.blank?
        newsletter.update_column(:user_subscriptions_count, newsletter.user_subscriptions_count + value)
      else
        newsletter.update_column(:contact_group_subscriptions_count, newsletter.contact_group_subscriptions_count + value)
      end
      newsletter.update_column(:subscriptions_count, newsletter.subscriptions_count + value)
    end

  end
end
