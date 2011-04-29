Alchemy-Mailings Module
=======================

About
-----

Alchemy-Mailings is a newsletter module for Alchemy CMS.
For more Information please visit http://alchemy-app.com

Install
-------

1. First of all install Alchemy:

    <https://github.com/magiclabs/alchemy/>

2. Install these plugins:

        $ script/plugin install git://github.com/magiclabs/alchemy-mailings.git
        $ script/plugin install git://github.com/rails/auto_complete.git

3. Then put these lines into your `config/environment.rb` file inside the `config` block:

        config.gem 'vpim'
        config.gem 'acts_as_taggable_on_steroids'
        config.plugins = [ :all, 'alchemy-mailings', :alchemy ]

4. Migrate your database:

        $ rake db:migrate:alchemy-mailings

5. Seed the database:

  5.1. Put this line into your db/seeds.rb file:
        
        AlchemyMailings::Seeder.seed!

  5.2. Run this rake task:

        $ rake db:seed

6. Copy all assets:

        $ rake alchemy-mailings:assets:copy:all

Resources
---------

* Homepage: <http://alchemy-app.com>
* Wiki: <http://wiki.alchemy-app.com>
* Issue-Tracker: <http://issues.alchemy-app.com>
* Sourcecode: <https://github.com/magiclabs/alchemy-mailings>

Authors
---------

* Carsten Fregin: <https://github.com/cfregin>
* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
