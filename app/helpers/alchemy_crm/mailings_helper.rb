module AlchemyCrm
	module MailingsHelper

		include Alchemy::PagesHelper

		# Renders the tracking image that records the receivement of the mailing inside the mail client.
		def render_tracking_image
			return "" if @preview_mode || @recipient.nil?
			image_tag(
				alchemy_crm.recipient_reads_url(:id => @recipient.id),
				:style => "width: 0; height: 0; display: none",
				:width => 0,
				:height => 0,
				:alt => ''
			)
		end

		# Renders a link to the unsubscribe page
		def render_unsubscribe_link
		end

		# Renders a notice to open the mailing inside a browser, if it does not displays correctly.
		# The notice and the link inside are translated via I18n.
		# 
		# === Example translation:
		# 
		#   de:
		#     alchemy_crm:
		#      here: 'hier'
		#      read_in_browser_notice: "Falls der Newsletter nicht richtig dargestellt wird, klicken Sie bitte %{link}."
		# 
		# === Options:
		# 
		#   html_options [Hash] # Passed to the link. Useful for styling the link with inline css.
		# 
		def read_in_browser_notice(html_options = {})
			return "" if @recipient.nil?
			::I18n.t(
				:read_in_browser_notice,
				:link => link_to(::I18n.t(:here, :scope => :alchemy_crm), alchemy_crm.mailing_path(:m => @mailing.sha1, :r => @recipient.sha1), html_options),
				:scope => :alchemy_crm
			).html_safe
		end

	end
end
