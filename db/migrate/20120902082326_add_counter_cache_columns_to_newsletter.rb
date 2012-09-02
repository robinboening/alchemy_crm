class AddCounterCacheColumnsToNewsletter < ActiveRecord::Migration
  def change
  	add_column :alchemy_crm_newsletters, :subscriptions_count, :integer, :default => 0, :nil => false
  	add_column :alchemy_crm_newsletters, :user_subscriptions_count, :integer, :default => 0, :nil => false
  	add_column :alchemy_crm_newsletters, :contact_group_subscriptions_count, :integer, :default => 0, :nil => false
  end
end
