#################################
# This is simply the latest version...
# I take it and patch it with latest version.. not sure it works :)
#################################
#
# Dockerfile versions:
#
# - 20220108 v1.1 bundle installing BEFORE copying files :) This should derive time to compile WAY down! time docker build .
#                 Time to build now: 13 seconds!

# ruby/gems 1.9.1
FROM palladius/septober:v1.2 as base 

# Linux
RUN apt-get -y update && apt-get -y install libmysqlclient-dev mysql-common libmysqlclient18 mysql-client

WORKDIR /var/www-public/septober/

# 2. Add Gem and build. Takes time but should be done seldom

COPY Gemfile Gemfile.lock /var/www-public/septober/
RUN bundle install

# 3. Latest Code. This is fast to iterate thru skaffold.

ADD . /var/www-public/septober/

# Added for MySQL but if you only use SQLite, its ok to remove the initializer.
RUN mv ./config/initializers/abstract_mysql2_adapter.rb ./config/initializers/abstract_mysql2_adapter.rb.inutile
#RUN /bin/sh /var/www-public/septober/dockerize/prep.sh
#RUN bundle install

# Pathching the bloody sqlite3 :/ #HORRIBLE I know!
# https://stackoverflow.com/questions/17643897/cannot-load-such-file-sqlite3-sqlite3-native-loaderror-on-ruby-on-rails
#RUN sed -e 's/s.require_paths = \["lib"\]/s.require_paths = \["lib\/sqlite3_native"\]/g' -i vendor/bundle#/ruby/1.9.1/specifications/sqlite3-1.3.5.gemspec

RUN cat /var/www-public/septober/VERSION
#CMD ["rails", "server"]
CMD ["./entrypoint-8080.sh"] 
