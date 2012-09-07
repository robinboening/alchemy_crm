class AddEmailsSentToDeliveries < ActiveRecord::Migration
  def change
  	add_column :alchemy_crm_deliveries, :emails_sent, :integer, :default => 0, :nil => false
  end
end
