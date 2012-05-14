module Alchemy
  class EssenceElementTeaser < ActiveRecord::Base

    acts_as_essence(
      :ingredient_column => :url,
      :preview_text_method => :url
    )

    # Saves the content from params
    def save_ingredient(params, options = {})
      return true if params.blank?
      self.url = params["url"]
      self.title = params["title"]
      self.text = params["text"]
      self.save!
    end

  end
end
