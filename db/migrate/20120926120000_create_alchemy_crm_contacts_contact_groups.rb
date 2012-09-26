class CreateAlchemyCrmContactsContactGroups < ActiveRecord::Migration

  def change
    create_table :alchemy_crm_contacts_contact_groups, :id => false do |table|
      table.references :contact
      table.references :contact_group
    end
    add_index :alchemy_crm_contacts_contact_groups, [:contact_id, :contact_group_id], :name => :contacts_contact_groups, :uniq => true
  end

end
