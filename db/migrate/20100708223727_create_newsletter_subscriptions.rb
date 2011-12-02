class CreateNewsletterSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :contact_id
      t.integer :newsletter_id
      t.boolean :wants, :default => true
      t.boolean :verified, :default => false
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
