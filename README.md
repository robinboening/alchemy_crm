Alchemy CRM Module *(2.0.alpha)*
===============================

About
-----

This branch of the Alchemy CRM is a newsletter module for Alchemy CMS 2.1.
For more Information please visit [http://alchemy-cms.com](http://alchemy-cms.com)

**CAUTION: This branch is not stable. Please do not use it in productive environments.**

Install
-------

1. Put this line into your projects `Gemfile`:

        gem "alchemy_crm", :git => 'git://github.com/magiclabs/alchemy_crm', :branch => 'rails31'

2. Update your bundle:

        $ bundle

3. Mount the Alchemy CRM Engine into your app:

        # config/routes.rb
        ...
        mount AlchemyCrm::Engine => '/newsletter'
        mount Alchemy::Engine => '/'

    NOTE: It is **strongly** recommended to mount this module before you mount Alchemy CMS

4. Copy the migrations into your app and migrate the database:

        $ rake alchemy_crm:install:migrations
        $ rake db:migrate

5. Seed the database:

    1. Put this line into your projects `db/seeds.rb` file:
        
            AlchemyCrm::Seeder.seed!

    2. And run this rake task:

            $ rake db:seed

6. Generate files and folders:

    1. Run scaffold generator

            $ rails g alchemy_crm:scaffold

    2. Run copy elements rake task

            $ rake alchemy_crm:elements:copy

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

* MIT: <https://raw.github.com/magiclabs/alchemy_crm/rails31/MIT-LICENSE>
