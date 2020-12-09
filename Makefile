VERSION=$(shell cat VERSION)

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
docker-build-latest:
	docker build -t=septober-ng:latest .

# I doubt this work ;-)
docker-run-latest-bash: docker-build-latest
	docker run -it -p 8080:3000 septober-ng:latest bash

docker-build:
	docker build -t=septober-ng:v$(VERSION) .

docker-push: # docker-build
	docker tag septober-ng:v$(VERSION) gcr.io/7eptober/septober-ng:v$(VERSION)
	docker push gcr.io/7eptober/septober-ng:v$(VERSION)



docker-run-v1:
	docker run -it -p 8080:3000 --name=septober-v1-p8080 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
docker-run-daemon-v1:
	docker run -p 3000:3000 -d palladius/septober:v1 /bin/sh -c "cd /home/riccardo/git/septober && make run"
docker-run-v1:
	docker run -it -p 8080:3000 --name=septober-v1-p8080 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
docker-run-v1.1:
	docker run -p 80:8080 --name=septober-v11-p8080 palladius/septober:v1.1 /bin/sh -c "cd /home/riccardo/git/septober && make run-prod"
docker-run-v1.2:
	docker run -p 80:8080 --name=septober-v12-p8080 palladius/septober:v1.2
###############################################################
#docker-troubleshoot-v1.2:
#	docker run -it -p 3005:3000 palladius/septober:v1.2 bash


build-local:
	docker build -t=septober-ng:local .
run-local: build-local
	@echo Riccardo check it has the LATEST version!
	docker run -it -p 8080:3000 septober-ng:local bash -c "rails server"

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
