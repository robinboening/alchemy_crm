class AddContactGroupIdToAlchemyCrmSubscriptions < ActiveRecord::Migration
  def change
    add_column :alchemy_crm_subscriptions, :contact_group_id, :integer
  end
end
