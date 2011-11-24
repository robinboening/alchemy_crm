module AlchemyCrm
	class NewsletterLayout
  
	  def self.get_layouts_for_select()
	    layouts = []
	    Alchemy::PageLayout.get_layouts.each do |layout|
	      if layout['newsletter']
	        layouts << [display_name_for(layout["name"]), layout["name"]]
	      end
	    end
	    layouts
	  end
  
	  def self.get(name)
	    Alchemy::PageLayout.get(name)
	  end
  	
		def self.display_name_for(name)
			I18n.t("alchemy.page_layout_names.#{name}", :default => name.camelcase)
		end
		
	end
end