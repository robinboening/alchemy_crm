namespace 'alchemy-mailings' do
	
	namespace :assets do
  
	  desc "Copies all assets from Alchemy-Mailings plugin folder to public folder"
	  task :copy do
	    run "cd #{current_path} && RAILS_ENV=production rake alchemy-mailings:assets:copy:all"
	  end
  
	end

	namespace :db do
  
	  desc "Migrate Alchemy-Mailings database schema"
	  task :migrate, :roles => :app, :except => { :no_release => true } do
	    run "cd #{current_path} && RAILS_ENV=production rake db:migrate:alchemy-mailings"
	  end
  
	end
	
end