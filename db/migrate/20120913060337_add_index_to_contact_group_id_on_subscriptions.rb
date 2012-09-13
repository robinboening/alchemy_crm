class AddIndexToContactGroupIdOnSubscriptions < ActiveRecord::Migration
  def change
    add_index :alchemy_crm_subscriptions, :contact_group_id
  end
end
