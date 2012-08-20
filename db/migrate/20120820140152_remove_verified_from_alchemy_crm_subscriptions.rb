class RemoveVerifiedFromAlchemyCrmSubscriptions < ActiveRecord::Migration
  def up
  	remove_column :alchemy_crm_subscriptions, :verified
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
