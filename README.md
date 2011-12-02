Alchemy-Mailings Module
=======================

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

4. Migrate your database:

        $ rake db:migrate:alchemy_crm

5. Seed the database:

  5.1. Put this line into your db/seeds.rb file:
        
        AlchemyCrm::Seeder.seed!

  5.2. Run this rake task:

        $ rake db:seed

6. Copy all assets:

        $ rake alchemy_crm:assets:copy:all

Resources
---------

* Homepage: <http://alchemy-app.com>
* Wiki: <http://wiki.alchemy-app.com>
* Issue-Tracker: <http://issues.alchemy-app.com>
* Sourcecode: <https://github.com/magiclabs/alchemy_crm>

Authors
---------

* Carsten Fregin: <https://github.com/cfregin>
* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
