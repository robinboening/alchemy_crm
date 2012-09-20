module AlchemyCrm
  class Recipient < ActiveRecord::Base

    belongs_to :delivery
    belongs_to :contact
    has_many :reactions

    validates_presence_of :email
    validates_format_of :email, :with => Authlogic::Regex.email, :if => proc { email.present? }

    before_create :set_sha1

    scope :pending, where(:message_id => nil)
    scope :finished, where("#{self.table_name}.message_id IS NOT NULL")

    # Initialize a new Recipient from given Contact
    #
    # The Recipient is marked as readonly so it cannot be saved in the database
    #
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

    # Returns the email adress the email should be delivered to.
    #
    # Uses the contact#mail_to if a contact is associated
    # Returns the value of email column if not.
    #
    def mail_to
      contact.nil? ? email : contact.mail_to
    end

    # This method is called if a user opens the email.
    #
    # Please use the +render_tracking_image+ helper in your newsletter views to have this working.
    #
    # It sets read to true and stores the date.
    #
    # === Note
    #
    # This only works if the user allows to load external images from emails.
    #
    def reads!
      update_attributes(:read => true, :read_at => Time.now)
    end

    # This method is called if a user clicks a link in the email.
    #
    # It sets reacted to true, stores the date and records the page id, element id and url of the link.
    #
    # Please use the +alchemy_crm.recipient_reacts_url+ helper in your newsletter views for links to have this working.
    #
    # === Example
    #
    #   alchemy_crm.recipient_reacts_url(:url => 'http://myhomepage.com/fancy_article', :page_id => [optional Page.id], :element_id => [optional Element.id])
    #
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

  private

    def self.generate_salt
      [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
    end

    def self.generate_sha1(salt)
      Digest::SHA1.hexdigest(Time.now.to_i.to_s + salt)
    end

    def set_sha1
      self.salt = self.class.generate_salt
      self.sha1 = self.class.generate_sha1(self.salt)
    end

  end
end
