class AddDeliveredAtToSentMailings < ActiveRecord::Migration
  def self.up
    add_column :sent_mailings, :delivered_at, :datetime
  end

  def self.down
    remove_column :sent_mailings, :delivered_at
  end
end
