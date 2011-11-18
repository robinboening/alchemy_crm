class RemoveSentMailingPdfIdFromSentMailings < ActiveRecord::Migration
  def self.up
		remove_column :sent_mailings, :sent_mailing_pdf_id
  end

  def self.down
    add_column :sent_mailings, :sent_mailing_pdf_id, :integer
  end
end
