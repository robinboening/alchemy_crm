# encoding: UTF-8

module AlchemyCrm
  class Contact < ActiveRecord::Base

    acts_as_taggable

    ACCESSIBLE_ATTRIBUTES = [
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
      :tag_list
    ]

    attr_accessible(*ACCESSIBLE_ATTRIBUTES)
    attr_accessible(*ACCESSIBLE_ATTRIBUTES, :as => :admin)

    has_many :subscriptions, :dependent => :destroy
    has_many :newsletters, :through => :subscriptions, :uniq => true
    has_many :recipients

    accepts_nested_attributes_for :subscriptions, :allow_destroy => true

    Config.get(:additional_contact_validations).each do |field|
      validates_presence_of field.to_sym
    end
    validates_presence_of :email
    validates_uniqueness_of :email, :if => proc { email.present? }
    validates_format_of :email, :with => ::Authlogic::Regex.email, :if => proc { errors[:email].blank? }

    before_save :update_sha1, :if => proc { email_sha1.blank? || email_changed? }
    after_save :update_subscriptions

    scope :subscribed_to, lambda { |newsletter|
      joins(:subscriptions).where(:alchemy_crm_subscriptions => {
        :newsletter_id => newsletter.class.name == "AlchemyCrm::Newsletter" ? newsletter.id : newsletter.collect(&:id)
      })
    }
    scope :not_subscribed_to, lambda { |newsletter|
      contacts = self.scoped
      if newsletter.class.name == "AlchemyCrm::Newsletter"
        contacts = contacts.where("
          alchemy_crm_subscriptions.contact_id IS NULL
          OR
          (select count(*) from alchemy_crm_subscriptions where alchemy_crm_subscriptions.newsletter_id=#{newsletter.id}) = 0
        ")
      else
        contacts = contacts.where("alchemy_crm_subscriptions.contact_id IS NULL OR alchemy_crm_subscriptions.newsletter_id NOT IN(#{newsletter.collect(&:id).join(',')})")
      end
      contacts.includes(:subscriptions)
    }
    scope :verified, where(:verified => true)
    scope :disabled, where(:disabled => true)
    scope :enabled, where(:disabled => false)
    scope :available, verified.enabled

    SEARCHABLE_ATTRIBUTES = [
      "salutation",
      "title",
      "firstname",
      "lastname",
      "company",
      "address",
      "zip",
      "city",
      "country",
      "email",
      "phone",
      "mobile",
      "cached_tag_list"
    ]

    EXPORTABLE_COLUMNS = SEARCHABLE_ATTRIBUTES + [
      "verified",
      "disabled"
    ]

    COLUMN_NAMES = [
      [::I18n.t(:salutation, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Salutation'), "salutation"],
      [::I18n.t(:title, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Title'), "title"],
      [::I18n.t(:firstname, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Firstname'), "firstname"],
      [::I18n.t(:lastname, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Lastname'), "lastname"],
      [::I18n.t(:company, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Company'), "company"],
      [::I18n.t(:address, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Address'), "address"],
      [::I18n.t(:zip, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Zipcode'), "zip"],
      [::I18n.t(:city, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'City'), "city"],
      [::I18n.t(:country, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Country'), "country"],
      [::I18n.t(:email, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Email'), "email"],
      [::I18n.t(:phone, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Phone'), "phone"],
      [::I18n.t(:mobile, :scope => 'activerecord.attributes.alchemy_crm/contact', :default => 'Mobile'), "mobile"]
    ]

    FILTERABLE_ATTRIBUTES = COLUMN_NAMES.collect { |a| a[1] }

    INTERPOLATION_NAME_METHODS = %w(fullname name_with_title firstname lastname name email)

    def disable!
      update_attributes({
        :verified => false,
        :disabled => true
      })
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

    def contact_groups
      ContactGroup.find_by_sql("#{ContactGroup.tagged_with(self.tag_list, :any => true).to_sql} UNION #{ContactGroup.with_matching_filters(self.attributes).to_sql}")
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

    def self.clean_human_attribute_name(attrb)
      human_attribute_name(attrb).gsub(/\*$/, '')
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
        contacts << Contact.create(remapped_attributes)
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

    def contact_groups_newsletters
      return [] if contact_groups.blank?
      contact_groups.collect(&:newsletters).flatten.uniq
    end

    # Subscribes to given newsletters
    def subscribe(newsletter, contact_group_id=nil)
      subscriptions.create(:newsletter => newsletter, :contact_group_id => contact_group_id)
    end

    # Destroys all subscriptions for given newsletter
    def unsubscribe(newsletter)
      if newsletter.class.name == "AlchemyCrm::Newsletter"
        subscriptions.find_by_newsletter_id(newsletter.id).destroy
      else
        subscriptions.where(:newsletter_id => newsletter.collect(&:id)).destroy_all
      end
    end

  private

    # Creates subscriptions depending on contact´s contact_groups. Also deletes useless subscriptions.
    def update_subscriptions
      destroy_unused_subscriptions
      create_new_subscriptions if verified? && !disabled? && contact_groups_newsletters.any?
    end

    def create_new_subscriptions
      contact_groups_newsletters.each do |newsletter|
        if !subscriptions.collect(&:newsletter_id).include?(newsletter.id)
          contact_group = (contact_groups & newsletter.contact_groups).first
          subscribe(newsletter, contact_group.id)
        end
      end
    end

    def destroy_unused_subscriptions
      if !verified? || disabled?
        subscriptions.destroy_all
        return
      end
      subscriptions.each do |subscription|
        next if subscription.contact_group_id.blank?
        if !contact_groups_newsletters.collect(&:id).include?(subscription.newsletter_id)
          subscription.destroy
        end
      end
    end

    def update_sha1
      salt = email_salt || [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
      self.email_salt, self.email_sha1 = salt, Digest::SHA1.hexdigest(email + salt)
    end

  end
end
