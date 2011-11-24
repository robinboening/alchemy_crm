namespace 'alchemy_crm' do
	
	namespace :assets do
  
	  desc "Copies all assets from Alchemy-Mailings plugin folder to public folder"
	  task :copy do
	    run "cd #{current_path} && RAILS_ENV=production #{rake} alchemy_crm:assets:copy:all"
	  end
  
	end
	
end
