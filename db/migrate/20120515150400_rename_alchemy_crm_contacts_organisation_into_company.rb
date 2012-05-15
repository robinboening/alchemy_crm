class RenameAlchemyCrmContactsOrganisationIntoCompany < ActiveRecord::Migration
  def up
    rename_column :alchemy_crm_contacts, :organisation, :company
  end

  def down
    rename_column :alchemy_crm_contacts, :company, :organisation
  end
end
