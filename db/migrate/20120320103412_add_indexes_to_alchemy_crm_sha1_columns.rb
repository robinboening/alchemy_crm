class AddIndexesToAlchemyCrmSha1Columns < ActiveRecord::Migration
  def change
    add_index :alchemy_crm_contacts, :email_sha1
    add_index :alchemy_crm_mailings, :sha1
    add_index :alchemy_crm_recipients, :sha1
  end
end
