class CreateReactions < ActiveRecord::Migration
  def self.up
    create_table :reactions do |t|
      t.integer :recipient_id
      t.integer :page_id
      t.integer :element_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reactions
  end
end
