Alchemy CRM Module
==================

About
-----

Alchemy CRM is a newsletter module for Alchemy CMS.
For more Information please visit http://alchemy-cms.com

Install
-------

1. First of all install Alchemy 2.1 beta:

    <https://github.com/magiclabs/alchemy_cms/tree/next_stable>

2. Install the gems:

        $ bundle install

4. Copy the migrations into your app and migrate the database:

        $ rake alchemy_crm:install:migrations
        $ rake db:migrate

5. Seed the database:

  5.1. Put this line into your db/seeds.rb file:
        
        AlchemyCrm::Seeder.seed!

  5.2. Run this rake task:

        $ rake db:seed

Resources
---------

* Homepage: <http://alchemy-cms.com>
* Wiki: <http://wiki.alchemy-cms.com>
* Issue-Tracker: <http://issues.alchemy-cms.com>
* Sourcecode: <https://github.com/magiclabs/alchemy_crm>

Authors
---------

* Carsten Fregin: <https://github.com/cfregin>
* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
