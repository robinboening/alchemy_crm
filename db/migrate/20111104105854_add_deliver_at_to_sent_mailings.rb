class AddDeliverAtToSentMailings < ActiveRecord::Migration
  def self.up
    add_column :sent_mailings, :deliver_at, :datetime
  end

  def self.down
    remove_column :sent_mailings, :deliver_at
  end
end
