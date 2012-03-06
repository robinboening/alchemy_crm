module AlchemyCrm
	module BaseHelper

		# Renders a <small> html tag with the contact count for current tag in it.
		def contact_count_from_tag(tag)
			content_tag('small', "(#{Contact.tagged_with(tag).count})")
		end

		# Renders the layout from @page.page_layout.
		# 
		# File resists in /app/views/newsletter_layouts/_LAYOUT-NAME.html.erb
		def render_newsletter_layout
			render "alchemy/newsletter_layouts/#{@page.page_layout.downcase}"
		end

	end
end
