class AddContactsCountToContactGroup < ActiveRecord::Migration
  def change
    add_column :alchemy_crm_contact_groups, :contacts_count, :integer, :default => 0, :nil => false
  end
end
