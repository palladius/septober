VERSION=$(shell cat VERSION)
APPNAME= septober-ng
# project for "septober-ng" (PUBLIC no pwd)
PROJECT_ID = 7eptober
# project for "septober-mysql" (PRIVATE with mysql pwd)
#PROJECT_ID = ric-cccwiki

# funge anche senza: miracolo!
#PWD=$(shell pwd)

install:
	sudo apt-get install sqlite libsqlite3-dev
	touch install

configure: install
	bundle install
	rake db:migrate
	rake db:seed
	touch configure

run: configure
	rake db:migrate
	rails server

run-prod: configure
	RAILS_ENV=production rake db:migrate
	RAILS_ENV=production rails server -p 8080

# only if you know what youre doing...
plugins-update:
	rails g on_the_spot:install

##########################################################
# Docker inspiration: https://github.com/kstaken/dockerfile-examples

# cd /home/riccardo/git/septober/ && make run
docker-build-latest: docker-build
	echo Building locally two tags: both latest version with explicit vVERSION and LATEST
#	docker build -t=septober-ng:latest .

# I doubt this work ;-)
docker-run-latest-bash: docker-build-latest
	docker run -it -p 8080:8080 $(APPNAME):latest bash

docker-run-latest-prod: docker-build
	docker run -it --env RAILS_ENV=production -p 8080:8080 $(APPNAME):latest ./entrypoint-8080.sh

docker-run-latest-prod-bash: docker-build
	docker run -it --env RAILS_ENV=production -p 8080:8080 $(APPNAME):latest bash


docker-build:
	docker build -t=$(APPNAME):v$(VERSION) .
	docker tag $(APPNAME):v$(VERSION) $(APPNAME):latest

# New generation push, with both VERSION and latest. T be sure I use a different project
# Where cloud build is enabled :)
docker-push: docker-build
	docker tag $(APPNAME):v$(VERSION) gcr.io/$(PROJECT_ID)/$(APPNAME):v$(VERSION)
	docker tag $(APPNAME):v$(VERSION) gcr.io/$(PROJECT_ID)/$(APPNAME)
	docker push gcr.io/$(PROJECT_ID)/$(APPNAME):v$(VERSION)
	docker push gcr.io/$(PROJECT_ID)/$(APPNAME)

docker-compose:
	echo Riccardo were doing this to test MySQL DB connectivity in dev.
	docker-compose up

####################################################################
# OLD IMAGES - they work by pure luck
# they DO work but i want to forget them :)

#docker-run-v1:
# #	docker run -it -p 8080:3000 --name=septober-v1-p8080 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
# docker-run-daemon-v1:
# 	docker run -p 3000:3000 -d palladius/septober:v1 /bin/sh -c "cd /home/riccardo/git/septober && make run"
# docker-run-v1:
# 	docker run -it -p 8080:3000 --name=septober-v1-p8080 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
# docker-run-v1.1:
# 	docker run -p 80:8080 --name=septober-v11-p8080 palladius/septober:v1.1 /bin/sh -c "cd /home/riccardo/git/septober && make run-prod"
# docker-run-v1.2:
# 	docker run -p 80:8080 --name=septober-v12-p8080 palladius/septober:v1.2
# ####################################################################


build-local:
	docker build -t=$(APPNAME):v$(VERSION) .
run-local: build-local
	@echo Riccardo check it has the LATEST version!
	docker run -it -p 8080:8080 septober-ng:v$(VERSION) ./entrypoint-8080.sh 
run-local-bash-nobuild: # build-local
	@echo Riccardo check it has the LATEST version!
	docker run -it -p 8080:8080 septober-ng:v$(VERSION) bash
# FUNGE!!!
docker-run-mountvolume: build-local
	docker run -it -p 8080:8080 -v $(PWD):/var/www-public/septober/ $(APPNAME):v$(VERSION) bash

debug-local: build-local
	@echo Riccardo check it has the LATEST version!
	docker run -it -p 8080:3000 septober-ng:local bash

test-dbs:
	@echo "1. Testing local sqlite3 (just library)"
	echo User.all  | rails console
	@echo "2. Testing remote mysql2 (library and connection)"
	echo User.all  | RAILS_ENV=production rails console

run-riccardo-pvt-image:
	docker run -it -p 8080:8080 gcr.io/ric-cccwiki/septober-mysql bash

installa-locale:
	bundle install --path vendor/bundle
heroku-push:
	heroku container:push web -a septober
	heroku container:release web  -a septober
minikube-start:
	minikube start
	minikube dashboard
minikubami:
	echo Checking that minikube is running...
	ps aux |grep minikube
	kubectl create deployment septober-prova --image=septober-ng:v2.3.14
	kubectl expose deployment septober-prova --type=LoadBalancer --port=9191
	minikube service septober-prova


# Skaffold stuff

build-skaffold-gcb:
	@echo Building with skaffold build and profile GoogleCloudBuild. If it doesn work consider using: make gcloud-ricc-configure:
	skaffold build -p gcb

build-skaffold-local:
	@echo Building with skaffold build and profile GoogleCloudBuild
	skaffold build -p local

# normal
gcloud-ricc-configure:
	# this is Riccardo only
	gcloud-activate-palladius 
	#gcloud config configurations activate cccwiki
	gcloud auth application-default login

skaffold-dev:
	skaffold dev 

skaffold-dev-from-docker-compose:
	echo This is a very interesting skaffold config I built out of docker-compose. Should byuld MariaDB and Septober and manage together with kubectl. Lets try it out.
	skaffold dev -f skaffold-from-dockercompose.yaml 