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
			:organisation,
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
			:organisation,
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

		validates_presence_of :salutation, :message => "^Bitte wählen Sie eine Anrede aus.", :unless => proc { skip_validation }
		validates_presence_of :firstname, :message => "^Bitte geben Sie einen Vornamen an.", :unless => proc { skip_validation }
		validates_presence_of :lastname, :message => "^Bitte geben Sie einen Namen an."
		validates_presence_of :email, :message => "^Bitte geben Sie eine E-Mail Adresse an."
		validates_uniqueness_of :email, :message => "^Diese E-Mail Adresse ist bereits eingetragen."
		validates_format_of :email, :with => ::Authlogic::Regex.email, :message => "^Die E-Mail Adresse ist nicht valide.", :if => proc { errors[:email].blank? }

		before_save :update_sha1

		scope :verified, where(:verified => true)
		scope :disabled, where(:disabled => true)
		scope :enabled, where(:disabled => false)
		scope :available, verified.enabled

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

		def disable!
			self.disabled = true
			save!
		end

		def fullname
			if lastname.present? || firstname.present?
				"#{::I18n.t(salutation, :scope => [:alchemy_crm, :salutations])} #{title} #{name}".squeeze(" ")
			else
				name
			end
		end

		def name
			if lastname.present? || firstname.present?
				"#{firstname} #{lastname}".squeeze(" ")
			else
				email
			end
		end

		def self.fake
			fake = new(
				:salutation => 'mr',
				:title => 'Dr.',
				:firstname => 'Max',
				:lastname => 'Mustermann',
				:email => 'max@mustermann.de',
				:phone => '040-1234567',
				:mobile => '0171-1234567',
				:address => 'Lange Straße 10',
				:zip => '20000',
				:city => 'Hamburg',
				:organisation => 'Musterfirma',
				:country => 'DE'
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
					:organisation => card.org.blank? ? nil : card.org.first,
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
				maker.org = organisation
			end
			vcf = File.new(Rails.root.to_s + "/tmp/#{fullname}.vcf", "w")
			vcf.write(card.encode)
			vcf.close
		end

	private

		def update_sha1
			if email_sha1.blank? || email.changed?
				salt = email_salt || [Array.new(6){rand(256).chr}.join].pack("m")[0..7]
				self.email_salt, self.email_sha1 = salt, Digest::SHA1.hexdigest(email + salt)
			end
		end

	end
end
