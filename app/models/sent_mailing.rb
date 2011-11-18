# encoding: UTF-8

class SentMailing < ActiveRecord::Base

	attr_accessor :chunk_delay
	PDF_DIR = Rails.root.join("sent_mailing_pdfs")

  belongs_to :mailing
  has_many :recipients, :dependent => :destroy

  after_create :generate_pdf, :recipients_from_mailing_contacts

	scope :delivered, where("`sent_mailings`.`delivered_at` IS NOT NULL")
	scope :pending, where("`sent_mailings`.`delivered_at` IS NULL")

	def delivered?
		!self.delivered_at.nil?
	end

	# Sending mails in chunks.
	def deliver!(current_server)
		raise "No Mailing Given" if self.mailing.blank?
		#100.times { |i| self.recipients << Recipient.new(:email => "tvdeyen+#{i}@gmail.com") }
		@chunk_delay = 0
		self.recipients.each_slice(settings(:send_mails_in_chunks_of)) do |recipients_chunk|
			send_mail_chunk(recipients_chunk, current_server)
			@chunk_delay += 1
		end
		self.update_attribute(:delivered_at, Time.now)
	end
	handle_asynchronously :deliver!, :run_at => Proc.new { |m| m.deliver_at || Time.now }

	# Send the mail chunk via delayed_job and waiting some time before next is enqueued
	def send_mail_chunk(recipients_chunk, current_server)
		recipients_chunk.each do |recipient|
			# MailingsMailer.my_mail(
			# 	self.mailing,
			# 	recipient,
			# 	:server => current_server
			# ).deliver
			puts "sending mail at: #{recipient.email}"
		end
	end
	handle_asynchronously :send_mail_chunk, :run_at => Proc.new { |m| (m.chunk_delay * m.settings(:send_mail_chunks_every)).minutes.from_now }

  def pdf_path#:nodoc:
    raise "No Mailing Given" if self.mailing.blank?
    File.join(PDF_DIR, "#{self.mailing.file_name}-#{created_at.strftime('%Y%m%d%H%M')}.pdf")
  end

	def settings(name)
		AlchemyMailings::Config.get(name)
	end

private

	def recipients_from_mailing_contacts
		raise "No Mailing Given" if self.mailing.blank?
		self.mailing.all_contacts.each do |contact|
			self.recipients << Recipient.create(
				:email => contact.email,
				:contact => contact
			)
		end
	end

  # This generates a pdf version of the newsletter.
  # This has no layout and is just for proofing what content was sent to the recipients.
  def generate_pdf
    raise "No Mailing Given" if self.mailing.blank?
    raise "No Page Given" if self.mailing.page.blank?
    Prawn::Document.generate(self.pdf_path, :page_size => "A4", :orientation => :portrait) do |pdf|
      pdf.text("Empfängerliste:\n\n")
      pdf.text(self.recipients.collect { |r| r.email }.join(', '))
      pdf.text("\nVersendet am: #{self.created_at.strftime("%d.%m.%Y, %H:%Mh")}")
      pdf.text("Betreff: #{self.mailing.subject}\n\n")
      pdf.text("Inhalt:\n\n")
      self.mailing.page.elements.each do |element|
        element.all_contents_by_type(["EssenceText", "EssenceRichtext"]).each do |text_content|
          pdf.text(text_content.essence_type == 'EssenceText' ? text_content.ingredient : text_content.essence.stripped_body)
        end
        element.all_contents_by_type("EssencePicture").each do |picture_content|
          pdf.image(picture_content.essence.picture.file_path) rescue nil
        end
        pdf.text("\n")
      end
    end
  end

end
