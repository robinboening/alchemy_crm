class EssenceElementTeaser < ActiveRecord::Base

	# Returns the first x (default 30) characters of self.url for the Element#preview_text method.
  def preview_text(maxlength = 30)
    url.to_s[0..maxlength]
  end
  
  # Returns self.url. Used for Content#ingredient method.
  def ingredient
    self.url
  end
	
  # Saves the content from params
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.url = params["url"]
    self.title = params["title"]
    self.text = params["text"]
    self.save!
  end

end
