class CreateSentMailings < ActiveRecord::Migration
  def self.up
    create_table :sent_mailings do |t|
      t.string :name
      t.integer :sent_mailing_pdf_id
      t.integer :mailing_id
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :sent_mailings
  end
end
