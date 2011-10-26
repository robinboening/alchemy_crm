class Element < Activerecord::Base

  def update_from_element(source, url)
  	self.contents.each do |content|
  		source_content = source.contents.find_by_name(content.name)
  		if !source_content.blank? && source_content.essence_type == content.essence_type
  			case content.essence_type
  				when "EssenceText"
  				content.essence.body = source_content.essence.body
  				when "EssenceRichtext"
  				content.essence.body = source_content.essence.body
  				when "EssencePicture"
  				content.essence.picture_id = source_content.essence.picture_id
  				when "EssenceAttachment"
  				content.essence.attachment_id = source_content.essence.attachment_id
  			end
  			content.essence.save
  		end
  	end
  	teaser = self.contents.find_by_essence_type("EssenceElementTeaser")
  	if !teaser.essence.blank?
  		teaser.essence.url = url
  		teaser.essence.save
  	end
  end

end
