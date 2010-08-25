class CreateContactGroupsNewsletters < ActiveRecord::Migration
  def self.up
    create_table :contact_groups_newsletters, :id => false do |t|
      t.integer :contact_group_id
      t.integer :newsletter_id
    end
  end

  def self.down
    drop_table :contact_groups_newsletters
  end
end
