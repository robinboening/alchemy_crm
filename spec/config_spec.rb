require 'spec_helper'

module AlchemyCrm
	describe 'Configuration' do
		describe 'file' do
			context 'is present in host application' do
				before(:each) do
					@config_file = Rails.root.join('config', 'alchemy_crm.config.yml')
					File.open(@config_file, 'w') do |file|
						file.puts({'mail_from' => 'jon@doe.com'}.to_yaml)
					end
				end
				it "should load the app config" do
					Config.show.should == {'mail_from' => 'jon@doe.com'}
				end
				after(:each) do
					FileUtils.rm_f @config_file
				end
			end
			context 'is not present in application' do
				it 'should load the default config' do
					default_config = File.join(File.dirname(__FILE__), '..', 'config/alchemy_crm.config.yml')
					Config.show.should == YAML.load_file(default_config)
				end
			end
		end
	end
end
