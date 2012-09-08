class AddIndexesToAlchemyCrmContacts < ActiveRecord::Migration
  def change
  	add_index :alchemy_crm_contacts, [:verified, :disabled], :name => 'alchemy_crm_contacts_available_index'
  end
end
