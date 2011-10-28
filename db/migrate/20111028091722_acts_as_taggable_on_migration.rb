class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    change_table :taggings do |t|
      t.references :tagger, :polymorphic => true
      t.string :context
    end
    remove_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
