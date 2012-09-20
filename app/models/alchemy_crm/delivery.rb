# encoding: UTF-8
module AlchemyCrm
  class Delivery < ActiveRecord::Base

    attr_accessor :chunk_counter

    belongs_to :mailing
    has_many :recipients, :dependent => :destroy

    scope :delivered, where("`alchemy_crm_deliveries`.`delivered_at` IS NOT NULL")
    scope :pending, where("`alchemy_crm_deliveries`.`delivered_at` IS NULL")

    def self.settings(name)
      AlchemyCrm::Config.get(name)
    end

    # Starts delivering
    #
    # === It:
    #  1. creates the recipients
    #  2. send mails in chunks (Chunks can be configured in +config/alchemy_crm.config.yml+)
    #  3. is handled asynchronous via delayed job.
    #
    def start!(options={})
      create_recipients
      send_chunks(options)
      update_column(:delivered_at, Time.now)
    end
    handle_asynchronously :start!, :run_at => proc { |m| m.deliver_at || Time.now }

    # Returns true if delivered_at is not null
    def delivered?
      !self.delivered_at.nil?
    end

    def mail_count_per_chunk
      @mail_count_per_chunk ||= self.class.settings(:send_mails_in_chunks_of).to_i
    end

    # Returns the count of chunks this delivery has
    def chunk_count
      (mailing.newsletter_subscriptions_count.to_f / mail_count_per_chunk.to_f).ceil
    end

  private

    # Sends mails in chunks.
    #
    # Configure chunking in +config/alchemy_crm.config.yml+
    #
    def send_chunks(options={})
      @chunk_counter = 0
      chunk_count.times do |i|
        send_mail_chunk(options)
        @chunk_counter = i
      end
    end

    # Sends the mail chunk via delayed_job and waiting some time before next is enqueued
    def send_mail_chunk(options)
      recipients.pending.limit(mail_count_per_chunk).offset(self.emails_sent).each do |recipient|
        mail = MailingsMailer.build(mailing, recipient, options).deliver
        update_column(:emails_sent, self.emails_sent + 1)
        recipient.update_column(:message_id, mail.message_id)
      end
    end
    handle_asynchronously :send_mail_chunk, :run_at => proc { |m| (m.chunk_counter * m.class.settings(:send_mail_chunks_every)).minutes.from_now }

    # Handles creation of recipients.
    #
    # Only creates recipients for contacts that did not have got any emails for that mailing yet.
    #
    # Slices the contact ids collection into smaller parts. So it will not break the mysql connection.
    #
    def create_recipients
      mailing.pending_subscriber_ids_and_emails_hash.each_slice(5000) do |subscriber_ids_and_emails|
        Recipient.mass_create(self.id, subscriber_ids_and_emails)
      end
    end

  end
end
