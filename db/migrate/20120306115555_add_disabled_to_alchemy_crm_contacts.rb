class AddDisabledToAlchemyCrmContacts < ActiveRecord::Migration
  def change
    add_column :alchemy_crm_contacts, :disabled, :boolean, :default => false
  end
end
