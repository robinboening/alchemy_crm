class RecipientsController < AlchemyMailingsController
  
  def reads
    recipient = Recipient.find_by_id(params[:id])
    recipient.update_attributes(:read => true, :read_at => Time.now) unless recipient.nil?
    render :nothing => true
  end
  
  def reacts
    page = Page.find(params[:page_id])
    element = Element.find(params[:element_id])
    recipient = Recipient.find_by_id(params[:id])
    unless recipient.nil?
      recipient.update_attributes(
        :reacted => true,
        :reacted_at => Time.now
      )
      Reaction.create(
        :recipient => recipient,
        :element => element,
        :page => page
      )
    end
    if multi_language?
      redirect_to show_page_with_language_path(
        :lang => page.language,
        :urlname => page.urlname,
        :anchor => "#{element.name}_#{element.id}"
      )
    else
      redirect_to show_page_path(
        :urlname => page.urlname,
        :anchor => "#{element.name}_#{element.id}"
      )
    end
  end
  
end
