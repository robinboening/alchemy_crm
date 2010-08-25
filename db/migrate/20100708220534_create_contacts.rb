class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :title
      t.string :salutation
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :mobile
      t.string :address
      t.string :zip
      t.string :city
      t.string :country
      t.string :organisation
      t.string :email_sha1
      t.string :email_salt
      t.boolean :verified, :default => false
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
