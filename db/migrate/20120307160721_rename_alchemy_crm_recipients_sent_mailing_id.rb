class RenameAlchemyCrmRecipientsSentMailingId < ActiveRecord::Migration
	def change
		rename_column :alchemy_crm_recipients, :sent_mailing_id, :delivery_id
	end
end
