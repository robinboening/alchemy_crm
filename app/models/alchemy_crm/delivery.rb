# encoding: UTF-8
module AlchemyCrm
  class Delivery < ActiveRecord::Base

    attr_accessor :chunk_counter

    belongs_to :mailing
    has_many :recipients, :dependent => :destroy

    after_create :create_recipients

    scope :delivered, where("`alchemy_crm_deliveries`.`delivered_at` IS NOT NULL")
    scope :pending, where("`alchemy_crm_deliveries`.`delivered_at` IS NULL")

    def delivered?
      !self.delivered_at.nil?
    end

    def mail_count_per_chunk
      @mail_count_per_chunk ||= self.class.settings(:send_mails_in_chunks_of).to_i
    end

    def chunk_count
      (mailing.newsletter_subscriptions_count.to_f / mail_count_per_chunk.to_f).ceil
    end

    # Sending mails in chunks.
    def send_chunks(options={})
      raise "No Mailing Given" if mailing.blank?
      @chunk_counter = 0
      chunk_count.times do |i|
        send_mail_chunk(options)
        @chunk_counter = i
      end
      update_column(:delivered_at, Time.now)
    end
    handle_asynchronously :send_chunks, :run_at => proc { |m| m.deliver_at || Time.now }

    # Send the mail chunk via delayed_job and waiting some time before next is enqueued
    def send_mail_chunk(options)
      recipients.not_recieved_email.limit(mail_count_per_chunk).offset(self.emails_sent).each do |recipient|
        mail = MailingsMailer.build(mailing, recipient, options).deliver
        update_column(:emails_sent, self.emails_sent + 1)
        recipient.update_column(:message_id, mail.message_id)
      end
    end
    handle_asynchronously :send_mail_chunk, :run_at => proc { |m| (m.chunk_counter * m.class.settings(:send_mail_chunks_every)).minutes.from_now }

    def self.settings(name)
      AlchemyCrm::Config.get(name)
    end

  private

    # Handles creation of Recipients for Delivery.
    # This is called before the Delivery is created.
    def create_recipients
      mailing.contact_ids_not_recieved_email_yet.each_slice(1000) do |contact_ids|
        mailing.subscribers.where(:id => contact_ids).select("id,email").each_slice(1000) do |subscribers_collection|
          Recipient.mass_create(subscribers_collection, self)
        end
      end
    end
    handle_asynchronously :create_recipients

  end
end
