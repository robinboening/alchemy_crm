module AlchemyMailings
  class Config
  
    # Returns the configuration for given parameter
    def self.get(name)
      read_file.fetch('settings')[name.to_s]
    end
    
    def self.show
      read_file
    end
    
  private
    
    def self.read_file
      YAML.load_file( File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy/config.yml') )
    end
    
  end
end
