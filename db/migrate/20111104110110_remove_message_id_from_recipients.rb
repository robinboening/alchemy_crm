class RemoveMessageIdFromRecipients < ActiveRecord::Migration
  def self.up
		remove_column :recipients, :message_id
  end

  def self.down
    add_column :recipients, :message_id, :string
  end
end
