class AddMailingIdToRecipients < ActiveRecord::Migration
  def change
  	add_column :alchemy_crm_recipients, :mailing_id, :integer
  end
end
