module AlchemyCrm
  class Subscription < ActiveRecord::Base

    belongs_to :contact
    belongs_to :newsletter
    belongs_to :contact_group

    scope :not_with_contact_group, lambda { |contact_group_ids|
      where("#{self.table_name}.contact_group_id NOT IN(#{contact_group_ids.join(',')})")
    }

    def self.mass_create(newsletter, contacts, contact_group_id)
      sql_values = []
      contacts.each do |contact|
        sql_values << ["(#{contact.id}, #{newsletter.id}, #{contact_group_id})"]
      end
      if sql_values.any?
        ActiveRecord::Base.connection.execute(
          "INSERT INTO #{self.table_name} (contact_id, newsletter_id, contact_group_id) VALUES #{sql_values.join(", ")}"
        )
      end
    end

  end
end
