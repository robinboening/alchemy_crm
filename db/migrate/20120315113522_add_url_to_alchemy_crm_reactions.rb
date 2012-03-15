class AddUrlToAlchemyCrmReactions < ActiveRecord::Migration
  def change
    add_column :alchemy_crm_reactions, :url, :text
  end
end
