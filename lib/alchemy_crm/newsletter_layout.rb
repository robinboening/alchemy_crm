module AlchemyCrm
	class NewsletterLayout

		def self.get_layouts_for_select()
			all
			@@newsletter_layouts.map do |l|
				[display_name_for(l["name"]), l["name"]]
			end
		end

		def self.all
			@@newsletter_layouts ||= Alchemy::PageLayout.get_all_by_attributes(:newsletter => true)
		end

		def self.get(name)
			all
			@@newsletter_layouts.detect { |l| l['name'] == name.to_s }
		end

		def self.display_name_for(name)
			Alchemy::I18n.t(name, :scope => :page_layout_names, :default => name.to_s.camelcase)
		end

	end
end

Alchemy::PageLayout.class_eval do

	def self.selectable_layouts(language_id, layoutpage = false)
		class_variable_get('@@definitions').select do |layout|
			used = layout["unique"] && has_a_page_this_layout?(layout["name"], language_id)
			if layoutpage
				layout["layoutpage"] == true && !used && layout["newsletter"] != true
			else
				layout["layoutpage"] != true && !used && layout["newsletter"] != true
			end
		end
	end

end
