# This works but then u need to add all of septober tree
#FROM rails:onbuild

FROM palladius/septober:v1.2

MAINTAINER Riccardo Carlesso

ADD ../* /septober/

RUN /bin/sh /septober/dockerize/prep.sh

CMD: [ "cd /septober/ && make run" ]
