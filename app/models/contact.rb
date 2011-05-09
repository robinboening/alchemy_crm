class Contact < ActiveRecord::Base
  
  require 'vpim/vcard'
  require 'digest/sha1'
  
  acts_as_taggable
  
  has_many :newsletter_subscriptions, :dependent => :destroy
  accepts_nested_attributes_for :newsletter_subscriptions, :allow_destroy => true
  
  has_many :newsletters, :through => :newsletter_subscriptions, :uniq => true
  
  validates_presence_of :email, :message => "Bitte geben Sie eine E-Mail Adresse an."
  validates_uniqueness_of :email, :message => "Diese E-Mail Adresse ist bereits eingetragen."
  validates_format_of :email, :with => /^([a-zA-Z0-9_+\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/, :message => "Die E-Mail Adresse ist nicht valide.", :if => Proc.new { |contact| contact.errors[:email].blank? }
	
	

  # def validate
  #   if self.newsletter_subscriptions.length < 1
  #     self.errors.add_to_base("Bitte wählen Sie zumindestens einen Newsletter aus.")
  #   end
  # end
  
  before_save :update_sha1
  
  COLUMN_NAMES = [
    ["Titel", "title"],
    ["Anrede", "salutation"],
    ["Vorname", "firstname"],
    ["Nachname", "lastname"],
    ["Adresse", "address"],
    ["Postleitzahl", "zip"],
    ["Stadt", "city"],
    ["Land", "country"],
    ["Firma", "organisation"]
  ]
  
  def update_sha1
    if(self.email_sha1.blank? || self.email != Contact.find(self.id).email)
      salt = self.email_salt || [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
      self.email_salt, self.email_sha1 = salt, Digest::SHA1.hexdigest(self.email + salt)
    end
  end

  def fullname_reversed
    fullname :flipped => true
  end
  
  def fullname(options = {})
    options = (default_options = { :flipped => false }.merge(options))
    options[:flipped] ? "#{self.lastname}, #{self.firstname}".squeeze(" ") : "#{self.firstname} #{self.lastname}".squeeze(" ")
  end

  def self.replace_tag(old_tag, new_tag)
    self.find_tagged_with(old_tag).each do |contact|
      contact.tags.delete(old_tag)
      contact.tags << new_tag
      contact.save
    end
  end
  
  def self.find_by_query(query, options, paginate)
    column_names = Contact.public_column_names
    search_string = (column_names.join(" LIKE '%#{query}%' OR ") + " LIKE '%#{query}%'")
    options[:conditions] = search_string
    if paginate
      self.paginate(:all, options)
    else
      options.delete(:page)
      options.delete(:per_page)
      self.find(:all, options)
    end
  end
  
  #TODO: Zu den selbstgewählten Mailingformaten müssten noch alle durch den Backend User gewählten Formate mit angezeigt werden, oder?
  def all_newsletters
    self.newsletters
  end
  
  def self.public_column_names
    Contact.column_names - ["created_at", "updated_at", "email_salt", "verified", "email_sha1", "id"]
  end
  
  def self.filterable_column_names
    COLUMN_NAMES
  end
  
  def self.find_or_create(data)
    if (contact = Contact.find_by_email(data[:email])).nil?
      contact = Contact.create(data)
    end
    contact
  end
  
  def all_subscriptions_verified?
    self.newsletter_subscriptions.inject(true){|acc, s| acc = s.verified? && acc; acc}
  end
  
  def self.new_from_vcard(vcard)
    for card in Vpim::Vcard.decode(vcard) do
      remapped_attributes = {
        :organisation => card.org.blank? ? nil : card.org.first,
        :lastname => card.name.blank? ? nil : card.name.family,
        :firstname => card.name.blank? ? nil : card.name.given,
        :salutation => card.name.blank? ? nil : card.name.prefix,
        :address => card.address.blank? ? nil : card.address.street,
        :city => card.address.blank? ? nil : card.address.locality,
        :country => card.address.blank? ? nil : card.address.country,
        :zip => card.address.blank? ? nil : card.address.postalcode,
        :email => card.email.to_s,
        :phone => card.telephone.location.include?("cell") ? nil : card.telephone.to_s,
        :mobile => card.telephones.detect { |t| t.location.include?("cell") }.to_s
      }
      self.create!(remapped_attributes)
    end
  end
  
  def to_vcard
    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.prefix = salutation unless salutation.blank?
        name.given = firstname unless firstname.blank?
        name.family = lastname unless lastname.blank?
      end
      maker.add_tel(phone) { |t| t.location = 'work' } unless phone.blank?
      maker.add_tel(mobile) { |t| t.location = 'cell' } unless mobile.blank?
      maker.add_email(email) { |e| e.location = 'work' } unless email.blank?
      maker.add_addr do |addr|
        addr.street = address
        addr.postalcode = zip
        addr.locality = city
        addr.country = country
      end
      maker.org = organisation
    end
    vcf = File.new(RAILS_ROOT + "/tmp/#{fullname}.vcf", "w")
    vcf.write(card.encode)
    vcf.close
  end
  
end
