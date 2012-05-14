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

    # Returns all contacts found via newsletter.
    def newsletter_contacts
      return [] if newsletter.blank?
      newsletter.contacts
    end

    # Returns all contacts found via newsletter contacts and additional email addresses.
    def contacts
      (newsletter_contacts + contacts_from_additional_email_addresses).uniq
    end

    def contacts_count
      return 0 if contacts.blank?
      contacts.count
    end

    def contacts_not_having_email_yet
      return contacts if recipients.empty?
      contacts.select { |c| !recipients.collect(&:email).include?(c.email) }
    end

    # Returns a list of all email addresses for contacts that have not got any email yet.
    def emails
      contacts_not_having_email_yet.collect(&:email)
    end

    # Return a list of email addresses from additional_email_addresses field.
    def additional_emails
      return [] if additional_email_addresses.blank?
      additional_email_addresses.gsub(/\s/,'').split(',').uniq
    end

    # Returns a list of contacts found or initialized by email address from additional_email_addresses field.
    def contacts_from_additional_email_addresses
      additional_emails.collect{ |email| Contact.find_or_initialize_by_email(:email => email) }
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
