module AlchemyCrm
	module MailingsHelper

		include Alchemy::PagesHelper

		# Renders the newsletter layout for +@mailing.page+
		# 
		# The +@mailing.page.page_layout+ must have a +newsletter_layout+ prefix.
		# The partial itself is named without the +newsletter_layout+ prefix.
		# The partial resists in +/app/views/newsletter_layouts/+
		# 
		# === Example:
		# 
		# Given a mailing page with a +standard+ layout has partials named +_standard.html.erb+ and +_standard.text.erb+
		# But the page page_layout attribute is +newsletter_layout_standard+
		# 
		def render_newsletter_layout(options={})
			options = {:format => 'html'}.update(options)
			render "alchemy/newsletter_layouts/#{@page.page_layout.downcase.gsub(Regexp.new(Mailing::MAILING_PAGE_LAYOUT_PREFIX), '')}.#{options[:format]}.erb"
		end

		# Renders the tracking image that records the receivement of the mailing inside the mail client.
		def render_tracking_image
			return "" if @preview_mode || @recipient.nil?
			image_tag(
				alchemy_crm.recipient_reads_url(:h => @recipient.sha1, :host => current_host),
				:style => "width: 0; height: 0; display: none",
				:width => 0,
				:height => 0,
				:alt => ''
			)
		end

		# Renders a link to the unsubscribe page.
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
					:email => @contact ? @contact.email : nil,
					:host => current_host
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
		# 
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
				:link => link_to(
					::I18n.t(:here, :scope => :alchemy_crm),
					alchemy_crm.show_mailing_url(
						:m => @mailing.sha1,
						:r => @recipient.sha1,
						:host => current_host
					),
					html_options,
					:host => current_host
				),
				:scope => :alchemy_crm
			).html_safe
		end

		# Use this helper to render an image from your server.
		# 
		# The notice and the link inside are translated via I18n.
		# 
		# === Example:
		# 
		#   <%= image_from_server_tag('logo.png', :alt => 'Logo', :width => 230, :height => 116, :style => 'outline:none; text-decoration:none; -ms-interpolation-mode: bicubic;') %>
		#   => <img src="http://example.com/assets/logo.png"
		#  
		# === Options:
		# 
		#   html_options [Hash] # Passed to the image_tag helper.
		# 
		def image_from_server_tag(image, html_options={})
			image_tag([current_server, Rails.application.config.assets.prefix, image].join('/'), html_options)
		end

		# Renders a link that tracks the reaction of a recipient.
		# 
		# After getting tracked the controller redirects to the url passed in.
		# 
		# It has the same arguments that the Rails +link_to+ helper has.
		# 
		# === Example:
		# 
		#   <%= tracked_link_tag('read more' :r => 'http://example.com/my-article', :style => 'color: black') %>
		#   => <a href="http://example.com/recipient/s3cr3tSh41/reacts?r=http%3A%2F%2Fexample.com%2Fmy-article" style="color: black">
		# 
		# *NOTE:* You can even pass a block like you could for +link_to+ helper from Rails.
		# 
		def tracked_link_tag(*args)
			params = {:h => @recipient.sha1, :r => args.first, :host => current_host}
			if block_given?
				link_to(alchemy_crm.recipient_reacts_url(params), args.last) do
					yield
				end
			else
				link_to(args.first, alchemy_crm.recipient_reacts_url(params.merge(:r => args[1])), args.last)
			end
		end

		def current_host
			(defined?(request)).nil? || request.nil? ? @options[:host] : request.host
		end

		def current_server
			if (defined?(request)).nil? || request.nil?
				protocol = @options.nil? || @options[:protocol].blank? ? 'http://' : @options[:protocol]
			else
				protocol = request.protocol
			end
			if (defined?(request)).nil? || request.nil?
				if @options
					port = @options[:port] && @options[:port] != 80 ? @options[:port] : nil
				else
					port = nil
				end
			else
				port = request.port != 80 ? request.port : nil
			end
			[protocol, current_host, port ? ":#{port}" : nil].join
		end

		def current_language
			return @language if @language
			if @options && @options[:language_id]
				@language = Alchemy::Language.find(@options[:language_id])
			else
				@language = Alchemy::Language.get_default
			end
		end

	end
end
