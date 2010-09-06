class NewsletterLayout
  
  def self.get_layouts_for_select()
    layouts = []
    PageLayout.get_layouts.each do |layout|
      if layout['newsletter']
        layouts << [layout["display_name"], layout["name"]]
      end
    end
    layouts
  end
  
end
