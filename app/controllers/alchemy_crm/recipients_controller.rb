module AlchemyCrm
	class RecipientsController < AlchemyCrm::BaseController

		def reads
			recipient = Recipient.find_by_sha1(params[:h])
			if recipient && !recipient.read?
				recipient.reads!
			end
			render :nothing => true
		end

		def reacts
			recipient = Recipient.find_by_sha1(params[:h])
			if recipient
				recipient.reacts!({
					:page_id => params[:page_id],
					:element_id => params[:element_id],
					:url => params[:r].present? ? CGI.unescape(params[:r]) : nil
				})
			end
			if params[:r].present?
				redirect_to CGI.unescape(params[:r])
			else
				page = Alchemy::Page.includes(:elements).find(params[:page_id])
				element = page.elements.find_by_id(params[:element_id])
				redirect_to alchemy.show_page_url(
					:urlname => page.urlname,
					:lang => multi_language? ? page.language_code : nil,
					:anchor => element ? element.dom_id : nil
				)
			end
		end

	end
end
