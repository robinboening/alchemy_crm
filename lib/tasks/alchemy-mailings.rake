namespace :db do
  namespace :migrate do
    description = "Migrate the database through scripts in vendor/plugins/alchemy-mailings/lib/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    description << "Target specific version with VERSION=x. Turn off output with VERBOSE=false."

    desc description
    task "alchemy-mailings" => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), "../../db/migrate/"), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
end

namespace 'alchemy-mailings' do
  
  namespace 'migrations' do
    desc "Syncs Alchemy-Mailings migrations into db/migrate"
    task 'sync' do
      system "rsync -ruv #{File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')} #{Rails.root}/db"
    end
  end
  
  namespace 'assets' do
    namespace 'copy' do
      
      desc "Copy all assets for Alchemy-Mailings into apps public folder"
      task "all" do
        Rake::Task['alchemy-mailings:assets:copy:javascripts'].invoke
        Rake::Task['alchemy-mailings:assets:copy:stylesheets'].invoke
        Rake::Task['alchemy-mailings:assets:copy:images'].invoke
      end
      
      desc "Copy javascripts for Alchemy-Mailings into apps public folder"
      task "javascripts" do
        system "mkdir -p #{Rails.root}/public/javascripts/alchemy-mailings"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'javascripts', '*')} #{RAILS_ROOT}/public/javascripts/alchemy-mailings/"
      end
      
      desc "Copy stylesheets for Alchemy-Mailings into apps public folder"
      task "stylesheets" do
        system "mkdir -p #{Rails.root}/public/stylesheets/alchemy-mailings"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'stylesheets', '*')} #{RAILS_ROOT}/public/stylesheets/alchemy-mailings/"
      end
      
      desc "Copy images for Alchemy-Mailings into apps public folder"
      task "images" do
        system "mkdir -p #{Rails.root}/public/images/alchemy-mailings"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'images', '*')} #{RAILS_ROOT}/public/images/alchemy-mailings/"
      end
      
    end
  end
  
end
