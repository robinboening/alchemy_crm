# encoding: UTF-8

class Mailing < ActiveRecord::Base

  belongs_to :page, :dependent => :destroy
  has_many :sent_mailings
  belongs_to :newsletter
  validates_presence_of :name, :message => "Bitte geben Sie einen Namen an."
  validates_presence_of :newsletter_id, :message => "Bitte wählen Sie einen Newsletter aus.", :on => :create
  before_save :update_sha1

  after_create :create_page

  def update_sha1
    if(self.sha1.blank? || self.id.blank?)
      salt = self.salt || [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
      self.salt, self.sha1 = salt, Digest::SHA1.hexdigest(self.created_at.to_s + salt)
    end
  end
  
  def contacts_from_format
    self.newsletter.all_contacts rescue []
  end
  
  def all_contacts
    self.contacts_from_format.uniq
  end
  
  def recipients_count
    additional_email_addresses_count = self.all_additional_email_addresses.length
    return additional_email_addresses_count if self.newsletter.nil?
    self.newsletter.contacts_count + additional_email_addresses_count
  end
  
  def all_email_addresses
    self.all_contacts.collect{ |c| c.email } + self.all_additional_email_addresses
  end
  
  def all_additional_email_addresses
    self.additional_email_addresses.gsub(/ /,'').split(',') rescue []
  end
  
  def self.copy(id)
    source = self.find(id)
    clone = source.clone
    clone.name = "#{source.name} (Kopie)"
    clone
  end

private

	def create_page
		mailing_root = Page.find_by_name('Alchemy Mailings Rootpage')
		raise "Alchemy Mailings Rootpage not found. Did you seed the database?" if mailing_root.blank?
		mailing_page = Page.new(
		  :name => "Mailing #{self.name}",
		  :sitemap => false,
		  :page_layout => self.newsletter.layout,
			:language => Language.get_default
		)
		if mailing_page.save!
		  mailing_page.move_to_child_of mailing_root
		  self.page = mailing_page
		  save
		else
			raise "Error while creating Mailingpage: #{mailing_page.errors.full_messages}"
		end
	end

end
