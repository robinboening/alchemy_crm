module ElementExtension
  
  def update_from_element(source, server = "")
    self.contents.each do |content|
      c = source.content_by_name(content.name)
      if !c.blank? && c.essence_type == content.essence_type
        case c.essence_type
        when "EssenceText"
          content.essence.body = c.essence.body
          content.essence.save
        when "EssenceRichtext"
          content.essence.body = c.essence.body
          content.essence.save
        when "EssencePicture"
          content.essence.picture_id = c.essence.picture_id
          content.essence.save
        when "EssenceFile"
          content.essence.attachment_id = c.essence.attachment_id
          content.essence.save
        end
      end
    end
    teaser = self.all_contents_by_type("EssenceTeaserLink").first
    if !teaser.essence.blank?
      teaser.essence.url = File.join(server, "#{source.page.urlname}##{source.name}_#{source.id}")
      teaser.essence.save
    end
  end
  
end

if defined?(stampable)
  Element.send(:include, ElementExtension)
end
