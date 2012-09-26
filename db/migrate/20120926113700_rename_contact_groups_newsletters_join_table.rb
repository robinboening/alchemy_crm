class RenameContactGroupsNewslettersJoinTable < ActiveRecord::Migration

  def up
    rename_table :alchemy_contact_groups_newsletters, :alchemy_crm_contact_groups_newsletters
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
