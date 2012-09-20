# encoding: UTF-8
module AlchemyCrm
  class Mailing < ActiveRecord::Base

    MAILING_PAGE_LAYOUT_PREFIX = "newsletter_layout_"

    belongs_to :page, :dependent => :destroy, :class_name => 'Alchemy::Page'
    has_many :deliveries, :dependent => :destroy
    has_many :recipients, :through => :deliveries
    belongs_to :newsletter

    validates_presence_of :name
    validates_presence_of :newsletter_id, :on => :create

    before_create :set_sha1
    after_create :create_page

    # Returns an Array of all subscribers ids.
    #
    # Subscribers are contacts that subscribed the newsletter this mailing is for.
    #
    def subscriber_ids
      Subscription.where(:newsletter_id => self.newsletter_id).select(:contact_id).collect(&:contact_id)
    end

    # Returns all subscribers as ActiveRecord relation.
    #
    # Subscribers are contacts that subscribed the newsletter this mailing is for.
    #
    # === Arguments
    #
    # You can choose what columns should be selected from contacts table via the optional argument.
    # Default is 'alchemy_crm_contacts.id'.
    #
    def subscribers(column_selects = "alchemy_crm_contacts.id")
      Contact.scoped.where(:id => subscriber_ids).select(column_selects.to_s)
    end

    def newsletter_subscriptions_count
      newsletter.subscriptions_count
    end

    # Returns contact ids from all recipients.
    def recipients_contact_ids
      recipients.select(:contact_id).collect(&:contact_id)
    end

    # Returns all ids from subscribers that have not become a recipient yet.
    def pending_subscriber_ids
      subscriber_ids - recipients_contact_ids
    end

    # Returns a hash with email as key and contact id as value from all subscribers that have not become a recipient yet.
    #
    # === Example
    #
    #   {'jon@doe.com' => 2, 'jane@doe.com' => 3}
    #
    def pending_subscriber_ids_and_emails_hash
      hash = Hash.new
      pending_subscriber_ids.map { |id| hash[Contact.find(id).email] = id }
      hash
    end

    # Returns the count of subscribers that have not become a recipient yet.
    def pending_subscribers_count
      return newsletter_subscriptions_count if recipients.empty?
      return 0 if subscriber_ids.blank?
      pending_subscriber_ids.count
    end

    # Return a list of email addresses from additional_email_addresses field.
    def additional_emails
      return [] if additional_email_addresses.blank?
      additional_email_addresses.gsub(/\s/,'').split(',').uniq
    end

    def recipients_count
      return 0 if deliveries.empty?
      deliveries.select(:emails_sent).collect(&:emails_sent).inject(:+)
    end

    # Makes a copy of another mailing.
    def self.copy(id)
      source = self.find(id)
      new(source.attributes.merge(
        "name" => "#{source.name} (#{::I18n.t(:copy, :scope => :alchemy_crm, :default => 'Copy')})"
      ).except("id", "updated_at", "created_at", "sha1", "salt", "page_id"))
    end

    def next_pending_delivery
      deliveries.pending.first
    end

  private

    def create_page
      mailing_root = Alchemy::Page.find_by_name('Alchemy CRM Rootpage')
      raise "Alchemy CRM root page not found. Did you seed the database?" if mailing_root.blank?
      mailing_page = Alchemy::Page.new(
        :name => "Mailing #{name}",
        :sitemap => false,
        :page_layout => newsletter.layout,
        :language => Alchemy::Language.get_default,
        :parent_id => mailing_root.id
      )
      if mailing_page.save
        self.page = mailing_page
        save
      else
        raise "Error while creating mailing page: #{mailing_page.errors.full_messages.join(' ')}"
      end
    end

    def set_sha1
      self.salt = [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
      self.sha1 = Digest::SHA1.hexdigest(Time.now.to_i.to_s + salt)
    end

  end
end
