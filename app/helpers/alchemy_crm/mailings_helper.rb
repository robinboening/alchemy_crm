module AlchemyCrm
	module MailingsHelper

		include Alchemy::PagesHelper

		# Renders the tracking image that records the receivement of the mailing inside the mail client.
		def render_tracking_image
			return "" if @preview_mode || @recipient.nil?
			image_tag(
				alchemy_crm.recipient_reads_url(:h => @recipient.sha1),
				:style => "width: 0; height: 0; display: none",
				:width => 0,
				:height => 0,
				:alt => ''
			)
		end

		# Renders a link to the unsubscribe page
		# 
		# Please notice that you have to create a page with a +newsletter_signout+ page layout and this page has to be public.
		# 
		# The text inside the link is translated.
		# 
		# === Example translation:
		# 
		#   de:
		#     alchemy_crm:
		#       unsubscribe: 'abmelden'
		# 
		# === Options:
		# 
		#   html_options [Hash] # Passed to the link. Useful for styling the link with inline css.
		# 
		# You can pass an optional block thats gets passed to +link_to+
		# 
		def link_to_unsubscribe_page(html_options={})
			unsubscribe_page = Alchemy::Page.find_by_page_layout('newsletter_signout')
			text = ::I18n.t(:unsubscribe, :scope => :alchemy_crm)
			if unsubscribe_page.nil?
				warning('Newsletter Signout Page Could Not Be Found. Please create one!', text)
			else
				url = alchemy.show_page_url(
					:urlname => unsubscribe_page.urlname,
					:lang => multi_language? ? unsubscribe_page.language_code : nil,
					:email => @contact ? @contact.email : nil
				)
				if block_given?
					link_to(url, html_options) do
						yield
					end
				else
					link_to(text, url, html_options)
				end
			end
		end

		# Renders a notice to open the mailing inside a browser, if it does not displays correctly.
		# The notice and the link inside are translated via I18n.
		# 
		# === Example translation:
		# 
		#   de:
		#     alchemy_crm:
		#       here: 'hier'
		#       read_in_browser_notice: "Falls der Newsletter nicht richtig dargestellt wird, klicken Sie bitte %{link}."
		# 
		# === Options:
		# 
		#   html_options [Hash] # Passed to the link. Useful for styling the link with inline css.
		# 
		def read_in_browser_notice(html_options = {})
			return "" if @recipient.nil?
			::I18n.t(
				:read_in_browser_notice,
				:link => link_to(::I18n.t(:here, :scope => :alchemy_crm), alchemy_crm.show_mailing_url(:m => @mailing.sha1, :r => @recipient.sha1), html_options),
				:scope => :alchemy_crm
			).html_safe
		end

		# Use this helper to render an image from your server
		# The notice and the link inside are translated via I18n.
		# 
		# === Example:
		# 
		#   <%= image_from_server_tag('logo.png', :alt => 'Logo', :width => 230, :height => 116, :style => 'outline:none; text-decoration:none; -ms-interpolation-mode: bicubic;') %>
		#   <img src="http://example.com/assets/logo.png"
		#  
		# === Options:
		# 
		#   html_options [Hash] # Passed to the image_tag helper.
		# 
		def image_from_server_tag(image, html_options={})
			image_tag([current_server, Rails.application.config.assets.prefix, image].join('/'), html_options)
		end

		def tracked_link_tag(*args)
			if block_given?
				link_to(alchemy_crm.recipient_reacts_url(:h => @recipient.sha1, :r => args.first), args.last) do
					yield
				end
			else
				link_to(args.first, url, args.last)
			end
		end

	end
end
