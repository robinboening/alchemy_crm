class CreateContactGroupFilters < ActiveRecord::Migration
  def self.up
    create_table :contact_group_filters do |t|
      t.string :column
      t.string :value
      t.string :operator
      t.integer :contact_group_id
      
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :contact_group_filters
  end
end
