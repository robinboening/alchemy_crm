class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do |t|
      t.string :email
      t.boolean :bounced, :default => false
      t.boolean :read, :default => false
      t.boolean :reacted, :default => false
      t.integer :sent_mailing_id
      t.integer :contact_id
      t.string :message_id
      t.datetime :read_at
      t.datetime :bounced_at
      t.datetime :reacted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :recipients
  end
end
