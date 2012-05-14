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
      app_config = Rails.root.join('config/alchemy_crm.config.yml')
      default_config = File.join(File.dirname(__FILE__), '..', '..', 'config/alchemy_crm.config.yml')
      if File.exist?(app_config)
        YAML.load_file(app_config)
      elsif File.exist?(default_config)
        YAML.load_file(default_config)
      else
        raise "No config file found!"
      end
    end

  end
end
