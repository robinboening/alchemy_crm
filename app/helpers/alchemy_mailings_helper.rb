module AlchemyMailingsHelper
  
  def contact_count_from_tag(tag)
    unless tag.nil?
      count = Contact.find_tagged_with(tag).length
    else
      count = 0
    end
    "&nbsp;<small>(#{count})</small>"
  end
  
end
