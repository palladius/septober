Docker
======

* Consider using RAILS_SERVE_STATIC_FILES to serve static files. See
  also Google ruby/CDN docs:
  https://cloud.google.com/appengine/docs/flexible/ruby/serving-static-files

Vulnerabilities
===============

* Try to merge github pull requuests and see if it still woks.
* https://github.com/palladius/septober/pulls
* If jquery is patched, verify the EDIT IN PLACE still works Riccardo

CLI
===

* septober tag 123 travels,shopping,riccardo
* TAGS work => 1 bug security, see github

Facebook
========

* septober tag 123 travels,shopping,riccardo
* TAGS work => 1 bug security, see github
* Facebook
* FEATURE: Todo.Refactorize into:
  - provide maybe with ajax growing number of textfields (or maybe just 5)
  - with many fields

 Notable queries
 ===============

  - here (GPS/IP/address)
  - this computer (hostname matches)
  - assign a virtual relevance points (1..1000) depending on PRI, GPD closeness , overdueness, ... and sort over this!

Gemfile
=======

1. Vulnerabilities

2. sqlite3 gem

Hello! The sqlite3-ruby gem has changed it's name to just sqlite3.  Rather than
installing `sqlite3-ruby`, you should install `sqlite3`.  Please update your
dependencies accordingly.
