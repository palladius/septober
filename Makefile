
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
	RAILS_ENV=production rails server

# only if you know what youre doing...
plugins-update:
	rails g on_the_spot:install

##########################################################
# Docker inspiration: https://github.com/kstaken/dockerfile-examples

# cd /home/riccardo/git/septober/ && make run
docker-build:
	docker build -t=septober-ng .

# I doubt this work ;-)
docker-run:
	docker build -t riccseptober .
	docker run --name riccardo-septober -d riccseptober

docker-run:
	docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
docker-run-daemon:
	docker run -p 3000:3000 -d palladius/septober:v1 /bin/sh -c "cd /home/riccardo/git/septober && make run"
docker-run-v1:
	docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'
docker-run-v1.1:
	docker run -p 80:3001 --name=septober-v11-p3001 palladius/septober:v1.1 /bin/sh -c "cd /home/riccardo/git/septober && make run-prod"
docker-run-v1.2:
	docker run -p 80:3002 --name=septober-v12-p3002 palladius/septober:v1.2 

docker-troubleshoot-v1.2:
	docker run -it -p 3005:3000 palladius/septober:v1.2 bash


build-local:
	docker build -t=septober-ng:local .

run-local: build-local
	docker run -it -p 3001:3000 septober-ng:local bash
