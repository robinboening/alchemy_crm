namespace 'alchemy_crm' do

	desc "Migrates the database, inserts essential data into the database and copies all assets."
	task :prepare do
		Rake::Task['alchemy_crm:install:migrations'].invoke
		Rake::Task['alchemy_crm:seeder:copy'].invoke
	end

	namespace 'seeder' do
		desc "Copy a line of code into the seeds.rb file"
		task :copy do
			File.open("./db/seeds.rb", "a") do |f|
				f.puts "\n# Seeding Alchemy CRM data"
				f.puts "AlchemyCrm::Seeder.seed!\n"
			end
		end
	end

	namespace 'elements' do
		desc "Copy all crm elements into app"
		task :copy do
			Dir.glob(File.expand_path('../../app/views/alchemy/elements/*', File.dirname(__FILE__))).each do |file|
				FileUtils.cp(file, Rails.root.join('app/views/alchemy/elements/'))
			end
		end
	end

end
