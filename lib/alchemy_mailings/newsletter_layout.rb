module AlchemyMailings
	class NewsletterLayout
  
	  def self.get_layouts_for_select()
	    layouts = []
	    Alchemy::PageLayout.get_layouts.each do |layout|
	      if layout['newsletter']
	        layouts << [layout["display_name"], layout["name"]]
	      end
	    end
	    layouts
	  end
  
	  def self.get(name)
	    Alchemy::PageLayout.get(name)
	  end
  
	end
end