Project folder and file structure
**********************************

For modularity reasons, this project is divides into several different
Django apps. The same kind of files are duplicated over different apps,
with similar purposes but different implementations.


App structure
==============

* ``ecnomeep/payments`` - responsible for payments and payment categories models and views.
* ``ecnomeep/stocks`` - responsible for stock model and views.
* ``ecnomeep/users`` - responsible for user, budget and budget entry models and views.
* ``ecnomeep/utils`` - various shared functions and mixins.


File types
===========

Server side
------------

* ``admin.py`` - registers models in the Django admin
* ``models.py`` - definitions of Django models, i.e. database objects
* ``serializers.py`` - Django REST Framework Serializers for (de)serialization
                       of model instances.
* ``urls.py`` - declares patters for URL:s. Global URL:s, including API
                URL:s without an app with it own name, is definied in
                ``economeep/conf/urls.py``, while app-specific URL:s is
                defined in the ``urls.py`` of each app.
* ``views.py`` - contains views and view classes that are used by
                 incoming HTTP requests, such as API calls.


Client side
------------
App specific static files are located in ``*appname*/static/*appname/*``,
in order to create a namespace for them (which means you can see from
which app a static file is imported from).

* ``directives`` - specifies custom HTML tags or attributes to be used by Angular
* ``services`` - utility-functions and managers/containers for shared data
* ``filters`` - formatters used in templates, used as ``| myfilter``
* ``resources`` - used for creating and fetching model instances

