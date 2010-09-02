Alchemy-Mailings Module
=======================

About
-----

Alchemy-Mailings is a newsletter module for Alchemy WebCMS.
For more Information please visit http://alchemy-app.com

Install
-------

1. First of all install Alchemy:

    <http://github.com/tvdeyen/alchemy/>

2. In your Rails App folder enter:

        script/plugin install git://github.com/tvdeyen/alchemy-mailings.git

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

* Homepage: <http://alchemy-app.com/>
* Issue-Tracker and Wiki: <http://redmine.alchemy-app.com/>
* Sourcecode: <http://github.com/tvdeyen/alchemy-mailings/>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
