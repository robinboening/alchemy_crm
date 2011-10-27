namespace 'alchemy-mailings' do
	
	namespace :assets do
  
	  desc "Copies all assets from Alchemy-Mailings plugin folder to public folder"
	  task :copy do
	    run "cd #{current_path} && RAILS_ENV=production #{rake} alchemy-mailings:assets:copy:all"
	  end
  
	end
	
end
