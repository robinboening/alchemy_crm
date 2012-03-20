module AlchemyCrm
	module BaseHelper

		# Renders a <small> html tag with the contact count for current tag in it.
		def contact_count_from_tag(tag)
			content_tag('small', "(#{Contact.tagged_with(tag).count})")
		end

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

	end
end
