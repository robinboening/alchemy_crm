class AddTaggingsCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :taggings_count, :integer, :default => 0
    ActsAsTaggableOn::Tag.all.each do |tag|
      ActsAsTaggableOn::Tag.update_counters tag.id, :taggings_count => tag.taggings.count
    end
  end
end
