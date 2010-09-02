class NewsletterLayout
  
  def self.element_names_for(newsletter_layout)
    newsletter_layouts = self.get_layouts
    layout_description = newsletter_layouts.detect { |p| p["name"].downcase == newsletter_layout.downcase }
    raise "No Layout Description for #{newsletter_layout} found! in newsletter_layouts.yml" if layout_description.blank?
    layout_description["elements"]
  end
  
  # Returns the newsletter_layout.yml file. Tries to first load from config/alchemy and if not found from vendor/plugins/alchemy/config/alchemy.
  def self.get_layouts
    if File.exists? "#{RAILS_ROOT}/config/alchemy/newsletter_layouts.yml"
      layouts = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/newsletter_layouts.yml" )
    elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/newsletter_layouts.yml"
      layouts = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/newsletter_layouts.yml" )
    else
      raise "Could not find newsletter_layouts.yml neither in config/alchemy/, nor in vendor/plugins/alchemy/config/alchemy/"
    end
    layouts
  end
  
  # Returns the newsletter_layout description found by name in newsletter_layouts.yml
  def self.get(name = "")
    begin
      self.get_layouts.detect{|a| a["name"].downcase == name.downcase}
    rescue Exception => e
      # TODO: Log error message
      #Rails::Logger.error("++++++ ERROR\n#{e}")
      return nil
    end
  end
  
  def self.get_layouts_for_select()
    array = []
    self.get_layouts.each do |layout|
      array << [layout["display_name"], layout["name"]]
    end
    array
  end
  
  def self.get_newsletter_layout_names
    a = []
    self.get_layouts.each{ |l| a << l.keys.first}
    a
  end
  
end
