#################################
# This is simply the latest version...
# I take it and patch it with latest version.. not sure it works :)
#################################

# ruby/gems 1.9.1
FROM palladius/septober:v1.2

MAINTAINER Riccardo Carlesso <riccardo.carlesso@gmail.com>

# Linux
RUN apt-get -y update
RUN apt-get -y install libmysqlclient-dev mysql-common libmysqlclient18 mysql-client

# 2. Latest Code

ADD . /var/www-public/septober/
WORKDIR /var/www-public/septober/
# horrible again
RUN cp Gemfile-sqlite3 Gemfile
# Added for MySQL but if you only use SQLite, its ok to remove the initializer.
RUN mv ./config/initializers/abstract_mysql2_adapter.rb ./config/initializers/abstract_mysql2_adapter.rb.inutile
#RUN /bin/sh /var/www-public/septober/dockerize/prep.sh
RUN bundle install

# Pathching the bloody sqlite3 :/ #HORRIBLE I know!
# https://stackoverflow.com/questions/17643897/cannot-load-such-file-sqlite3-sqlite3-native-loaderror-on-ruby-on-rails
#RUN sed -e 's/s.require_paths = \["lib"\]/s.require_paths = \["lib\/sqlite3_native"\]/g' -i vendor/bundle#/ruby/1.9.1/specifications/sqlite3-1.3.5.gemspec


RUN cat /var/www-public/septober/VERSION
CMD ["rails", "server"]
