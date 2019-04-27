# make docker-build

# Would work but is empty...
#FROM rails:onbuild

# This has most code
FROM palladius/septober:v1.2

MAINTAINER Riccardo Carlesso <palladiusbonton+septober@gmail.com>

# WORKDIR /home/riccardo/git/septober
EXPOSE 3000

RUN mkdir -p /dockerize/
ADD ./ /dockerize/
RUN /bin/sh /dockerize/prep.sh

#RUN /bin/sh /dockerize/run.sh
#CMD: [ "cd /septober/ && make run" ]
CMD [ "/dockerize/run.sh" ] 

