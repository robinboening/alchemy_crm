module AlchemyCrm
  class Config
  
    # Returns the configuration for given parameter
    def self.get(name)
      read_file[name.to_s]
    end
    
    def self.show
      read_file
    end
    
  private
    
    def self.read_file
      YAML.load_file( File.join(File.dirname(__FILE__), '..', '..', 'config/configuration.yml') )
    end
    
  end
end
