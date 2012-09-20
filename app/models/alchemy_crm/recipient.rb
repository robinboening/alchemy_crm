module AlchemyCrm
  class Recipient < ActiveRecord::Base

    belongs_to :delivery
    belongs_to :contact
    has_many :reactions

    validates_presence_of :email
    validates_format_of :email, :with => Authlogic::Regex.email, :if => proc { email.present? }

    before_create :set_sha1

    scope :not_received_email, where(:message_id => nil)
    scope :got_email, where("alchemy_crm_recipients.message_id IS NOT NULL")

    def mail_to
      contact.nil? ? email : contact.mail_to
    end

    def reads!
      update_attributes(:read => true, :read_at => Time.now)
    end

    def reacts!(options={})
      update_attributes(
        :reacted => true,
        :reacted_at => Time.now
      )
      reactions.create(
        :element_id => options[:element_id],
        :page_id => options[:page_id],
        :url => options[:url]
      )
    end

    def self.new_from_contact(contact)
      raise "No contact given!" if contact.nil?
      recipient = new(:contact => contact, :email => contact.email, :sha1 => Digest::SHA1.hexdigest(Time.now.to_i.to_s))
      recipient.readonly!
      recipient
    end

    # Mass creates recipients in an much more efficient way then ActiveRecord does.
    #
    # The second argument has to be a hash with an email adress as key and a contact id (or nil, if no contact is associated) as value.
    #
    # === Example
    #
    #   Recipient.mass_create(1, {'jon@doe.com' => 1, 'jane@doe.com' => nil})
    #
    def self.mass_create(delivery_id, emails_n_contact_ids = {})
      sql_values = []
      emails_n_contact_ids.each do |email, contact_id|
        salt = self.generate_salt
        sql_values << ["('#{email}', #{delivery_id}, #{contact_id.nil? ? 'NULL' : contact_id}, NOW(), '#{self.generate_sha1(salt)}', '#{salt}')"]
      end
      if sql_values.any?
        ActiveRecord::Base.connection.execute(
          "INSERT INTO #{self.table_name} (email, delivery_id, contact_id, created_at, sha1, salt) VALUES #{sql_values.join(", ")}"
        )
      end
    end

  private

    def set_sha1
      self.salt = self.class.generate_salt
      self.sha1 = self.class.generate_sha1(self.salt)
    end

    def self.generate_salt
      [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
    end

    def self.generate_sha1(salt)
      Digest::SHA1.hexdigest(Time.now.to_i.to_s + salt)
    end

  end
end
