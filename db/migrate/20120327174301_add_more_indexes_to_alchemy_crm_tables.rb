class AddMoreIndexesToAlchemyCrmTables < ActiveRecord::Migration
	def change
		add_index :alchemy_crm_recipients, :message_id
		add_index :alchemy_crm_recipients, :email
		add_index :alchemy_crm_recipients, :contact_id
		add_index :alchemy_crm_recipients, :delivery_id
		add_index :alchemy_crm_contacts, :email
		add_index :alchemy_crm_reactions, :recipient_id
		add_index :alchemy_contact_groups_newsletters, [:contact_group_id, :newsletter_id], :name => 'contact_group_newsletter_index', :unique => true
		add_index :alchemy_crm_subscriptions, [:contact_id, :newsletter_id], :name => 'contact_newsletter_index', :unique => true
	end
end