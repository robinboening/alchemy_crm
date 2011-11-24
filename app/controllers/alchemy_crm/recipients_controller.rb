module AlchemyCrm
	class RecipientsController < AlchemyCrm::BaseController

		def reads
			recipient = Recipient.find_by_id(params[:id])
			recipient.update_attributes(:read => true, :read_at => Time.now) unless recipient.nil?
			render :nothing => true
		end

		def reacts
			page = Alchemy::Page.find(params[:page_id])
			element = Alchemy::Element.find(params[:element_id])
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
			redirect_to alchemy.show_page_path(
				:lang => multi_language? ? page.language : nil,
				:urlname => page.urlname,
				:anchor => "#{element.name}_#{element.id}"
			)
		end

	end
end
