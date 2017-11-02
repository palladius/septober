
install:
	sudo apt-get install sqlite libsqlite3-dev
	touch install

configure: install
	bundle install
	rake db:migrate
	rake db:seed
	touch configure

# I doubt this work ;-)
docker-run:
	sudo docker build -t riccseptober .
	sudo docker run --name riccardo-septober -d riccseptober

docker-run-v1:
	sudo docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'

run: configure
	rake db:migrate
	rails server

# only if you know what youre doing...
plugins-update:
	rails g on_the_spot:install
