# encoding: UTF-8

module AlchemyCrm
  class Contact < ActiveRecord::Base

    acts_as_taggable

    attr_accessible(
      :salutation,
      :title,
      :firstname,
      :lastname,
      :email,
      :phone,
      :mobile,
      :address,
      :zip,
      :city,
      :company,
      :country,
      :subscriptions_attributes
    )

    attr_accessible(
      :salutation,
      :title,
      :firstname,
      :lastname,
      :email,
      :phone,
      :mobile,
      :address,
      :zip,
      :city,
      :company,
      :country,
      :subscriptions_attributes,
      :verified,
      :disabled,
      :tag_list,
      :as => :admin
    )

    has_many :subscriptions, :dependent => :destroy
    has_many :newsletters, :through => :subscriptions, :uniq => true
    has_many :recipients

    attr_accessor :skip_validation

    accepts_nested_attributes_for :subscriptions, :allow_destroy => true

    validates_presence_of :salutation, :unless => proc { skip_validation }
    validates_presence_of :firstname, :unless => proc { skip_validation }
    validates_presence_of :lastname
    validates_presence_of :email
    validates_uniqueness_of :email
    validates_format_of :email, :with => ::Authlogic::Regex.email, :if => proc { errors[:email].blank? }

    before_save :update_sha1, :if => proc { email_sha1.blank? || email_changed? }

    scope :verified, where(:verified => true)
    scope :disabled, where(:disabled => true)
    scope :enabled, where(:disabled => false)
    scope :available, verified.enabled

    COLUMN_NAMES = [
      [::I18n.t(:title, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Title'), "title"],
      [::I18n.t(:salutation, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Salutation'), "salutation"],
      [::I18n.t(:firstname, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Firstname'), "firstname"],
      [::I18n.t(:lastname, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Lastname'), "lastname"],
      [::I18n.t(:address, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Address'), "address"],
      [::I18n.t(:zip, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Zipcode'), "zip"],
      [::I18n.t(:city, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'City'), "city"],
      [::I18n.t(:country, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Country'), "country"],
      [::I18n.t(:company, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Company'), "company"]
    ]

    INTERPOLATION_NAME_METHODS = %w(fullname name_with_title firstname lastname name email)

    def disable!
      update_attributes({
        :verified => false,
        :disabled => true
      }, :as => :admin)
      subscriptions.destroy_all
    end

    # Returns a full name
    # Salutation + Title + Firstname + Lastname
    def fullname
      if lastname.present? || firstname.present?
        "#{translated_salutation} #{name_with_title}".squeeze(" ")
      else
        name
      end
    end

    # Translated salutation
    #
    # Translate the saluations in your +config/LOCALE.yml+
    #
    #   alchemy_crm:
    #     salutations:
    #       mr:
    #       ms:
    #
    def translated_salutation
      ::I18n.t(salutation, :scope => [:alchemy_crm, :salutations], :default => salutation.to_s.capitalize)
    end

    # Returns the name and title
    # Title + Firstname + Lastname
    def name_with_title
      "#{title} #{name}".squeeze(" ")
    end

    # Returns the name ot email, if no name is present
    # Firstname + Lastname, or email
    def name
      if lastname.present? || firstname.present?
        "#{firstname} #{lastname}".squeeze(" ")
      else
        email
      end
    end

    # Uses the +config['name_interpolation_method']+ to return the value for emails and forms %{name} interpolations.
    def interpolation_name_value
      name_interpolation_method = Config.get(:name_interpolation_method)
      if name_interpolation_method.present? && INTERPOLATION_NAME_METHODS.include?(name_interpolation_method.to_s) && self.respond_to?(name_interpolation_method.to_sym)
        self.send(name_interpolation_method.to_sym)
      else
        fullname
      end
    end

    def self.fake
      fake = new(
        :salutation => nil,
        :title => ::I18n.t(:title, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'Dr.'),
        :firstname => ::I18n.t(:firstname, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'Jon'),
        :lastname => ::I18n.t(:lastname, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'Doe'),
        :email => ::I18n.t(:email, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'jon@doe.com'),
        :phone => ::I18n.t(:phone, :scope => 'alchemy_crm.fake_contact_attributes', :default => '1-1234567'),
        :mobile => ::I18n.t(:mobile, :scope => 'alchemy_crm.fake_contact_attributes', :default => '123-456789'),
        :address => ::I18n.t(:address, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'Street 1'),
        :zip => ::I18n.t(:zip, :scope => 'alchemy_crm.fake_contact_attributes', :default => '10000'),
        :city => ::I18n.t(:city, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'City'),
        :company => ::I18n.t(:company, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'Company inc.'),
        :country => ::I18n.t(:country, :scope => 'alchemy_crm.fake_contact_attributes', :default => 'US')
      )
      fake.readonly!
      fake
    end

    def self.replace_tag(old_tag, new_tag)
      self.tagged_with(old_tag).each do |contact|
        contact.tags.delete(old_tag)
        contact.tags << new_tag
        contact.save
      end
    end

    def self.find_by_query(query, options, paginate)
      column_names = Contact.public_column_names
      search_string = (column_names.join(" LIKE '%#{query}%' OR ") + " LIKE '%#{query}%'")
      contacts = where(search_string)
      if paginate
        contacts.paginate(options)
      else
        contacts
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
      self.subscriptions.inject(true){|acc, s| acc = s.verified? && acc; acc}
    end

    def self.new_from_recipient(recipient)
      raise "No recipient found!" if recipient.nil?
      contact = new(:email => recipient.email, :lastname => recipient.email)
      contact.readonly!
      contact
    end

    def self.new_from_vcard(vcard, verified)
      raise "No vcard found!" if vcard.nil?
      raise ::I18n.t(:imported_contacts_not_verified, :scope => :alchemy_crm) if !verified
      contacts = []
      ::Vpim::Vcard.decode(vcard).each do |card|
        remapped_attributes = {
          :company => card.org.blank? ? nil : card.org.first,
          :lastname => card.name.blank? ? nil : card.name.family,
          :firstname => card.name.blank? ? nil : card.name.given,
          :title => card.name.blank? ? nil : card.name.prefix,
          :address => card.address.blank? ? nil : card.address.street,
          :city => card.address.blank? ? nil : card.address.locality,
          :country => card.address.blank? ? nil : card.address.country,
          :zip => card.address.blank? ? nil : card.address.postalcode,
          :email => card.email.to_s,
          :phone => card.telephone ? card.telephone.location.include?("cell") ? nil : card.telephone.to_s : nil,
          :mobile => card.telephones.detect { |t| t.location.include?("cell") }.to_s,
          :verified => true
        }
        contact = Contact.new(remapped_attributes, :as => :admin)
        contact.skip_validation = true
        contact.save
        contacts << contact
      end
      contacts
    end

    def to_vcard
      card = Vpim::Vcard::Maker.make2 do |maker|
        maker.add_name do |name|
          name.prefix = title unless title.blank?
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
        maker.org = company
      end
      vcf = File.new(Rails.root.to_s + "/tmp/#{fullname}.vcf", "w")
      vcf.write(card.encode)
      vcf.close
    end

  private

    def update_sha1
      salt = email_salt || [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
      self.email_salt, self.email_sha1 = salt, Digest::SHA1.hexdigest(email + salt)
    end

  end
end
