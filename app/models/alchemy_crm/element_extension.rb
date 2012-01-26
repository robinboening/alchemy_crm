# Extending Alchemys Element model
Alchemy::Element.class_eval do

	def update_from_element(source, url)
		self.contents.each do |content|
			source_content = source.contents.find_by_name(content.name)
			if !source_content.blank? && source_content.essence_type == content.essence_type
				case content.essence_type
					when "Alchemy::EssenceText"
					content.essence.body = source_content.essence.body
					when "Alchemy::EssenceRichtext"
					content.essence.body = source_content.essence.body
					when "Alchemy::EssencePicture"
					content.essence.picture_id = source_content.essence.picture_id
					when "Alchemy::EssenceAttachment"
					content.essence.attachment_id = source_content.essence.attachment_id
				end
				content.essence.save
			end
		end
		teaser = self.contents.where(:essence_type => "Alchemy::EssenceElementTeaser").first
		if !teaser.essence.blank?
			teaser.essence.url = url
			teaser.essence.save
		end
	end

end
