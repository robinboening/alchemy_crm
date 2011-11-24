module AlchemyCrm
	module BaseHelper

		include Alchemy::PagesHelper
		include Alchemy::ElementsHelper

		def contact_count_from_tag(tag)
			content_tag('small', "(#{Contact.tagged_with(tag).count})")
		end

		# Renders the layout from @page.page_layout. File resists in /app/views/newsletter_layouts/_LAYOUT-NAME.html.erb
		def render_newsletter_layout(options={})
			default_options = {
				:render_format => "html"
			}
			options = default_options.merge(options)
			render :partial => "alchemy/page_layouts/#{@page.page_layout.downcase}.#{options[:render_format]}.erb"
		end

	end
end

Alchemy::BaseHelper.send(:include, AlchemyCrm::AlchemyCrmHelper)
