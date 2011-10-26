namespace 'alchemy-mailings' do

  desc "Migrates the database, inserts essential data into the database and copies all assets."
  task :prepare do
    Rake::Task['alchemy-mailings:migrations:sync'].invoke
    Rake::Task['alchemy-mailings:seeder:copy'].invoke
    Rake::Task['alchemy-mailings:assets:copy:all'].invoke
  end

  namespace 'seeder' do
    desc "Copy a line of code into the seeds.rb file"
    task :copy do
      File.open("./db/seeds.rb", "a") do |f|
        f.puts "\n# Seeding Alchemy Mailings data"
        f.puts "AlchemyMailings::Seeder.seed!\n"
      end
    end
  end

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
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'javascripts', '*')} #{Rails.root.to_s}/public/javascripts/alchemy-mailings/"
      end
      
      desc "Copy stylesheets for Alchemy-Mailings into apps public folder"
      task "stylesheets" do
        system "mkdir -p #{Rails.root}/public/stylesheets/alchemy-mailings"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'stylesheets', '*')} #{Rails.root.to_s}/public/stylesheets/alchemy-mailings/"
      end
      
      desc "Copy images for Alchemy-Mailings into apps public folder"
      task "images" do
        system "mkdir -p #{Rails.root}/public/images/alchemy-mailings"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'images', '*')} #{Rails.root.to_s}/public/images/alchemy-mailings/"
      end
      
    end
  end
  
end
