class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.string :name
      t.string :subject
      t.string :salt
      t.string :sha1
      t.integer :page_id
      t.text :additional_email_addresses
      t.integer :newsletter_id
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :mailings
  end
end
