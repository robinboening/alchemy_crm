class RecipientsController < ApplicationController
  
  def reads
    recipient = Recipient.find_by_id(params[:id])
    recipient.update_attributes(:read => true, :read_at => Time.now) unless recipient.nil?
    render :nothing => true
  end
  
  def reacts
    url = URI.unescape(params[:url])
    recipient = Recipient.find_by_id(params[:id])
    recipient.update_attributes(:reacted => true, :reacted_at => Time.now) unless recipient.nil? || recipient.reacted
    redirect_to url
  end
  
end
