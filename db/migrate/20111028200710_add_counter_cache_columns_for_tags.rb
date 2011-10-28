class AddCounterCacheColumnsForTags < ActiveRecord::Migration
  def self.up
    add_column :contacts, :cached_tag_list, :text
    add_column :contact_groups, :cached_contact_tag_list, :text
  end

  def self.down
    remove_column :contacts, :cached_tag_list
    remove_column :contact_groups, :cached_contact_tag_list
  end
end