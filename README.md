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

2. In your Rails App folder enter:

        script/plugin install git://github.com/magiclabs/alchemy-mailings.git

3. Then enter following lines into your config/environment.rb file

    * Inside the config block:

            config.gem 'vpim'
            config.gem 'acts_as_taggable_on_steroids'
            
            config.plugins = [ :all, 'alchemy-mailings', :alchemy ]

4. Then install these plugins:

        script/plugin install git://github.com/rails/auto_complete.git

5. Then create your database and migrate:

        rake db:create
        rake db:migrate:alchemy-mailings

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
