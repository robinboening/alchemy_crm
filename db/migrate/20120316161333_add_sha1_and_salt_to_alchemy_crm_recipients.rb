class AddSha1AndSaltToAlchemyCrmRecipients < ActiveRecord::Migration
  def change
    add_column :alchemy_crm_recipients, :sha1, :string
    add_column :alchemy_crm_recipients, :salt, :string
  end
end
