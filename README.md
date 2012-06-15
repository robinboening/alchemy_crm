Alchemy CRM Module
==================

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_crm.png?branch=2.0-stable)](http://travis-ci.org/magiclabs/alchemy_crm)

Building and sending Newsletters has never been easier!

About
-----

A fully featured CRM / Newsletter and Mailings Module for Alchemy CMS.

For more Information please visit [http://alchemy-cms.com](http://alchemy-cms.com)

Install
-------

1. Install Alchemy CMS:

http://guides.alchemy-cms.com/getting_started.html

2. Put this line into your projects `Gemfile`:

        # Gemfile
        gem "alchemy_crm", :git => 'git://github.com/magiclabs/alchemy_crm', :branch => '2.0-stable'

Or install it via Rubygems:

        $ gem install alchemy_crm

3. Update your bundle:

        $ bundle

4. Mount the Alchemy CRM Engine into your app:

        # config/routes.rb
        ...
        mount AlchemyCrm::Engine => '/newsletter'
        mount Alchemy::Engine => '/'

    NOTE: It is **strongly** recommended to mount this module before you mount Alchemy CMS

5. Copy the migrations into your app and migrate the database:

        $ rake alchemy_crm:install:migrations
        $ rake db:migrate

6. Seed the database:

    1. Put this line into your projects `db/seeds.rb` file:

            AlchemyCrm::Seeder.seed!

    2. And run this rake task:

            $ rake db:seed

7. Generate files and folders:

    1. Run scaffold generator

            $ rails g alchemy_crm:scaffold

    2. Run copy elements rake task

            $ rake alchemy_crm:elements:copy

Resources
---------

* Homepage: <https://github.com/magiclabs/alchemy_crm>
* Issue-Tracker: <https://github.com/magiclabs/alchemy_crm/issues>
* Sourcecode: <https://github.com/magiclabs/alchemy_crm>

Authors
---------

* Thomas von Deyen: <https://github.com/tvdeyen>

License
-------

* BSD: <https://raw.github.com/magiclabs/alchemy_crm/LICENSE>
