class CreateEssenceElementLinks < ActiveRecord::Migration
  def self.up
    create_table :essence_element_links do |t|
      t.string :url
      t.string :title
      t.string :text
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_element_links
  end
end
