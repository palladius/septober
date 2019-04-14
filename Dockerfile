# This works but then u need to add all of septober tree
#FROM rails:onbuild

FROM palladius/septober:v1.2

MAINTAINER Riccardo Carlesso <riccardo.carlesso@gmail.com>

ADD . /septober/

WORKDIR /septober/


# Added for MySQL but if you only use SQLite, its ok to remove the initializer.
RUN mv ./config/initializers/abstract_mysql2_adapter.rb ./config/initializers/abstract_mysql2_adapter.rb.inutile

RUN /bin/sh /septober/dockerize/prep.sh


CMD [ "cd /septober/ && rails s" ]
