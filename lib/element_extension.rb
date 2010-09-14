module ElementExtension
  
  def update_from_element(source, server = "")
    self.contents.each do |content|
      source_content = source.contents.find_by_name(content.name)
      if !source_content.blank? && source_content.essence_type == content.essence_type
        case content.essence_type
        when "EssenceText" || "EssenceRichtext"
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
      teaser.essence.url = File.join(server, "#{source.page.urlname}##{source.name}_#{source.id}")
      teaser.essence.save
    end
  end
  
end
Element.send(:include, ElementExtension)
