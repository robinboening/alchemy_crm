# encoding: UTF-8
module AlchemyCrm
	class Mailing < ActiveRecord::Base

		belongs_to :page, :dependent => :destroy
		has_many :deliveries, :dependent => :destroy
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

		def contacts_from_newsletter
			self.newsletter.all_contacts
		end

		def all_contacts
			(contacts_from_newsletter + contacts_from_additional_email_addresses).uniq
		end

		def recipients_count
			all_contacts.count
		end

		def all_email_addresses
			self.all_contacts.collect{ |c| c.email } + self.all_additional_email_addresses
		end

		def all_additional_email_addresses
			self.additional_email_addresses.gsub(/ /,'').split(',') rescue []
		end

		def contacts_from_additional_email_addresses
			all_additional_email_addresses.collect{ |email| Contact.new(:email => email) }
		end

		def self.copy(id)
			source = self.find(id)
			clone = source.clone
			clone.name = "#{source.name} (Kopie)"
			clone
		end

		# File name from name. Used for sent mailings PDF.
		def file_name
			name.gsub(' ', '_').downcase
		end

		def next_pending_delivery
			deliveries.pending.first
		end

	private

		def create_page
			mailing_root = Alchemy::Page.find_by_name('Alchemy CRM Rootpage')
			raise "Alchemy CRM Rootpage not found. Did you seed the database?" if mailing_root.blank?
			mailing_page = Alchemy::Page.new(
				:name => "Mailing #{self.name}",
				:sitemap => false,
				:page_layout => self.newsletter.layout,
				:language => Language.get_default,
				:parent_id => mailing_root.id
			)
			if mailing_page.save
				self.page = mailing_page
				save
			else
				raise "Error while creating Mailingpage: #{mailing_page.errors.full_messages}"
			end
		end

	end
end
