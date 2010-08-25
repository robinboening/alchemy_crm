class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string :name
      t.string :layout
      t.boolean :public, :default => false
      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
